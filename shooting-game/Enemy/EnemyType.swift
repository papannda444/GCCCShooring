//
//  EnemyType.swift
//  shooting-game
//
//  Created by papannda444 on 2019/03/04.
//  Copyright © 2019 三野田脩. All rights reserved.
//

import Foundation

enum EnemyType: String {
    case red = "enemy_red"
    case blue = "enemy_blue"
    case yellow = "enemy_yellow"

    init() {
        self = .red
    }
}
