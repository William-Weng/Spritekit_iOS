//
//  GameScene.swift
//  SpaceBattle
//
//  Created by William-Weng on 2018/9/15.
//  Copyright © 2018年 William-Weng. All rights reserved.
//
/// [(一)宇宙大戰 Space Battle — 新建場景Scene、精靈節點、Particle粒子及背景音樂](http://www.ifiero.com/index.php/archives/126)
/// [[原創]SpriteKit+Swift學習筆記（七）-簡述碰撞檢測](https://segmentfault.com/a/1190000002394575)
/// [SKView｜Sprite Kit入門](http://spritekit.senchan-office.com/index.php/skview)

import SpriteKit
import GameplayKit

// MARK: - 物體的相關代號
struct PhysicsCategory {
    static let Player: UInt32 = 0x01 << 1
    static let Alien:  UInt32 = 0x01 << 2
    static let Bullet: UInt32 = 0x01 << 3
    static let None:   UInt32 = 0x01 << 4
}

// MARK: - 場景主體
class GameScene: SKScene {
    
    /// 物體之間的碰撞關係
    enum CollisionStatus {
        case player_alien
        case alien_bullet
        case nothing
    }
    
    private let gameHelper = GameHelper.shared
    
    private var playerNode: SKSpriteNode!
    private var lastUpdateTimeInterval: TimeInterval = 0
    private var deltaTimeInterval: TimeInterval = 0
    private var isGameOver = false
    private var currentScore: Int = 0 { didSet { scoreSetting(currentScore) } }
    
    lazy private var currentScoreLabel: SKLabelNode = {
        let labelInfo = (position: CGPoint.init(x: -370, y: 750), text: "當前：0")
        return scoreLabel(with: labelInfo.position, text: labelInfo.text)
    }()
    
    lazy private var bestScoreLabel: SKLabelNode = {
        let bestScore = gameHelper.getScore(for: .bestScore)
        let labelInfo = (position: CGPoint.init(x: 370, y: 750), text: "最高：\(bestScore)")
        return scoreLabel(with: labelInfo.position, text: labelInfo.text)
    }()
    
    override func didMove(to view: SKView) {
        
        physicsWorldSetting()
        initScoreLabel()
        backgroundMusicSetting()
        initPlayer()
        makeAliens(for: 0.6)
    }
    
    override func update(_ currentTime: TimeInterval) {
        
        if (lastUpdateTimeInterval == 0) { lastUpdateTimeInterval = currentTime }
        
        deltaTimeInterval = currentTime - lastUpdateTimeInterval
        lastUpdateTimeInterval = currentTime
        
        updateBackground(delta: deltaTimeInterval)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        spawnBullet(from: playerNode)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        playerNode.position.x = playerPosition(with: touches)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        playGame(contact)
    }
}

extension GameScene {
    
    /// 產生敵人
    @objc private func spawnAlien() {
        
        let imageName = randomImageName()
        let alien = SKSpriteNode.init(imageNamed: imageName)
        
        alien.physicsBody = SKPhysicsBody.init(texture: SKTexture.init(imageNamed: imageName), size: SKTexture.init(imageNamed: imageName).size())
        
        alien.physicsBody?.categoryBitMask = PhysicsCategory.Alien
        alien.physicsBody?.contactTestBitMask = PhysicsCategory.Player
        alien.physicsBody?.collisionBitMask = PhysicsCategory.None
        
        alien.zPosition = 1
        alien.position = randomPosition(with: frame)
        alien.run(sequenceAlienAction(with: alien))
        
        addChild(alien)
    }
    
    /// 產生子彈
    @objc private func spawnBullet(from spriteNode: SKSpriteNode) {
        
        let imageName = "BulletBlue"
        let bullet = SKSpriteNode.init(imageNamed: imageName)
        
        bullet.physicsBody = SKPhysicsBody.init(texture: SKTexture.init(imageNamed: imageName), size: SKTexture.init(imageNamed: imageName).size())
        
        bullet.physicsBody?.categoryBitMask = PhysicsCategory.Bullet
        bullet.physicsBody?.contactTestBitMask = PhysicsCategory.Alien
        bullet.physicsBody?.collisionBitMask = PhysicsCategory.None
        
        bullet.physicsBody?.usesPreciseCollisionDetection = true
        
        bullet.zPosition = 1
        bullet.position = spriteNode.position
        
        if let effect = bulletEffect(for: bullet, with: GameConstant.Effect.ShootTrailBlue.rawValue) {
            bullet.run(sequenceBulletAction(with: bullet, skNode: effect))
        }
        
        playSound(with: GameConstant.Sound.torpedo.rawValue)
        addChild(bullet)
    }
}

// MARK: - SKPhysicsContactDelegate
extension GameScene: SKPhysicsContactDelegate {
    
