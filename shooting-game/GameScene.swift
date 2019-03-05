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

    var powerItemTimer: Timer?

    var asteroidTimer: Timer?
    var timerForAsteroud: Timer?
    var asteroudDuration: TimeInterval = 6.0 {
        didSet {
            if asteroudDuration < 2.0 {
                timerForAsteroud?.invalidate()
            }
        }
    }
    var score: Int = 0 {
        didSet {
            scoreLabel?.text = "Score: \(score)"
        }
    }

    var spaceship: SpaceShip!
    var shipType = SpaceShipType()
    var scoreLabel: SKLabelNode?
    var timeLabel: SKLabelNode?
    var touchPosition: CGPoint?

    let planets = ["enemy_red", "enemy_yellow"]
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
            spaceship = RedShip(moveSpeed: 2, displayViewFrame: frame)
        case .blue:
            spaceship = BlueShip(moveSpeed: 2, displayViewFrame: frame)
        case .yellow:
            spaceship = YellowShip(moveSpeed: 3, displayViewFrame: frame)
        case .purple:
            spaceship = PurpleShip(moveSpeed: 1.5, displayViewFrame: frame)
        case .silver:
            spaceship = SilverShip(moveSpeed: 1, displayViewFrame: frame)
        case .pink:
            spaceship = PinkShip(moveSpeed: 1, displayViewFrame: frame)
        }
        spaceship.delegate = self
        spaceship.setHitPoint(hitPoint: 5)
        spaceship.setPhysicsBody(categoryBitMask: spaceshipCategory, contactTestBitMask: enemyCategory + powerItemCategory)
        addChild(spaceship as! SKNode)

        asteroidTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true ) { _ in
            self.addAsteroid()
        }
        timerForAsteroud = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            self.asteroudDuration -= 0.5
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
        spaceship.touchViewBegin(touchedViewFrame: frame)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchPosition = convertPoint(fromView: touches.first!.location(in: view))
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isPaused { gameSceneClose() }
        touchPosition = nil
        spaceship.touchViewEnd()
    }

    override func update(_ currentTime: TimeInterval) {
        guard let position = touchPosition else {
            return
        }
        spaceship.moveToPosition(touchPosition: position)
    }

    func gameEnd() {
        isPaused = true
        asteroidTimer?.invalidate()
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

    func addAsteroid() {
        let name = planets.randomElement()!
        let asteroid = SKSpriteNode(imageNamed: name)
        let positionX = frame.width * (CGFloat.random(in: 0...1) - 0.5)
        asteroid.position = CGPoint(x: positionX, y: frame.height / 2 + asteroid.frame.height)
        asteroid.scale(to: CGSize(width: 70, height: 70))
        asteroid.physicsBody = SKPhysicsBody(circleOfRadius: asteroid.frame.width / 2)
        asteroid.physicsBody?.categoryBitMask = enemyCategory
        asteroid.physicsBody?.contactTestBitMask = bulletCategory + spaceshipCategory
        asteroid.physicsBody?.collisionBitMask = 0
        addChild(asteroid)

        let move = SKAction.moveTo(y: -frame.height / 2 - asteroid.frame.height, duration: asteroudDuration)
        let remove = SKAction.removeFromParent()
        asteroid.run(SKAction.sequence([move, remove]))
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
            spaceship.powerUp(itemType: item.type)
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
            guard let heart = spaceship.hearts.popLast() else {
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
