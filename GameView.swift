import SwiftUI
import SceneKit

struct GameView: View {
    var body: some View {
        SceneKitView()
            .ignoresSafeArea()
    }
}

struct SceneKitView: UIViewRepresentable {
    func makeUIView(context: Context) -> SCNView {
        let view = SCNView()
        view.scene = GameScene()
        view.allowsCameraControl = false
        view.showsStatistics = true
        view.backgroundColor = UIColor.black
        return view
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {}
}
