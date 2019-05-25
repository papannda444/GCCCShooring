//
//  GameViewController.swift
//  shooting-game
//
//  Created by 三野田脩 on 2018/12/23.
//  Copyright © 2018 三野田脩. All rights reserved.
//

import GameplayKit
import SpriteKit
import UIKit

class GameViewController: UIViewController {
    var shipType = SpaceShipType()

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let view = self.view as? SKView else {
            return
        }
        // Load the SKScene from 'GameScene.sks'
        guard let scene = SKScene(fileNamed: "GameScene") else {
            return
        }
        if let gameScene = scene as? GameScene {
            gameScene.gameSceneClose = {
                self.dismiss(animated: false, completion: nil)
            }
            gameScene.shipType = shipType
        }
        // Set the scale mode to scale to fit the window
        scene.scaleMode = .aspectFit
        // Present the scene
        view.presentScene(scene)
        view.ignoresSiblingOrder = true
        //        view.showsPhysics = true
        //        view.showsFPS = true
        //        view.showsNodeCount = true
        view.isMultipleTouchEnabled = false
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
