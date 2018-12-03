//
//  GameViewController.swift
//  lipstickDemo
//
//  Created by 天明 on 2018/11/30.
//  Copyright © 2018 天明. All rights reserved.
//

import UIKit
import SpriteKit
//import GameplayKit

/// 插口红游戏原型
class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let view = self.view as! SKView? else {
            return
        }
        view.backgroundColor = UIColor.white
        view.ignoresSiblingOrder = true
        view.showsFPS = true
        view.showsNodeCount = true
        view.showsPhysics = true //开启显示物理体积的边框，便于调试
        
        //let scene = TestScene(size: UIScreen.main.bounds.size)
        let scene = LipstickScene(size: UIScreen.main.bounds.size)
        view.presentScene(scene)
        
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
