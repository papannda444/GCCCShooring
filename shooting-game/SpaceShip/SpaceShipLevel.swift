//
//  SpaceShipLevel.swift
//  shooting-game
//
//  Created by papannda444 on 2019/03/11.
//  Copyright © 2019 三野田脩. All rights reserved.
//

import Foundation

enum SpaceShipLevel: String {
    case one
    case two
    case three

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
