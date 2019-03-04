//
//  EnemyState.swift
//  shooting-game
//
//  Created by papannda444 on 2019/03/04.
//  Copyright © 2019 三野田脩. All rights reserved.
//

import Foundation

enum EnemyState: String {
    case normal
    case poison

    init() {
        self = .normal
    }
}
