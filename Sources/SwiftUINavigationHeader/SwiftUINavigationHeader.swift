import SwiftUI

public extension View {
    func navigationBarState(_ barState: BarState, displayMode: NavigationBarItem.TitleDisplayMode = .inline) -> some View {
        navigationBarState(barState, displayMode: displayMode, defaultTintColor: nil)
    }
    
    func navigationBarState(_ barState: BarState, displayMode: NavigationBarItem.TitleDisplayMode = .inline, defaultTintColor: UIColor?) -> some View {
        return navigationBarTitleDisplayMode(displayMode)
            .overlay(NavigationBarView(state: barState, defaultTintColor: defaultTintColor).frame(width: 0, height: 0))
    }
}

public enum BarState: Equatable {
    case expanded
    case transitioning(CGFloat)
    case compact
}

public struct BarStateWrapper {
    public let state: BarState
    let baseTintColor: UIColor
}

fileprivate struct NavigationBarView: UIViewControllerRepresentable {
    let barState: BarState
    let defaultTintColor: UIColor?
    
    init(state: BarState, defaultTintColor: UIColor?) {
        self.barState = state
        self.defaultTintColor = defaultTintColor
    }
    
    func makeUIViewController(context: Context) -> NavigationViewWrapperController {
        let vc = NavigationViewWrapperController()
        if let defaultTintColor = defaultTintColor {
            vc.defaultTintColor = defaultTintColor
        }
        return vc
    }
    
    func updateUIViewController(_ uiViewController: NavigationViewWrapperController, context: Context) {
        uiViewController.setNavigationBarTransitionState(barState)
    }
    
    static func dismantleUIViewController(_ uiViewController: NavigationViewWrapperController, coordinator: Coordinator) {
        //
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    
    class Coordinator {
        
    }
    
    class NavigationViewWrapperController: UIViewController {
        
        var currentBarState: BarState = .expanded
        var defaultTintColor: UIColor = .systemBlue
        
        override func viewWillAppear(_ animated: Bool) {
            setNavigationBarTransitionState(currentBarState)
        }
        
        override func viewDidAppear(_ animated: Bool) {
            setNavigationBarTransitionState(currentBarState)
        }
        
        override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()
            
            setNavigationBarTransitionState(currentBarState)
        }
        
        private var navigationBar: UINavigationBar? {
            //(view.next as? UIViewController)?.navigationController?.navigationBar
            return findNavBar(self.view)
        }
        
        private var isActive: Bool {
            self.navigationController?.topViewController == self.parent
        }
        
        func setNavigationBarTransitionState(_ state: BarState) {
            guard isActive else { return }
            
            switch state {
            case .expanded:
                navigationBar?.backgroundView?.alpha = 0
                updateTintColor(0)
                setNavigationBarShadow(opacity: 1)
                break
            case .compact:
                navigationBar?.backgroundView?.alpha = 1
                updateTintColor(1)
                setNavigationBarShadow(opacity: 0)
                break
            case .transitioning(let percentCompleted):
                navigationBar?.backgroundView?.alpha = percentCompleted
                updateTintColor(percentCompleted)
                setNavigationBarShadow(opacity: Float(1-percentCompleted))
                break
            }
            currentBarState = state
        }
        
        private func setNavigationBarShadow(opacity: Float) {
            
            navigationBar?.rawBarButtons.forEach({
                $0.layer.shadowOffset = .zero
                $0.layer.shadowRadius = 10
                $0.layer.shadowOpacity = opacity
            })
            if opacity > 0 {
                navigationBar?.rawContentView?.clipsToBounds = false
            }
        }
        
        private func updateTintColor(_ saturation: CGFloat) {
            let tintColor = saturation <= 0 ? .white : defaultTintColor.withSaturation(saturation)
            navigationBar?.tintColor = tintColor
        }
        
        
        private func findNavBar(_ subview: UIView?) -> UINavigationBar? {
            guard let subview = subview else { return nil }
            
            for v in subview.subviews {
                if let navBar = v as? UINavigationBar {
                    return navBar
                }
            }
            
            return findNavBar(subview.superview)
        }
        
        /// go downwards
        /*private func findNavBar(_ root: UIView?) -> UINavigationBar? {
            guard let root = root else { return nil }

            var navbar: UINavigationBar? = nil
            for v in root.subviews {
                if let navBar = v as? UINavigationBar {
                    navbar = navBar
                    break
                } else {
                    navbar = findNavBar(v)
                    if navbar != nil { break }
                }
            }

            return navbar
        }*/
    }
}
