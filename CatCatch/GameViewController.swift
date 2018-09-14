//
//  GameViewController.swift
//  CatCatch
//
//  Created by Kyle Smith on 4/4/17.
//  Copyright © 2017 Smith Coding. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {
    
    lazy var gameOverPanel: UIView = {
        let v = UIView()
        v.backgroundColor = .green
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    let scene: GameScene = {
        let s = GameScene(size: UIScreen.main.bounds.size)
        return s
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGameOver()
        scene.viewController = self
        
        //let scene = GameScene(size: UIScreen.main.bounds.size)
        //let scene = GameScene(size: CGSize(width: 1536, height: 2048))
        let skView = self.view as! SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.ignoresSiblingOrder = true
        scene.scaleMode = .aspectFill
        skView.presentScene(scene)
    }
    
    private func setupGameOver() {
        view.addSubview(gameOverPanel)
        
        gameOverPanel.isHidden = true
        gameOverPanel.topAnchor.constraint(equalTo: view.topAnchor, constant: 128).isActive = true
        gameOverPanel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 64).isActive = true
        gameOverPanel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -64).isActive = true
        gameOverPanel.heightAnchor.constraint(equalToConstant: 420).isActive = true
        
    }
    
    func showGameOver() {
        gameOverPanel.isHidden = false
        scene.isUserInteractionEnabled = false
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
