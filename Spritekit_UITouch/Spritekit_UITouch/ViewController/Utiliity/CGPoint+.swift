//
//  CGPoint+.swift
//  Spritekit_UITouch
//
//  Created by William-Weng on 2018/11/27.
//  Copyright © 2018年 William-Weng. All rights reserved.
//

import SpriteKit

extension CGPoint {
    
    /// 兩數相加
    static func +(left: CGPoint, right: CGPoint) -> CGPoint {
        return CGPoint(x: left.x + right.x, y: left.y + right.y)
    }
    
    /// 兩數相減
    static func -(left: CGPoint, right: CGPoint) -> CGPoint {
        return CGPoint(x: left.x - right.x, y: left.y - right.y)
    }
    
    /// 倍數相乘
    static func *(point: CGPoint, scalar: CGFloat) -> CGPoint {
        return CGPoint(x: point.x * scalar, y: point.y * scalar)
    }
    
    /// 倍數相除
    static func /(point: CGPoint, scalar: CGFloat) -> CGPoint {
        return CGPoint(x: point.x / scalar, y: point.y / scalar)
    }
}

extension CGPoint {
    
    /// 長度
    var length: CGFloat {
        return sqrt(x * x + y * y)
    }
    
    /// 法向量(單位長度 + 方向)
    var normalized: CGPoint {
        return self / length
    }
    
    /// 角度
    var angle: CGFloat {
        return atan2(y, x)
    }
}
