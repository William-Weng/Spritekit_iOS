//
//  PlayerNode.swift
//  FlappyBird
//
//  Created by William-Weng on 2018/11/22.
//  Copyright © 2018年 William-Weng. All rights reserved.
//

import SpriteKit

class PlayerNode: SKSpriteNode {
    
    private let RunKey = (flapping: "flapping", wobbing: "wobbing")
    private let AnimationTime = (flap: TimeInterval(0.1), wobbing: TimeInterval(0.5))
    private lazy var playerTextures = { makePlayerTextures() }()
}

extension PlayerNode {
    
    /// 拍打翅膀
    func flapping() {
        let animation = flappingAnimation()
        run(animation, withKey: RunKey.flapping)
    }
    
    /// 上下浮動
    func wobbing() {
        let animation = wobbingAnimation()
        run(animation, withKey: RunKey.wobbing)
    }
}

/// MARK: - 小工具
extension PlayerNode {
    
    /// 拍打翅膀的圖片動畫
    private func flappingAnimation() -> SKAction {
        
        let flappingAnimation = SKAction.animate(with: playerTextures, timePerFrame: AnimationTime.flap)
        let repeatFlapping = SKAction.repeatForever(flappingAnimation)
        
        return repeatFlapping
    }
    
    /// 上下浮動的移動動畫
    private func wobbingAnimation() -> SKAction {
        
        let moveUp = SKAction.moveBy(x: 0, y: 50, duration: AnimationTime.wobbing)
        let moveDown = moveUp.reversed()
        let wobbingAnimation = SKAction.sequence([moveUp, moveDown])
        let repeatWobbing = SKAction.repeatForever(wobbingAnimation)
        
        moveDown.timingMode = .easeInEaseOut
        
        return repeatWobbing
    }
    
    /// 取得Atlas資料夾內的所有圖檔
    private func makePlayerTextures() -> [SKTexture] {
        
        let textureAtlasFolder = SKTextureAtlas(named: GameConstant.AtlasFolder.penguin.rawValue)
        let atlasImageNames = replaceImageNames(textureAtlasFolder.textureNames, from: ".png", to: "")
        
        var textures = [SKTexture]()
        
        for imageName in atlasImageNames {
            textures.append(SKTexture(imageNamed: imageName))
        }
        
        return textures
    }
    
    /// 處理檔案副檔名、排序
    private func replaceImageNames(_ names: [String], from: String, to: String) -> [String] {
        
        let imageNames = names.sorted().map { (name) -> String in
            return name.replacingOccurrences(of: from, with: to)
        }
        
        return imageNames
    }
}
