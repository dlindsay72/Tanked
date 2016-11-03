//
//  GameScene.swift
//  Tanked
//
//  Created by Dan Lindsay on 2016-11-02.
//  Copyright © 2016 Dan Lindsay. All rights reserved.
//

import SpriteKit

enum Player {
    case none, red, blue
}

enum zPositions {
    
    static let base: CGFloat = 10
    static let bullet: CGFloat = 20
    static let unit: CGFloat = 30
    static let smoke: CGFloat = 40
    static let fire: CGFloat = 50
    static let selectionmarker: CGFloat = 60
    static let menuBar: CGFloat = 70
}


class GameScene: SKScene {
    
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    
    var lastTouch = CGPoint.zero
    var originalTouch = CGPoint.zero
    var cameraNode: SKCameraNode!
    var currentPlayer = Player.red
    var units = [Unit]()
    var bases = [Base]()
    var selectedItem: GameItem?
    
    
    override func didMove(to view: SKView) {
        
        cameraNode = camera!
        createStartingLayout()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let touch = touches.first else { return }
        
        lastTouch = touch.location(in: self.view)
        
        originalTouch = lastTouch
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let touch = touches.first else { return }
        
        touchesMoved(touches, with: event)
        
        let distance = originalTouch.manhattanDistance(to: lastTouch)
        
        if distance < 44 {
            nodesTapped(at: touch.location(in: self))
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let touch = touches.first else { return }
        
        let touchLocation = touch.location(in: self.view)
        let newX = cameraNode.position.x + (lastTouch.x - touchLocation.x)
        let newY = cameraNode.position.y + (touchLocation.y - lastTouch.y)
        
        cameraNode.position = CGPoint(x: newX, y: newY)
        
        lastTouch = touchLocation
    }
    
   
    func createStartingLayout() {
        
        for row in 0..<3 {
            for col in 0..<3 {
                let base = Base(imageNamed: "base")
                base.position = CGPoint(x: -256 + (col * 256), y: -64 + (row * 256))
                
                base.zPosition = zPositions.base
                bases.append(base)
                
                addChild(base)
            }
        }
        
        for i in 0..<5 {
            //create five red tanks
            let unit = Unit(imageNamed: "tankRed")
            
            //mark them owned by red
            unit.owner = .red
            
            //position them neatly
            unit.position = CGPoint(x: -128 + (i * 64), y: -320)
            
            //give them the correct zPosition
            unit.zPosition = zPositions.unit
            
            //add them to the units array for easy lookup
            units.append(unit)
            
            //add them to the spriteKit scene
            addChild(unit)
        }
        
        for i in 0..<5 {
            //create 5 blue tanks
            let unit = Unit(imageNamed: "tankBlue")
            
            unit.owner = .blue
            
            unit.position = CGPoint(x: -128 + (i * 64), y: 704)
            
            unit.zPosition = zPositions.unit
            
            //these are rotated 180 degrees
            unit.zRotation = CGFloat.pi
            units.append(unit)
            
            addChild(unit)
        }
        
       
    }
    
    func nodesTapped(at point: CGPoint) {
        
        let tappedNodes = nodes(at: point)
        var tappedMove: SKNode!
        var tappedUnit: Unit!
        var tappedBase: Base!
        
        for node in tappedNodes {
            
            if node is Unit {
                
                tappedUnit = node as! Unit
                
            } else if node is Base {
                
                tappedBase = node as! Base
                
            } else if node.name == "move" {
                
                tappedMove = node
            }
        }
        
        if tappedMove != nil {
            //move or attack
            
        } else if tappedUnit != nil {
            
            //user tapped a unit
            if selectedItem != nil && tappedUnit == selectedItem {
                
                //it was already selected, so deselect it
                selectedItem = nil
            } else {
                
                // don't let us control enemy units or dead units
                if tappedUnit.owner == currentPlayer && tappedUnit.isAlive {
                    
                    selectedItem = tappedUnit
                }
            }
        } else if tappedBase != nil {
            
            //user tapped a base
            if tappedBase.owner == currentPlayer {
                
                //and it's theirs - select it
                selectedItem = tappedBase
            }
        } else {
            
            //user tapped something else
            selectedItem = nil
        }
    }
    
    
}


















