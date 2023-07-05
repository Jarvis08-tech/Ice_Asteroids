//
//  DataClass.swift
//  X.000.000.001
//
//  Created by Develop on 18.12.20.
//

import SpriteKit
import GameplayKit

//Aktueller Score
var actualScore = 0

//Status ob im game oder nicht
enum gameState {
    case preGame
    case inGame
    case afterGame
}
var curentGameState = gameState.preGame
