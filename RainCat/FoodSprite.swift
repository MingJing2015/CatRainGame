//
//  FoodSprite.swift
//  RainCat
//
//  Created by Ming Jing on 17/3/23.
//  Copyright © 2017年 Thirteen23. All rights reserved.
//

import SpriteKit

public class FoodSprite : SKSpriteNode {
    public static func newInstance() -> FoodSprite {
        let foodDish = FoodSprite(imageNamed: "food_dish")
        
        foodDish.physicsBody = SKPhysicsBody(rectangleOf: foodDish.size)
        foodDish.physicsBody?.categoryBitMask = FoodCategory
        foodDish.physicsBody?.contactTestBitMask = WorldCategory | RainDropCategory | CatCategory
        
        // sky=0; ground=1; umbrella=2; rain=3;  cat=4; food=5
        foodDish.zPosition = 5
        
        return foodDish
    }
}
