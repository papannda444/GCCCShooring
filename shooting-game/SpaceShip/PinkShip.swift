//
//  PinkShip.swift
//  shooting-game
//
//  Created by papannda444 on 2019/03/03.
//  Copyright © 2019 三野田脩. All rights reserved.
//

import Foundation
import SpriteKit

class PinkShip: SKSpriteNode {
    weak var delegate: SpaceShipDelegate?

    var state = SpaceShipState() {
        didSet {
            let statusTexture: SKTexture?
            switch state {
            case .normal:
                statusTexture = nil
            default:
                // state is .speed or .stone
                statusTexture = SKTexture(imageNamed: state.rawValue)
            }

            delegate?.updateShipState(statusTexture: statusTexture)
        }
    }
    var level = SpaceShipLevel() {
        didSet {
            delegate?.levelUpShip(level: level)
            switch level {
            case .one:
                maxWarpCount = 3
            case .two:
                maxWarpCount = 4
            case .three:
                maxWarpCount = 5
            }
            reuseWarp()
        }
    }
    var moveSpeed: CGFloat = 0.0
    var hearts: [SKSpriteNode] = []
    var maxHitPoint: Int = 0
    var bulletTimer: Timer?
    var timerForPowerItem: Timer?
    var warps: [SKSpriteNode] = []
    var maxWarpCount: Int = 3

    convenience init(moveSpeed: CGFloat, displayViewFrame frame: CGRect) {
        let texture = SKTexture(imageNamed: SpaceShipType.pink.rawValue)
        self.init(texture: texture, color: .clear, size: texture.size())
        self.moveSpeed = moveSpeed
        position = CGPoint(x: 0, y: frame.height / 2 - self.frame.height)
        scale(to: CGSize(width: 70, height: 70))
        physicsBody = SKPhysicsBody(circleOfRadius: self.frame.width / 4)

        let moveToTop = SKAction.sequence([
            SKAction.moveTo(y: frame.height + 10, duration: 0.4),
            SKAction.removeFromParent()
        ])
        let bullet = Bullet(bulletType: .pink, bulletLevel: level, position: position)
        bullet.run(moveToTop)
        delegate?.addBullet(bullet: bullet)
        bulletTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { [weak self, level] _ in
            let bullet = Bullet(bulletType: .pink, bulletLevel: level, position: self?.position ?? .zero)
            bullet.run(moveToTop)
            self?.delegate?.addBullet(bullet: bullet)
        }
    }

    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func touchViewBegin(touchPosition position: CGPoint) {
        guard let warp = warps.popLast() else {
            return
        }
        warp.position = self.position
        self.position = position
        warp.physicsBody?.contactTestBitMask = physicsBody?.contactTestBitMask ?? 0
        warp.run(.repeatForever(.rotate(byAngle: .degreeToRadian(degree: -360), duration: 2.0)))
    }

    func setWarps() {
        for _ in 1...maxWarpCount {
            let warp = SKSpriteNode(imageNamed: "warp")
            warp.scale(to: CGSize(width: 70, height: 70))
            warps.append(warp)
        }
        delegate?.displayNodes(kind: .warp, nodes: warps)
    }

    func reuseWarp() {
        if warps.count >= maxWarpCount {
            return
        }
        let warp = SKSpriteNode(imageNamed: "warp")
        warp.scale(to: CGSize(width: 70, height: 70))
        warps.append(warp)
        delegate?.displayNodes(kind: .warp, nodes: warps)
    }
}

extension PinkShip: SpaceShip {
    func damaged(_ enemy: Enemy? = nil) {
        if isShipState(equal: .stone) {
            enemy?.damaged()
            delegate?.scoreUp(of: 1)
            return
        }

        guard let heart = hearts.popLast() else {
            return
        }
        heart.removeFromParent()

        if hearts.isEmpty { delegate?.lostAllHearts() }
    }

    func touchViewBegin(touchedViewFrame frame: CGRect) {
    }
}
