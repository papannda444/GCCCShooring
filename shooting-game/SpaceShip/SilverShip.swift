//
//  SilverShip.swift
//  shooting-game
//
//  Created by papannda444 on 2019/03/03.
//  Copyright © 2019 三野田脩. All rights reserved.
//

import Foundation
import SpriteKit

class SilverShip: SKSpriteNode, SpaceShip {
    weak var delegate: SpaceShipDelegate?

    var state = SpaceShipState()
    var moveSpeed: CGFloat = 0.0
    var hearts: [SKSpriteNode] = []
    var maxHitPoint: Int = 0
    var bulletTimer: Timer?
    var timerForPowerItem: Timer?
    var powerUpTime: Float = 5.0 {
        didSet {
            if powerUpTime <= 0.0 {
                powerUpTime = 5.0
                timerForPowerItem?.invalidate()
                state = .normal
            }
        }
    }

    convenience init(moveSpeed: CGFloat, displayViewFrame frame: CGRect) {
        let texture = SKTexture(imageNamed: SpaceShipType.silver.rawValue)
        self.init(texture: texture, color: .clear, size: texture.size())
        self.moveSpeed = moveSpeed
        position = CGPoint(x: 0, y: frame.height / 2 - self.frame.height)
        scale(to: CGSize(width: 80, height: 80))
    }

    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func touchViewBegin(touchedViewFrame frame: CGRect) {
        bulletTimer?.invalidate()
        let moveToTop = SKAction.sequence([
            SKAction.moveTo(y: frame.height + 10, duration: 0.3),
            SKAction.removeFromParent()
        ])
        let bullet = Bullet(bulletType: .silver, position: position)
        bullet.run(moveToTop)
        delegate?.addBullet(bullet: bullet)
        bulletTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            let bullet = Bullet(bulletType: .silver, position: self?.position ?? .zero)
            bullet.run(moveToTop)
            self?.delegate?.addBullet(bullet: bullet)
        }
    }
}
