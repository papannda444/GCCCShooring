//
//  SpaceShipState.swift
//  shooting-game
//
//  Created by papannda444 on 2019/03/03.
//  Copyright © 2019 三野田脩. All rights reserved.
//

import Foundation

enum SpaceShipState: String {
    case normal
    case speed
    case stone

    init() {
        self = .normal
    }

    mutating func shipPowerUp(itemType: PowerItem.ItemType) {
        switch itemType {
        case .speed:
            self = .speed
        case .stone:
            self = .stone
        case .heal:
            self = .normal
        }
    }
}
