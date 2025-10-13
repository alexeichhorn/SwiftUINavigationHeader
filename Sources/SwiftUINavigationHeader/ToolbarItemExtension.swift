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

public extension View {

    @ViewBuilder
    func tintColor(for barState: BarStateWrapper) -> some View {
        if #available(iOS 26.0, *) {
            self
        } else {
            let tintColor = Self.computeTintColor(for: barState)
            if #available(iOS 16.0, *) {
                self.tint(Color(tintColor))
            } else {
                self.foregroundColor(Color(tintColor))
            }
        }
    }

    private static func computeTintColor(for barState: BarStateWrapper) -> UIColor {
        switch barState.state {
        case .expanded: return .white
        case .transitioning(let percentage):
            return barState.baseTintColor.withSaturation(percentage)
        case .compact: return barState.baseTintColor
        }
    }

}
