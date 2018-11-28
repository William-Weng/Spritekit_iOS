//
//  GameScene.swift
//  SpriteKit_SKCropNode
//
//  Created by William-Weng on 2018/11/28.
//  Copyright © 2018年 William-Weng. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    override func didMove(to view: SKView) {
        
        let starNode = SKSpriteNode(imageNamed: "Star")
        let photoFrame = SKSpriteNode(imageNamed: "PhotoFrame")
        let maskNode = SKSpriteNode(imageNamed: "Mask")
        let cropNode = SKCropNode()
        
        backgroundColor = .white

        starNode.setScale(0.9)
        photoFrame.position = .zero
        
        addChild(photoFrame)
        
        // 星星跟Mask做遮罩
        cropNode.addChild(starNode)
        cropNode.maskNode = maskNode
        
        photoFrame.addChild(cropNode)
    }
}
