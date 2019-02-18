//
//  PowerItem.swift
//  shooting-game
//
//  Created by 三野田脩 on 2018/12/24.
//  Copyright © 2018 三野田脩. All rights reserved.
//

import Foundation
import SpriteKit

class PowerItem: SKSpriteNode {
  
  enum ItemType: String {
    case auto
    case speed
    case stone
  }
  
  var type: ItemType
  
  convenience init(itemType type: ItemType, addedViewFrame viewFrame: CGRect) {
    let texture = SKTexture(imageNamed: type.rawValue)
    self.init(texture: texture, color: .clear, size: texture.size())
    self.type = type
    scale(to: CGSize(width: 70, height: 70))
    physicsBody = SKPhysicsBody(circleOfRadius: self.frame.width)
    let positionX = viewFrame.width * (CGFloat.random(in: 0...1) - 0.5)
    position = CGPoint(x: positionX, y: viewFrame.height / 2 + self.frame.height)
  }
  
  override init(texture: SKTexture?, color: UIColor, size: CGSize) {
    type = .auto // default value, please to change convenience init
    super.init(texture: texture, color: color, size: size)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func setPhysicsBody(categoryBitMask: UInt32, contactTestBitMask: UInt32) {
    physicsBody = SKPhysicsBody(circleOfRadius: frame.width / 2)
    physicsBody?.categoryBitMask = categoryBitMask
    physicsBody?.contactTestBitMask = contactTestBitMask
    physicsBody?.collisionBitMask = 0
  }
}
