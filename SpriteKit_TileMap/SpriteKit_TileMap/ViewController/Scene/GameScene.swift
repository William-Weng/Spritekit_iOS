//
//  GameScene.swift
//  SpriteKit_TileMap
//
//  Created by William-Weng on 2018/12/3.
//  Copyright © 2018年 William-Weng. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    lazy var tileCode: [String] = { return GameUtility.readMapCodes(withFileName: "Map.txt") }()
    
    override func didMove(to view: SKView) {
        addChild(mapNodes(ForCode: tileCode))
    }
}

// MARK: - 小工具
extension GameScene {
    
    /// 產生地圖Node
    private func mapNodes(ForCode tileCode: [String]) -> TileMapNode {
        let tileMapNode = TileMapNode(tileSize: GameConstant.TileSize, tileCodes: tileCode)
        return tileMapNode
    }
}

