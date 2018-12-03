//
//  GameScene.swift
//  SpriteKit_TexturePacker
//
//  Created by William-Weng on 2018/12/3.
//  Copyright © 2018年 William-Weng. All rights reserved.
//
// [TexturePacker - Create Sprite Sheets for your game!](https://www.codeandweb.com/texturepacker)
// [Tiled Map Editor | A flexible level editor](https://www.mapeditor.org/)
// [SKTiled - 讓SpriteKit讀取TMX地圖檔](https://github.com/mfessenden/SKTiled)

import SpriteKit

class GameScene: SKScene {
    
    override func didMove(to view: SKView) {
        if let tilemap = SKTilemap.load(tmxFile: "Map") {
            addChild(tilemap)
        }
    }
}
