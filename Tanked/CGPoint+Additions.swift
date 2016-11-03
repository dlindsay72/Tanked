//
//  CGPoint+Additions.swift
//  Tanked
//
//  Created by Dan Lindsay on 2016-11-02.
//  Copyright © 2016 Dan Lindsay. All rights reserved.
//

import UIKit

extension CGPoint {
    
    func manhattanDistance(to: CGPoint) -> CGFloat {
        
        return (abs(x - to.x) + abs(y - to.y))
    }
}
