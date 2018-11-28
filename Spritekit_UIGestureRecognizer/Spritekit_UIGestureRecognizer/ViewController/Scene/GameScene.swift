//
//  GameScene.swift
//  Spritekit_UIGestureRecognizer
//
//  Created by William-Weng on 2018/11/28.
//  Copyright © 2018年 William-Weng. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {

    let unitScale:CGFloat = 1.0
    
    var rabbit: SKSpriteNode?
    var lastScale: CGFloat = 1.0
    
    override func didMove(to view: SKView) {
        initChildNode()
        initGestureRecognizers()
    }
}

// MARK: - 主功能
extension GameScene {
    
    /// 點擊顯示 / 消失
    @objc func tapZoomOut(_ recognizer: UITapGestureRecognizer) {
        guard let rabbit = rabbit else { return }
        rabbit.isHidden.toggle()
    }
    
    /// 長按恢復背景大小
    @objc func longPressZoomIn(_ recognizer: UILongPressGestureRecognizer) {
        recognizer.view?.transform = .identity
    }
    
    /// 背景放大縮小
    @objc func pinchZoomInOut(_ recognizer: UIPinchGestureRecognizer) {
        
        guard let myView = recognizer.view,
              recognizer.state != .ended
        else {
            lastScale = unitScale; return
        }
        
        let newScale = unitScale - (lastScale - recognizer.scale)
        let transform = myView.transform

        myView.transform = transform.scaledBy(x: newScale, y: newScale)
        lastScale = recognizer.scale
    }
    
    /// 旋轉兔子
    @objc func rotationRabbit(_ recognizer: UIRotationGestureRecognizer) {
        
        guard let rabbit = rabbit else { return }
        rabbit.zRotation = recognizer.rotation
    }

    /// 拖動
    @objc func pan(_ recognizer: UIPanGestureRecognizer) {
        
        guard let view = view,
              let rabbit = rabbit
        else {
            return
        }

        let position = recognizer.location(in: view)
        
        rabbit.position = position
    }
    
    /// 滑動
    @objc func swipe(_ recognizer: UISwipeGestureRecognizer) {
        
        guard let rabbit = rabbit else { return }
        
        let direction = recognizer.direction
        
        var action = SKAction()
        
        switch direction {
        case .up:
            action = SKAction.move(to: CGPoint(x: 0, y: 300), duration: 0.5)
        case .down:
            action = SKAction.move(to: CGPoint(x: 0, y: -300), duration: 0.5)
        case .left:
            action = SKAction.move(to: CGPoint(x: -300, y: 0), duration: 0.5)
        case .right:
            action = SKAction.move(to: CGPoint(x: 300, y: 0), duration: 0.5)
        default:
            break
        }
        
        rabbit.run(action)
    }
}

// MARK: - 小工具
extension GameScene {
    
    /// 初始化物件
    private func initChildNode() {
        rabbit = childNode(withName: "rabbit") as? SKSpriteNode
    }
    
    /// 初始化各種手勢
    private func initGestureRecognizers() {

        let tap = UITapGestureRecognizer(target: self, action: #selector(tapZoomOut(_:)))
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPressZoomIn(_:)))
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(pinchZoomInOut(_:)))
        let rotation = UIRotationGestureRecognizer(target: self, action: #selector(rotationRabbit(_:)))
        let pan = UIPanGestureRecognizer(target: self, action: #selector(pan(_:)))
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(swipe(_:)))
        
        view?.addGestureRecognizer(tap)
        view?.addGestureRecognizer(longPress)
        view?.addGestureRecognizer(pinch)
        view?.addGestureRecognizer(rotation)
        view?.addGestureRecognizer(pan)
        view?.addGestureRecognizer(swipe)
    }
}

