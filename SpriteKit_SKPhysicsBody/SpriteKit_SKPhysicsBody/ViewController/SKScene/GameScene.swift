//
//  GameScene.swift
//  SpriteKit_SKPhysicsBody
//
//  Created by William-Weng on 2018/11/29.
//  Copyright © 2018年 William-Weng. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        labelWithPhysicsBody()
    }
}

extension GameScene {
    
    /// 標籤加上物理體 (要綁鐵塊才會往下掉)
    private func labelWithPhysicsBody() {
        
        let myLabel = SKLabelNode(text: "Hello")
        let labelBody = SKPhysicsBody(rectangleOf: myLabel.frame.size)
        
        myLabel.physicsBody = labelBody
        myLabel.fontColor = #colorLiteral(red: 1, green: 0.231372549, blue: 0.1882352941, alpha: 1)
        myLabel.fontSize = 128.0
        myLabel.fontName = "Chalkduster"

        addChild(myLabel)
    }
}

