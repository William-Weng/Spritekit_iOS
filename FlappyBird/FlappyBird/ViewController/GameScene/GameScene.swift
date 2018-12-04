//
//  GameScene.swift
//  FlappyBird
//
//  Created by William-Weng on 2018/11/22.
//  Copyright © 2018年 William-Weng. All rights reserved.
//
/// [iOS開發實戰-基於SpriteKit的FlappyBird小遊戲](https://www.jianshu.com/p/10f985687356)

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    /* 障礙物的位置 */
    enum ObstaclePosition {
        case up
        case down
    }
    
    /* 物體的相關代號 */
    struct PhysicsCategory {
        static let Player: UInt32 = 0x01 << 1
        static let Obstacle: UInt32 = 0x01 << 2
        static let None: UInt32 = 0x01 << 3
    }
    
    /* 跟著畫面移動的Nodes */
    private let MoveNodeNames = [
        GameConstant.NodeName.background.rawValue,
        GameConstant.NodeName.floor.rawValue,
    ]
    
    private let helper = GameHelper.shared
    private let ObstacleWidth: CGFloat = 100
    private lazy var highScore = helper.getScore(for: .bestScore)

    private var player: PlayerNode?
    private var background: SKSpriteNode?
    private var floor: SKSpriteNode?
    private var mainCamera: SKCameraNode?
    private var scoreLabel: SKLabelNode?
    private var highedScoreLabel: SKLabelNode?
    
    private var isGameOver = false
    private var nowObstacleTag = 0

    private var nowScoreSet = Set<Int>()
    private var nowScore = 0

    override func didMove(to view: SKView) {
        physicsWorldSetting()
        initBackgroundMusic()
        initChildNode()
        initPlayerBody()
        playerAnimation()
        obstacleNodes(for: 2.0)
    }
    
    override func update(_ currentTime: TimeInterval) {
        
        if (isGameOver) { return }
        
        movePlayer()
        moveCamera()
        moveAllSprites(camera: mainCamera, nodeNames: MoveNodeNames)
        calculateScore()
        autoRemoveObstacleNode()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if (isGameOver) { return }
        
        let jumpAction = SKAction.move(by: CGVector(dx: 0, dy: 50), duration: 0.1)
        player?.run(jumpAction)
    }
}

// MARK: - SKPhysicsContactDelegate
extension GameScene: SKPhysicsContactDelegate {
    
    /// 物理世界的相關設定
    private func physicsWorldSetting() {
        physicsWorld.contactDelegate = self
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        isGameOver = true
        showAlert(message: "GameOver…")
    }
}

// MARK: - 小工具
extension GameScene {
    
    /// 初始化場景物件
    private func initChildNode() {
        
        player = childNode(withName: GameConstant.NodeName.player.rawValue) as? PlayerNode
        
        background = childNode(withName: GameConstant.NodeName.background.rawValue) as? SKSpriteNode
        floor = childNode(withName: GameConstant.NodeName.floor.rawValue) as? SKSpriteNode

        mainCamera = childNode(withName: GameConstant.NodeName.mainCamera.rawValue) as? SKCameraNode
        scoreLabel = childNode(withName: GameConstant.NodeName.scoreLabel.rawValue) as? SKLabelNode
        highedScoreLabel = childNode(withName: GameConstant.NodeName.highedScoreLabel.rawValue) as? SKLabelNode
        
        highedScoreLabel?.text = "High:\(highScore)"
    }
    
    /// 主角綁上鐵塊
    private func initPlayerBody() {
        
        guard let player = player,
              let radius = Optional.some(player.size.height * 0.5 * 0.5)
        else {
            return
        }
        
        let playerBody = SKPhysicsBody(circleOfRadius: radius)
        
        player.physicsBody = playerBody

        player.physicsBody?.allowsRotation = false
        player.physicsBody?.categoryBitMask = PhysicsCategory.Player
        player.physicsBody?.contactTestBitMask = PhysicsCategory.Obstacle
        player.physicsBody?.collisionBitMask = PhysicsCategory.Obstacle
    }
    
    /// 移動攝影機
    private func moveCamera() {
        mainCamera?.position.x += GameConstant.CameraMoveX
    }
    
    /// 移動主角
    private func movePlayer() {
        player?.position.x += GameConstant.CameraMoveX
    }
    
    /// 移動全部場景
    private func moveAllSprites(camera: SKCameraNode?, nodeNames: [String]) {
        for nodeName in MoveNodeNames { moveSpriteNode(camera: camera, with: nodeName) }
    }
    
    /// 主角的動畫顯示
    private func playerAnimation() {
        player?.flapping()
        // player?.wobbing()
        playerTrailEmitter()
    }
    
