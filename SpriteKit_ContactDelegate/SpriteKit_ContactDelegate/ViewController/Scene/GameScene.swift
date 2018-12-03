//
//  GameScene.swift
//  SpriteKit_ContactDelegate
//
//  Created by William-Weng on 2018/11/30.
//  Copyright © 2018年 William-Weng. All rights reserved.
//

import SpriteKit

struct Football {
    static let left: UInt32 = 0x01 << 1
    static let right: UInt32 = 0x01 << 2
    static let none: UInt32 = 0x01 << 3
}

class GameScene: SKScene {
    
    let imageName: (left: String, right: String) = ("football_1", "football_2")
    var football: (left: SKSpriteNode?, right: SKSpriteNode?) = (nil, nil)
    
    override func didMove(to view: SKView) {
        initDelegate()
        initChildNode()
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        let (bodyA, bodyB) = (contact.bodyA, contact.bodyB)
        
        if bodyA.categoryBitMask == Football.left && bodyB.categoryBitMask == Football.right {
            showAlert(message: "足球被撞到了")
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        playBall()
    }
}

extension GameScene: SKPhysicsContactDelegate {
    
    /// 設定碰撞的Delegate
    private func initDelegate() {
        physicsWorld.contactDelegate = self
        physicsBody = SKPhysicsBody(edgeLoopFrom: CGRect(origin: CGPoint(x: frame.origin.x, y: frame.origin.y + 125), size: frame.size))
    }
    
    /// 設定足球實體
    private func initChildNode() {
        
        football.left = childNode(withName: imageName.left) as? SKSpriteNode
        football.right = childNode(withName: imageName.right) as? SKSpriteNode
        
        football.left?.physicsBody = SKPhysicsBody(circleOfRadius: 100)
        football.right?.physicsBody = SKPhysicsBody(circleOfRadius: 100)
        
        /// 分類
        football.left?.physicsBody?.categoryBitMask = Football.left
        football.right?.physicsBody?.categoryBitMask = Football.right

        /// 誰可以撞我
        football.left?.physicsBody?.contactTestBitMask = Football.right
        football.right?.physicsBody?.contactTestBitMask = Football.left
        
        /// ?
        football.left?.physicsBody?.collisionBitMask = Football.none
        football.right?.physicsBody?.collisionBitMask = Football.none
    }
    
    /// 踢球
    private func playBall() {
        
        guard let football_1 = football.left,
              let football_2 = football.right
        else {
            return
        }
        
        let action = SKAction.move(to: football_2.position, duration: 2.0)
        football_1.run(action)
    }
    
    /// 顯示提示框
    private func showAlert(message: String) {
        
        let vc = view?.window?.rootViewController
        let alert = UIAlertController(title: "撞到了…", message: message, preferredStyle: .alert)
        let aciton = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(aciton)
        
        vc?.present(alert, animated: true, completion: nil)
    }
}
