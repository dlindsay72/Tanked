//
//  GameScene.swift
//  Tanked
//
//  Created by Dan Lindsay on 2016-11-02.
//  Copyright © 2016 Dan Lindsay. All rights reserved.
//

import SpriteKit


class GameScene: SKScene {
    
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    
    var lastTouch = CGPoint.zero
    var originalTouch = CGPoint.zero
    var cameraNode: SKCameraNode!
    
    override func didMove(to view: SKView) {
        
       cameraNode = camera!
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let touch = touches.first else { return }
        
        lastTouch = touch.location(in: self.view)
        
        originalTouch = lastTouch
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let touch = touches.first else { return }
        
        let touchLocation = touch.location(in: self.view)
        let newX = cameraNode.position.x + (lastTouch.x - touchLocation.x)
        let newY = cameraNode.position.y + (touchLocation.y - lastTouch.y)
        
        cameraNode.position = CGPoint(x: newX, y: newY)
        
        lastTouch = touchLocation
    }
    
   
    
    
}
