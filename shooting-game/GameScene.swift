//
//  GameScene.swift
//  shooting-game
//
//  Created by 三野田脩 on 2018/12/23.
//  Copyright © 2018 三野田脩. All rights reserved.
//

import CoreMotion
import GameplayKit
import SpriteKit

class GameScene: SKScene {
    var gameSceneClose: () -> Void = {}

    var gameClearTimer: Timer?
    var clearTime: TimeInterval = 100.00 {
        didSet {
            timeLabel?.text = "\(String(format: "time: %.2f", clearTime))"
            if clearTime <= 0 {
                timeLabel?.text = "\(String(format: "time: %.2f", 0.00))"
                gameClear()
            }
        }
    }

    var enemyTimer: Timer?
    var powerItemTimer: Timer?

    var score: Int = 0 {
        didSet {
            scoreLabel?.text = "Score: \(score)"
        }
    }

    var spaceShip: SpaceShip!
    var shipType = SpaceShipType()
    var scoreLabel: SKLabelNode?
    var timeLabel: SKLabelNode?
    var touchPosition: CGPoint?

    let enemyTypes: [EnemyType] = [.red, .yellow]
    let itemTypes: [PowerItem.ItemType] = [
        .speed, .speed, .speed,
        .stone, .stone, .stone,
        .heal   //回復アイテムの出現率低め
    ]

    let spaceshipCategory: UInt32   = 0b00001
    let bulletCategory: UInt32      = 0b00010
    let powerItemCategory: UInt32   = 0b00100
    let enemyCategory: UInt32       = 0b01000
    let enemyBulletCategory: UInt32 = 0b10000

    override func didMove(to view: SKView) {
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self

        switch shipType {
        case .red:
            spaceShip = RedShip(moveSpeed: 2, displayViewFrame: frame)
        case .blue:
            spaceShip = BlueShip(moveSpeed: 2, displayViewFrame: frame)
        case .yellow:
            spaceShip = YellowShip(moveSpeed: 3, displayViewFrame: frame)
        case .purple:
            spaceShip = PurpleShip(moveSpeed: 1.5, displayViewFrame: frame)
        case .silver:
            spaceShip = SilverShip(moveSpeed: 1, displayViewFrame: frame)
        case .pink:
            spaceShip = PinkShip(moveSpeed: 1, displayViewFrame: frame)
        }
        spaceShip.delegate = self
        spaceShip.setHitPoint(hitPoint: 5)
        spaceShip.setPhysicsBody(categoryBitMask: spaceshipCategory, contactTestBitMask: enemyCategory + powerItemCategory)
        addChild(spaceShip as! SKNode)

        enemyTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true ) { _ in
            self.addEnemy()
        }
        powerItemTimer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { _ in
            self.addPowerItem()
        }

        let score = SKLabelNode(text: "Score: 0")
        score.fontName = "Papyrus"
        score.fontSize = 50
        score.position = CGPoint(x: -frame.width / 2 + score.frame.width / 2 + 50, y: frame.height / 2 - score.frame.height * 5)
        addChild(score)
        scoreLabel = score

        let time = SKLabelNode(text: "\(String(format: "time: %.2f", clearTime))")
        time.fontName = "Times New Roman"
        time.fontSize = 40
        time.position = CGPoint(x: 0, y: frame.height / 2 - time.frame.height)
        addChild(time)
        timeLabel = time

