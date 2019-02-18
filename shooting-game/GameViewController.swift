//
//  GameViewController.swift
//  shooting-game
//
//  Created by 三野田脩 on 2018/12/23.
//  Copyright © 2018 三野田脩. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    guard let view = self.view as! SKView? else { return }
    // Load the SKScene from 'GameScene.sks'
    guard let scene = SKScene(fileNamed: "GameScene") else { return }
    if let gameScene = scene as? GameScene {
      gameScene.endGame = {
        self.dismiss(animated: false, completion: nil)
      }
    }
    // Set the scale mode to scale to fit the window
    scene.scaleMode = .aspectFit
    // Present the scene
    view.presentScene(scene)
    
    view.ignoresSiblingOrder = true
    
    view.showsFPS = true
    view.showsNodeCount = true
  }
  
  override var shouldAutorotate: Bool {
    return true
  }
  
  override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    if UIDevice.current.userInterfaceIdiom == .phone {
      return .allButUpsideDown
    } else {
      return .all
    }
  }
  
  override var prefersStatusBarHidden: Bool {
    return true
  }
  
}
