//
//  UmbrellaSprite.swift
//  RainCat
//
//  Created by Ming Jing on 17/3/23.
//  Copyright © 2017年 Thirteen23. All rights reserved.
//

import SpriteKit

public class UmbrellaSprite : SKSpriteNode {

    private var destination : CGPoint!
    private let easing : CGFloat = 0.1

    
    // 创建了一个新的精灵结点（ sprite node ）
    public static func newInstance() -> UmbrellaSprite {
        
        let umbrella = UmbrellaSprite(imageNamed: "umbrella")
        
        // Add new ?? 
        umbrella.zPosition = 2
        
        // 构造一个 CGPath 来初始化 SKPhysicsBody
        // 创建路径来初始化雨伞的 SKPhysicsBody 主要有两个原因。首先，就像之前提到的一样，我们只希望雨伞的顶部能够与其它对象碰撞。其次，这样我们可以自行调控雨伞的有效撞击区域
        
        let path = UIBezierPath()
        path.move(to: CGPoint())
        path.addLine(to: CGPoint(x: -umbrella.size.width / 2 - 30, y: 0))
        path.addLine(to: CGPoint(x: 0, y: umbrella.size.height / 2))
        path.addLine(to: CGPoint(x: umbrella.size.width / 2 + 30, y: 0))
        
        umbrella.physicsBody = SKPhysicsBody(polygonFrom: path.cgPath)
        umbrella.physicsBody?.isDynamic = false
        umbrella.physicsBody?.restitution = 0.9

        
        return umbrella
    }
    
    public func updatePosition(point : CGPoint) {
        position = point
        destination = point
    }
    
    public func setDestination(destination : CGPoint) {
        self.destination = destination
    }
    
    public func update(deltaTime : TimeInterval) {
        let distance = sqrt(pow((destination.x - position.x), 2) + pow((destination.y - position.y), 2))
        
        if(distance > 1) {
            let directionX = (destination.x - position.x)
            let directionY = (destination.y - position.y)
            
            position.x += directionX * easing
            position.y += directionY * easing
        } else {
            position = destination;
        }
    }
}

