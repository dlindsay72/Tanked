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
    static let selectionMarker: CGFloat = 60
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
    var selectedItem: GameItem? {
        didSet {
            selectedItemChanged()
        }
    }
    
    var selectionMarker: SKSpriteNode!
    var moveSquares = [SKSpriteNode]()
    
    var menuBar: SKSpriteNode!
    var menuBarPlayer: SKSpriteNode!
    var menuBarEndTurn: SKSpriteNode!
    var menuBarCapture: SKSpriteNode!
    var menuBarBuild: SKSpriteNode!
    
    
    override func didMove(to view: SKView) {
        
        for _ in 0..<41 {
            
            let moveSquare = SKSpriteNode(color: UIColor.white, size: CGSize(width: 64, height: 64))
            
            moveSquare.alpha = 0
            moveSquare.name = "move"
            moveSquares.append(moveSquare)
            
            addChild(moveSquare)
        }
        
        cameraNode = camera!
        createStartingLayout()
        
        selectionMarker = SKSpriteNode(imageNamed: "selectionMarker")
        selectionMarker.zPosition = zPositions.selectionMarker
        
        addChild(selectionMarker)
        
        hideSelectionMarker()
        createMenuBar()
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
            
            unit.position = CGPoint(x: -128 + (i * 64), y: -128)
            
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
            } else if node.name == "endturn" {
                endTurn()
                return
            } else if node.name == "capture" {
                captureBase()
                return
            } else if node.name == "build" {
                
                guard let selectedBase = selectedItem as? Base else { return }
                
                if let unit = selectedBase.buildUnit() {
                    //we got a new unit back!
                    units.append(unit)
                    addChild(unit)
                }
                
                selectedItem = nil
                return
            }
        }
        
        if tappedMove != nil {
            //move or attack
            guard let selectedUnit = selectedItem as? Unit else { return }
            
            let tappedUnits = units.itemsAt(position: tappedMove.position)
            
            if tappedUnits.count == 0 {
                selectedUnit.move(to: tappedMove)
            } else {
                selectedUnit.attack(target: tappedUnits[0])
            }
            
            selectedItem = nil
            
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
    
    func showSelectionMarker() {
        
        guard let item = selectedItem else { return }
        
        selectionMarker.removeAllActions()
        
        selectionMarker.position = item.position
        selectionMarker.alpha = 1
        
        let rotate = SKAction.rotate(byAngle: -CGFloat.pi, duration: 1)
        let repeatForever = SKAction.repeatForever(rotate)
        
        selectionMarker.run(repeatForever)
    }
    
    func hideSelectionMarker() {
        
        selectionMarker.removeAllActions()
        selectionMarker.alpha = 0
    }
    
    func selectedItemChanged() {
        //hide all buttons by default
        hideMoveOptions()
        hideBuildMenu()
        hideCaptureMenu()
        
        if let item = selectedItem {
            //something was selected, show the selection marker
            showSelectionMarker()
            
            if selectedItem is Unit {
                //it was a unit, let the user choose where to move
                showMoveOptions()
                //get the list of bases at this items position
                let currentBases = bases.itemsAt(position: item.position)
                
                if currentBases.count > 0 {
                    //we found a base we didn't already own
                    if currentBases[0].owner != currentPlayer {
                        
                        showCaptureMenu()
                    }
                }
            } else {
                showBuildMenu()
            }
            
        } else {
            //nothing was selected
            hideSelectionMarker()
        }
    }
    
    func hideMoveOptions() {
        
        moveSquares.forEach {
            
            $0.alpha = 0
        }
    }
    
    func showMoveOptions() {
        
        guard let selectedUnit = selectedItem as? Unit else { return }
        
        var counter = 0
        
        //loop from 5 squares to the left and right, bottom to top
        for row in -5..<5 {
            for col in -5..<5 {
                //only allow moves that are 4 or fewer spaces
                let distance = abs(col) + abs(row)
                
                guard distance <= 4 else { continue }
                
                //calculate the map position for this square, then see which items are there
                
                let squarePosition = CGPoint(x: selectedUnit.position.x + CGFloat(col * 64), y: selectedUnit.position.y + CGFloat(row * 64))
                let currentUnits = units.itemsAt(position: squarePosition)
                
                var isAttack = false
                
                if currentUnits.count > 0 {
                    if currentUnits[0].owner == currentPlayer || currentUnits[0].isAlive == false {
                        //if there is a unit there and it's ours or dead, ignore this move
                        continue
                    } else {
                        // if there's any other unit there, this is an attack
                        isAttack = true
                    }
                }
                // if this is an attack, and we haven't already fired, color the square red
                if isAttack {
                    
                    guard selectedUnit.hasFired == false else { continue }
                    
                    moveSquares[counter].color = UIColor.red
                } else {
                    // if this is a move and we haven't already moved, color the square white
                    guard selectedUnit.hasMoved == false else { continue }
                    
                    moveSquares[counter].color = UIColor.white
                }
                
                //position the square, make it partially visible, then add 1 to the counter so the next move square is used
                moveSquares[counter].position = squarePosition
                moveSquares[counter].alpha = 0.35
                
                counter += 1
                
            }
        }
    }
    
    func createMenuBar() {
        //create a translucent black menu bar, positioned near the top
        menuBar = SKSpriteNode(color: UIColor(white: 0, alpha: 0.65), size: CGSize(width: 1024, height: 60))
        
        menuBar.position = CGPoint(x: 0, y: 354)
        menuBar.zPosition = zPositions.menuBar
        cameraNode.addChild(menuBar)
        
        //add the "Red's Turn" sprite to the top left corner
        menuBarPlayer = SKSpriteNode(imageNamed: "red")
        menuBarPlayer.anchorPoint = CGPoint(x: 0, y: 0.5)
        menuBarPlayer.position = CGPoint(x: -512 + 20, y: 0)
        menuBar.addChild(menuBarPlayer)
        
        //add the red "End Turn" sprite to the top right corner
        menuBarEndTurn = SKSpriteNode(imageNamed: "redEndTurn")
        menuBarEndTurn.anchorPoint = CGPoint(x: 1, y: 0.5)
        menuBarEndTurn.position = CGPoint(x: 512 - 20, y: 0)
        menuBarEndTurn.name = "endturn"
        menuBar.addChild(menuBarEndTurn)
        
        //add the "Capture" button to the center of the menu bar
        menuBarCapture = SKSpriteNode(imageNamed: "capture")
        menuBarCapture.position = CGPoint(x: 0, y: 0)
        menuBarCapture.name = "capture"
        menuBar.addChild(menuBarCapture)
        hideCaptureMenu()
        
        //add the "Build" button tot he center of the menu bar
        menuBarBuild = SKSpriteNode(imageNamed: "build")
        menuBarBuild.position = CGPoint(x: 0, y: 0)
        menuBarBuild.name = "build"
        menuBar.addChild(menuBarBuild)
        hideBuildMenu()
        
    }
    
    func hideCaptureMenu() {
        menuBarCapture.alpha = 0
    }
    
    func showCaptureMenu() {
        menuBarCapture.alpha = 1
    }
    
    func hideBuildMenu() {
        menuBarBuild.alpha = 0
    }
    
    func showBuildMenu() {
        menuBarBuild.alpha = 1
    }
    
    func endTurn() {
        
        if currentPlayer == .red {
            //switch the controlling player
            currentPlayer = .blue
            //update the 2 textures
            menuBarEndTurn.texture = SKTexture(imageNamed: "blueEndTurn")
            
            let setTexture = SKAction.setTexture(SKTexture(imageNamed: "blue"), resize: true)
            
            menuBarPlayer.run(setTexture)
        } else {
            currentPlayer = .red
            menuBarEndTurn.texture = SKTexture(imageNamed: "redEndTurn")
            
            let setTexture = SKAction.setTexture(SKTexture(imageNamed: "red"), resize: true)
            menuBarPlayer.run(setTexture)
        }
        //resize all bases and units
        bases.forEach { $0.reset() }
        units.forEach { $0.reset() }
        
        //remove any dead units
        units = units.filter { $0.isAlive }
        //clear whatever was selected
        selectedItem = nil
    }
    
    func captureBase() {
        
        guard let item = selectedItem else { return }
        
        let currentBases = bases.itemsAt(position: item.position)
        
        //if we have a base here...
        if currentBases.count > 0 {
            //...and it's not owned by us already
            if currentBases[0].owner != currentPlayer {
                //capture it!
                currentBases[0].setOwner(currentPlayer)
                selectedItem = nil
            }
        }
    }
    
}


















