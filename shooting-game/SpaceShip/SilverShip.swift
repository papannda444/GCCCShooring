//
//  SilverShip.swift
//  shooting-game
//
//  Created by papannda444 on 2019/03/03.
//  Copyright © 2019 三野田脩. All rights reserved.
//

import Foundation
import SpriteKit

class SilverShip: SKSpriteNode {
    weak var delegate: SpaceShipDelegate?

    var state = SpaceShipState() {
        didSet {
            let statusTexture: SKTexture?
            switch state {
            case .normal:
                statusTexture = nil
            default:
                // state is .speed or .stone
                statusTexture = SKTexture(imageNamed: state.rawValue)
            }

            delegate?.updateShipState(statusTexture: statusTexture)
        }
    }
    var level = SpaceShipLevel() {
        didSet {
            delegate?.levelUpShip(level: level)
        }
    }
    var moveSpeed: CGFloat = 0.0
    var hearts: [SKSpriteNode] = []
    var maxHitPoint: Int = 0
    var bulletTimer: Timer?
    var timerForPowerItem: Timer?

    convenience init(moveSpeed: CGFloat, displayViewFrame frame: CGRect) {
        let texture = SKTexture(imageNamed: SpaceShipType.silver.rawValue)
        self.init(texture: texture, color: .clear, size: texture.size())
        self.moveSpeed = moveSpeed
        position = CGPoint(x: 0, y: frame.height / 2 - self.frame.height)
        scale(to: CGSize(width: 120, height: 120))
        physicsBody = SKPhysicsBody(circleOfRadius: self.frame.width / 4)
    }

    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SilverShip: SpaceShip {
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

    func touchViewBegin(touchedViewFrame frame: CGRect) {
        bulletTimer?.invalidate()
        let duration: Double
        switch level {
        case .one:
            duration = 3.0
        case .two:
            duration = 2.0
        case .three:
            duration = 1.0
        }
        let moveToTop = SKAction.sequence([
            SKAction.moveTo(y: frame.height + 10, duration: duration),
            SKAction.removeFromParent()
        ])
        moveToTop.timingMode = .easeIn
        let transformHuge = SKAction.scale(by: 3, duration: duration)
        let bullet = Bullet(bulletType: .silver, bulletLevel: level, position: position)
        bullet.run(.group([moveToTop, transformHuge]))
        delegate?.addBullet(bullet: bullet)
        bulletTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self, level] _ in
            let bullet = Bullet(bulletType: .silver, bulletLevel: level, position: self?.position ?? .zero)
            bullet.run(.group([moveToTop, transformHuge]))
            self?.delegate?.addBullet(bullet: bullet)
        }
    }
}
