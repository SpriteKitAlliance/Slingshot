//
//  Extensions.swift
//  Slingshot
//
//  Created by Skyler Lauren on 12/23/16.
//  Copyright © 2016 Sprite Kit Alliance. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to
//  deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
//  IN THE SOFTWARE.

import Foundation
import UIKit

extension CGFloat {
    public func clamped(v1: CGFloat, _ v2: CGFloat) -> CGFloat {
        let min = v1 < v2 ? v1 : v2
        let max = v1 > v2 ? v1 : v2
        return self < min ? min : (self > max ? max : self)
    }
}

extension CGPoint {
    
    public func distanceFromPoint(point: CGPoint) -> CGFloat{
        let xDist = (x - point.x)
        let yDist = (y - point.y)
        return sqrt((xDist * xDist) + (yDist * yDist))
    }
    
    public func addPoint(point: CGPoint) -> CGPoint{
        return CGPoint(x: self.x+point.x, y: self.y+point.y)
    }
    
    public func subtract(point: CGPoint) -> CGPoint{
        return CGPoint(x: self.x-point.x, y: self.y-point.y)
    }
}

