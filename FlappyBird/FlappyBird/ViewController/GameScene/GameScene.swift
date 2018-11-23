//
//  GameScene.swift
//  FlappyBird
//
//  Created by William-Weng on 2018/11/22.
//  Copyright © 2018年 William-Weng. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    private let moveNodeNames = [
        GameConstant.NodeName.background.rawValue,
        GameConstant.NodeName.floor.rawValue,
    ]
    
    private var player: PlayerNode?
    private var background: SKSpriteNode?
    private var floor: SKSpriteNode?
    private var mainCamera: SKCameraNode?
    
    override func didMove(to view: SKView) {
        initChildNode()
        playerAnimation()
    }
    
    override func update(_ currentTime: TimeInterval) {
        movePlayer()
        moveCamera()
        moveAllSprites(camera: mainCamera, nodeNames: moveNodeNames)
    }
}

// MARK: - 小工具
extension GameScene {
    
    /// 初始化場景物件
    private func initChildNode() {
        
        player = childNode(withName: GameConstant.NodeName.player.rawValue) as? PlayerNode
        background = childNode(withName: GameConstant.NodeName.background.rawValue) as? SKSpriteNode
        floor = childNode(withName: GameConstant.NodeName.floor.rawValue) as? SKSpriteNode
        
        mainCamera = childNode(withName: GameConstant.NodeName.mainCamera.rawValue) as? SKCameraNode
    }
    
    /// 移動攝影機
    private func moveCamera() {
        mainCamera?.position.x += GameConstant.CameraMoveX
    }
    
    /// 移動主角
    private func movePlayer() {
        player?.position.x += GameConstant.CameraMoveX
    }
    
    /// 移動全部場景
    private func moveAllSprites(camera: SKCameraNode?, nodeNames: [String]) {
        for nodeName in moveNodeNames { moveSpriteNode(camera: camera, with: nodeName) }
    }
    
    /// 主角的動畫顯示
    private func playerAnimation() {
        player?.flapping()
        player?.wobbing()
        playerTrailEmitter()
    }
}

// MARK: - 小工具2
extension GameScene {
    
    /// 移動場景
    private func moveSpriteNode(camera: SKCameraNode?, with nodeName: String) {
        
        guard let camera = camera else { return }
        
        enumerateChildNodes(withName: nodeName) { (node, _ ) in
            if node.position.x + self.size.width < camera.position.x {
                node.position.x += self.size.width * GameConstant.SceneNunbers
            }
        }
    }
    
    /// 主角尾巴的物件效果
    private func playerTrailEmitter() {
        
        guard let emitter = SKEmitterNode(fileNamed: GameConstant.EmitterName.trail.rawValue),
              let trailNode = Optional.some(SKNode())
        else {
            return
        }
        
        emitter.targetNode = trailNode
        trailNode.zPosition = 1
        
        addChild(trailNode)
        player?.addChild(emitter)
    }
}
