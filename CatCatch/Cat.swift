//
//  Cat.swift
//  CatCatch
//
//  Created by Kyle Smith on 4/4/17.
//  Copyright © 2017 Smith Coding. All rights reserved.
//

import SpriteKit

enum CatType: Int, CustomStringConvertible {
    case unknown = 0, black, white, red, orange, bad
    
    var spriteName: String {
       let spriteNames = [
        "Black",
        "White",
        "Red",
        "Orange",
        "Bad"]
        
        return spriteNames[rawValue - 1]
    }
    
    var color: SKColor {
        let colors = [
        SKColor.black,
        SKColor.white,
        SKColor.red,
        SKColor.orange,
        SKColor.purple]
        
        return colors[rawValue - 1]
    }
    
    var highlightedSpriteName: String {
        return spriteName + "-Highlighted"
    }
    
    static func random() -> CatType {
        return CatType(rawValue: Int(arc4random_uniform(5)) + 1)!
    }
    
    var description: String {
        return spriteName
    }
}


class Cat: CustomStringConvertible {
    let catType: CatType
    //var sprite: SKSpriteNode?
    var sprite: SKShapeNode?
    
    init(catType: CatType) {
        self.catType = catType
    }
    
    var description: String {
        return "type:\(catType)"
    }
}
