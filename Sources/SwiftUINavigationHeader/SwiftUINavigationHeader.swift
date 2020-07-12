import SwiftUI

public extension View {
    func navigationBarState(_ barState: BarState) -> some View {
        return navigationBarTitleDisplayMode(.inline)
            .overlay(NavigationBarView(state: barState).frame(width: 0, height: 0))
    }
}

public enum BarState {
    case expanded
    case transitioning(CGFloat)
    case compact
}

fileprivate struct NavigationBarView: UIViewControllerRepresentable {
    let barState: BarState
    
    init(state: BarState) {
        self.barState = state
    }
    
    func makeUIViewController(context: Context) -> NavigationViewWrapperController {
        return NavigationViewWrapperController()
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
        
        override func viewDidAppear(_ animated: Bool) {
            setNavigationBarTransitionState(currentBarState)
        }
        
        private var navigationBar: UINavigationBar? {
            (view.next as? UIViewController)?.navigationController?.navigationBar
        }
        
        func setNavigationBarTransitionState(_ state: BarState) {
            switch state {
            case .expanded:
                navigationBar?.backgroundView?.alpha = 0
                setNavigationBarShadow(opacity: 1)
                break
            case .compact:
                navigationBar?.backgroundView?.alpha = 1
                setNavigationBarShadow(opacity: 0)
                break
            case .transitioning(let percentCompleted):
                navigationBar?.backgroundView?.alpha = percentCompleted
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
        }
    }
}
