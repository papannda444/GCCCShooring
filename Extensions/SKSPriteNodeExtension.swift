//
//  SKSPriteNodeExtension.swift
//  shooting-game
//
//  Created by papannda444 on 2019/03/08.
//  Copyright © 2019 三野田脩. All rights reserved.
//

import Foundation
import SpriteKit

extension SKSpriteNode {
    func setPhysicsBody(categoryBitMask: UInt32, contactTestBitMask: UInt32) {
        physicsBody = physicsBody ?? SKPhysicsBody(circleOfRadius: frame.width / 2)
        physicsBody?.categoryBitMask = categoryBitMask
        physicsBody?.contactTestBitMask = contactTestBitMask
        physicsBody?.collisionBitMask = 0
    }
}
