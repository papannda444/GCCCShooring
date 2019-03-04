//
//  YellowEnemy.swift
//  shooting-game
//
//  Created by papannda444 on 2019/03/04.
//  Copyright © 2019 三野田脩. All rights reserved.
//

import Foundation
import SpriteKit

class YellowEnemy: SKSpriteNode, Enemy {
    var state = EnemyState()
    var enemyMove: [SKAction] = []
    var hitPoint: Int = 0
    var attackTimer: Timer?
    var killPoint: Int = 20

    convenience init(moveSpeed: CGFloat, displayViewFrame frame: CGRect) {
        let texture = SKTexture(imageNamed: EnemyType.yellow.rawValue)
        self.init(texture: texture, color: .clear, size: texture.size())
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
}
