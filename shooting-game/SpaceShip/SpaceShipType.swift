//
//  SpaceShipType.swift
//  shooting-game
//
//  Created by papannda444 on 2019/03/03.
//  Copyright © 2019 三野田脩. All rights reserved.
//

import Foundation

enum SpaceShipType: String {
    case red = "ship_red"
    case blue = "ship_blue"
    case yellow = "ship_yellow"
    case purple = "ship_purple"
    case silver = "ship_silver"
    case pink = "ship_pink"

    init() {
        self = .red
    }
}
