//
//  File.swift
//  
//
//  Created by Alexander Eichhorn on 12.07.20.
//

import UIKit

extension UINavigationBar {
    
    var backgroundView: UIView? {
        return subviews.first(where: { NSStringFromClass($0.classForCoder) == "_UIBarBackground" })
    }
    
    var rawContentView: UIView? {
        subviews.first(where: { NSStringFromClass($0.classForCoder) == "_UINavigationBarContentView" })
    }
    
    var rawBarButtons: [UIView] {
        return rawContentView?.subviews ?? [] //.filter({ NSStringFromClass($0.classForCoder) == "_UIButtonBarButton" }) ?? []
    }
    
}

extension UIColor {
    
    func withSaturation(_ saturation: CGFloat) -> UIColor {
        var hue: CGFloat = 0, oldSaturation: CGFloat = 0, brightness: CGFloat = 0, alpha: CGFloat = 0
        
        if getHue(&hue, saturation: &oldSaturation, brightness: &brightness, alpha: &alpha) {
            return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
        } else { // seems to be happening in iOS 12
            var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, cAlpha: CGFloat = 0
            getRed(&red, green: &green, blue: &blue, alpha: &cAlpha)
            
            UIColor(red: red, green: green, blue: blue, alpha: cAlpha).getHue(&hue, saturation: &oldSaturation, brightness: &brightness, alpha: &alpha)
            return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
        }
        
    }

}

extension Collection where Indices.Iterator.Element == Index {
    
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Iterator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
    
}
