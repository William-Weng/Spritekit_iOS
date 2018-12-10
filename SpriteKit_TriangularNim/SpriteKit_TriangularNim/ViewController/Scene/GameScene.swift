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
    
    /* 線段的顏色 */
    enum LineColor: Int {
        case first = 0
        case second = 1
        
        func value() -> UIColor {
            switch self {
            case .first: return UIColor.blue
            case .second: return UIColor.red
            }
        }
        
        func name() -> String {
            switch self {
            case .first: return "藍色"
            case .second: return "紅色"
            }
        }
    }
    
    typealias LinePoint = (first: CGPoint?, next: CGPoint?)
    typealias LinearEquationParameter = (a: CGFloat, b: CGFloat)
    typealias IntersectionInCircle = (p1: CGPoint, p2: CGPoint)
    
    let NodeName = "Nim"
    let ImageName = (normal: "TouchNormal", selected: "TouchSelected")
    var totalCount = 0
    
    var shapeNode: SKShapeNode?
    var linePoint: LinePoint = (nil, nil)
    var linePath: CGPath? { get { return drawLinePath()?.cgPath } }
    
    var nowNodeSet = Set<SKNode>()
    var selectedNodeSet = Set<SKNode>()
    var count = 1
    
    override func didMove(to view: SKView) {
        nodesCount()
    }
    
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
        
        let lineColor: LineColor = (count % 2 != 0) ? .first : .second
        
        linePoint.next = position
        drawLine(with: lineColor.value())
        nimTest()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        linePoint = (nil, nil)
        winRule()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesEnded(touches, with: event)
    }
}

// MARK: - 小工具
extension GameScene {
    
    /// 取得圓圓的總數量
    private func nodesCount() {
        enumerateChildNodes(withName: NodeName) { (node, _) in
            self.totalCount += 1
        }
    }
    
    /// 畫線
    private func drawLine(with color: UIColor) {
        
        clearShapeNode()
        
        shapeNode = SKShapeNode()
        
        shapeNode?.zPosition = 2
        shapeNode!.path = linePath
        shapeNode!.position = CGPoint(x: frame.midX, y: frame.midY)
        shapeNode!.strokeColor = color
        shapeNode!.lineWidth = 5
        
        addChild(shapeNode!)
    }
    
    /// 測試上面的點有沒有被連到
    private func nimTest() {
        
        nowNodeSet.removeAll()
        
        enumerateChildNodes(withName: NodeName) { (node, _) in
            self.touchedPointNode(node, point: self.linePoint)
            self.drawLastSelectedNode(node)
        }
    }
    
    /// 畫上一次被選擇的點
    private func drawLastSelectedNode(_ node: SKNode) {
        
        for selectedNode in self.selectedNodeSet {
            if node == selectedNode, let node = node as? SKSpriteNode {
                node.texture = SKTexture(imageNamed: self.ImageName.selected)
            }
        }
    }
    
    /// 贏的規則 (至少要畫1~3個，如果有包含之前畫的就不算)
    private func winRule() {
        
        guard 1...3 ~= nowNodeSet.count,
              let lineNode = shapeNode?.copy() as? SKShapeNode
        else {
            clearShapeNode(); return
        }
        
        for node in nowNodeSet {
            if selectedNodeSet.contains(node) { clearShapeNode(); return }
            selectedNodeSet.insert(node)
        }
        
        count += 1
        addChild(lineNode)
        
        if (selectedNodeSet.count >= totalCount - 1) {
            let lineColor = LineColor(rawValue: (count - 1) % 2)
            showAlert(message: "\(lineColor!.name()) 獲勝")
        }
    }
}

// MARK: - 小工具
extension GameScene {
    
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
    
    /// 清除不要的線
    private func clearShapeNode() {
        shapeNode?.removeFromParent()
        shapeNode = nil
    }
    
    /// 求出直線方程式 (y = ax + b) 與圓型方程式 ((x-x0)^2 + (y-y0)^2 = r^2) 的聯立解
    /// (a^2 + 1)x^2 + 2(a*b - a*y0 - x0)x + (x0^2 + y0^2 + b^2 - r^2 - 2*b*y0)
    /// 感謝 Kevin-Wang
    private func touchedPointNode(_ node: SKNode, point: LinePoint) {
        
        guard let myNode = node as? SKSpriteNode,
              let linearEquationParameter = findLinearEquationParameter(point: point),
              let radius = Optional.some(myNode.frame.width / 2.0),
              let nodeCenter = Optional.some(CGPoint(x: myNode.frame.midX, y: myNode.frame.midY))
        else {
            return
        }
        
        let (a, b) = linearEquationParameter

        firstNodeInCircle(myNode, a: a, b: b, center: nodeCenter, r: radius)
        otherNodeInCircle(myNode, point: point, a: a, b: b, center: nodeCenter, r: radius)
    }
}

