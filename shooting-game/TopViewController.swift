//
//  TopViewController.swift
//  shooting-game
//
//  Created by 三野田脩 on 2018/12/23.
//  Copyright © 2018 三野田脩. All rights reserved.
//

import UIKit

class TopViewController: UIViewController {
    @IBOutlet private weak var bestScoreLabel: UILabel!
    @IBOutlet private weak var currentScoreLabel: UILabel!
    @IBOutlet private weak var redShipButton: UIButton!
    @IBOutlet private weak var blueShipButton: UIButton!
    @IBOutlet private weak var yellowShipButton: UIButton!
    @IBOutlet private weak var purpleShipButton: UIButton!
    @IBOutlet private weak var silverShipButton: UIButton!
    @IBOutlet private weak var pinkShipButton: UIButton!

    private var shipType: SpaceShip.ShipType?
    private var redFrame: UIImage?
    private var blackFrame: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()
        UserDefaults.standard.removeObject(forKey: "currentScore")
        redFrame = UIImage(named: "frame_border_red")
        blackFrame = UIImage(named: "frame_border_black")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let bestScore = UserDefaults.standard.integer(forKey: "bestScore")
        bestScoreLabel.text = "Best Score: \(bestScore)"
        let currentScore = UserDefaults.standard.integer(forKey: "currentScore")
        currentScoreLabel.text = "Current Score: \(currentScore)"
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let gameViewController = segue.destination as? GameViewController
        gameViewController?.shipType = shipType
    }

    private func clearShipFrame() {
        redShipButton.setBackgroundImage(blackFrame, for: .normal)
        blueShipButton.setBackgroundImage(blackFrame, for: .normal)
        yellowShipButton.setBackgroundImage(blackFrame, for: .normal)
        purpleShipButton.setBackgroundImage(blackFrame, for: .normal)
        silverShipButton.setBackgroundImage(blackFrame, for: .normal)
        pinkShipButton.setBackgroundImage(blackFrame, for: .normal)
    }

    @IBAction private func tapRedShipButton(_ sender: UIButton) {
        shipType = .red
        clearShipFrame()
        sender.setBackgroundImage(redFrame, for: .normal)
    }

    @IBAction private func tapBlueShipButton(_ sender: UIButton) {
        shipType = .blue
        clearShipFrame()
        sender.setBackgroundImage(redFrame, for: .normal)
    }

    @IBAction private func tapYellowShipButton(_ sender: UIButton) {
        shipType = .yellow
        clearShipFrame()
        sender.setBackgroundImage(redFrame, for: .normal)
    }

    @IBAction private func tapPurpleShipButton(_ sender: UIButton) {
        shipType = .purple
        clearShipFrame()
        sender.setBackgroundImage(redFrame, for: .normal)
    }

    @IBAction private func tapSilverShipButton(_ sender: UIButton) {
        shipType = .silver
        clearShipFrame()
        sender.setBackgroundImage(redFrame, for: .normal)
    }

    @IBAction private func tapPinkShipButton(_ sender: UIButton) {
        shipType = .pink
        clearShipFrame()
        sender.setBackgroundImage(redFrame, for: .normal)
    }
}
