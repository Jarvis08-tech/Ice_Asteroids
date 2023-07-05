//
//  GameMenu.swift
//  X.000.000.001
//
//  Created by Develop on 18.12.20.
//

import SpriteKit
import GameplayKit

class GameMenu: SKScene {
    
    
    //Hintergrund Daten
    private let w: CGFloat = 512
    private var h: CGFloat = 0
    
    //Labels für den Text
    private let lastScoreLabel = SKLabelNode(fontNamed: "Helvetica")
    private let highScoreLabel = SKLabelNode(fontNamed: "Helvetica")
    private let gameName = SKLabelNode(fontNamed: "Helvetica-Bold")
    private let gameOverLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
    private let tapToStartLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
    
    //Einblenden für den Text
    private let fadeInAction = SKAction.fadeIn(withDuration: 0.3)
    private let fadeOutAction = SKAction.fadeOut(withDuration: 0.3)
    
    //Um Objekte zu löschen
    private let delete = SKAction .removeFromParent()
    
    //Objekte Initialisieren
    private let rocket = SKSpriteNode(imageNamed: "Rocket")
    private let spaceStation = SKSpriteNode(imageNamed: "Space Stacion")
    private let informationBoard = SKSpriteNode(imageNamed: "Information Board")
    private let okButton = SKSpriteNode(imageNamed: "OK Button")
    private let informationButton = SKSpriteNode(imageNamed: "Information Button")
    
    //Ob inforamtion board ein oder aus ist
    private var boardStatus = false
    
    //Ob scene game over anzeigen soll
    private var gameOverBefore = false
    
    
    override func didMove(to view: SKView) {
        
        //Game over oder nicht
        if curentGameState == gameState.afterGame {
            gameOverBefore = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                if curentGameState == gameState.afterGame {
                    curentGameState = gameState.preGame
                }
            }
        }
        
        //Hintergrundbild einrichten
        h = w / view.bounds.width * view.bounds.height
        self.size = CGSize(width: w, height: h)
        let backg = SKSpriteNode(imageNamed: "Background")
        backg.position = CGPoint(x: w / 2, y: h / 2)
        backg.zPosition = 0
        self.addChild(backg)
        
        //Game Titel Text
        gameName.text = "Ice Asteroids"
        gameName.fontSize = 70
        gameName.fontColor = .white
        gameName.zPosition = 10
        gameName.alpha = 0
        gameName.position = CGPoint(x: self.size.width/2, y: self.size.height*0.85)
        self.addChild(gameName)
        if curentGameState == gameState.preGame {
            gameName.run(fadeInAction)
        }
        
        //Game Over Text
        if curentGameState == gameState.afterGame {
            gameOverLabel.text = "Game Over"
            gameOverLabel.fontSize = 70
            gameOverLabel.fontColor = .white
            gameOverLabel.zPosition = 10
            gameOverLabel.alpha = 0
            gameOverLabel.position = CGPoint(x: self.size.width/2, y: self.size.height*0.85)
            self.addChild(gameOverLabel)
            gameOverLabel.run(fadeInAction)
        }
        
        //Gemachter Score anzeigen
        if curentGameState == gameState.afterGame {
            lastScoreLabel.text = "Score \(actualScore)"
            lastScoreLabel.fontSize = 40
            lastScoreLabel.fontColor = .white
            lastScoreLabel.zPosition = 10
            lastScoreLabel.alpha = 0
            lastScoreLabel.position = CGPoint(x: self.size.width/2, y: self.size.height*0.77)
            self.addChild(lastScoreLabel)
            lastScoreLabel.run(fadeInAction)
        }
        
        //Highscore auswerten
        let defaults = UserDefaults()
        var highscoreNumber = defaults.integer(forKey: "highScoreSaved")
        //Hight score auswerten
        if curentGameState == gameState.afterGame {
            if actualScore > highscoreNumber {
                highscoreNumber = actualScore
                defaults.set(highscoreNumber, forKey: "highScoreSaved")
            }
        }
        
        //High Score anzeigen
        highScoreLabel.text = "Highscore \(highscoreNumber)"
        highScoreLabel.fontSize = 40
        highScoreLabel.fontColor = .white
        highScoreLabel.zPosition = 10
        highScoreLabel.alpha = 0
        highScoreLabel.position = CGPoint(x: self.size.width/2, y: self.size.height*0.7)
        self.addChild(highScoreLabel)
        highScoreLabel.run(fadeInAction)
        
        //Start Knopf
        tapToStartLabel.text = "Tap To Start"
        tapToStartLabel.fontSize = 50
        tapToStartLabel.fontColor = .white
        tapToStartLabel.zPosition = 10
        tapToStartLabel.alpha = 0
        tapToStartLabel.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        self.addChild(tapToStartLabel)
        tapToStartLabel.run(fadeInAction)
        
        //Rakete machen
        rocket.setScale(0.1)
        rocket.position = CGPoint(x: self.size.width/2, y: 272)
        rocket.zPosition = 1
        self.addChild(rocket)
        
        //Space Station Anzeigen
        spaceStation.setScale(0.4)
        spaceStation.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        spaceStation.position = CGPoint(x: self.size.width/2, y: self.size.height*0)
        spaceStation.zPosition = 3
        self.addChild(spaceStation)
        
