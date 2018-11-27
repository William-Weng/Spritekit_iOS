//
//  GameConstant.swift
//  SpriteKit_Move
//
//  Created by William-Weng on 2018/11/26.
//  Copyright © 2018年 William-Weng. All rights reserved.
//

import UIKit

class GameConstant: NSObject {
    
    /* 最大的場景大小 */
    static let MaxSceneSize = CGSize.init(width: 2048, height: 1536)
    
    /* 場景名稱 */
    enum SceneName: String {
        case game = "GameScene.sks"
    }
    
    /* 物件的Node名稱 */
    enum NodeName: String {
        case football = "football"
    }
}
