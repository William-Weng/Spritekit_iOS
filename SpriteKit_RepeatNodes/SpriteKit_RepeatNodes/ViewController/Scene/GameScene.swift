//
//  GameScene.swift
//  SpriteKit_RepeatNodes
//
//  Created by William-Weng on 2018/11/29.
//  Copyright © 2018年 William-Weng. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    let randomIndex = GKShuffledDistribution(lowestValue: -200, highestValue: 200)
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        initSceneBounds()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        makeBalls(with: 100)
    }
}

// MARK: - 小工具
extension GameScene {
    
    /// 設定Scene的邊界
    private func initSceneBounds() {
        let bounds = CGRect(origin: frame.origin, size: frame.size)
        physicsBody = SKPhysicsBody(edgeLoopFrom: bounds)
    }
    
    /// 產生很多球
    private func makeBalls(with count: Int) {
        
        let action = SKAction.sequence([
                SKAction.run(makeBall),
                SKAction.wait(forDuration: 0.1)
            ])
        let repeatAction = SKAction.repeat(action, count: count)
        
        run(repeatAction)
    }
    
    /// 產生一個球
    private func makeBall() {
        
        let randomPosition = CGPoint(x: randomIndex.nextInt(), y: -Int(frame.origin.y) + randomIndex.nextInt())
        let ballNode = SKSpriteNode(imageNamed: "ball")
        let ballBody = SKPhysicsBody(circleOfRadius: ballNode.frame.width / 2.0)
        
        ballNode.physicsBody = ballBody
        ballNode.zPosition = 1
        ballNode.position = randomPosition
        
        addChild(ballNode)
    }
}
