//
//  Enemy.swift
//  shooting-game
//
//  Created by 三野田脩 on 2019/02/11.
//  Copyright © 2019 三野田脩. All rights reserved.
//

import Foundation
import SpriteKit

protocol Enemy {
    var state: EnemyState { get set }
    var enemyMove: [SKAction] { get set }
    var hitPoint: Int { get set }
    var attackTimer: Timer? { get set }
    var killPoint: Int { get set }

    func setPhysicsBody(categoryBitMask: UInt32, contactTestBitMask: UInt32)
}

extension Enemy {
    mutating func setHitPoint(hitPoint: Int) {
        self.hitPoint = hitPoint
    }

    mutating func createEnemyMovement(displayViewFrame frame: CGRect) {
        enemyMove = []
    }

    func isShipState(equal state: EnemyState) -> Bool {
        return self.state == state
    }
}
