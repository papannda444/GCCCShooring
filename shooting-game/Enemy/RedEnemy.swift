//
//  RedEnemy.swift
//  shooting-game
//
//  Created by papannda444 on 2019/03/04.
//  Copyright © 2019 三野田脩. All rights reserved.
//

import Foundation
import SpriteKit

class RedEnemy: SKSpriteNode, Enemy {
    weak var delegate: EnemyDelegate?

    var state = EnemyState()
    var enemyMove: [SKAction] = []
    var hitPoint: Int = 0
    var firstAttackTimer: Timer?
    var secondAttackTimer: Timer?
    var killPoint: Int = 20

    convenience init(moveSpeed: CGFloat, displayViewFrame frame: CGRect) {
        let texture = SKTexture(imageNamed: EnemyType.red.rawValue)
        self.init(texture: texture, color: .clear, size: texture.size())
        scale(to: CGSize(width: 70, height: 70))
    }

    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func startMove() {
        guard let action = enemyMove.randomElement() else {
            return
        }
        run(action)

        firstAttackTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { [weak self] _ in
            let bullet = EnemyBullet(enemyType: .red, position: self?.position ?? .zero)
            self?.delegate?.enemyAttack(bullet: bullet)
        }
        secondAttackTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { [weak self] _ in
            let bullet = EnemyBullet(enemyType: .red, position: self?.position ?? .zero)
            self?.delegate?.enemyAttack(bullet: bullet)
        }
    }
}
