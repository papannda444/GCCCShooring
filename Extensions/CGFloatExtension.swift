//
//  CGFloatExtension.swift
//  shooting-game
//
//  Created by papannda444 on 2019/03/04.
//  Copyright © 2019 三野田脩. All rights reserved.
//

import UIKit

extension CGFloat {
    var radian: CGFloat {
        return self * .pi / 180.0
    }

    static func degreeToRadian(degree: CGFloat) -> CGFloat {
        return degree * .pi / 180.0
    }
}
