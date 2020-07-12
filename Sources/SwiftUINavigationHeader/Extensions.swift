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
    
    var rawBarButtons: [UIView] {
        let contentView = subviews.first(where: { NSStringFromClass($0.classForCoder) == "_UINavigationBarContentView" })
        return contentView?.subviews ?? [] //.filter({ NSStringFromClass($0.classForCoder) == "_UIButtonBarButton" }) ?? []
    }
    
}

