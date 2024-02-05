import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        
//        let endpointStorage = ApiEndpointStorage(suiteName: "PocketTracker")
//        let faceTrackingVC = OldFaceTrackingViewController(endpointStorage: endpointStorage)
        let navVc = UINavigationController(rootViewController: StartViewController())
        
        window.rootViewController = navVc
        self.window = window
        window.makeKeyAndVisible()
    }
}

