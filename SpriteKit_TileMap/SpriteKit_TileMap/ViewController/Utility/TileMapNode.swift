//
//  TileMapNode.swift
//  SpriteKit_TileMap
//
//  Created by William-Weng on 2018/12/3.
//  Copyright © 2018年 William-Weng. All rights reserved.
//

import SpriteKit

class TileMapNode: SKNode {
    
    var tileSize = CGSize()
    var atlas: SKTextureAtlas?
    
    init(tileSize: CGSize) {
        super.init()
        self.tileSize = tileSize
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(tileSize: CGSize, tileCodes: [String]) {
        self.init(tileSize: tileSize)
        mapNodeSetting(tileSize: tileSize, tileCodes: tileCodes)
    }
}

extension TileMapNode {
    
    /// 製作地圖 (跑雙迴圈)
    private func mapNodeSetting(tileSize: CGSize, tileCodes: [String]) {
        
        for (indexRow, tileCode) in tileCodes.enumerated() {
            for (indexColunm, code) in tileCode.enumerated() {
                
                if let tileNode = nodeTexture(forCode: code) {
                    tileNode.position = nodePostion(forRow: indexRow, colunm: indexColunm)
                    addChild(tileNode)
                }
            }
        }
    }
    
    /// 處理各點的圖形材質
    private func nodeTexture(forCode tileCode: Character) -> SKSpriteNode? {
        
        guard let tileType = GameConstant.MapTextureCode.init(rawValue: tileCode),
              let tileNode = Optional.some(SKSpriteNode(texture: tileType.texture))
        else {
            return nil
        }
        
        tileNode.blendMode = .replace
        tileNode.texture?.filteringMode = .nearest
        
        return tileNode
    }
    
    /// 計算地圖各點的所在位置
    private func nodePostion(forRow row: Int, colunm: Int) -> CGPoint {
        
        let x = CGFloat(colunm) * tileSize.width + tileSize.width / 2
        let y = CGFloat(row) * tileSize.height + tileSize.height / 2
        
        return CGPoint(x: x, y: -y)
    }
}
