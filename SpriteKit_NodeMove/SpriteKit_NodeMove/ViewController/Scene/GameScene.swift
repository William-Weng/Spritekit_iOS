//
//  GameScene.swift
//  SpriteKit_NodeMove
//
//  Created by William-Weng on 2018/11/29.
//  Copyright © 2018年 William-Weng. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    var football: SKSpriteNode? { return childNode(withName: "football") as? SKSpriteNode }
    
    override func didMove(to view: SKView) {
        worldSetting()
        footballSetting()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        playFootball(with: 1000, for: touch)
    }
}

extension GameScene {
    
    /// 物理世界的範圍
    private func worldSetting() {
        physicsBody = SKPhysicsBody(edgeLoopFrom: CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.size.width, height: frame.size.height))
    }
    
    /// 足球的物理體設定
    private func footballSetting() {
        if let football = football { football.physicsBody = SKPhysicsBody(circleOfRadius: football.size.width / 2.0) }
    }
    
    /// 拉動足球
    private func playFootball(with speed: Int, for touch: UITouch) {
        let direction = (touch.location(in: self).x > 0) ? 1 : -1
        football?.physicsBody?.applyForce(CGVector(dx: direction * speed * 8 , dy: 0))
    }
}
