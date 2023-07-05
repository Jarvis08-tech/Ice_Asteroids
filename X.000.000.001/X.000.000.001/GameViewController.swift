//
//  GameViewController.swift
//  X.000.000.001
//
//  Created by Develop on 18.12.20.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            //Game Scene anzeigen
            let scene = GameMenu()
            view.presentScene(scene)
            view.ignoresSiblingOrder = true
            view.showsFPS = false
            view.showsNodeCount = false
            view.showsPhysics = false

        }
    }
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
