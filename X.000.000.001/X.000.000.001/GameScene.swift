//
//  GameScene.swift
//  X.000.000.001
//
//  Created by Develop on 18.12.20.
//

import SpriteKit
import GameplayKit
import Foundation

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    
    //Hintergrund
    private let w: CGFloat = 512
    private var h: CGFloat = 0
    
    //Technische sachen
    private var timeLastAsreroid = Date()
    private var sparnSpeed : Double = 1.5
    private var fuel : Double = 100
    private var breakOrNot = false
    private var actualScoreCount = Date()
    private var chanceIceAsteroid = 15
    
    //Ist um das Spielfeld fest zu legen
    private var gameArea: CGRect
    override init(size: CGSize) {
        //Rechteck
        let maxAspectRatio: CGFloat = 16.0/9.0
        let playableWith = size.height / maxAspectRatio
        let margin = (size.width - playableWith) / 2
        gameArea = CGRect(x: margin, y: 0, width: playableWith, height: size.height)
        super.init(size: size)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //Text initialisieren
    private let actualScoreShow = SKLabelNode(fontNamed: "Helvetica-Bold")
    private let fuelShow = SKLabelNode(fontNamed: "Helvetica-Bold")
    
    //Fade in für den Text
    private let fadeInAction = SKAction.fadeIn(withDuration: 0.3)
    
    //Um Objekte zu löschen
    private let delete = SKAction .removeFromParent()
    
    //Rakete initialisiren
    private let rocket = SKSpriteNode(imageNamed: "Rocket")
    
    //Pause knopf und play button initialisieren
    private let breakButton = SKSpriteNode(imageNamed: "Break Button")
    private let playButton = SKSpriteNode(imageNamed: "Play Button")
    
    
    override func didMove(to view: SKView) {
        
        //Zufalszahlen Initialisieren
        initRnd()
        
        //Hintergrundbild einrichten
        h = w / view.bounds.width * view.bounds.height
        self.size = CGSize(width: w, height: h)
        let backg = SKSpriteNode(imageNamed: "Background")
        backg.position = CGPoint(x: w / 2, y: h / 2)
        backg.zPosition = 0
        self.addChild(backg)
        
        // Kollisionserkennung einrichten
        self.physicsWorld.contactDelegate = self
        self.physicsWorld.gravity = CGVector.zero
 
        //Rakete machen
        rocket.setScale(0.1)
        //Andere Position bei iPad und iPhone
        if UIDevice.current.userInterfaceIdiom == .pad {
            rocket.position = CGPoint(x: self.size.width/2, y: self.size.height*0.15)
        } else {
            rocket.position = CGPoint(x: self.size.width/2, y: self.size.height*0.35)
        }
        rocket.zPosition = 2
        rocket.physicsBody = SKPhysicsBody(texture: rocket.texture!, size: rocket.size)
        //rocket.physicsBody = SKPhysicsBody(rectangleOf: rocket.size)
        rocket.name = "rocket"
        self.addChild(rocket)
        
        //Break Button
        breakButton.setScale(0.07)
        breakButton.anchorPoint = CGPoint(x: 1, y: 0.5)
        breakButton.position = CGPoint(x: self.size.width*0.95, y: self.size.height*0.92)
        breakButton.zPosition = 10
        breakButton.alpha = 0
        breakButton.name = "Break Buton"
        self.addChild(breakButton)
        breakButton.run(fadeInAction)
        
        //actualScore Anzeige
        actualScoreShow.text = "Score"
        actualScoreShow.fontSize = 40
        actualScoreShow.fontColor = .white
        actualScoreShow.zPosition = 10
        actualScoreShow.alpha = 0
        actualScoreShow.horizontalAlignmentMode = .left
        actualScoreShow.position = CGPoint(x: self.size.width*0.05, y: self.size.height*0.92)
        self.addChild(actualScoreShow)
        actualScoreShow.run(fadeInAction)
        
        //Fuel Anzeige
        fuelShow.text = "Fuel"
        fuelShow.fontSize = 40
        fuelShow.fontColor = .white
        fuelShow.zPosition = 10
        fuelShow.alpha = 0
        fuelShow.horizontalAlignmentMode = .left
        fuelShow.position = CGPoint(x: self.size.width*0.05, y: self.size.height*0.85)
        self.addChild(fuelShow)
        fuelShow.run(fadeInAction)
        
        //Play Button
        playButton.setScale(0.2)
        playButton.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        playButton.zPosition = 20
        playButton.name = "Play Button"
        
    }
    
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch: AnyObject in touches {
            //Bewege Rakete wenn bedingungen erfüllt
            if curentGameState == gameState.inGame && fuel > 0 && breakOrNot == false {
                //Punkte initialisiseren
                let pointOfTouch = touch.location(in: self)
                let previousPointOfTouch = touch.previousLocation(in: self)
                let amountDragged = pointOfTouch.x - previousPointOfTouch.x
                //Treibstoff verlieren beim Steuern
                if amountDragged > 0 {
                    fuel -= Double(amountDragged*0.04)
                    if fuel < 0 { fuel = 0 }
                } else {
                    fuel += Double(amountDragged*0.04)
                    if fuel < 0 { fuel = 0 }
                }
                //Rakete bewegen
                rocket.position.x += amountDragged
                //Das Rakete anhaltet und nicht unendlich nach links geht
                if rocket.position.x > gameArea.maxX - rocket.size.width {
                    rocket.position.x = gameArea.maxX - rocket.size.width
                }
                if rocket.position.x < gameArea.minX + rocket.size.width {
                    rocket.position.x = gameArea.minX + rocket.size.width
                }
            }
        }
        
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch: AnyObject in touches {
            //Berührungspunkte suchen
            let pointOfTouch = touch.location(in: self)
            let nodeITapped = atPoint(pointOfTouch)
            //Wenn Pause knopf gedrückt wurde
            if pointOfTouch.y > self.size.height*0.85 && pointOfTouch.x > self.size.width*0.8 && breakOrNot == false {
                breakStart()
            }
            if nodeITapped.name == "Play Button" {
                breakEnd()
            }
        }
        
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        
        //Das Rakete nicht runter rutscht (Geräteabhängig)
        if UIDevice.current.userInterfaceIdiom == .pad {
            rocket.position.y = self.size.height*0.15
        } else {
            rocket.position.y = self.size.height*0.35
        }
        
        //Regelmässig Planeten starten
        if curentGameState == gameState.inGame && Date() >
            timeLastAsreroid.addingTimeInterval(0.8) && breakOrNot == false {
            //Asteroid oder Ice Asteroid
            witchAsteroid()
            //Zeit zurüksetzen
            timeLastAsreroid = Date()
        }
        
        //Geschiwindikeit vom Raumschiff erhöhen und Score schreiben
        if curentGameState == gameState.inGame && Date() >
            actualScoreCount.addingTimeInterval(sparnSpeed/4) && breakOrNot == false {
            //Treibstoff verbrauchen
            if fuel > 0 {
                fuel -= 0.3
                if fuel < 0 { fuel = 0 }
            }
            //Score erhöhen
            actualScore += 1
            //Speed erhöhen von Raumschiff (nur wenn genug fuel sonst gleichmässig)
            if fuel > 0 {
                if sparnSpeed > 0.8 { sparnSpeed -= 0.001 }
            }
            //Zeit zurüksetzen
            actualScoreCount = Date()
        }
            
        //Game over
        if curentGameState == gameState.afterGame {
            gameOver()
        }
        
        //Score im Text anpassen
        actualScoreShow.text = "Score \(actualScore)"
        fuelShow.text = "Fuel \(Int(fuel))%"
        
    }
    
    
    private func witchAsteroid() {
        
        //Ranom Zahl wenn 1 ice sonst normaler
        let randomNumber = randomInt(min: 1, max: chanceIceAsteroid)
        switch randomNumber {
        case 1:
            iceAsteroids()
            chanceIceAsteroid += 1
        default:
            asteroids()
        }
        
    }
    

    private func asteroids() {
        
        //Nimm einen Punkt zwischen links und rehchts
        let randomXStart = randomFloat(min: CGFloat(gameArea.minX + rocket.size.width), max: CGFloat(gameArea.maxX - rocket.size.width))
        
        //gebe einen Start und einen Endpunkt
        let startPoint = CGPoint(x: randomXStart, y: self.size.height * 1.2)
        let endPoint = CGPoint(x: randomXStart, y: -self.size.height * 0.2)
        
        //Asteroiden initialisieren
        let asteroid = SKSpriteNode(imageNamed: "Asteroid")
        asteroid.position = startPoint
        asteroid.zPosition = 2
        
        //Planeten bewegen
        let speedString = String(format: "%.1f", sparnSpeed)
        let speed = Double(speedString)!
        let moveAsteroid = SKAction.move(to: endPoint, duration: speed)
        let asteroidSequence = SKAction.sequence([moveAsteroid, delete])
        asteroid.run(asteroidSequence)
        
        // neuer Planet mit zufälliger Farbe
        asteroid.color = bColors[iRnd(bColors.count) ]
        asteroid.colorBlendFactor = 0.5 + 0.25 * cRnd()
        
        // Größe
        let bWidth = 60 + cRnd() * 40
        let bHeight = bWidth * (1.1 + 0.2 * cRnd())
        asteroid.size = CGSize(width: bWidth, height: bHeight)
        
        //Körper für kontakte
        asteroid.physicsBody = SKPhysicsBody(rectangleOf: asteroid.size)
        //asteroid.physicsBody = SKPhysicsBody(texture: asteroid.texture!, size: asteroid.size)
        asteroid.physicsBody?.categoryBitMask = Category.asteroid
        asteroid.physicsBody?.contactTestBitMask = Category.rocket
        asteroid.physicsBody?.collisionBitMask = Category.none
        asteroid.name = "asteroid"
        
        //Asteroid hinzufügen
        self.addChild(asteroid)
        
    }
    

    private func iceAsteroids() {
        
        //Nimm einen Punkt zwischen links und rehchts
        let randomXStart = randomFloat(min: CGFloat(gameArea.minX + rocket.size.width), max: CGFloat(gameArea.maxX - rocket.size.width))
        
        //gebe einen Start und einen Endpunkt
        let startPoint = CGPoint(x: randomXStart, y: self.size.height * 1.2)
        let endPoint = CGPoint(x: randomXStart, y: -self.size.height * 0.2)
        
        //Asteroiden initialisieren
        let iceAsteroid = SKSpriteNode(imageNamed: "Ice Asteroid")
        iceAsteroid.position = startPoint
        iceAsteroid.zPosition = 2
        
        //Planeten bewegen
        let speedString = String(format: "%.1f", sparnSpeed)
        let speed = Double(speedString)!
        let moveIceAsteroid = SKAction.move(to: endPoint, duration: speed)
        let iceAsteroidSequence = SKAction.sequence([moveIceAsteroid, delete])
        iceAsteroid.run(iceAsteroidSequence)
        
        // Größe
        let bWidth = 20 + cRnd() * 20
        let bHeight = bWidth * (1.1 + 0.2 * cRnd())
        iceAsteroid.size = CGSize(width: bWidth, height: bHeight)
        
        //Körper
        iceAsteroid.physicsBody = SKPhysicsBody(rectangleOf: iceAsteroid.size)
        //iceAsteroid.physicsBody = SKPhysicsBody(texture: iceAsteroid.texture!, size: iceAsteroid.size)
        iceAsteroid.physicsBody?.categoryBitMask = Category.iceAsteroid
        iceAsteroid.physicsBody?.contactTestBitMask = Category.rocket
        iceAsteroid.physicsBody?.collisionBitMask = Category.none
        iceAsteroid.name = "iceAsteroid"
        
        //Asteroid hinzufügen
        self.addChild(iceAsteroid)
        
    }
    
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        //Wenn Rakete Ice Asteroid trifft
        if let asteroidContact = getSpriteFrom(contact, category: Category.iceAsteroid) {
            asteroidContact.physicsBody?.contactTestBitMask = Category.none
            let del = SKAction .removeFromParent()
            asteroidContact.run(del)
            //Rakte wieder gerade machen/derehen
            let rotateSpaceship = SKAction.rotate(toAngle: 0, duration: 0.1)
            rocket.run(rotateSpaceship)
            //Treibstoff aufladen
            fuel = 100
        }
        
        //Wenn Rakete Asteroid trifft
        if let asteroidContact = getSpriteFrom(contact, category: Category.asteroid) {
            curentGameState = gameState.afterGame
            let del = SKAction .removeFromParent()
            asteroidContact.run(del)
        }
        
    }
    
    
    private func gameOver() {
        print(chanceIceAsteroid)
        //Rackete löschen und alle aktionen beenden
        self.removeAllActions()
        rocket.removeAllActions()
        rocket.run(delete)
        //Scene wechseln
        let sceneToMoveTo = GameMenu()
        sceneToMoveTo.scaleMode = self.scaleMode
        let myTransition = SKTransition.fade(withDuration: 0.7)
        self.view?.presentScene(sceneToMoveTo, transition: myTransition)
        
    }
    
    
    private func breakStart() {
        
        breakOrNot = true
        //Pausenknopf löschen und Play knopf hinzufügen
        breakButton.run(delete)
        self.addChild(playButton)
        //Nach einer kleinen Ziet alle Actionen beenden
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) {
            self.scene?.view?.isPaused = true
        }
        
    }
    
    
    private func breakEnd() {
        
        breakOrNot = false
        //Pausenknopf hinzufügen und Play knopf löschen
        playButton.run(delete)
        addChild(breakButton)
        //Alles wieder bewegen
        self.scene?.view?.isPaused = false
        
    }
    
    
    
    // bodyA und bodyB auswerten, gibt SpriteNode der gewünschten Kategorie zurück
    private func getSpriteFrom(_ contact:SKPhysicsContact, category: UInt32) -> SKSpriteNode? {
        if contact.bodyA.categoryBitMask == category {
            return contact.bodyA.node as? SKSpriteNode
        } else if contact.bodyB.categoryBitMask == category {
            return contact.bodyB.node as? SKSpriteNode
        } else {
            return nil
        }
    }
    //Random Zahl zwischen min und Max wert
    private func randomFloat(min: CGFloat, max: CGFloat) -> CGFloat {
        return CGFloat(arc4random_uniform(UInt32(max - min + 1))) + min
    }
    private func randomInt(min: Int, max: Int) -> Int {
        return Int(arc4random_uniform(UInt32(max - min + 1))) + min
    }
    // Zufallszahlen für diverse Zahlentypen
    private func cRnd() -> CGFloat {
        return CGFloat(drand48())
    }
    private func dRnd() -> Double {
        return Double(drand48())
    }
    private func iRnd(_ n: Int) -> Int {
        return Int(arc4random_uniform(UInt32(n)))
    }
    private func initRnd() {
        // drand48 initialisieren
        srand48(Int(arc4random_uniform(100000000)))
    }
    // Farben der Planeten
    private let bColors:[SKColor] = [.black, .darkGray, .gray, .lightGray ]
    // Objekt -Kategorien für die Kolisionserkennung
    struct Category {
        static let none:UInt32 = 0
        static let asteroid:UInt32 = 1
        static let rocket:UInt32 = 2
        static let iceAsteroid:UInt32 = 4
    }
}
