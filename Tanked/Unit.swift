//
//  Unit.swift
//  Tanked
//
//  Created by Dan Lindsay on 2016-11-02.
//  Copyright © 2016 Dan Lindsay. All rights reserved.
//

import UIKit
import SpriteKit

class Unit: GameItem {
    
    var isAlive = true
    var hasMoved = false
    var hasFired = false
    
    func move(to target: SKNode) {
        
        //refuse to let this unit move twice
        guard hasMoved == false else { return }
        
        hasMoved = true
        
        var sequence = [SKAction]()
        
        //if we need to move along the x axis now, calculate that movement and add it to the sequence array
        
        if position.x != target.position.x {
            
            let path = UIBezierPath()
            
            path.move(to: CGPoint.zero)
            
            path.addLine(to: CGPoint(x: target.position.x - position.x, y: 0))
            sequence.append(SKAction.follow(path.cgPath, asOffset: true, orientToPath: true, speed: 200))
        }
        
        //repeat for the y axis
        if position.y != target.position.y {
            
            let path = UIBezierPath()
            
            path.move(to: CGPoint.zero)
            path.addLine(to: CGPoint(x: 0, y: target.position.y - position.y))
            
            sequence.append(SKAction.follow(path.cgPath, asOffset: true, orientToPath: true, speed: 200))
        }
        run(SKAction.sequence(sequence))
    }
    
    func attack(target: Unit) {
        
    }

}
