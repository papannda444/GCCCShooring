//
//  Enemy.swift
//  shooting-game
//
//  Created by 三野田脩 on 2019/02/11.
//  Copyright © 2019 三野田脩. All rights reserved.
//

import Foundation
import SpriteKit

protocol Enemy: AnyObject {
    var state: EnemyState { get set }
    var enemyMove: [SKAction] { get set }
    var hitPoint: Int { get set }
    var attackTimer: Timer? { get set }
    var killPoint: Int { get set }

    func setPhysicsBody(categoryBitMask: UInt32, contactTestBitMask: UInt32)
}

extension Enemy {
    func setHitPoint(hitPoint: Int) {
        self.hitPoint = hitPoint
    }

    func createEnemyMovement(displayViewFrame frame: CGRect) {
        let positionX = frame.width * (CGFloat.random(in: 0...1) - 0.5)
        let topToBottom = SKAction.sequence([
            SKAction.move(to: CGPoint(x: positionX, y: frame.height / 2 + 100), duration: 0.0),
            SKAction.rotate(toAngle: CGFloat.degreeToRadian(degree: 180), duration: 0.0),
            SKAction.moveTo(y: -frame.height / 2 - 100, duration: 4.0),
            SKAction.removeFromParent()
        ])
        enemyMove.append(topToBottom)
        let bottomToTop = SKAction.sequence([
            SKAction.move(to: CGPoint(x: positionX, y: -frame.height / 2 - 100), duration: 0.0),
            SKAction.moveTo(y: frame.height / 2 + 100, duration: 4.0),
            SKAction.removeFromParent()
        ])
        enemyMove.append(bottomToTop)
    }

    func isShipState(equal state: EnemyState) -> Bool {
        return self.state == state
    }
}
