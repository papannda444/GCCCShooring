//
//  EnemyState.swift
//  shooting-game
//
//  Created by papannda444 on 2019/03/04.
//  Copyright © 2019 三野田脩. All rights reserved.
//

import Foundation

enum EnemyState: Equatable {
    case normal
    case poison(level: Int)

    init() {
        self = .normal
    }

    static func == (leftState: EnemyState, rightState: EnemyState) -> Bool {
        switch (leftState, rightState) {
        case (.normal, .normal):
            return true
        case let (.poison(level: leftLevel), .poison(level: rightLevel)):
            return leftLevel == rightLevel
        default:
            return false
        }
    }
}
