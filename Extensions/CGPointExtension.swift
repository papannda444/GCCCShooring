//
//  CGPointExtension.swift
//  shooting-game
//
//  Created by papannda444 on 2019/02/23.
//  Copyright © 2019 三野田脩. All rights reserved.
//

import UIKit

extension CGPoint {
    var rotation: CGFloat {
        return atan2(x, y) * 180.0 / CGFloat.pi
    }
    var length: CGFloat {
        get {
            return sqrt(x * x + y * y)
        }
    }
    var unit: CGPoint {
        get {
            return self * (1.0 / length)
        }
    }

    //加算
    static func + (left: CGPoint, right: CGPoint) -> CGPoint {
        return CGPoint(x: left.x + right.x, y: left.y + right.y)
    }
    static func += (left: inout CGPoint, right: CGPoint) {
        left = left + right
    }
    //減算
    static func - (left: CGPoint, right: CGPoint) -> CGPoint {
        return CGPoint(x: left.x - right.x, y: left.y - right.y)
    }
    static func -= (left: inout CGPoint, right: CGPoint) {
        left = left - right
    }
    //乗算
    static func * (left: CGPoint, right: CGFloat) -> CGPoint {
        return CGPoint(x: left.x * right, y: left.y * right)
    }
    static func *= (left: inout CGPoint, right: CGFloat) {
        left = left * right
    }
    //除算
    static func / (left: CGPoint, right: CGFloat) -> CGPoint {
        return CGPoint(x: left.x / right, y: left.y / right)
    }
    static func /= (left: inout CGPoint, right: CGFloat) {
        left = left / right
    }
    //逆ベクトル
    static prefix func - (value: CGPoint) -> CGPoint {
        return CGPoint(x: -value.x, y: -value.y)
    }
}
