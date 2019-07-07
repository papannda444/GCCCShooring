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

    var touchEndGameTimer: Timer?
    var isTouchEndGame: Bool = false

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

    let enemyTypes: [EnemyType] = [.red, .yellow, .blue]
    let itemTypes: [PowerItem.ItemType] = [
        .speed, .speed, .speed,
        .stone, .stone, .stone,
        .heal, .heal //回復アイテムの出現率低め
    ]

    let spaceshipCategory: UInt32   = 0b000001
    let bulletCategory: UInt32      = 0b000010
    let powerItemCategory: UInt32   = 0b000100
    let warpCategory: UInt32        = 0b001000
    let enemyCategory: UInt32       = 0b010000
    let enemyBulletCategory: UInt32 = 0b100000

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
            spaceShip = PinkShip(moveSpeed: 0, displayViewFrame: frame)
        }
        spaceShip.delegate = self
        spaceShip.setHitPoint(hitPoint: 5)
        if let pink = spaceShip as? PinkShip {
            pink.setWarps()
        }
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
        if pausedScene.isPaused {
            if !isTouchEndGame {
                return
            }
            gameSceneClose()
        }
        touchPosition = convertPoint(fromView: touches.first!.location(in: view))
        spaceShip.touchViewBegin(touchPosition: touchPosition!, touchedViewFrame: frame)
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
        touchEndGameTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { [weak self] _ in
            self?.isTouchEndGame = true
        }
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
            enemy = BlueEnemy(moveSpeed: 2, displayViewFrame: frame)
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
    func displayNodes(kind: DisplayNodes, nodes: [SKSpriteNode]) {
        for (index, node) in nodes.enumerated() {
            if node.inParentHierarchy(self) {
                continue
            }
            switch kind {
            case .heart:
                node.position = CGPoint(x: -frame.width / 2 + node.frame.height * CGFloat(index + 1),
                                        y: frame.height / 2 - node.frame.height)
            case .warp:
                node.position = CGPoint(x: -frame.width / 2 + node.frame.height * CGFloat(index + 1),
                                        y: frame.height / 2 - node.frame.height * 3)
                node.setPhysicsBody(categoryBitMask: warpCategory)
            }
            addChild(node)
        }
    }

    func addBullet(bullet: SKSpriteNode) {
        bullet.setPhysicsBody(categoryBitMask: bulletCategory, contactTestBitMask: enemyCategory)
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
        case is YellowShip:
            switch spaceShip.level {
            case .one:
                pausedScene.children.compactMap { $0 as? EnemyBullet }.forEach {
                    $0.removeFromParent()
                    score += 1
                }
            case .two:
                pausedScene.children.compactMap { $0 as? EnemyBullet }.forEach {
                    $0.removeFromParent()
                    score += 1
                }
                pausedScene.children.compactMap { $0 as? Enemy }.forEach { $0.damaged() }
            case .three:
                pausedScene.children.compactMap { $0 as? EnemyBullet }.forEach {
                    $0.removeFromParent()
                    score += 1
                }
                pausedScene.children.compactMap { $0 as? Enemy }.forEach { $0.damaged(3) }
            }
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

    func killedEnemy(_ enemy: Enemy, score: Int) {
        if Float.random(in: 0 ... 1) < 0.075 {
            let powerUpItem = PowerItem(itemType: .level, addedViewFrame: frame)
            powerUpItem.position = (enemy as? SKSpriteNode)?.position ?? .zero
            addPowerItem(powerUpItem)
        }
        self.score += score
    }
}

extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        var shipContent: SKPhysicsBody
        var affectToShip: SKPhysicsBody

        if contact.bodyA.categoryBitMask & (spaceshipCategory | bulletCategory | warpCategory) != 0 {
            shipContent = contact.bodyA
            affectToShip = contact.bodyB
        } else {
            shipContent = contact.bodyB
            affectToShip = contact.bodyA
        }

        if let item = affectToShip.node as? PowerItem {
            item.removeFromParent()
            if let pink = spaceShip as? PinkShip,
                shipContent.categoryBitMask == warpCategory {
                shipContent.node?.removeFromParent()
                pink.reuseWarp()
            }
            spaceShip.powerUp(itemType: item.type)
            return
        }

        if let ship = shipContent.node as? SpaceShip {
            (affectToShip.node as? EnemyBullet)?.removeFromParent()
            if let enemy = affectToShip.node as? Enemy {
                ship.damaged(enemy)
            } else {
                ship.damaged()
            }
        } else if let bullet = shipContent.node as? Bullet {
            if let enemy = affectToShip.node as? Enemy {
                bullet.contact(enemy: enemy)
            } else {
                bullet.removeFromParent()
            }
        } else if let pink = spaceShip as? PinkShip,
            let warp = shipContent.node {
            if let enemy = affectToShip.node as? Enemy {
                enemy.damaged(Int.max)
                spaceShip.powerUp(itemType: .heal)
            } else if let enemyBullet = affectToShip.node as? EnemyBullet {
                enemyBullet.removeFromParent()
                score += 1
            }
            warp.removeFromParent()
            pink.reuseWarp()
        }
    }
}
