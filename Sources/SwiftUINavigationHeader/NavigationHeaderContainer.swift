//
//  NavigationHeaderContainer.swift
//  
//
//  Created by Alexander Eichhorn on 12.07.20.
//

import SwiftUI

public struct NavigationHeaderContainer<Header, Content>: View where Header: View, Content: View {
    let header: Header
    let content: Content
    let bottomFadeout: Bool
    let headerAlignment: Alignment
    
    private var headerHeight: ((CGSize) -> CGFloat)?
    
    public init(bottomFadeout: Bool = false, headerAlignment: Alignment = .center, @ViewBuilder header: () -> Header, @ViewBuilder content: () -> Content) {
        self.header = header()
        self.content = content()
        self.bottomFadeout = bottomFadeout
        self.headerAlignment = headerAlignment
    }
    
    public var body: some View {
        GeometryReader { outerGeo in
            ScrollView {
                //VStack {
                    GeometryReader { geo in
                        ZStack(alignment: .top) {
                            
                            header
                                .frame(width: geo.size.width, height: self.unscaledBackdropHeight(for: outerGeo), alignment: headerAlignment)
                                .clipped()
                                .scaleEffect(self.backdropScale(for: geo, outerGeometry: outerGeo), anchor: .bottom)
                            
                            // top fade out
                            Rectangle()
                                .foregroundColor(.clear)
                                .background(LinearGradient(gradient: self.topGradient, startPoint: .top, endPoint: .bottom))
                                .frame(height: 120, alignment: .top)
                                .transformEffect(CGAffineTransform(translationX: 0, y: self.backdropTranslation(for: geo)))
                            
                            
                            if bottomFadeout {
                                // bottom fade out
                                Rectangle()
                                    .foregroundColor(.clear)
                                    .background(LinearGradient(gradient: Gradient(colors: [.clear, Color(.systemBackground)]), startPoint: .center, endPoint: .bottom))
                            }
                            
                        }
                        .navigationBarState(self.navigationBarState(for: geo, outerGeometry: outerGeo))
                    }
                    .frame(height: self.unscaledBackdropHeight(for: outerGeo))
                    
                    content
                //}
            }
        }
        
    }
    
    
    public func headerHeight(_ closure: @escaping (_ frameSize: CGSize) -> CGFloat) -> some View {
        var modifiedSelf = self
        modifiedSelf.headerHeight = closure
        return modifiedSelf
    }
    
    
    private func unscaledBackdropHeight(for geometry: GeometryProxy) -> CGFloat {
        
        if let height = self.headerHeight?(geometry.size) {
            return height
        }
        
        let width = geometry.size.width
        let height = width / 16.0 * 9.0
        if height < 300 { return height + 84 }
        return height
    }
    
    private func backdropScale(for geometry: GeometryProxy, outerGeometry: GeometryProxy) -> CGFloat {
        let frame = geometry.frame(in: .global)
        //print(frame)
        let height = unscaledBackdropHeight(for: outerGeometry)
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
    
    private func navigationBarState(for geometry: GeometryProxy, outerGeometry: GeometryProxy) -> BarState {
        let frame = geometry.frame(in: .global)
        let offset = -frame.minY + safeAreaTop // +64 works for iPhone X
        let height = unscaledBackdropHeight(for: outerGeometry)
        
        //print(frame)
        
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
            Gradient.Stop(color: Color(.systemBackground).opacity(0.3), location: 0),
            Gradient.Stop(color: .clear, location: 1)
        ])
    }
}
