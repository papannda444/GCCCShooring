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
    func killedEnemy(_: Enemy, score: Int)
}

protocol Enemy: AnyObject {
    var delegate: EnemyDelegate? { get set }
    var state: EnemyState { get set }
    var enemyMove: [SKAction] { get set }
    var hitPoint: Int { get set }
    var firstAttackTimer: Timer? { get set }
    var secondAttackTimer: Timer? { get set }
    var killPoint: Int { get set }
    var poisonDamageTimer: Timer? { get set }

    func setPhysicsBody(categoryBitMask: UInt32)
    func startMove()
    func damaged(_ damege: Int)
    func invalidateAttackTimer()
}

extension Enemy {
    func setHitPoint(hitPoint: Int) {
        self.hitPoint = hitPoint
    }

    func damaged() {
        self.damaged(1)
    }

    func createEnemyMovement(displayViewFrame frame: CGRect) {
        let positionX = frame.width * (CGFloat.random(in: 0...1) - 0.5)
        var path = CGMutablePath()
        path.move(to: CGPoint(x: positionX, y: frame.height / 2 + 100))
        path.addLine(to: CGPoint(x: positionX, y: -frame.height / 2 - 100))
        path.addLine(to: CGPoint(x: positionX, y: frame.height / 2 + 100))
        let downUp = SKAction.sequence([
            .follow(path, duration: 8.0),
            SKAction.removeFromParent()
        ])
        enemyMove.append(downUp)
        path = CGMutablePath()
        path.move(to: CGPoint(x: frame.width / 2 + 100, y: frame.height / 2))
        path.addLine(to: CGPoint(x: frame.width / 4, y: 0))
        path.addLine(to: CGPoint(x: -frame.width / 4, y: 0))
        path.addLine(to: CGPoint(x: -frame.width / 2 - 100, y: frame.height / 2))
        let vShaped = SKAction.sequence([
            .follow(path, duration: 4.0),
            .removeFromParent()
        ])
        enemyMove.append(vShaped)
        path = CGMutablePath()
        path.move(to: CGPoint(x: -frame.width / 2 - 100, y: frame.height / 2))
        path.addLine(to: CGPoint(x: -frame.width / 4, y: 0))
        path.addLine(to: CGPoint(x: frame.width / 4, y: 0))
        path.addLine(to: CGPoint(x: frame.width / 2 + 100, y: frame.height / 2))
        let vShapedReverse = SKAction.sequence([
            .follow(path, duration: 4.0),
            .removeFromParent()
        ])
        enemyMove.append(vShapedReverse)
        path = CGMutablePath()
        path.move(to: CGPoint(x: -frame.width / 2 - 100, y: frame.height / 2))
        path.addLine(to: CGPoint(x: frame.width / 2, y: frame.height / 4))
        path.addLine(to: CGPoint(x: -frame.width / 2, y: 0))
        path.addLine(to: CGPoint(x: frame.width / 2 + 100, y: -frame.height / 4))
        let zigzag = SKAction.sequence([
            .follow(path, duration: 4.0),
            .removeFromParent()
        ])
        enemyMove.append(zigzag)
        path = CGMutablePath()
        path.move(to: CGPoint(x: frame.width / 2 + 100, y: frame.height / 2))
        path.addLine(to: CGPoint(x: -frame.width / 2, y: frame.height / 4))
        path.addLine(to: CGPoint(x: frame.width / 2, y: 0))
        path.addLine(to: CGPoint(x: -frame.width / 2 - 100, y: -frame.height / 4))
        let zigzagReverse = SKAction.sequence([
            .follow(path, duration: 4.0),
            .removeFromParent()
        ])
        enemyMove.append(zigzagReverse)
    }

    func isShipState(equal state: EnemyState) -> Bool {
        return self.state == state
    }

    func invalidateAttackTimer() {
        firstAttackTimer?.invalidate()
        secondAttackTimer?.invalidate()
    }

    func poisoning(level: Int) {
        if state == .poison(level: level) {
            return
        }
        state = .poison(level: level)
        poisonDamageTimer?.invalidate()
        poisonDamageTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self, state] _ in
            switch state {
            case .poison(level: 1):
                self?.damaged()
            case .poison(level: 2):
                self?.damaged(2)
            case .poison(level: 3):
                self?.damaged(5)
            default:
                fatalError("Never called")
            }
        }
    }
}

extension Enemy where Self: SKSpriteNode {
    func damaged(_ damage: Int) {
        hitPoint -= damage
        let blink = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.0, duration: 0.05),
            SKAction.fadeAlpha(to: 1.0, duration: 0.05)
        ])
        run(blink, withKey: "blink")

        if hitPoint < 0 {
            guard let explosion = SKEmitterNode(fileNamed: "Explosion"),
                self.parent != nil else {
                    return
            }
            explosion.position = position
            parent?.addChild(explosion)
            explosion.run(SKAction.wait(forDuration: 1.0)) {
                explosion.removeFromParent()
            }
            removeFromParent()
            delegate?.killedEnemy(self, score: killPoint)
        }
    }
}
