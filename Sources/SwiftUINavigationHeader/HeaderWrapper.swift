//
//  HeaderWrapper.swift
//  
//
//  Created by Alexander Eichhorn on 12.07.20.
//

import SwiftUI

public struct HeaderWrapper<Header, Content>: View where Header: View, Content: View {
    let header: Header
    let content: Content
    
    public init(@ViewBuilder header: () -> Header, @ViewBuilder content: () -> Content) {
        self.header = header()
        self.content = content()
    }
    
    public var body: some View {
        GeometryReader { outerGeo in
            ScrollView {
                //VStack {
                    GeometryReader { geo in
                        ZStack(alignment: .bottom) {
                            
                            header
                                .frame(width: geo.size.width, height: self.unscaledBackdropHeight(for: geo), alignment: .top)
                                .scaleEffect(self.backdropScale(for: geo), anchor: .bottom)
                            
                            // top fade out
                            Rectangle()
                                .foregroundColor(.clear)
                                .background(LinearGradient(gradient: self.topGradient, startPoint: .top, endPoint: .center))
                                .transformEffect(CGAffineTransform(translationX: 0, y: self.backdropTranslation(for: geo)))
                            
                        }
                        .navigationBarHeader(barState: self.navigationBarState(for: geo))
                    }
                    .frame(height: self.unscaledBackdropHeight(for: outerGeo))
                    
                    content
                //}
            }
        }
        
    }
    
    
    // TODO: outsource it
    private func unscaledBackdropHeight(for geometry: GeometryProxy) -> CGFloat {
        let width = geometry.size.width
        let height = width / 16.0 * 9.0
        if height < 300 { return height + 84 }
        return height
    }
    
    private func backdropScale(for geometry: GeometryProxy) -> CGFloat {
        let frame = geometry.frame(in: .global)
        //print(frame)
        let height = unscaledBackdropHeight(for: geometry)
        //if frame.minY + 84 <= 0 { return 1.0 }
        let y = max(frame.minY, 0) // -84
        return (height + y) / height
    }
    
    private func backdropTranslation(for geometry: GeometryProxy) -> CGFloat {
        let frame = geometry.frame(in: .global)
        //if frame.minY <= 0 { return 0 }
        return -frame.minY
    }
    
    private var safeAreaTop: CGFloat {
        UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0
    }
    
    private func navigationBarState(for geometry: GeometryProxy) -> BarState {
        let frame = geometry.frame(in: .global)
        let offset = -frame.minY + safeAreaTop // +64 works for iPhone X
        let height = unscaledBackdropHeight(for: geometry)
        
        print(frame)
        
        if offset < height-44 {
            return .expanded
        } else if offset < height {
            return .transitioning((offset - height + 44) / 44)
        } else {
            return .compact
        }
    }
    
    private var topGradient: Gradient {
        return Gradient(stops: [
            Gradient.Stop(color: Color(.systemBackground).opacity(0.3), location: 0.0),
            Gradient.Stop(color: Color(.systemBackground).opacity(0.2), location: 0.3),
            Gradient.Stop(color: .clear, location: 0.6)
        ])
    }
}
