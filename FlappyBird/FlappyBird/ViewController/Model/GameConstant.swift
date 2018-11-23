//
//  GameConstant.swift
//  FlappyBird
//
//  Created by William-Weng on 2018/11/22.
//  Copyright © 2018年 William-Weng. All rights reserved.
//

import UIKit

class GameConstant: NSObject {
    
    /* 最大的場景大小 */
    static let MaxSceneSize = CGSize.init(width: 1334, height: 750)
    
    /* 有幾個場景 */
    static let SceneNunbers:CGFloat = 2.0
    
    /* 畫面移動的速度 */
    static let CameraMoveX: CGFloat = 5
    
    /* 物件的Node名稱 */
    enum NodeName: String {
        case player = "player"
        case floor = "floor"
        case background = "background"
        case mainCamera = "mainCamera"
    }
    
    /* 場景名稱 */
    enum SceneName: String {
        case game = "GameScene.sks"
    }
    
    /* 光影特效名稱 */
    enum EmitterName: String {
        case trail = "Trail.sks"
    }
    
    /* 動畫圖片資料夾名稱 */
    enum AtlasFolder: String {
        case penguin = "Penguin.atlas"
    }
}