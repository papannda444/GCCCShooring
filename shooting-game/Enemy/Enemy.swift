//
//  Enemy.swift
//  shooting-game
//
//  Created by 三野田脩 on 2019/02/11.
//  Copyright © 2019 三野田脩. All rights reserved.
//

import Foundation
import SpriteKit

protocol EnemyDelegate: AnyObject {
    func enemyAttack(bullet: EnemyBullet)
    func killedEnemy(score: Int)
}

protocol Enemy: AnyObject {
    var delegate: EnemyDelegate? { get set }
    var state: EnemyState { get set }
    var enemyMove: [SKAction] { get set }
    var hitPoint: Int { get set }
    var firstAttackTimer: Timer? { get set }
    var secondAttackTimer: Timer? { get set }
    var killPoint: Int { get set }

    func setPhysicsBody(categoryBitMask: UInt32, contactTestBitMask: UInt32)
    func startMove()
    func damaged()
    func invalidateAttackTimer()
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

    func invalidateAttackTimer() {
        firstAttackTimer?.invalidate()
        secondAttackTimer?.invalidate()
    }
}

extension Enemy where Self: SKSpriteNode {
    func damaged() {
        if action(forKey: "blink") != nil {
            return
        }

        hitPoint -= 1
        if hitPoint > 0 {
            let blink = SKAction.repeat(SKAction.sequence([
                SKAction.fadeAlpha(to: 0.0, duration: 0.05),
                SKAction.fadeAlpha(to: 1.0, duration: 0.05)
            ]), count: 3)
            run(blink, withKey: "blink")
            return
        }

        guard let explosion = SKEmitterNode(fileNamed: "Explosion") else {
            return
        }
        explosion.position = position
        self.parent?.addChild(explosion)
        explosion.run(SKAction.wait(forDuration: 1.0)) {
            explosion.removeFromParent()
        }
        removeFromParent()
        delegate?.killedEnemy(score: killPoint)
    }
}
