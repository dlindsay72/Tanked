//
//  Array+Additions.swift
//  Tanked
//
//  Created by Dan Lindsay on 2016-11-03.
//  Copyright © 2016 Dan Lindsay. All rights reserved.
//

import UIKit

extension Array where Element: GameItem {
    
    func itemsAt(position: CGPoint) -> [Element] {
        
        return filter {
            
            let diffX = abs($0.position.x - position.x)
            let diffY = abs($0.position.y - position.y)
            
            return diffX + diffY < 20
        }
    }
}
