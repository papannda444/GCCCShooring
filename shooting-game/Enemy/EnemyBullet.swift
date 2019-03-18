//
//  EnemyBullet.swift
//  shooting-game
//
//  Created by papannda444 on 2019/03/11.
//  Copyright © 2019 三野田脩. All rights reserved.
//

import Foundation
import SpriteKit

class EnemyBullet: SKSpriteNode {
    var enemyType = EnemyType()
    var moveTimer: Timer?
    var viewFrame = CGRect()

    convenience init(enemyType type: EnemyType, position: CGPoint, displayedViewFrame frame: CGRect) {
        let texture = SKTexture(imageNamed: "enemy_bullet")
        self.init(texture: texture, color: .clear, size: texture.size())
        enemyType = type
        viewFrame = frame
        scale(to: CGSize(width: 30, height: 30))
        self.position = CGPoint(x: position.x, y: position.y)
    }

    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func startMove(shipPosition: CGPoint) {
        let movement = shipPosition - self.position
        moveTimer = Timer.scheduledTimer(withTimeInterval: 1 / 60, repeats: true) { _ in
            self.moveToShip(movement: movement)
        }
    }

    private func moveToShip(movement: CGPoint) {
        if position.y < viewFrame.minY || viewFrame.maxY < position.y ||
            position.x < viewFrame.minX || viewFrame.maxX < position.x {
            removeFromParent()
        }
        position += movement.unit * 5
    }
}
