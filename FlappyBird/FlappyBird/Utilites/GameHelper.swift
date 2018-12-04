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
    
    /// 設定遊戲分數
    public func setScore(with score: Int, for key: ScoreKey) {
        
        let userDefault = UserDefaults.standard
        userDefault.set(score, forKey: key.rawValue)
        userDefault.synchronize()
    }
    
    /// 取得遊戲分數
    public func getScore(for key: ScoreKey) -> Int {
        
        let userDefault = UserDefaults.standard
        let score = userDefault.integer(forKey: key.rawValue)
        
        return score
    }
    
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
