//
//  GameScene.swift
//  SpriteKit_Move
//
//  Created by William-Weng on 2018/11/26.
//  Copyright © 2018年 William-Weng. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    private var football: SKSpriteNode?
    
    private var updateTime: (new: TimeInterval, old: TimeInterval) = (0, 0)
    private var deltaTime: TimeInterval = 0
    private var velocity: CGPoint = .zero
    
    override func didMove(to view: SKView) {
        initChildNode()
    }
    
    override func update(_ currentTime: TimeInterval) {
        updateFPS(currentTime)
        moveFootball(football, with: velocity)
        checkBounds(for: football)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let touch = touches.first,
              let location = Optional.some(touch.location(in: self)),
              let football = football
        else {
            return
        }
        
        velocity = footballVelocity(football, with: location)
    }
}

// MARK: - 小工具
extension GameScene {
    
    /// 初始化物件
    private func initChildNode() {
        football = childNode(withName: GameConstant.NodeName.football.rawValue) as? SKSpriteNode
    }
    
    /// 計算更新的時間差(60fps)
    private func updateFPS(_ currentTime: TimeInterval) {
        
        updateTime.new = currentTime
        
        if updateTime.old != 0 {
            deltaTime = updateTime.new - updateTime.old
        } else {
            deltaTime = 0
        }
        
        updateTime.old = currentTime
    }
    
    /// 跟據點擊的位置與足球的距離來決定初始的速度
    private func footballVelocity(_ football: SKSpriteNode?, with touchLocation: CGPoint) -> CGPoint {
        
        guard let football = football else { return .zero }
        
        let footballVelocity = CGPoint(x: touchLocation.x - football.position.x,  y: touchLocation.y - football.position.y)
        return footballVelocity
    }
    
    /// 根據速度移動足球
    private func moveFootball(_ football: SKSpriteNode?, with velocity: CGPoint) {
        
        guard let football = football else { return }
        
        let moveVelocity = CGPoint(x: velocity.x * CGFloat(deltaTime), y: velocity.y * CGFloat(deltaTime))
        football.position = CGPoint(x: football.position.x + moveVelocity.x, y: football.position.y + moveVelocity.y)
    }
    
    /// 足球碰到邊界的反彈設定
    private func checkBounds(for football: SKSpriteNode?) {

        guard let football = football,
              let skView = view,
              let maxBound = Optional.some((width: skView.frame.size.width, height: skView.frame.size.height))
        else {
            return
        }
        
        if (football.position.x <= -maxBound.width || football.position.x >= maxBound.width) {
            velocity.x = -velocity.x
        }
        
        if (football.position.y <= -maxBound.height || football.position.y >= maxBound.height) {
            velocity.y = -velocity.y
        }
    }
}


