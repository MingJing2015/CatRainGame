//
//  GameScene.swift
//  RainCat
//
//  Created by Marc Vandehey on 8/29/16.
//  Copyright © 2016 Thirteen23. All rights reserved.
//  https://medium.com/@marc.vandehey/raincat-lesson-1-79a750ef319f#.x6va3aie3

import SpriteKit

//class GameScene: SKScene {
// 游戏场景添加对 SKPhysicsContactDelegate 协议的支持
class GameScene: SKScene, SKPhysicsContactDelegate {

    private var lastUpdateTime : TimeInterval = 0
    private var currentRainDropSpawnTime : TimeInterval = 0
    private var rainDropSpawnRate : TimeInterval = 0
    
    private let foodEdgeMargin : CGFloat = 75.0

    // 雨滴元素将由一个 SKSpriteNode 和另外一个物理实体构成。
    // 你可以用一张图片或是一块纹理来实例化一个 SKSpriteNode 对象。
    let raindropTexture = SKTexture(imageNamed: "rain_drop")
    
    private let backgroundNode = BackgroundNode()
    
    // initialized umbrellaSprite
    private let umbrellaNode = UmbrellaSprite.newInstance()
    
    // variable :
    private var catNode : CatSprite!
    private var foodNode : FoodSprite!

    
  override func sceneDidLoad() {
    self.lastUpdateTime = 0
    
    // 全局边界
    var worldFrame = frame
    worldFrame.origin.x -= 100
    worldFrame.origin.y -= 100
    worldFrame.size.height += 200
    worldFrame.size.width += 200
    
    // 建了一个和场景形状相同的边界，只不过我们将每个边都扩张了 100 个点
    self.physicsBody = SKPhysicsBody(edgeLoopFrom: worldFrame)
    self.physicsBody?.categoryBitMask = WorldCategory

    self.physicsWorld.contactDelegate = self

    
    // 初始化背景，并将其加入场景中
    backgroundNode.setup(size: size)
    
    addChild(backgroundNode)
    
    // add the umbrella to the center of the screen:
    //umbrellaNode.position = CGPoint(x: frame.midX, y: frame.midY)
    
    umbrellaNode.updatePosition(point: CGPoint(x: frame.midX, y: frame.midY))
    
    umbrellaNode.zPosition = 4
    addChild(umbrellaNode)
    
    spawnCat()
    
    spawnFood()
  }


override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

    //spawnRaindrop()
    
    let touchPoint = touches.first?.location(in: self)
    
    if let point = touchPoint {
        umbrellaNode.setDestination(destination: point)
    }
  }

  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {

    let touchPoint = touches.first?.location(in: self)
    
    if let point = touchPoint {
        umbrellaNode.setDestination(destination: point)
    }
}

