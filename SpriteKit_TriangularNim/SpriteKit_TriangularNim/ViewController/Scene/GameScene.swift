//
//  GameScene.swift
//  SpriteKit_TriangularNim
//
//  Created by William-Weng on 2018/12/6.
//  Copyright © 2018年 William-Weng. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    /* 物體的相關代號 */
    struct PhysicsCategory {
        static let Line: UInt32 = 0x01 << 1
        static let Point: UInt32 = 0x01 << 2
        static let None: UInt32 = 0x01 << 3
    }
    
    typealias LinePoint = (first: CGPoint?, next: CGPoint?)
    typealias LinearEquationParameter = (a: CGFloat, b: CGFloat)

    let NodeName = "Nim"
    let ImageName = (normal: "TouchNormal", selected: "TouchSelected")
    
    var shapeNode: SKShapeNode?
    var linePoint: LinePoint = (nil, nil)
    var linePath: CGPath? {
        get { return drawLinePath()?.cgPath }
    }
    
    override func didMove(to view: SKView) {}
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let touch = touches.first,
              let position = Optional.some(touch.location(in: self))
        else {
            return
        }
        
        linePoint.first = position
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let _ = linePoint.first,
              let touch = touches.first,
              let position = Optional.some(touch.location(in: self))
        else {
            return
        }
        
        linePoint.next = position
        drawLine(with: .blue)
        nimTest()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        linePoint = (nil, nil)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesEnded(touches, with: event)
    }
}

// MARK: - 小工具
extension GameScene {
    
    /// 畫線
    private func drawLine(with color: UIColor) {
        
        shapeNode?.removeFromParent()
        shapeNode = nil
        
        shapeNode = SKShapeNode()
        
        shapeNode?.zPosition = 2
        shapeNode!.path = linePath
        shapeNode!.position = CGPoint(x: frame.midX, y: frame.midY)
        shapeNode!.strokeColor = color
        shapeNode!.lineWidth = 5
        
        addChild(shapeNode!)
    }
    
    /// 畫線的路徑
    private func drawLinePath() -> UIBezierPath? {
        
        guard let firstLinePoint = linePoint.first,
              let nextLinePoint = linePoint.next
        else {
            return nil
        }
        
        let bezierPath = UIBezierPath()
        
        bezierPath.lineWidth = 1
        bezierPath.lineJoinStyle = .round
        
        bezierPath.move(to: firstLinePoint)
        bezierPath.addLine(to: nextLinePoint)
        bezierPath.close()
        
        return bezierPath
    }
}

// MARK: - 小工具
extension GameScene {
    
    /// 測試上面的點有沒有被連到
    private func nimTest() {
        
        enumerateChildNodes(withName: NodeName) { (node, _) in
            self.touchedPoint(with: node)
        }
    }
    
    /// 求出直線方程式 (y = ax + b) 與圓型方程式 ((x-x0)^2 + (y-y0)^2 = r^2) 的聯立解 => (a^2 + 1)x^2 + 2(a*b - a*y0 - x0)x + (x0^2 + y0^2 + b^2 - r^2 - 2*b*y0)
    private func touchedPoint(with node: SKNode) {
        
        guard let myNode = node as? SKSpriteNode,
              let linearEquationParameter = findLinearEquationParameter(point: self.linePoint),
              let radius = Optional.some(myNode.frame.width / 2.0),
              let nodeCenter = Optional.some(CGPoint(x: myNode.frame.midX, y: myNode.frame.midY))
        else {
            return
        }
        
        let r = radius
        let (a, b) = linearEquationParameter
        let (x0, y0) = (x0: nodeCenter.x, y0: nodeCenter.y)
        let factor = findFactor(a: a, b: b, x0: x0, y0: y0, r: r)
        let nodeImageName = (factor < 0) ? ImageName.normal : ImageName.selected
        
        myNode.texture = SKTexture(imageNamed: nodeImageName)
    }
    
    /// 求出二方一次方程式的因子 (b^b - 4*a*c)
    private func findFactor(a: CGFloat, b: CGFloat, x0: CGFloat, y0: CGFloat, r: CGFloat) -> CGFloat {
        
        let A = a * a + 1
        let B = 2 * (a * b - a * y0 - x0)
        let C = x0 * x0 + y0 * y0 + b * b - r * r - 2 * b * y0
        
        let factor = B * B - 4 * A * C
        
        return factor
    }
    
    /// 求兩點直線方程式 (y = ax + b) 的 (a, b)參數值
    private func findLinearEquationParameter(point: LinePoint) -> LinearEquationParameter? {
        
        guard let firstLinePoint = point.first,
              let nextLinePoint = point.next
        else {
            return nil
        }
        
        let a = (nextLinePoint.y - firstLinePoint.y) / (nextLinePoint.x - firstLinePoint.x)
        let b = nextLinePoint.y - a * nextLinePoint.x
        
        return LinearEquationParameter(a: a, b: b)
    }
}
