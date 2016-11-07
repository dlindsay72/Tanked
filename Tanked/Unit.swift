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
    
    //give each unit 3 health points by default
    var health = 3 {
        
        didSet{
            //remove any existing flashing for this unit
            removeAllActions()
            
            //if we still have health
            if health > 0 {
                //make fade out and fade in actions
                let fadeOut = SKAction.fadeAlpha(to: 0.5, duration: 0.25 * Double(health))
                let fadeIn = SKAction.fadeAlpha(to: 1, duration: 0.25 * Double(health))
                
                //put them together in a sequence and make them repeat forever
                let sequence = SKAction.sequence([fadeIn, fadeOut])
                let repeatForever = SKAction.repeatForever(sequence)
                
                run(repeatForever)
            } else {
                //if the tank is destroyed, change it's texture to a burnt out tank
                texture = SKTexture(imageNamed: "tankDead")
                
                //force it to have 100% alpha
                alpha = 1
                
                //mark it as dead, so it can't be moved anymore
                isAlive = false
            }
        }
    }
    
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
        //make sure this unit has not fired already
        guard hasFired == false else { return }
        hasFired = true
        //turn the tank to face the target
        rotate(toFace: target)
        //create a new bullet and give it the same color as this tank
        let bullet: SKSpriteNode
        
        if owner == .red {
            
            bullet = SKSpriteNode(imageNamed: "bulletRed")
        } else {
            
            bullet = SKSpriteNode(imageNamed: "bulletBlue")
        }
        
        //place the bullet underneath the unit
        bullet.zPosition = zPositions.bullet
        //add the bullet to our parent - i.e. the game scene
        parent?.addChild(bullet)
        //draw a line from the bullet to the target
        let path = UIBezierPath()
        
        path.move(to: position)
        path.addLine(to: target.position)
        //create an action for that movement
        let move = SKAction.follow(path.cgPath, asOffset: false, orientToPath: true, speed: 500)
        //create an action that makes the target take damage
        let damageTarget = SKAction.run { [unowned target] in
            target.takeDamage()
        }
            //create an action for the smoke and fire particle emitter
            let createExplosion = SKAction.run { [unowned self] in
                //create the smoke emitter
                if let smoke = SKEmitterNode(fileNamed: "Smoke") {
                    smoke.position = target.position
                    smoke.zPosition = zPositions.smoke
                    self.parent?.addChild(smoke)
                }
                //create the fire emitter over the smoke emitter
                if let fire = SKEmitterNode(fileNamed: "Fire") {
                    fire.position = target.position
                    fire.zPosition = zPositions.fire
                    self.parent?.addChild(fire)
                }
                
            }
            //create a combined sequence: bullet moves, target takes damage, explosion is created, then bullet is removed from the game
            let sequence = [move, damageTarget, createExplosion, SKAction.removeFromParent()]
            
            //run that sequence on the bullet
            bullet.run(SKAction.sequence(sequence))
    }
    
    
    func rotate(toFace node: SKNode) {
        let angle = atan2(node.position.y - position.y, node.position.x - position.x)
        
        zRotation = angle - (CGFloat.pi / 2)
    }
    
    func takeDamage() {
        health -= 1
    }
    
    func reset() {
        
        if isAlive == true {
            
            hasFired = false
            hasMoved = false
        } else {
            
            let fadeAway = SKAction.fadeOut(withDuration: 0.5)
            let sequence = [fadeAway, SKAction.removeFromParent()]
            
            run(SKAction.sequence(sequence))
        }
    }

}






