        gameClearTimer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [weak self] _ in
            self?.clearTime -= 0.01
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchPosition = convertPoint(fromView: touches.first!.location(in: view))
        spaceShip.touchViewBegin(touchedViewFrame: frame)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchPosition = convertPoint(fromView: touches.first!.location(in: view))
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isPaused { gameSceneClose() }
        touchPosition = nil
        spaceShip.touchViewEnd()
    }

    override func update(_ currentTime: TimeInterval) {
        guard let position = touchPosition else {
            return
        }
        spaceShip.moveToPosition(touchPosition: position)
    }

    func gameEnd() {
        isPaused = true
        enemyTimer?.invalidate()
        powerItemTimer?.invalidate()
        gameClearTimer?.invalidate()
        let bestScore = UserDefaults.standard.integer(forKey: "bestScore")
        if score > bestScore {
            UserDefaults.standard.set(score, forKey: "bestScore")
        }
        let currentScore = UserDefaults.standard.integer(forKey: "currentScore")
        if score > currentScore {
            UserDefaults.standard.set(score, forKey: "currentScore")
        }
    }

    func gameClear() {
        gameEnd()

        let gameOverLabel = SKLabelNode(text: "Game Clear")
        gameOverLabel.fontName = "Papyrus"
        gameOverLabel.fontSize = 100
        gameOverLabel.fontColor = .blue
        gameOverLabel.position = CGPoint.zero
        addChild(gameOverLabel)

        let touchScreenLabel = SKLabelNode(text: "Touch Screen")
        touchScreenLabel.fontName = "Papyrus"
        touchScreenLabel.fontSize = 50
        touchScreenLabel.position = CGPoint(x: 0, y: -gameOverLabel.frame.height)
        addChild(touchScreenLabel)
    }

    func gameOver() {
        gameEnd()

        let gameOverLabel = SKLabelNode(text: "Game Over")
        gameOverLabel.fontName = "Papyrus"
        gameOverLabel.fontSize = 100
        gameOverLabel.fontColor = .red
        gameOverLabel.position = CGPoint.zero
        addChild(gameOverLabel)

        let touchScreenLabel = SKLabelNode(text: "Touch Screen")
        touchScreenLabel.fontName = "Papyrus"
        touchScreenLabel.fontSize = 50
        touchScreenLabel.position = CGPoint(x: 0, y: -gameOverLabel.frame.height)
        addChild(touchScreenLabel)
    }

    func addEnemy() {
        let name = enemyTypes.randomElement()!
        var enemy: Enemy
        switch name {
        case .red:
            enemy = RedEnemy(moveSpeed: 2, displayViewFrame: frame)
            enemy.setHitPoint(hitPoint: 2)
        case .yellow:
            enemy = YellowEnemy(moveSpeed: 2, displayViewFrame: frame)
            enemy.setHitPoint(hitPoint: 2)
        case .blue:
            enemy = RedEnemy(moveSpeed: 2, displayViewFrame: frame)
            enemy.setHitPoint(hitPoint: 2)
        }
        enemy.setPhysicsBody(categoryBitMask: enemyCategory, contactTestBitMask: bulletCategory + spaceshipCategory)
        enemy.createEnemyMovement(displayViewFrame: frame)
        guard let enemyNode = enemy as? SKNode else {
            return
        }
        addChild(enemyNode)
        enemyNode.run(enemy.enemyMove.randomElement()!)
    }

    func addPowerItem() {
        let type = itemTypes.randomElement()!
        let item = PowerItem(itemType: type, addedViewFrame: frame)
        item.setPhysicsBody(categoryBitMask: powerItemCategory, contactTestBitMask: spaceshipCategory + bulletCategory)
        addChild(item)

        let move = SKAction.moveTo(y: -frame.height / 2 - item.frame.height, duration: 5.0)
        let remove = SKAction.removeFromParent()
        item.run(SKAction.sequence([move, remove]))
    }
}

extension GameScene: SpaceShipDelegate {
    func displayHeart(hearts: [SKSpriteNode]) {
        for (index, heart) in hearts.enumerated() {
            if heart.inParentHierarchy(self) {
                continue
            }
            heart.position = CGPoint(x: -frame.width / 2 + heart.frame.height * CGFloat(index + 1), y: frame.height / 2 - heart.frame.height)
            addChild(heart)
        }
    }

    func addBullet(bulletType: Bullet.BulletType, position: CGPoint, _ positions: CGPoint..., action: SKAction) {
        let bullet = Bullet(bulletType: bulletType, position: position)
        bullet.setPhysicsBody(categoryBitMask: bulletCategory, contactTestBitMask: enemyCategory + powerItemCategory)
        bullet.run(action)
        addChild(bullet)
        if positions.isEmpty {
            return
        }
        for position in positions {
            let bullet = Bullet(bulletType: bulletType, position: position)
            bullet.setPhysicsBody(categoryBitMask: bulletCategory, contactTestBitMask: enemyCategory + powerItemCategory)
            bullet.run(action)
            addChild(bullet)
        }
    }
}

extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        var shipContent: SKPhysicsBody
        var affectToShip: SKPhysicsBody

        if contact.bodyA.categoryBitMask & (spaceshipCategory | bulletCategory) != 0 {
            shipContent = contact.bodyA
            affectToShip = contact.bodyB
        } else {
            shipContent = contact.bodyB
            affectToShip = contact.bodyA
        }

        if let item = affectToShip.node as? PowerItem {
            affectToShip.node?.removeFromParent()
            if let bullet = shipContent.node as? Bullet {
                bullet.removeFromParent()
            }
            spaceShip.powerUp(itemType: item.type)
            return
        }

        if let ship = shipContent.node as? SpaceShip {
            affectToShip.node?.removeFromParent()
            //爆発の処理をエネミー側で行いたい
            guard let enemyNode = affectToShip.node,
                let explosion = SKEmitterNode(fileNamed: "Explosion") else {
                    return
            }
            explosion.position = enemyNode.position
            addChild(explosion)
            run(SKAction.wait(forDuration: 1.0)) {
                explosion.removeFromParent()
            }
            //下記の処理をスペースシップ側で行いたい
            if ship.isShipState(equal: .stone) {
                score += 5
                return
            }
            guard let heart = spaceShip.hearts.popLast() else {
                return
            }
            heart.removeFromParent()
            if ship.hearts.isEmpty { gameOver() }
        } else if let bullet = shipContent.node as? Bullet {
            score += 5
            bullet.removeFromParent()
            affectToShip.node?.removeFromParent()
            guard let enemyNode = affectToShip.node,
                let explosion = SKEmitterNode(fileNamed: "Explosion") else {
                    return
            }
            explosion.position = enemyNode.position
            addChild(explosion)
            run(SKAction.wait(forDuration: 1.0)) {
                explosion.removeFromParent()
            }
        }
    }
}
