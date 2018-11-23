//
//  GameScene.swift
//  SpriteKit_HelloWorld
//
//  Created by William-Weng on 2018/11/21.
//  Copyright © 2018年 William-Weng. All rights reserved.
//

import UIKit
import SpriteKit

class GameScene: SKScene {

    let label = SKLabelNode()
    
    override func didMove(to view: SKView) {
        
        label.text = "QOO"
        label.position = CGPoint(x: view.frame.width / 2, y: view.frame.height / 2)
        
        view.backgroundColor = .green
        
        addChild(label)
    }
}
