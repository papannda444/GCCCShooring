//
//  SpaceShipProtocol.swift
//  shooting-game
//
//  Created by papannda444 on 2019/03/03.
//  Copyright © 2019 三野田脩. All rights reserved.
//

import Foundation
import SpriteKit

protocol Spaceship {
    var state: SpaceShipState { get set }
    var moveSpeed: CGFloat { get set }
    var viewFrame: CGRect { get set }
    var hearts: [SKSpriteNode] { get set }
    var delegate: SpaceShipDelegate? { get set }
    var timerForPowerItem: Timer? { get set }
    var powerUpTime: Float { get set }

    func setPhysicsBody(categoryBitMask: UInt32, contactTestBitMask: UInt32)
    func moveToPosition(touchPosition position: CGPoint)
    func powerUp(itemType: PowerItem.ItemType)
}

extension Spaceship {
    mutating func setHitPoint(hitPoint: Int) {
        for index in 1...hitPoint {
            let heart = SKSpriteNode(imageNamed: "heart")
            heart.scale(to: CGSize(width: viewFrame.width / 10, height: viewFrame.width / 10))
            heart.position = CGPoint(x: -viewFrame.width / 2 + heart.frame.height * CGFloat(index), y: viewFrame.height / 2 - heart.frame.height)
            hearts.append(heart)
        }
        guard let delegate = delegate else {
            return
        }
        delegate.displayHeart(hearts: hearts)
    }
}
