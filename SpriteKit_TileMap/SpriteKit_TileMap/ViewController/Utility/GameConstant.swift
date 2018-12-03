//
//  GameConstant.swift
//  SpriteKit_TileMap
//
//  Created by William-Weng on 2018/12/3.
//  Copyright © 2018年 William-Weng. All rights reserved.
//

import SpriteKit

class GameConstant {
    
    /* 單格地圖的大小 */
    static let TileSize = CGSize(width: 32, height: 32)
    
    /// 地圖材質的類型代號
    enum MapTextureCode: Character {
        case grass = "o"
        case wall = "x"
        case stone = "#"
        case water = "?"
    }
}

extension GameConstant.MapTextureCode {
    
    /* 材質 */
    var texture: SKTexture {
        get { return findTexture() }
    }
    
    /// 取得對應的材質
    private func findTexture() -> SKTexture {
        
        let atlas = SKTextureAtlas(named: "Scenery.atlas")
        let name = findTextureName()
        let texture = atlas.textureNamed(name)
        
        return texture
    }
    
    /// 取得材質名稱
    private func findTextureName() -> String {
        
        switch self {
        case .grass: return "grass"
        case .wall: return "wall"
        case .stone: return "stone"
        case .water: return "water"
        }
    }
}
