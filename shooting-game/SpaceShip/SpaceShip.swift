//
//  SpaceShip.swift
//  shooting-game
//
//  Created by papannda444 on 2019/03/03.
//  Copyright © 2019 三野田脩. All rights reserved.
//

import Foundation
import SpriteKit

protocol SpaceShipDelegate: AnyObject {
    func displayHeart(hearts: [SKSpriteNode])
    func addBullet(bullet: SKSpriteNode)
    func updateShipState(statusTexture: SKTexture?)
    func levelUpShip(level: SpaceShipLevel)
    func lostAllHearts()
}

protocol SpaceShip: AnyObject {
    var delegate: SpaceShipDelegate? { get set }
    var state: SpaceShipState { get set }
    var level: SpaceShipLevel { get set }
    var moveSpeed: CGFloat { get set }
    var hearts: [SKSpriteNode] { get set }
    var maxHitPoint: Int { get set }
    var bulletTimer: Timer? { get set }
    var timerForPowerItem: Timer? { get set }

    func getPosition() -> CGPoint
    func setPhysicsBody(categoryBitMask: UInt32, contactTestBitMask: UInt32?)
    func moveToPosition(touchPosition position: CGPoint)
    func powerUp(itemType: PowerItem.ItemType)
    func touchViewBegin(touchedViewFrame frame: CGRect)
}

extension SpaceShip {
    func setHitPoint(hitPoint: Int) {
        self.maxHitPoint = hitPoint
        for _ in 1...hitPoint {
            let heart = SKSpriteNode(imageNamed: "heart")
            heart.scale(to: CGSize(width: 70, height: 70))
            hearts.append(heart)
        }
        delegate?.displayHeart(hearts: hearts)
    }

    func damaged(_ enemy: Enemy? = nil) {
        if isShipState(equal: .stone) {
            enemy?.damaged()
            return
        }

        guard let heart = hearts.popLast() else {
            return
        }
        heart.removeFromParent()

        if hearts.isEmpty { delegate?.lostAllHearts() }
    }

    func isShipState(equal state: SpaceShipState) -> Bool {
        return self.state == state
    }

    func touchViewEnd() {
        bulletTimer?.invalidate()
    }
}

extension SpaceShip where Self: SKSpriteNode {
    func getPosition() -> CGPoint {
        return position
    }

    func moveToPosition(touchPosition position: CGPoint) {
        let movement = position - self.position
        self.position += movement * moveSpeed / 10
    }

    func powerUp(itemType: PowerItem.ItemType) {
        state.shipPowerUp(itemType: itemType)
        switch itemType {
        case .speed:
            let prevSpeed = moveSpeed
            moveSpeed *= 1.5
            timerForPowerItem = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { [weak self] _ in
                self?.moveSpeed = prevSpeed
                self?.state = .normal
            }
        case .stone:
            let prevSpeed = moveSpeed
            moveSpeed /= 2
            timerForPowerItem = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { [weak self] _ in
                self?.moveSpeed = prevSpeed
                self?.state = .normal
            }
        case .heal:
            if hearts.count >= maxHitPoint {
                return
            }
            let heart = SKSpriteNode(imageNamed: "heart")
            heart.scale(to: CGSize(width: 70, height: 70))
            hearts.append(heart)
            delegate?.displayHeart(hearts: hearts)
        case .level:
            level.levelUp()

            if hearts.count >= maxHitPoint {
                return
            }
            let heart = SKSpriteNode(imageNamed: "heart")
            heart.scale(to: CGSize(width: 70, height: 70))
            hearts.append(heart)
            delegate?.displayHeart(hearts: hearts)
        }
    }
}
