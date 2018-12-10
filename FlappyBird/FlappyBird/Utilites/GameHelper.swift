//
//  GameHelper.swift
//  FlappyBird
//
//  Created by William-Weng on 2018/12/4.
//  Copyright © 2018年 William-Weng. All rights reserved.
//

import SpriteKit

class GameHelper: NSObject {
    
    static let shared = GameHelper()
    
    enum ScoreKey: String {
        case currentScore = "CurrentScore"
        case bestScore = "BestScore"
    }
    
    private override init() {}
        
    /// 場景轉換
    public func transferScene(from oldScene: SKScene, to sceneName: String) {
        
        guard let transition = Optional.some(SKTransition.doorsOpenVertical(withDuration: 0.5)),
              let scene = SKScene.init(fileNamed: sceneName),
              let view = oldScene.view
        else {
            return
        }
        
        scene.size = oldScene.size
        scene.scaleMode = .aspectFill
        view.presentScene(scene, transition: transition)
    }
}
