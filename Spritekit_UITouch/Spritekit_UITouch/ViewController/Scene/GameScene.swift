//
//  GameScene.swift
//  Spritekit_UITouch
//
//  Created by William-Weng on 2018/11/27.
//  Copyright © 2018年 William-Weng. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    private let velocityPerSecond: CGFloat = 10
    private let minErrorLength: CGFloat = 5
    
    private var player: SKSpriteNode?
    private var updateTime: (new: TimeInterval, old: TimeInterval) = (0, 0)
    private var deltaTime: TimeInterval = 0
    private var lastVelocity: CGPoint = .zero
    private var lastTouchLocation: CGPoint = .zero
    
    override func didMove(to view: SKView) {
        initChildNodes()
    }
    
    override func update(_ currentTime: TimeInterval) {
        updateFPS(currentTime)
        arrivedTouchPoint(player)
        movePlayer(player, velocity: lastVelocity)
        rotatePlayer(player, velocity: lastVelocity)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchAction(touches, with: event)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchAction(touches, with: event)
    }
}

// MARK: - 主工具
extension GameScene {
    
    /// 初始化物件
    private func initChildNodes() {
        player = childNode(withName: "zombie") as? SKSpriteNode
        player?.run(playerAnimtion(with: 0.1))
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
    
    /// 處理Touch的相關動作
    private func touchAction(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let touch = touches.first,
              let location = Optional.some(touch.location(in: self))
        else {
            return
        }
        
        lastTouchLocation = location
        velocitySetting(player, with: lastTouchLocation)
    }
}

// MARK: - 小工具
extension GameScene {
    
    /// 主角的動畫 (重複)
    private func playerAnimtion(with time: TimeInterval) -> SKAction {
        
        let action = SKAction.animate(with: playerAnimtionTextures(), timePerFrame: time)
        let fullAction = SKAction.sequence([action, action.reversed()])
        
        return SKAction.repeatForever(fullAction)
    }
    
    /// 主角的動畫圖片
    private func playerAnimtionTextures() -> [SKTexture] {
        
        var textures = [SKTexture]()
        
        for index in 1...4 {
            let imageName = "zombie\(index)"
            textures.append(SKTexture.init(imageNamed: imageName))
        }
        
        return textures
    }
    
    /// 決定移動的速度 (速率 + 方向)
    private func velocitySetting(_ player: SKSpriteNode?, with location: CGPoint) {
        
        guard let player = player,
              let distance = Optional.some(location - player.position),
              let direction = Optional.some(distance.normalized),
              let velocity = Optional.some(direction * velocityPerSecond)
        else {
            return
        }
        
        lastVelocity = velocity
    }
    
    /// 根據速度來移動主角
    private func movePlayer(_ player: SKSpriteNode?, velocity: CGPoint) {
        guard let player = player else { return }
        player.position = player.position + velocity
    }
    
    /// 將主角的方向轉至所點的方向
    private func rotatePlayer(_ player: SKSpriteNode?, velocity: CGPoint) {
        
        guard velocity != .zero,
              let player = player,
              let velocityRotation = Optional.some(velocity.angle)
        else {
            return
        }
        
        player.zRotation = velocityRotation
    }
    
    /// 到達所指定的點後停止動作 (兩者相差的距離 ~= 0)
    private func arrivedTouchPoint(_ player: SKSpriteNode?) {
        
        guard let player = player,
              let distance = Optional.some(lastTouchLocation - player.position),
              let length = Optional.some(distance.length)
        else {
            return
        }
        
        if (length <= minErrorLength) {
            player.position = lastTouchLocation
            lastVelocity = .zero
        }
    }
}




