//
//  Alien.swift
//  shooting-game
//
//  Created by 三野田脩 on 2019/02/11.
//  Copyright © 2019 三野田脩. All rights reserved.
//

import Foundation
import SpriteKit

class Alien: SKSpriteNode {
  
  enum AilenType: String {
    case easy
    case normal
    case hard
  }
  
  convenience init() {
    let texture = SKTexture(imageNamed: "spaceship")
    self.init(texture: texture, color: .clear, size: texture.size())
  }
  
  override init(texture: SKTexture?, color: UIColor, size: CGSize) {
    super.init(texture: texture, color: color, size: size)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func setPhysicsBody(categoryBitMask: UInt32, contactTestBitMask: UInt32) {
    
  }
}
