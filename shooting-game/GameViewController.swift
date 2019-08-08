//
//  GameViewController.swift
//  shooting-game
//
//  Created by 三野田脩 on 2018/12/23.
//  Copyright © 2018 三野田脩. All rights reserved.
//

import AVFoundation
import GameplayKit
import SpriteKit
import UIKit

class GameViewController: UIViewController {
    var shipType = SpaceShipType()
    var audioPlayer: AVAudioPlayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        playSound(resource: .bgm, numberOfLoops: -1)

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
                self.stopSound()
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

extension GameViewController: AVAudioPlayerDelegate {
    func playSound(resource: GameAudio, volume: Float = 1.0, numberOfLoops: Int = 0) {
        guard let path = Bundle.main.path(forResource: resource.fileName, ofType: resource.fileType) else {
            return
        }
        audioPlayer = try? AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
        audioPlayer?.delegate = self
        audioPlayer?.play()
        audioPlayer?.volume = volume
        audioPlayer?.numberOfLoops = numberOfLoops
    }

    func stopSound() {
        audioPlayer?.stop()
    }
}