    /// 物理世界的相關設定
    private func physicsWorldSetting() {
        physicsWorld.gravity = CGVector.init(dx: 0.0, dy: 0.0)
        physicsWorld.contactDelegate = self
    }
}

// MARK: - 小工具
extension GameScene {
    
    /// 飛機的設定 (初始化)
    private func initPlayer() {
        
        guard let _playerNode = childNode(withName: GameConstant.Node.player.rawValue) as? SKSpriteNode else { return }
        
        let playerTexture = SKTexture.init(imageNamed: "Player")
        
        playerNode = _playerNode
        
        playerNode.physicsBody = SKPhysicsBody.init(texture: playerTexture, size: playerTexture.size())
        playerNode.zPosition = 2
        
        playerNode.physicsBody?.categoryBitMask = PhysicsCategory.Player
        playerNode.physicsBody?.contactTestBitMask = PhysicsCategory.Alien
        playerNode.physicsBody?.collisionBitMask = PhysicsCategory.None
    }
    
    /// 背景音樂的設定
    private func backgroundMusicSetting() {
        
        let bgMusic = SKAudioNode.init(fileNamed: GameConstant.Music.spaceBattle.rawValue)
        bgMusic.autoplayLooped = true
        
        addChild(bgMusic)
    }
    
    /// 加入分數的LabelNode
    private func initScoreLabel() {
        addChild(bestScoreLabel)
        addChild(currentScoreLabel)
    }
    
    /// 隨機產生敵機
    private func makeAliens(for interval: TimeInterval) {
        Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(spawnAlien), userInfo: nil, repeats: true)
    }
    
    /// 測試遊戲物體碰撞後的處理方式
    private func playGame(_ contact: SKPhysicsContact) {
        
        let (bodyA, bodyB) = physicsBodyMaskSort(contact)
        let collisionStatus = bodyCollisionStatus(bodyA: bodyA, bodyB: bodyB)
        
        switch collisionStatus {
        case .alien_bullet:
            hitAliens(bodyA: bodyA.node as! SKSpriteNode, bodyB: bodyB.node as! SKSpriteNode)
        case .player_alien:
            gameOver(bodyA: bodyA.node as! SKSpriteNode, bodyB: bodyB.node as! SKSpriteNode)
        case .nothing:
            break
        }
    }
}

// MARK: - 小工具2
extension GameScene {
    
    /// 完整的敵人動作路徑
    private func sequenceAlienAction(with spriteNode: SKSpriteNode) -> SKAction {
        
        let action = SKAction.sequence(
            [moveAlienAction(with: spriteNode, frame: frame),
             SKAction.removeFromParent()]
        )
        return action
    }
    
    /// 完整的子彈動作路徑
    private func sequenceBulletAction(with spriteNode: SKSpriteNode, skNode: SKNode) -> SKAction {
        
        let action = SKAction.sequence([
            moveBulletAction(with: spriteNode, frame: frame),
            SKAction.run({
                spriteNode.removeFromParent()
                skNode.removeFromParent()
            })
        ])
        
        return action
    }
    
    /// 產生敵人移動的動作路徑
    private func moveAlienAction(with spriteNode: SKSpriteNode, frame: CGRect) -> SKAction {
        let movePoint = CGPoint.init(x: spriteNode.position.x, y: -frame.size.height)
        return SKAction.move(to: movePoint, duration: randomDuration(min: 1.5, max: 3.5))
    }
    
    /// 產生子彈移動的動作路徑
    private func moveBulletAction(with spriteNode: SKSpriteNode, frame: CGRect) -> SKAction {
        let movePoint = CGPoint.init(x: spriteNode.position.x, y: spriteNode.position.y + frame.size.height)
        return SKAction.move(to: movePoint, duration: 0.5)
    }
    
    /// 隨機產生位置 (在畫面的左右邊)
    private func randomPosition(with frame: CGRect) -> CGPoint {
        
        let xPosition = CGFloat.random(min: -frame.size.width * 0.5, max: frame.size.width * 0.5)
        let yPosition = frame.size.height * 0.5
        
        return CGPoint.init(x: xPosition, y: yPosition)
    }
    
    /// 隨機產生時間間隔
    private func randomDuration(min: CGFloat, max: CGFloat) -> TimeInterval {
        return TimeInterval(CGFloat.random(min: min, max: max))
    }
    
    /// 隨機產生圖片名稱
    private func randomImageName() -> String {
        
        let index = GKRandomSource.sharedRandom().nextInt(upperBound: 3)
        let imageName = "Enemy0\(index)"

        return imageName
    }
    
    /// 更新背景畫面 (兩個同名的背景相互交換 -> 卷軸遊戲)
    private func updateBackground(delta daletaTimeInterval: TimeInterval) {
        
        enumerateChildNodes(withName: GameConstant.Node.background.rawValue) { (node, _) in
            
            guard let sprite = node as? SKSpriteNode else { return }
            sprite.position.y -= CGFloat(self.deltaTimeInterval * GameConstant.gameSpeed)
            
            if (sprite.position.y < -self.frame.height) { sprite.position.y += self.frame.height * 2 }
        }
    }
    