override func update(_ currentTime: TimeInterval) {

    // Called before each frame is rendered

    // Initialize _lastUpdateTime if it has not already been
    if (self.lastUpdateTime == 0) {
      self.lastUpdateTime = currentTime
    }

    // Calculate time since last update
    let dt = currentTime - self.lastUpdateTime

    // Update the Spawn Timer
    currentRainDropSpawnTime += dt

    // rainDropSpawnRate 目前是 0.5 秒
    if currentRainDropSpawnTime > rainDropSpawnRate {
        currentRainDropSpawnTime = 0
        
        spawnRaindrop()
    }
    
    self.lastUpdateTime = currentTime
    
    umbrellaNode.update(deltaTime: dt)
    
    catNode.update(deltaTime: dt, foodLocation: foodNode.position)
  }
    
    
    // 创建雨滴 -- 可以在 touchesBegan(_ touches:, with event:) 中调用这个方法，并看到如图的效果 rain drop
    private func spawnRaindrop() {
        
        let raindrop = SKSpriteNode(texture: raindropTexture)
        
        // ??
        raindrop.physicsBody?.density = 0.5
        
        raindrop.physicsBody = SKPhysicsBody(texture: raindropTexture, size: raindrop.size)
        
        // 加可触碰元素
        raindrop.physicsBody?.categoryBitMask = RainDropCategory
        raindrop.physicsBody?.contactTestBitMask = FloorCategory | WorldCategory
        
        //raindrop.position = CGPoint(x: size.width / 2, y: size.height / 2)
        
        // 利用 arc4Random() 来随机化 x 坐标，并通过调用 truncatingRemainder 来确保坐标在屏幕范围内
        let xPosition =
            CGFloat(arc4random()).truncatingRemainder(dividingBy: size.width)
        let yPosition = size.height + raindrop.size.height
        
        raindrop.position = CGPoint(x: xPosition, y: yPosition)
        
        // umbrella is 2, rain = 3  ??
        raindrop.zPosition = 3
        
        addChild(raindrop)
    }
    
    // 创建 Cat
    func spawnCat() {
        if let currentCat = catNode, children.contains(currentCat) {
            catNode.removeFromParent()
            catNode.removeAllActions()
            catNode.physicsBody = nil
        }
        
        catNode = CatSprite.newInstance()
        catNode.position = CGPoint(x: umbrellaNode.position.x, y: umbrellaNode.position.y - 30)
        
        addChild(catNode)
    }
    
     // 创建 food
    func spawnFood() {
    
        if let currentFood = foodNode, children.contains(currentFood) {
            foodNode.removeFromParent()
            foodNode.removeAllActions()
            foodNode.physicsBody = nil
        }
        
        foodNode = FoodSprite.newInstance()
        var randomPosition : CGFloat = CGFloat(arc4random())
        randomPosition = randomPosition.truncatingRemainder(dividingBy: size.width - foodEdgeMargin * 2)
        randomPosition += foodEdgeMargin
        
        foodNode.position = CGPoint(x: randomPosition, y: size.height)
        
        addChild(foodNode)
    }
    
    // 每当带有我们预先设置的 contactTestBitMasks 的物体碰撞发生时，这个方法就会被调用
    func didBegin(_ contact: SKPhysicsContact) {
        
        if (contact.bodyA.categoryBitMask == RainDropCategory) {
            contact.bodyA.node?.physicsBody?.collisionBitMask = 0
            contact.bodyA.node?.physicsBody?.categoryBitMask = 0
        } else if (contact.bodyB.categoryBitMask == RainDropCategory) {
            contact.bodyB.node?.physicsBody?.collisionBitMask = 0
            contact.bodyB.node?.physicsBody?.categoryBitMask = 0
        }
        
        // check for Food Category
        if contact.bodyA.categoryBitMask == FoodCategory || contact.bodyB.categoryBitMask == FoodCategory {
            handleFoodHit(contact: contact)
            return
        }
        
        // check for CatCategory:
        if contact.bodyA.categoryBitMask == CatCategory || contact.bodyB.categoryBitMask == CatCategory {
            
            // Go to process hit cat ...
            handleCatCollision(contact: contact)
            
            return
        }

        // 销毁操作来移除这些结点
        if contact.bodyA.categoryBitMask == WorldCategory {
            contact.bodyB.node?.removeFromParent()
            contact.bodyB.node?.physicsBody = nil
            contact.bodyB.node?.removeAllActions()
        } else if contact.bodyB.categoryBitMask == WorldCategory {
            contact.bodyA.node?.removeFromParent()
            contact.bodyA.node?.physicsBody = nil
            contact.bodyA.node?.removeAllActions()
        }
    }
    
    // handle Cat Collision
    func handleCatCollision(contact: SKPhysicsContact) {

        var otherBody : SKPhysicsBody
        
        if contact.bodyA.categoryBitMask == CatCategory {
            otherBody = contact.bodyB
        } else {
            otherBody = contact.bodyA
        }
        
        switch otherBody.categoryBitMask {
        case RainDropCategory:
            print("rain hit the cat")
            // ???
            catNode.hitByRain()
        case WorldCategory:
            spawnCat()
        default:
            print("Something hit the cat")
        }
    }
    
    // handle Food hit
    func handleFoodHit(contact: SKPhysicsContact) {
 
        var otherBody : SKPhysicsBody
        var foodBody : SKPhysicsBody
        
        if(contact.bodyA.categoryBitMask == FoodCategory) {
            otherBody = contact.bodyB
            foodBody = contact.bodyA
        } else {
            otherBody = contact.bodyA
            foodBody = contact.bodyB
        }
        
        switch otherBody.categoryBitMask {
        case CatCategory:
            //TODO increment points
            print("fed cat")
            fallthrough
        case WorldCategory:
            foodBody.node?.removeFromParent()
            foodBody.node?.physicsBody = nil
            
            spawnFood()
        default:
            print("something else touched the food")
        }
    }
}
