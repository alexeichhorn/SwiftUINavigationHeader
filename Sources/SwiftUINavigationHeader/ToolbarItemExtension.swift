//
//  ToolbarItemExtension.swift
//  SwiftUINavigationHeader
//
//  Created by Alexander Eichhorn on 26.06.22.
//

import SwiftUI

public struct HeaderToolbarItem<Content: View>: ToolbarContent {
    
    let placement: ToolbarItemPlacement
    let barState: BarStateWrapper
    let content: Content
    
    public init(placement: ToolbarItemPlacement = .automatic, barState: BarStateWrapper, @ViewBuilder content: () -> Content) {
        self.placement = placement
        self.barState = barState
        self.content = content()
    }
    
    public var body: some ToolbarContent {
        ToolbarItem(placement: placement) {
            content
                .tintColor(for: barState)
        }
    }
    
}

fileprivate extension View {
    
    func tintColor(for barState: BarStateWrapper) -> some View {
        let tintColor: UIColor
        switch barState.state {
        case .expanded: tintColor = .white
        case .transitioning(let percentage):
            tintColor = barState.baseTintColor.withSaturation(percentage)
        case .compact: tintColor = barState.baseTintColor
        }
        
        return self.foregroundColor(Color(tintColor))
    }
    
}
