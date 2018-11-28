//
//  GameViewController.swift
//  Spritekit_UIGestureRecognizer
//
//  Created by William-Weng on 2018/11/28.
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
        
        if let scene = GameScene(fileNamed: "GameScene") {
            
            let skView = self.view as! SKView
            
            skView.showsFPS = true
            skView.showsNodeCount = true
            skView.ignoresSiblingOrder = true
            scene.scaleMode = .aspectFill
            
            skView.presentScene(scene)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