extension GameScene {
    
    /// 求該點是否在該圓的範圍之內 (該點跟與該圓心的圓心距離 <= 半徑)
    private func pointInCircleRect(_ point: CGPoint? ,center: CGPoint, radius: CGFloat) -> Bool {
        
        guard let linePoint = point else { return false }
        
        let (x0, y0, r) = (center.x, center.y, radius)
        let (x1, y1) = (linePoint.x, linePoint.y)
        let isInCircle = (x1 - x0) * (x1 - x0) + (y1 - y0) * (y1 - y0) <= r * r
        
        return isInCircle
    }
    
    /// 求取兩點間的線段長度 P0(x0, y0) -> P1(x1, y1)
    private func lineLength(p0: CGPoint, p1: CGPoint) -> CGFloat {
        let length = sqrt((p0.x - p1.x) * (p0.x - p1.x) + (p0.y - p1.y) * (p0.y - p1.y))
        return length
    }
    
    /// 求出直線在該圓上的交點 (x = -B ± √(B^2 - 4AC) / 2A 與 y = ax + b)
    private func findIntersectionOnCircle(a: CGFloat, b: CGFloat, center: CGPoint, r: CGFloat) -> IntersectionInCircle? {
        
        let (x0, y0) = (center.x, center.y)
        
        let A = a * a + 1
        let B = 2 * (a * b - a * y0 - x0)
        let C = x0 * x0 + y0 * y0 + b * b - r * r - 2 * b * y0
        let factor = B * B - 4 * A * C
        
        if factor < 0 { return nil }
        
        let x1 = (-B + sqrt(factor)) / (2 * A)
        let x2 = (-B - sqrt(factor)) / (2 * A)
        let y1 = a * x1 + b
        let y2 = a * x2 + b
        
        let (p1, p2) = (CGPoint(x: x1, y: y1), CGPoint(x: x2, y: y2))
        let intersectionInCircle: IntersectionInCircle = (p1, p2)
        
        return intersectionInCircle
    }
    
    /// 求出二方一次方程式的因子 (b^2 - 4ac)
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
    
    /// 一開始的點是否在圓內的處理
    private func firstNodeInCircle(_ node: SKSpriteNode, a: CGFloat, b: CGFloat, center: CGPoint, r: CGFloat) {
        
        let isInCircle = pointInCircleRect(linePoint.first, center: center, radius: r)
        let nodeImageName = isInCircle ? ImageName.selected : ImageName.normal
        
        node.texture = SKTexture(imageNamed: nodeImageName)
    }
    
    /// 其它的點是否在圓內的處理
    private func otherNodeInCircle(_ node: SKSpriteNode, point: LinePoint, a: CGFloat, b: CGFloat, center: CGPoint, r: CGFloat) {
        
        guard let firstLinePoint = point.first,
              let nextLinePoint = point.next,
              let intersection = findIntersectionOnCircle(a: a, b: b, center: center, r: r)
        else {
            return
        }
        
        let lengthForLine = lineLength(p0: firstLinePoint, p1: nextLinePoint)
        let lengthP1 = lineLength(p0: firstLinePoint, p1: intersection.p1)
        let lengthP2 = lineLength(p0: firstLinePoint, p1: intersection.p2)
        
        let (x1, x2) = (firstLinePoint.x < nextLinePoint.x) ? (firstLinePoint.x, nextLinePoint.x) : (nextLinePoint.x, firstLinePoint.x)
        let (y1, y2) = (firstLinePoint.y < nextLinePoint.y) ? (firstLinePoint.y, nextLinePoint.y) : (nextLinePoint.y, firstLinePoint.y)
        
        let minLength = min(lengthP1, lengthP2)
        let minPoint = (lengthP1 > lengthP2) ? intersection.p2 : intersection.p1
        
        let isRightDirection = (x1...x2 ~= minPoint.x) || (y1...y2 ~= minPoint.y)
                
        if ((lengthForLine >= minLength) && isRightDirection) {
            node.texture = SKTexture(imageNamed: ImageName.selected)
            nowNodeSet.insert(node)
        }
    }
    
    /// 顯示提示框
    private func showAlert(message: String) {
        
        let viewController = view?.window?.rootViewController
        let alert = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        let aciton = UIAlertAction(title: "再玩一次", style: .default) { _ in
            GameHelper.shared.transferScene(from: self, to: GameConstant.SceneName.game.rawValue)
        }
        
        alert.addAction(aciton)
        viewController?.present(alert, animated: true, completion: nil)
    }
}
