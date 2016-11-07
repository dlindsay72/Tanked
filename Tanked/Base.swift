//
//  Base.swift
//  Tanked
//
//  Created by Dan Lindsay on 2016-11-02.
//  Copyright © 2016 Dan Lindsay. All rights reserved.
//

import UIKit
import SpriteKit

class Base: GameItem {
    
    var hasBuilt = false
    
    func reset() {
        hasBuilt = false
    }
    
    func setOwner(_ owner: Player) {
        
        self.owner = owner
        hasBuilt = true
        self.colorBlendFactor = 0.9
        
        if owner == .red {
            color = UIColor(red: 1, green: 0.4, blue: 0.1, alpha: 1)
        } else {
            color = UIColor(red: 0.1, green: 0.5, blue: 1, alpha: 1)
        }
    }
    
    func buildUnit() -> Unit? {
        //ensure bases build only one thing per turn
        guard hasBuilt == false else { return nil }
        hasBuilt = true
        
        //create a new unit
        let unit: Unit
        if owner == .red {
            
            unit = Unit(imageNamed: "tankRed")
        } else {
            unit = Unit(imageNamed: "tankBlue")
        }
        
        //mark it as having moved and fired already
        unit.hasMoved = true
        unit.hasFired = true
        
        //give it the same owner and position as this base
        unit.owner = owner
        unit.position = position
        
        //give it the correct zPosition
        unit.zPosition = zPositions.unit
        
        //send it back to the caller
        return unit
    }
}


















