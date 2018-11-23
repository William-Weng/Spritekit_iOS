//
//  GameScene.swift
//  SpriteKit_Camera
//
//  Created by William-Weng on 2018/11/21.
//  Copyright © 2018年 William-Weng. All rights reserved.
//

import UIKit
import SpriteKit

class GameScene: SKScene {

    private let moveNodeNames = [
        GameConstant.NodeName.background.rawValue,
        GameConstant.NodeName.ground.rawValue,
        GameConstant.NodeName.cloud.rawValue
    ]
    
    private var player: PlayerNode?
    private var ground: SKSpriteNode?
    private var background:  SKSpriteNode?
    private var cloud:SKSpriteNode?
    private var mainCamera: SKCameraNode?
    
    override func didMove(to view: SKView) {
        initChildNode()
        playerAnimation()
        trailEmitter()
    }
    
    override func update(_ currentTime: TimeInterval) {
        mainCamera?.position.x += GameConstant.CameraMoveX
        player?.position.x += GameConstant.CameraMoveX
        moveAllSprites(camera: mainCamera, nodeNames: moveNodeNames)
    }
}

// MARK: - 小工具
extension GameScene {
    
    /// 初始化物件
    private func initChildNode() {
        player = childNode(withName: GameConstant.NodeName.player.rawValue) as? PlayerNode
        cloud  = childNode(withName: GameConstant.NodeName.cloud.rawValue) as? SKSpriteNode
        ground = childNode(withName: GameConstant.NodeName.ground.rawValue) as? SKSpriteNode
        background = childNode(withName: GameConstant.NodeName.background.rawValue) as? SKSpriteNode
        mainCamera = childNode(withName: GameConstant.NodeName.mainCamera.rawValue) as? SKCameraNode
    }
    
    /// 主角的動畫顯示
    private func playerAnimation() {
        player?.flapping()
        player?.wobbing()
    }
    
    /// 主角尾巴的物件效果
    private func trailEmitter() {
        
        guard let emitter = SKEmitterNode(fileNamed: GameConstant.EmitterName.trail.rawValue),
              let trailNode = Optional.some(SKNode())
        else {
            return
        }
        
        trailNode.zPosition = 1
        emitter.targetNode = trailNode
        addChild(trailNode)
        player?.addChild(emitter)
    }
    
    /// 移動全部場景
    private func moveAllSprites(camera: SKCameraNode?, nodeNames: [String]) {
        for nodeName in moveNodeNames { moveSprite(camera: camera, with: nodeName) }
    }
    
    /// 移動場景
    private func moveSprite(camera: SKCameraNode?, with nodeName: String) {
        
        guard let camera = camera else { return }
        
        enumerateChildNodes(withName: nodeName) { (node, _ ) in
            if node.position.x + self.size.width < camera.position.x {
                node.position.x += self.size.width * GameConstant.SceneNunbers
            }
        }
    }
}