        //Informaton Button
        informationButton.setScale(0.07)
        informationButton.position = CGPoint(x: self.size.width/2, y: 50)
        informationButton.zPosition = 10
        informationButton.name = "informationButton"
        self.addChild(informationButton)
        
        //Information Board
        informationBoard.setScale(0.32)
        informationBoard.anchorPoint = CGPoint(x: 0.5, y: 0)
        informationBoard.position = CGPoint(x: self.size.width/2, y: 200)
        informationBoard.zPosition = 30
        
        //OkButton
        okButton.setScale(0.2)
        okButton.position = CGPoint(x: self.size.width/2, y: 260)
        okButton.zPosition = 31
        okButton.name = "OKButton"
        
        //Änderungen wenn das Gerät ein iPad ist
        if UIDevice.current.userInterfaceIdiom == .pad {
            informationBoard.setScale(0.28)
            okButton.setScale(0.18)
            informationBoard.position = CGPoint(x: self.size.width/2, y: 105)
            okButton.position = CGPoint(x: self.size.width/2, y: 165)
         }
        
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        
        //Wenn wieder der game Titel und nicht mehr Game Over gezeigt werden soll
        if curentGameState == gameState.preGame && gameOverBefore == true {
            gameOverBefore = false
            //Sachen ausblenden oder einblenden
            let textOutSequence = SKAction.sequence([fadeOutAction, delete])
            let waitText = SKAction.wait(forDuration: 1)
            let textInSequence = SKAction.sequence([waitText,fadeInAction])
            gameOverLabel.run(textOutSequence)
            lastScoreLabel.run(textOutSequence)
            gameName.run(textInSequence)
        }
        
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch: AnyObject in touches {
            //Berührungspunkte suchen
            let pointOfTouch = touch.location(in: self)
            let nodeITapped = atPoint(pointOfTouch)
            //Scene umstellen
            if boardStatus == false {
                //Wenn auf info Knopf gedrückt wurde
                if nodeITapped.name == "informationButton" {
                    moveInformationBoard()
                } else {
                    //Wenn oberhalb von info Knopf gedrückt wurde spiel starten
                    if pointOfTouch.y > self.size.height*0.2 {
                        startAnimation()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
                            self.startGame()
                        }
                    }
                }
            } else {
                //Board wieder schliessen
                if nodeITapped.name == "OKButton" || nodeITapped.name == "informationButton" {
                    moveInformationBoard()
                }
            }
        }
        
    }
    
    
    private func startAnimation() {
        
        //Score wieder auf null setzten
        actualScore = 0
        
        //Label entfernen
        tapToStartLabel.run(delete)
        highScoreLabel.run(delete)
        informationButton.run(delete)
        if curentGameState == gameState.afterGame {
            gameOverBefore = false
            gameOverLabel.run(delete)
            lastScoreLabel.run(delete)
        } else {
            gameName.run(delete)
        }
        
        //Rakete und danach space Station Bewegen
        //Einstellung für iPad oder iPhone
        if UIDevice.current.userInterfaceIdiom == .pad {
            let moveRocketPoint = CGPoint(x: self.size.width/2, y: self.size.height*0.15)
            let moveRocket = SKAction.move(to: moveRocketPoint, duration: 0.4)
            let moveStationPoint = CGPoint(x: self.size.width/2, y: self.size.height*(-0.5))
            let moveStation = SKAction.move(to: moveStationPoint, duration: 0.7)
            let wait = SKAction.wait(forDuration: 0.7)
            let actionSequeceRocket = SKAction.sequence([wait, moveRocket])
            let actionSequeceStation = SKAction.sequence([moveStation])
            rocket.run(actionSequeceRocket)
            spaceStation.run(actionSequeceStation)
        } else {
            let moveRocketPoint = CGPoint(x: self.size.width/2, y: self.size.height*0.35)
            let moveRocket = SKAction.move(to: moveRocketPoint, duration: 0.3)
            let moveStationPoint = CGPoint(x: self.size.width/2, y: self.size.height*(-0.4))
            let moveStation = SKAction.move(to: moveStationPoint, duration: 0.6)
            let wait = SKAction.wait(forDuration: 0.3)
            let actionSequeceRocket = SKAction.sequence([moveRocket])
            let actionSequeceStation = SKAction.sequence([wait, moveStation])
            rocket.run(actionSequeceRocket)
            spaceStation.run(actionSequeceStation)
        }
        
    }
    
    
    private func moveInformationBoard() {
        
        //Wenn Board noch nicht angezeigt ist anzeigen, sonst schliessen
        if boardStatus == false {
            boardStatus = true
            //Information Board und OK Button hinzufügen
            self.addChild(informationBoard)
            self.addChild(okButton)
        } else {
            boardStatus = false
            //Information Board und OK Button ausblenden lassen
            informationBoard.run(delete)
            okButton.run(delete)
        }
        
    }
    
    
    private func startGame() {
        
        //Sachen löschen
        rocket.run(delete)
        spaceStation.run(delete)
        //Status ändern
        curentGameState = gameState.inGame
        //Scene umstellen
        let sceneToMoveTo = GameScene(size: self.size)
        sceneToMoveTo.scaleMode = self.scaleMode
        let myTransition = SKTransition.fade(withDuration: 0)
        self.view?.presentScene(sceneToMoveTo, transition: myTransition)
        
    }

    
}
