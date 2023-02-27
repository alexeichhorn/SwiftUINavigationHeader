import SwiftUI

public extension View {
    
    @_disfavoredOverload
    func navigationBarState(_ barState: BarState, displayMode: NavigationBarItem.TitleDisplayMode = .inline, defaultTintColor: UIColor? = nil) -> some View {
        return navigationBarTitleDisplayMode(displayMode)
            .overlay(NavigationBarView(state: barState, defaultTintColor: defaultTintColor).frame(width: 0, height: 0))
    }
    
    func navigationBarState(_ barState: BarState, displayMode: NavigationBarItem.TitleDisplayMode = .inline, defaultTintColor: Color) -> some View {
        return navigationBarTitleDisplayMode(displayMode)
            .overlay(NavigationBarView(state: barState, defaultTintColor: UIColor(defaultTintColor)).frame(width: 0, height: 0))
    }
}

extension View {
    
    func navigationBarStateForHeaderContainer(_ barState: BarState, defaultTintColor: UIColor) -> some View {
        return navigationBarTitleDisplayMode(.inline)
            .overlay(NavigationBarView(state: barState, defaultTintColor: defaultTintColor, inHeaderContainer: true).allowsHitTesting(false))
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
    let inHeaderContainer: Bool
    
    init(state: BarState, defaultTintColor: UIColor?, inHeaderContainer: Bool = false) {
        self.barState = state
        self.defaultTintColor = defaultTintColor
        self.inHeaderContainer = inHeaderContainer
    }
    
    func makeUIViewController(context: Context) -> NavigationViewWrapperController {
        let vc = NavigationViewWrapperController()
        if let defaultTintColor = defaultTintColor {
            vc.defaultTintColor = defaultTintColor
        }
        vc.inHeaderContainer = inHeaderContainer
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
        var inHeaderContainer = false
        
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
        
        static private var navigationBarObserver: NSKeyValueObservation?
        
        private var backImageTintColorLock = NSLock()
        
        private func updateTintColor(_ saturation: CGFloat) {
            
            if #available(iOS 16.0, *) {
                
                let tintColor = saturation <= 0 ? UIColor(white: CGFloat.random(in: 0.999..<1.0), alpha: 1.0) : defaultTintColor.withSaturation(saturation)
                
                navigationBar?.tintColor = tintColor
                
                if inHeaderContainer {
                    
                    let containsReplicantViews = navigationBar?.rawBarButtons.contains(where: { NSStringFromClass($0.classForCoder) == "_UIReplicantView" }) ?? false
                    let isAnimating = (navigationBar?.rawBarButtons.allSatisfy { !($0.layer.animationKeys()?.isEmpty ?? true) } ?? true) || containsReplicantViews
                    
                    let appearance = UINavigationBarAppearance()
                    appearance.configureWithDefaultBackground()
                    //appearance.backgroundEffect = UIBlurEffect(style: .dark)
                    
                    let buttonAppearance = UIBarButtonItemAppearance()
                    buttonAppearance.normal.titleTextAttributes = [.foregroundColor: tintColor]
                    buttonAppearance.highlighted.titleTextAttributes = buttonAppearance.normal.titleTextAttributes
                    buttonAppearance.focused.titleTextAttributes = buttonAppearance.normal.titleTextAttributes
                    buttonAppearance.disabled.titleTextAttributes = buttonAppearance.normal.titleTextAttributes
                    
                    appearance.buttonAppearance = buttonAppearance
                    appearance.backButtonAppearance = buttonAppearance
                    
                    if !isAnimating {
                        parent?.navigationItem.standardAppearance = appearance
                        parent?.navigationItem.compactAppearance = appearance
                        parent?.navigationItem.scrollEdgeAppearance = appearance
                        parent?.navigationItem.compactScrollEdgeAppearance = appearance
                        
                        
                        if let backImageView = navigationBar?.rawBarButtons.min(by: \.frame.minX)?.subviews.filter({ !$0.isHidden }).compactMap({ $0.subviews.first as? UIImageView }).first {
                            
                            //backImageView.tintColor = tintColor
                            
                            Self.navigationBarObserver = backImageView.observe(\.tintColor) { [weak self] imageView, change in
                                if imageView.tintColor.distance(to: tintColor) > 0.0001 {
                                    self?.backImageTintColorLock.tryIfAvailable {
                                        imageView.tintColor = tintColor
                                    }
                                }
                            }
                        }
                    } else {
                        // make sure tint color doesn't change by a view update during animation
                        Self.navigationBarObserver = navigationBar?.observe(\.tintColor) { [weak self] navigationBar, change in
                            if navigationBar.tintColor.distance(to: tintColor) > 0.0001 {
                                self?.backImageTintColorLock.tryIfAvailable {
                                    navigationBar.tintColor = tintColor
                                }
                            }
                        }
                    }
                }
                
            } else {
                let tintColor = saturation <= 0 ? .white : defaultTintColor.withSaturation(saturation)
                navigationBar?.tintColor = tintColor
            }
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
