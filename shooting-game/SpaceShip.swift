//
//  SpaceShip.swift
//  shooting-game
//
//  Created by 三野田脩 on 2019/02/11.
//  Copyright © 2019 三野田脩. All rights reserved.
//

import Foundation
import SpriteKit

protocol SpaceShipDelegate: AnyObject {
    func displayHeart(hearts: [SKSpriteNode])
    func addBullet()
}

class SpaceShip: SKSpriteNode {
    enum ShipType: String {
        case red
        case blue
        case yellow
    }

    enum ShipState: String {
        case normal
        case speed
        case stone

        init() {
            self = .normal
        }

        mutating func shipPowerUp(itemType: PowerItem.ItemType) {
            switch itemType {
            case .speed:
                self = .speed
            case .stone:
                self = .stone
            }
        }
    }

    var type: ShipType
    var state: ShipState
    var moveSpeed: CGFloat
    var viewFrame: CGRect
    var hearts: [SKSpriteNode] = []
    weak var delegate: SpaceShipDelegate?

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

    convenience init(shipType type: ShipType, moveSpeed: CGFloat, addedViewFrame: CGRect) {
        let texture = SKTexture(imageNamed: type.rawValue)
        self.init(texture: texture, color: .clear, size: texture.size())
        self.type = type
        self.moveSpeed = moveSpeed
        self.viewFrame = addedViewFrame
        scale(to: CGSize(width: viewFrame.width / 5, height: viewFrame.width / 5))
        position = CGPoint(x: 0, y: -viewFrame.height / 2 + frame.height)
    }

    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        state = ShipState()

        type = .red // default value, please to change convenience init
        moveSpeed = 0.0
        viewFrame = CGRect.zero
        super.init(texture: texture, color: color, size: size)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setHitPoint(hitPoint: Int) {
        for index in 1...hitPoint {
            let heart = SKSpriteNode(imageNamed: "heart")
            heart.position = CGPoint(x: -viewFrame.width / 2 + heart.frame.height * CGFloat(index), y: viewFrame.height / 2 - heart.frame.height)
            hearts.append(heart)
        }
        guard let delegate = delegate else {
            return
        }
        delegate.displayHeart(hearts: hearts)
    }

    func setPhysicsBody(categoryBitMask: UInt32, contactTestBitMask: UInt32) {
        physicsBody = SKPhysicsBody(circleOfRadius: frame.width * 0.1)
        physicsBody?.categoryBitMask = categoryBitMask
        physicsBody?.contactTestBitMask = contactTestBitMask
        physicsBody?.collisionBitMask = 0
    }

    func moveToPosition(touchPosition position: CGPoint) {
        let movement = position - self.position
        self.position += movement * moveSpeed / 5
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

    func isShipState(equal state: SpaceShip.ShipState) -> Bool {
        return self.state == state
    }
}
