//
//  CatSprite.swift
//  RainCat
//
//  Created by Ming Jing on 17/3/23.
//  Copyright © 2017年 Thirteen23. All rights reserved.
//

import SpriteKit

public class CatSprite : SKSpriteNode {
    
    private let walkingActionKey = "action_walking"
    private let movementSpeed : CGFloat = 100
    
    private var timeSinceLastHit : TimeInterval = 2
    private let maxFlailTime : TimeInterval = 2
    
    private var currentRainHits = 4
    private let maxRainHits = 4
    
    private let walkFrames = [
        SKTexture(imageNamed: "cat_one"),
        SKTexture(imageNamed: "cat_two")
    ]
    
    
    private let meowSFX = [
        "cat_meow_1.mp3",
        "cat_meow_2.mp3",
        "cat_meow_3.mp3",
        "cat_meow_4.mp3",
        "cat_meow_5.wav",
        "cat_meow_6.wav",
        "cat_meow_7.mp3"
    ]

    
    public static func newInstance() -> CatSprite {
    
        let catSprite = CatSprite(imageNamed: "cat_one")
        
         // sky=0; ground=1; umbrella=2; rain=3;  cat=4; food=5
        catSprite.zPosition = 4
        
        catSprite.physicsBody = SKPhysicsBody(circleOfRadius: catSprite.size.width / 2)
        
        
        // get a callback when the cat is hit by rain or when it comes into contact with the edge of the world
        
        catSprite.physicsBody?.categoryBitMask = CatCategory
        catSprite.physicsBody?.contactTestBitMask = RainDropCategory | WorldCategory
        
        return catSprite
    }
    
    public func update(deltaTime : TimeInterval, foodLocation: CGPoint) {
        
        timeSinceLastHit += deltaTime
  
        if timeSinceLastHit >= maxFlailTime {
        
            if zRotation != 0 && action(forKey: "action_rotate") == nil {
                run(SKAction.rotate(toAngle: 0, duration: 0.25), withKey: "action_rotate")
            }
        
            if action(forKey: walkingActionKey) == nil {
                let walkingAction = SKAction.repeatForever(
                    SKAction.animate(with: walkFrames,
                                     timePerFrame: 0.1,
                                     resize: false,
                                     restore: true))
                
                run(walkingAction, withKey:walkingActionKey)
            }
            
            //Stand still if the food is above the cat.
            if foodLocation.y > position.y && abs(foodLocation.x - position.x) < 2 {
                physicsBody?.velocity.dx = 0
                removeAction(forKey: walkingActionKey)
                texture = walkFrames[1]
            } else if foodLocation.x < position.x {
                //Food is left
                physicsBody?.velocity.dx = -movementSpeed
                xScale = -1
            } else {
                //Food is right
                physicsBody?.velocity.dx = movementSpeed
                xScale = 1
            }
            
            physicsBody?.angularVelocity = 0
        }
    }
    
    public func hitByRain() {
        timeSinceLastHit = 0
        removeAction(forKey: walkingActionKey)
        
        //Determine if we should meow or not
        if(currentRainHits < maxRainHits) {
            currentRainHits += 1
            
            return
        }
        
        if action(forKey: "action_sound_effect") == nil {
            currentRainHits = 0
            
            let selectedSFX = Int(arc4random_uniform(UInt32(meowSFX.count)))
            
            run(SKAction.playSoundFileNamed(meowSFX[selectedSFX], waitForCompletion: true),
                withKey: "action_sound_effect")
        }
    }
}
