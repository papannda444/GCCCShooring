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

    override func viewDidLoad() {
        super.viewDidLoad()
        UserDefaults.standard.removeObject(forKey: "currentScore")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let bestScore = UserDefaults.standard.integer(forKey: "bestScore")
        bestScoreLabel.text = "Best Score: \(bestScore)"
        let currentScore = UserDefaults.standard.integer(forKey: "currentScore")
        currentScoreLabel.text = "Current Score: \(currentScore)"
    }
}
