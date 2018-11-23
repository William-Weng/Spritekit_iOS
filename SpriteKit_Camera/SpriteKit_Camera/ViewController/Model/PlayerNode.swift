//
//  PlayerNode.swift
//  SpriteKit_Camera
//
//  Created by William-Weng on 2018/11/21.
//  Copyright © 2018年 William-Weng. All rights reserved.
//

import SpriteKit

class PlayerNode: SKSpriteNode {
    
    private let RunKey = (flap: "flap", wobbing: "wobbing")
    private lazy var playerTextures = { makePlayerTextures() }()
}

extension PlayerNode {
    
    /// 拍打翅膀
    func flapping() {
        
        let playerAnimation = SKAction.animate(with: playerTextures, timePerFrame: TimeInterval(0.1))
        let repeatFlap = SKAction.repeatForever(playerAnimation)
        
        run(repeatFlap, withKey: RunKey.flap)
    }
    
    /// 上下浮動
    func wobbing() {
        
        let moveUp   = SKAction.moveBy(x: 0, y: 50, duration: 0.5)
        let moveDown = moveUp.reversed()
        let sequence = SKAction.sequence([moveUp, moveDown])
        let repeatWobble = SKAction.repeatForever(sequence)
        
        moveUp.timingMode = .easeInEaseOut
        run(repeatWobble, withKey: RunKey.wobbing)
    }
}

/// MARK: - 小工具
extension PlayerNode {
    
    /// 取得畫面資料夾內的所有圖檔
    private func makePlayerTextures() -> [SKTexture] {
        
        let textureAtlas = SKTextureAtlas(named: GameConstant.AtlasFolder.penguin.rawValue)
        let atlasImageNames = replaceImageNames(textureAtlas.textureNames, from: ".png", to: "")
        
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