    /// 主機跟敵人碰撞後，主機就88了
    private func gameOver(bodyA: SKSpriteNode, bodyB: SKSpriteNode) {
        
        isGameOver = true
        
        bodyA.physicsBody?.categoryBitMask = PhysicsCategory.None
        bodyA.removeFromParent()
        
        emitterEffect(for: bodyA, with: GameConstant.Effect.Explosion.rawValue, isGameOver: isGameOver)
    }
    
    /// 子彈擊中敵人後，敵人就88了，子彈也88了，分數++
    private func hitAliens(bodyA: SKSpriteNode, bodyB: SKSpriteNode) {
        
        bodyA.physicsBody?.categoryBitMask = PhysicsCategory.None
        bodyB.physicsBody?.categoryBitMask = PhysicsCategory.None
        bodyA.removeFromParent()
        bodyB.removeFromParent()

        emitterEffect(for: bodyA, with: GameConstant.Effect.ExplosionBlue.rawValue, isGameOver: isGameOver)
        playSound(with: GameConstant.Sound.explosion.rawValue)
        
        currentScore += 1
    }
    
    /// 被擊中的爆炸效果
    private func emitterEffect(for body: SKSpriteNode, with effect: String, isGameOver: Bool) {
        
        guard let emitter = SKEmitterNode.init(fileNamed: effect) else { return }
        
        emitter.position = body.position
        addChild(emitter)
        
        let sequence = SKAction.sequence([
            SKAction.wait(forDuration: TimeInterval(0.3)),
            SKAction.removeFromParent()
        ])
        
        emitter.run(sequence) {
            if (isGameOver) { self.gameHelper.transferScene(from: self, to: GameConstant.Scene.startUp.rawValue) }
        }
    }
    
    /// 子彈的效果
    private func bulletEffect(for bullet: SKSpriteNode, with effect: String) -> SKNode? {
        
        guard let trailNode = Optional.some(SKNode()),
              let emitter = SKEmitterNode.init(fileNamed: effect)
        else {
            return nil
        }
        
        trailNode.zPosition = 1
        emitter.targetNode = trailNode
        
        bullet.addChild(emitter)
        addChild(trailNode)
        
        return trailNode
    }
    
    /// 計算主機現在的所在位置
    private func playerPosition(with touches: Set<UITouch>) -> CGFloat {
        
        guard let touch = touches.first,
              let nowLocation = Optional.some(touch.location(in: self)),
              let previousLocation = Optional.some(touch.previousLocation(in: self)),
              let nowPositionX = Optional.some(playerNode.position.x + nowLocation.x - previousLocation.x)
        else {
            return 0
        }
        
        return nowPositionX
    }
    
    /// 產生文字LabelNode
    private func scoreLabel(with position: CGPoint, text: String) -> SKLabelNode {
        
        let label = SKLabelNode()
        
        label.fontSize = 60
        label.zPosition = 1
        label.text = text
        label.position = position
        
        return label
    }
    
    /// 分數相關設定 (記錄當前分數及更新最高分數)
    private func scoreSetting(_ nowScore: Int) {
        
        let nowBestScore = gameHelper.getScore(for: .bestScore)
        
        currentScoreLabel.text = "當前：\(nowScore)"
        gameHelper.setScore(with: nowScore, for: .currentScore)
        
        if (nowScore > nowBestScore) {
            bestScoreLabel.text = "最高：\(nowScore)"
            gameHelper.setScore(with: currentScore, for: .bestScore)
        }
    }
    
    /// 播放音效
    private func playSound(with sound: String) {
        let bulletSound = SKAction.playSoundFileNamed(sound, waitForCompletion: false)
        run(bulletSound)
    }
    
    /// 測試物體之間的碰撞關係
    private func bodyCollisionStatus(bodyA: SKPhysicsBody, bodyB: SKPhysicsBody) -> CollisionStatus {
        
        if (bodyA.categoryBitMask == PhysicsCategory.Player && bodyB.categoryBitMask == PhysicsCategory.Alien) { return .player_alien }
        if (bodyA.categoryBitMask == PhysicsCategory.Alien && bodyB.categoryBitMask == PhysicsCategory.Bullet) { return .alien_bullet }
        
        return .nothing
    }
    
    /// 將物體依照BitMask的大小排序 (小 -> 大)
    private func physicsBodyMaskSort(_ contact: SKPhysicsContact) -> (SKPhysicsBody, SKPhysicsBody) {
        
        let bodyA: SKPhysicsBody
        let bodyB: SKPhysicsBody
        
        if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask) {
            bodyA = contact.bodyA; bodyB = contact.bodyB
        } else {
            bodyA = contact.bodyB; bodyB = contact.bodyA
        }
        
        return (bodyA, bodyB)
    }
}
