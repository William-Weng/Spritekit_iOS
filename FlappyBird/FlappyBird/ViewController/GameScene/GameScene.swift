//
//  GameScene.swift
//  FlappyBird
//
//  Created by William-Weng on 2018/11/22.
//  Copyright © 2018年 William-Weng. All rights reserved.
//
/// [iOS開發實戰-基於SpriteKit的FlappyBird小遊戲](https://www.jianshu.com/p/10f985687356)

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
        initPlayerBody()
        playerAnimation()
    }
    
    override func update(_ currentTime: TimeInterval) {
        movePlayer()
        moveCamera()
        moveAllSprites(camera: mainCamera, nodeNames: moveNodeNames)
        autoRemoveObstacleNode()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let jumpAction = SKAction.move(by: CGVector(dx: 0, dy: 50), duration: 0.1)
        player?.run(jumpAction)
        
        let obstacleNode = makeObstacleNode()
        let obstacleNode2 = makeObstacleNode2()
        
        addChild(obstacleNode)
        addChild(obstacleNode2)
    }
    
    /// 產生障礙物
    private func makeObstacleNode() -> SKSpriteNode {
        
        let obstacleNode = SKSpriteNode(imageNamed: "Obstacle.png")
        let x = camera?.position.x ?? 0
        
        obstacleNode.size = CGSize(width: 100, height: 750)
        obstacleNode.position = CGPoint(x: x + 1334 / 2, y: -750 / 2)
        obstacleNode.zPosition = GameConstant.zPosition
        obstacleNode.name = GameConstant.NodeName.obstacle.rawValue

        return obstacleNode
    }
    
    /// 產生障礙物
    private func makeObstacleNode2() -> SKSpriteNode {
        
        let obstacleNode = SKSpriteNode(imageNamed: "Obstacle.png")
        let x = camera?.position.x ?? 0
        
        obstacleNode.size = CGSize(width: 100, height: 750)
        obstacleNode.position = CGPoint(x: x + 1334 / 2, y: 750 / 2)
        obstacleNode.zPosition = GameConstant.zPosition
        obstacleNode.name = GameConstant.NodeName.obstacle.rawValue
        
        return obstacleNode
    }
    
    /// 移除超過畫面的
    private func autoRemoveObstacleNode() {
        
        enumerateChildNodes(withName: GameConstant.NodeName.obstacle.rawValue) { (node, _) in
            
            guard let sprite = node as? SKSpriteNode,
                  let cameraX = self.camera?.position.x,
                  let spriteX = Optional.some(sprite.position.x)
            else {
                return
            }
            
            if (cameraX - 1334 / 2 > spriteX) { sprite.removeFromParent() }
            
            print(cameraX, spriteX)
        }
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
    
    /// 主角綁上鐵塊
    private func initPlayerBody() {
        let playerBody = SKPhysicsBody(rectangleOf: CGSize(width: 128, height: 128))
        player?.physicsBody = playerBody
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
        // player?.wobbing()
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
        trailNode.zPosition = GameConstant.zPosition
        
        addChild(trailNode)
        player?.addChild(emitter)
    }
}
