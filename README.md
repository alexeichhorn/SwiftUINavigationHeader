# SwiftUINavigationHeader

Create a great navigation header in few lines of code in SwiftUI

```
import SwiftUINavigationHeader

struct ThirdView: View {
    var body: some View {
        NavigationHeaderContainer(bottomFadeout: true) {
            Image("roadster")
                .resizable()
                .scaledToFill()
        } content: {
            
            topView
                .transformEffect(.init(translationX: 0, y: -100))
                .padding(.bottom, -100)
            
            Text(loremIpsum)
                .font(.body)
                .padding(32)
        }

    }
    
    private var topView: some View {
        Image("roadster")
            .resizable()
            .scaledToFill()
            .clipShape(Circle())
            .shadow(radius: 10)
            .frame(width: 200, height: 200, alignment: .center)
    }
}
