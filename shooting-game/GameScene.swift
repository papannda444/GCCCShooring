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
    var shipLevelLabel: SKLabelNode?
    var shipStatusLabel: SKSpriteNode?
    var touchPosition: CGPoint?

    let pausedScene = SKNode()
    let nonPausedScene = SKNode()

    let enemyTypes: [EnemyType] = [.red, .yellow]
    let itemTypes: [PowerItem.ItemType] = [
        .speed, .speed, .speed,
        .stone, .stone, .stone,
        .heal, .heal, //回復アイテムの出現率低め
        .level, .level //レベルアップアイテムの出現率低め
    ]

    let spaceshipCategory: UInt32   = 0b00001
    let bulletCategory: UInt32      = 0b00010
    let powerItemCategory: UInt32   = 0b00100
    let enemyCategory: UInt32       = 0b01000
    let enemyBulletCategory: UInt32 = 0b10000

    override func didMove(to view: SKView) {
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self
        addChild(pausedScene)
        addChild(nonPausedScene)

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
        spaceShip.setPhysicsBody(categoryBitMask: spaceshipCategory, contactTestBitMask: enemyCategory + enemyBulletCategory + powerItemCategory)
        pausedScene.addChild(spaceShip as! SKNode)

        enemyTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true ) { _ in
            self.addEnemy()
        }
        powerItemTimer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { _ in
            self.addPowerItem()
        }

        let score = SKLabelNode(text: "Score: 0")
        score.fontName = "Papyrus"
        score.fontSize = 50
        score.position = CGPoint(x: -frame.width / 2 + score.frame.width / 2 + 50,
                                 y: frame.height / 2 - score.frame.height * 4)
        addChild(score)
        scoreLabel = score

        let time = SKLabelNode(text: "\(String(format: "time: %.2f", clearTime))")
        time.fontName = "Times New Roman"
        time.fontSize = 40
        time.position = CGPoint(x: 0, y: frame.height / 2 - time.frame.height)
        addChild(time)
        timeLabel = time

        let level = SKLabelNode(text: "Lv: 1")
        level.fontName = "Papyrus"
        level.fontSize = 70
        level.position = CGPoint(x: frame.width / 2 - level.frame.width,
                                 y: frame.height / 2 - level.frame.height * 1.5)
        addChild(level)
        shipLevelLabel = level

        let status = SKSpriteNode(imageNamed: "")
        status.isHidden = true
        status.scale(to: CGSize(width: 80, height: 80))
        status.position = CGPoint(x: frame.width / 2 - status.frame.width,
                                  y: frame.height / 2 - status.frame.height - level.frame.height * 1.5)
        addChild(status)
        shipStatusLabel = status

        gameClearTimer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [weak self] _ in
            self?.clearTime -= 0.01
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if pausedScene.isPaused { gameSceneClose() }
        touchPosition = convertPoint(fromView: touches.first!.location(in: view))
        spaceShip.touchViewBegin(touchedViewFrame: frame)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchPosition = convertPoint(fromView: touches.first!.location(in: view))
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchPosition = nil
        spaceShip.touchViewEnd()
    }

    override func update(_ currentTime: TimeInterval) {
        if pausedScene.isPaused {
            spaceShip.touchViewEnd()
            return
        }
        guard let position = touchPosition else {
            return
        }
        spaceShip.moveToPosition(touchPosition: position)
    }

    func gameEnd() {
        pausedScene.isPaused = true
        enemyTimer?.invalidate()
        powerItemTimer?.invalidate()
        gameClearTimer?.invalidate()
        pausedScene.children.compactMap { $0 as? Enemy }.forEach { $0.invalidateAttackTimer() }
        pausedScene.children.compactMap { $0 as? EnemyBullet }.forEach { $0.moveTimer?.invalidate() }
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

        var confetti: [SKNode?] = []
        confetti.append(SKEmitterNode(fileNamed: "ConfettiBlue"))
        confetti.append(SKEmitterNode(fileNamed: "ConfettiGreen"))
        confetti.append(SKEmitterNode(fileNamed: "ConfettiOrange"))
        confetti.append(SKEmitterNode(fileNamed: "ConfettiPink"))
        confetti.append(SKEmitterNode(fileNamed: "ConfettiRed"))
        confetti.append(SKEmitterNode(fileNamed: "ConfettiYellow"))
        confetti.compactMap { $0 }.forEach {
            $0.position = CGPoint(x: 0, y: frame.height / 2)
            nonPausedScene.addChild($0)
        }
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
            enemy.setHitPoint(hitPoint: 3)
        case .yellow:
            enemy = YellowEnemy(moveSpeed: 2, displayViewFrame: frame)
            enemy.setHitPoint(hitPoint: 3)
        case .blue:
            enemy = RedEnemy(moveSpeed: 2, displayViewFrame: frame)
            enemy.setHitPoint(hitPoint: 3)
        }
        enemy.delegate = self
        enemy.setPhysicsBody(categoryBitMask: enemyCategory)
        enemy.createEnemyMovement(displayViewFrame: frame)
        enemy.startMove()
        pausedScene.addChild(enemy as! SKNode)
    }

    func addPowerItem(_ powerItem: PowerItem? = nil) {
        let type = itemTypes.randomElement()!
        let item = powerItem ?? PowerItem(itemType: type, addedViewFrame: frame)
        item.setPhysicsBody(categoryBitMask: powerItemCategory)
        pausedScene.addChild(item)
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

    func addBullet(bullet: SKSpriteNode) {
        bullet.setPhysicsBody(categoryBitMask: bulletCategory, contactTestBitMask: enemyCategory + powerItemCategory)
        pausedScene.addChild(bullet)
    }

    func updateShipState(statusTexture: SKTexture?) {
        guard let texture = statusTexture else {
            shipStatusLabel?.isHidden = true
            return
        }
        shipStatusLabel?.run(SKAction.setTexture(texture))
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.shipStatusLabel?.isHidden = false
        }
    }

    func levelUpShip(level: SpaceShipLevel) {
        shipLevelLabel?.text = "Lv: \(level.rawValue)"
        switch level {
        case .one:
            shipLevelLabel?.fontColor = .white
        case .two:
            shipLevelLabel?.fontColor = .yellow
        case .three:
            shipLevelLabel?.fontColor = .orange
        }
    }

    func lostAllHearts() {
        gameOver()
    }

    func startSpecialAttack(spaceShip: SpaceShip) {
        switch spaceShip {
        case is BlueShip:
            spaceShip.setPhysicsBody(categoryBitMask: spaceshipCategory, contactTestBitMask: powerItemCategory)
        default:
            break
        }
    }
}

extension GameScene: EnemyDelegate {
    func enemyAttack(bullet: EnemyBullet) {
        bullet.setPhysicsBody(categoryBitMask: enemyBulletCategory)
        bullet.startMove(shipPosition: spaceShip.getPosition())
        pausedScene.addChild(bullet)
    }

    func killedEnemy(score: Int) {
        self.score += score
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
            if let enemyBullet = affectToShip.node as? EnemyBullet {
                enemyBullet.removeFromParent()
                ship.damaged()
            } else if let enemy = affectToShip.node as? Enemy {
                ship.damaged(enemy)
            }
        } else if let bullet = shipContent.node as? Bullet {
            bullet.removeFromParent()
            if let enemy = affectToShip.node as? Enemy {
                enemy.damaged()
            }
        }
    }
}
