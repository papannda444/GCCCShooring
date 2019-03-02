//
//  Bullet.swift
//  shooting-game
//
//  Created by 三野田脩 on 2019/02/11.
//  Copyright © 2019 三野田脩. All rights reserved.
//

import Foundation
import SpriteKit

class Bullet: SKSpriteNode {
    enum BulletType: String {
        case red = "bullet_red"
        case blue = "bullet_blue"
        case yellow = "bullet_yellow"
        case purple = "bullet_purple"
        case silver = "bullet_silver"
        case pink = "bullet_pink"
    }

    var type: BulletType

    convenience init(bulletType type: BulletType, position: CGPoint) {
        let texture = SKTexture(imageNamed: type.rawValue)
        self.init(texture: texture, color: .clear, size: texture.size())
        self.type = type
        self.position = CGPoint(x: position.x, y: position.y + 50)
    }

    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        type = .red // default value, please to change convenience init
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
