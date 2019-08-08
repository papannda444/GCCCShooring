//
//  GameAudio.swift
//  shooting-game
//
//  Created by papannda444 on 2019/08/09.
//  Copyright © 2019 三野田脩. All rights reserved.
//

import Foundation

enum GameAudio: String {
    case bgm = "shooting-BGM"

    var fileName: String {
        return rawValue
    }

    var fileType: String {
        return "wav"
    }
}
