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

        init() {
            self = .red
        }
    }

    var type = BulletType()
    var level = SpaceShipLevel()

    convenience init(bulletType type: BulletType, bulletLevel level: SpaceShipLevel, position: CGPoint) {
        let texture = SKTexture(imageNamed: type.rawValue)
        self.init(texture: texture, color: .clear, size: texture.size())
        self.type = type
        self.level = level
        switch type {
        case .red:
            self.scale(to: CGSize(width: 60, height: 60))
        case .blue:
            self.scale(to: CGSize(width: 50, height: 50))
        case .yellow:
            self.scale(to: CGSize(width: 70, height: 70))
        case .purple:
            self.scale(to: CGSize(width: 40, height: 40))
        case .silver:
            self.scale(to: CGSize(width: 100, height: 100))
        case .pink:
            self.scale(to: CGSize(width: 30, height: 30))
        }
        self.position = CGPoint(x: position.x, y: position.y + 50)
    }

    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func contact(enemy: Enemy) {
        enemy.damaged()
        switch type {
        case .purple:
            enemy.poisoning(level: level.rawValue)
        case .silver:
            return
        default:
            break
        }
        removeFromParent()
    }
}
