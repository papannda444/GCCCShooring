//
//  BlueEnemy.swift
//  shooting-game
//
//  Created by papannda444 on 2019/07/08.
//  Copyright © 2019 三野田脩. All rights reserved.
//

import Foundation
import SpriteKit

class BlueEnemy: SKSpriteNode {
    weak var delegate: EnemyDelegate?

    var state = EnemyState()
    var enemyMove: [SKAction] = []
    var hitPoint: Int = 0
    var firstAttackTimer: Timer?
    var secondAttackTimer: Timer?
    var poisonDamageTimer: Timer?
    var pointTimer: Timer?
    var killPoint: Int = 10

    convenience init(moveSpeed: CGFloat, displayViewFrame frame: CGRect) {
        let texture = SKTexture(imageNamed: EnemyType.blue.rawValue)
        self.init(texture: texture, color: .clear, size: texture.size())
        scale(to: CGSize(width: 70, height: 70))
        firstAttackTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { [weak self] _ in
            let bullet = EnemyBullet(enemyType: .blue, position: self?.position ?? .zero, displayedViewFrame: frame)
            self?.delegate?.enemyAttack(bullet: bullet)
        }
        secondAttackTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { [weak self] _ in
            let bullet = EnemyBullet(enemyType: .blue, position: self?.position ?? .zero, displayedViewFrame: frame)
            self?.delegate?.enemyAttack(bullet: bullet)
        }
        pointTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.killPoint -= 2
            if self?.killPoint ?? 0 <= 4 {
                self?.pointTimer?.invalidate()
            }
        }
    }

    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension BlueEnemy: Enemy {
    func startMove() {
        guard let action = enemyMove.randomElement() else {
            return
        }
        run(action)
    }
}
