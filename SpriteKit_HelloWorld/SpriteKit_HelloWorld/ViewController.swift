//
//  ViewController.swift
//  SpriteKit_HelloWorld
//
//  Created by William-Weng on 2018/11/21.
//  Copyright © 2018年 William-Weng. All rights reserved.
//

import UIKit
import SpriteKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let view = view as? SKView else  { return }
        
        let scene = GameScene(size: view.frame.size)
        
        view.presentScene(scene)
    }
}

