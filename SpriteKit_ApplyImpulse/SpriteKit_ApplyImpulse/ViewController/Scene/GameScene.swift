//
//  GameScene.swift
//  SpriteKit_ApplyImpulse
//
//  Created by William-Weng on 2018/11/30.
//  Copyright © 2018年 William-Weng. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    let BallCenter = (name: "BallCenter", positon: CGPoint.zero)
    
    override func didMove(to view: SKView) {
        initGround()
        initElasticBall()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let elasticBall = childNode(withName: BallCenter.name)
        elasticBall?.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 100))
    }
}

// MARK: - 主工具
extension GameScene {
    
    /// 建立地板線 (不要因重力落下)
    private func initGround() {
        
        let ground = SKSpriteNode(color: .red, size: CGSize(width: 1800, height: 10))
        
        ground.position = CGPoint(x: 200, y: -150)
        ground.zPosition = 0
        ground.physicsBody = SKPhysicsBody(rectangleOf: ground.size)
        ground.physicsBody?.isDynamic = false
        
        addChild(ground)
    }
    
    /// 建立彈力球
    private func initElasticBall() {
        
        let ballCenter = elasticBallCenter(with: BallCenter.name)
        let balls = elasticBalls(with: 20)
        
        elasticBallsJointSpring(balls, for: ballCenter)
        elasticBallsJointLimit(balls)
    }
}

// MARK: - 小工具
extension GameScene {
    
    /// 將所有小球的物理體跟球中心點連起來
    private func elasticBallsJointSpring(_ balls: [SKShapeNode], for ballCenter: SKShapeNode) {
        
        addChild(ballCenter)
        
        for ball in balls { jointSpringForBall(ball, for: ballCenter) }
    }
    
    /// 將小球的物理體跟球中心點連起來
    private func jointSpringForBall(_ ball: SKShapeNode, for ballCenter: SKShapeNode) {
        
        let jointSpring = SKPhysicsJointSpring.joint(withBodyA: ballCenter.physicsBody!, bodyB: ball.physicsBody!, anchorA: ballCenter.position, anchorB: ball.position)
        
        jointSpring.damping = 0.2
        jointSpring.frequency = 10.0
        
        addChild(ball)
        physicsWorld.add(jointSpring)
    }
    
    /// 所有小球的距離 (兩顆球之間的距離)
    private func elasticBallsJointLimit(_ balls: [SKShapeNode]) {
        
        let maxIndex = balls.count - 1
        
        for index in 0...maxIndex {
            let jointNodeIndex: (previous: Int, next: Int) = (index < maxIndex) ? (index, index + 1) : (maxIndex, next: 0)
            jointLimitForBall(balls, index: jointNodeIndex)
        }
    }
    
    /// 小球之間的距離
    private func jointLimitForBall(_ balls: [SKShapeNode], index: (previous: Int, next: Int)) {
        
        let jointNode: (previous: SKNode, next: SKNode) = (balls[index.previous], balls[index.next])
        let jointLimit = SKPhysicsJointLimit.joint(withBodyA: jointNode.previous.physicsBody!, bodyB: jointNode.next.physicsBody!, anchorA: jointNode.previous.position, anchorB: jointNode.next.position)
        
        jointLimit.maxLength = 30
        physicsWorld.add(jointLimit)
    }
    
    /// 建立彈力球中心
    private func elasticBallCenter(with name: String) -> SKShapeNode {
        
        let ballCenter = drawElasticBall(for: BallCenter.positon)
        ballCenter.name = name
        
        return ballCenter
    }
    
    /// 建立彈力球球體
    private func elasticBalls(with count: Int) -> [SKShapeNode] {
        
        let dAngle = Double.pi / 10.0
        let radius = 100.0
        var balls = [SKShapeNode]()
        
        for index in 0..<count {
            
            let angle = dAngle * Double(index)
            let (x, y) = (radius * cos(angle) + Double(BallCenter.positon.x), radius * sin(angle) + Double(BallCenter.positon.y))
            let position = CGPoint(x: x, y: y)
            let ball = drawElasticBall(for: position)
            
            balls.append(ball)
        }
        
        return balls
    }
    
    /// 畫空心圓球
    private func drawElasticBall(for postion: CGPoint) -> SKShapeNode {
        
        let ball = SKShapeNode()
        let radius: CGFloat = 10.0
        
        ball.path = UIBezierPath(ovalIn : CGRect(x: -radius, y: -radius, width: radius * 2, height: radius * 2)).cgPath
        ball.position = postion
        ball.physicsBody = SKPhysicsBody(circleOfRadius: radius)
        
        return ball
    }
}
