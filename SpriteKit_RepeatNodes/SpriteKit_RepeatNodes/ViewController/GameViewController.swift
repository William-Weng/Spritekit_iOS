//
//  GameViewController.swift
//  SpriteKit_RepeatNodes
//
//  Created by William-Weng on 2018/11/29.
//  Copyright © 2018年 William-Weng. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {
    
    override var prefersStatusBarHidden: Bool { return true }
    override var shouldAutorotate: Bool { return true }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone { return .allButUpsideDown }
        return .all
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let skView = view as? SKView,
              let scene = GameScene(fileNamed: "GameScene")
        else {
            return
        }
        
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.ignoresSiblingOrder = true
        scene.scaleMode = .aspectFill
        
        skView.presentScene(scene)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
