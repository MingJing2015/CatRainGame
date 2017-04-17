//
//  BackgroundNode.swift
//  RainCat
//
//  Created by Ming Jing on 17/3/22.
//  Copyright © 2017年 Thirteen23. All rights reserved.
//

import Foundation

import SpriteKit


// 创建的这个对象是一个 SKNode[10] 实例，我们会把它作为背景元素的容器。
/*
public class BackgroundNode : SKNode {
    
    public func setup(size : CGSize) {
        
        let yPos : CGFloat = size.height * 0.10
        let startPoint = CGPoint(x: 0, y: yPos)
        let endPoint = CGPoint(x: size.width, y: yPos)
        
        physicsBody = SKPhysicsBody(edgeFrom: startPoint, to: endPoint)
        
        physicsBody?.restitution = 0.3
    }
}
*/

public class BackgroundNode : SKNode {
    
    public func setup(size : CGSize) {
        
        let yPos : CGFloat = size.height * 0.10
        let startPoint = CGPoint(x: 0, y: yPos)
        let endPoint = CGPoint(x: size.width, y: yPos)
        
        physicsBody = SKPhysicsBody(edgeFrom: startPoint, to: endPoint)
        physicsBody?.restitution = 0.3
        physicsBody?.categoryBitMask = FloorCategory
        physicsBody?.contactTestBitMask = RainDropCategory
        
        
        // 创建两个 SKShapeNode 来达到天空和地面的效果。
        let skyNode = SKShapeNode(rect: CGRect(origin: CGPoint(), size: size))
        skyNode.fillColor = SKColor(red:0.38, green:0.60, blue:0.65, alpha:1.0)
        skyNode.strokeColor = SKColor.clear
        skyNode.zPosition = 0
        
        let groundSize = CGSize(width: size.width, height: size.height * 0.35)
        let groundNode = SKShapeNode(rect: CGRect(origin: CGPoint(), size: groundSize))
        groundNode.fillColor = SKColor(red:0.99, green:0.92, blue:0.55, alpha:1.0)
        groundNode.strokeColor = SKColor.clear
        
        // sky=0; ground=1; umbrella=2; rain=3;   ??
 
        groundNode.zPosition = 1
        
        addChild(skyNode)
        addChild(groundNode)
    }
}

