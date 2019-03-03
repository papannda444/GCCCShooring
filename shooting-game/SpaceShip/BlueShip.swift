//
//  BlueShip.swift
//  shooting-game
//
//  Created by papannda444 on 2019/03/03.
//  Copyright © 2019 三野田脩. All rights reserved.
//

import Foundation
import SpriteKit

class BlueShip: SKSpriteNode, SpaceShip {
    weak var delegate: SpaceShipDelegate?

    var state = SpaceShipState()
    var moveSpeed: CGFloat = 0.0
    var hearts: [SKSpriteNode] = []
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
        let texture = SKTexture(imageNamed: SpaceShipType.blue.rawValue)
        self.init(texture: texture, color: .clear, size: texture.size())
        self.moveSpeed = moveSpeed
        position = CGPoint(x: 0, y: -frame.height / 2 + self.frame.height)
        scale(to: CGSize(width: 80, height: 80))
    }

    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setPhysicsBody(categoryBitMask: UInt32, contactTestBitMask: UInt32) {
        physicsBody = SKPhysicsBody(circleOfRadius: frame.width / 2)
        physicsBody?.categoryBitMask = categoryBitMask
        physicsBody?.contactTestBitMask = contactTestBitMask
        physicsBody?.collisionBitMask = 0
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
            timerForPowerItem = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
                self?.powerUpTime = 0.0
                self?.moveSpeed = prevSpeed
            }
        case .stone:
            let prevSpeed = moveSpeed
            moveSpeed /= 2
            timerForPowerItem = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
                self?.powerUpTime = 0.0
                self?.moveSpeed = prevSpeed
            }
        }
    }

    func touchViewBegin(touchedViewFrame frame: CGRect) {
        bulletTimer?.invalidate()
        let moveToTop = SKAction.moveTo(y: frame.height + 10, duration: 0.3)
        let remove = SKAction.removeFromParent()
        delegate?.addBullet(bulletType: .blue, position: position, action: SKAction.sequence([moveToTop, remove]))
        bulletTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.delegate?.addBullet(bulletType: .blue,
                                      position: self?.position ?? .zero,
                                      action: SKAction.sequence([moveToTop, remove]))
        }
    }
}