    /// 隨機產生障礙物 (有點問題？fps不足時…)
    private func obstacleNodes(for interval: TimeInterval) {
        Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(makeObstacleNodes), userInfo: nil, repeats: true)
    }
    
    /// 產生障礙物 (上 / 下)
    @objc private func makeObstacleNodes() {
        
        if (isGameOver) { return }
        
        let obstacleNodeUp = makeObstacleNode(by: .up, with: "Obstacle.png")
        let obstacleNodeDown = makeObstacleNode(by: .down, with: "Obstacle.png")
        
        obstacleNodeUp.tag = nowObstacleTag
        obstacleNodeDown.tag = nowObstacleTag

        obstaclePhysicsBodySetting(obstacleNodeUp)
        obstaclePhysicsBodySetting(obstacleNodeDown)
        
        nowObstacleTag += 1
        
        addChild(obstacleNodeUp)
        addChild(obstacleNodeDown)
    }
    
    /// 移除超過畫面的障礙物
    private func autoRemoveObstacleNode() {
        
        guard let cameraX = camera?.position.x,
              let sceneWidth = Optional.some(size.width)
        else {
            return
        }
        
        enumerateChildNodes(withName: GameConstant.NodeName.obstacle.rawValue) { (node, _) in
            
            guard let spriteNode = node as? MySpriteNode,
                  let spriteNodeX = Optional.some(spriteNode.position.x)
            else {
                return
            }
            
            if (cameraX - sceneWidth / 2 > spriteNodeX) { spriteNode.removeFromParent() }
        }
    }
    
    /// 計算分數 (主角飛過障礙物之後)
    private func calculateScore() {
        
        guard let player = player else { return }
        
        enumerateChildNodes(withName: GameConstant.NodeName.obstacle.rawValue) { (node, _) in
            
            guard let spriteNode = node as? MySpriteNode else { return }
            
            if (player.position.x > spriteNode.position.x + self.ObstacleWidth) {
                self.nowScoreSet.insert(spriteNode.tag)
            }
        }
        
        saveScore(with: nowScoreSet)
    }
    
    /// 記錄分數 (目前分數跟最高分)
    private func saveScore(with scoreSet: Set<Int>) {
        
        guard let scoreLabel = scoreLabel,
              let highedScoreLabel = highedScoreLabel
        else {
            return
        }
        
        if (scoreSet.count > nowScore) {
            nowScore = nowScoreSet.count
            scoreLabel.text = "Score:\(nowScore)"
            helper.setScore(with: nowScore, for: .currentScore)
            playSound(with: GameConstant.Sound.rising.rawValue)
        }
        
        if (nowScore > highScore) {
            highScore = nowScore
            helper.setScore(with: highScore, for: .bestScore)
            highedScoreLabel.text = "High:\(highScore)"
        }
    }
    
    /// 背景音樂的設定
    private func initBackgroundMusic() {
        
        let bgMusic = SKAudioNode.init(fileNamed: GameConstant.Music.background.rawValue)
        bgMusic.autoplayLooped = true
        
        addChild(bgMusic)
    }
}

// MARK: - 小工具2
extension GameScene {
    
    /// 移動場景
    private func moveSpriteNode(camera: SKCameraNode?, with nodeName: String) {
        
        guard let camera = camera else { return }
        
        enumerateChildNodes(withName: nodeName) { (node, _ ) in
            if node.position.x + self.size.width < camera.position.x {
                node.position.x += self.size.width * GameConstant.SceneNunbers
            }
        }
    }
    
    /// 主角尾巴的物件效果
    private func playerTrailEmitter() {
        
        guard let emitter = SKEmitterNode(fileNamed: GameConstant.EmitterName.trail.rawValue),
              let trailNode = Optional.some(SKNode()),
              let playerSize = player?.frame.size
        else {
            return
        }
        
        emitter.targetNode = trailNode
        emitter.position = CGPoint(x: -playerSize.width, y: -30)
        trailNode.zPosition = GameConstant.zPosition
        
        addChild(trailNode)
        player?.addChild(emitter)
    }
    
    /// 產生障礙物 (高度會變化)
    private func makeObstacleNode(by position: ObstaclePosition, with imageName: String) -> MySpriteNode {
        
        let obstacleNode = MySpriteNode(imageNamed: imageName)
        let x = camera?.position.x ?? 0
        let sceneSize = size
        let factor: CGFloat = (position == .up) ? 1 : -1
        let shuffledWidth = GKShuffledDistribution(lowestValue: 120, highestValue: 360)
        
        obstacleNode.size = CGSize(width: 100, height: sceneSize.height - CGFloat(shuffledWidth.nextInt()))
        obstacleNode.position = CGPoint(x: x + sceneSize.width / 2, y: factor * sceneSize.height / 2)
        obstacleNode.zPosition = GameConstant.zPosition
        obstacleNode.name = GameConstant.NodeName.obstacle.rawValue
        
        return obstacleNode
    }
    
    /// 障礙物鐵塊設定 (✖旋轉 / ✖重力影響 / ✖移動)
    private func obstaclePhysicsBodySetting(_ spriteNode: MySpriteNode) {
        
        let physicsBody = SKPhysicsBody(rectangleOf: spriteNode.size)
        
        spriteNode.physicsBody = physicsBody
        spriteNode.physicsBody?.allowsRotation = false
        spriteNode.physicsBody?.affectedByGravity = false
        spriteNode.physicsBody?.isDynamic = false
        
        spriteNode.physicsBody?.categoryBitMask = PhysicsCategory.Obstacle
        spriteNode.physicsBody?.contactTestBitMask = PhysicsCategory.Player
        spriteNode.physicsBody?.collisionBitMask = PhysicsCategory.Player
    }
    
    /// 顯示提示框
    private func showAlert(message: String) {
        
        let viewController = view?.window?.rootViewController
        let alert = UIAlertController(title: "撞到了…", message: message, preferredStyle: .alert)
        let aciton = UIAlertAction(title: "再玩一次", style: .default) { _ in
            self.helper.transferScene(from: self, to: GameConstant.SceneName.game.rawValue)
        }

        alert.addAction(aciton)
        viewController?.present(alert, animated: true, completion: nil)
    }
    
    /// 播放音效
    private func playSound(with sound: String) {
        let bulletSound = SKAction.playSoundFileNamed(sound, waitForCompletion: false)
        run(bulletSound)
    }
}

