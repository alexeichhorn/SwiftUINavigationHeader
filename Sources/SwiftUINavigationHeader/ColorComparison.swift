//
//  ColorComparison.swift
//  SwiftUINavigationHeader
//
//  Created by Alexander Eichhorn on 06.08.22.
//

import UIKit

extension UIColor {
    
    fileprivate var rgba: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        var r, g, b, a: CGFloat
        (r, g, b, a) = (0, 0, 0, 0)
        self.getRed(&r, green: &g, blue: &b, alpha: &a)
        return (r, g, b, a)
    }
    
    /// squared euclidean distance of rgba vectors
    func distance(to other: UIColor) -> CGFloat {
        let lhs = self.rgba
        let rhs = other.rgba
        
        return (lhs.red - rhs.red) * (lhs.red - rhs.red) + (lhs.green - rhs.green) * (lhs.green - rhs.green) + (lhs.blue - rhs.blue) * (lhs.blue - rhs.blue) + (lhs.alpha - rhs.alpha) * (lhs.alpha - rhs.alpha)
    }
    
}
