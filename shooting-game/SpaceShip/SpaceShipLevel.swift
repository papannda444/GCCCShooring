//
//  SpaceShipLevel.swift
//  shooting-game
//
//  Created by papannda444 on 2019/03/11.
//  Copyright © 2019 三野田脩. All rights reserved.
//

import Foundation

enum SpaceShipLevel: Int {
    case one = 1
    case two = 2
    case three = 3

    init() {
        self = .one
    }

    mutating func levelUp() {
        switch self {
        case .one:
            self = .two
        case .two:
            self = .three
        case .three:
            self = .three
        }
    }
}
