import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    private var coordinator: ICoordinator?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        window.makeKeyAndVisible()
        
        //        let endpointStorage = ApiEndpointStorage(suiteName: "PocketTracker")
        //        let faceTrackingVC = OldFaceTrackingViewController(endpointStorage: endpointStorage)
//        let navVc = UINavigationController(rootViewController: StartViewController())
        
        let rootVC = UINavigationController()
        window.rootViewController = rootVC
        
        coordinator = makeCoordinator(rootController: rootVC)
        coordinator?.startFlow()
    }
    
    private func makeCoordinator(rootController: UINavigationController) -> ICoordinator {
        let sessionProvider = SessionProvider()
        let requestBuilder = RequestBuilder(sessionProvider: sessionProvider)
        let urlSession = URLSession(configuration: .default)
        
        let requestManager = RequestManager(requestBuilder: requestBuilder, urlSession: urlSession)
        let endpointProvider = EndpointProvider()
        
        let servicesAssembly = ServicesAssembly(requestManager: requestManager, endpointProvider: endpointProvider)
        
        return AppCoordinator(
            router: Router(rootController: rootController),
            factory: CoordinatorFactory(modulesAssembly: ModulesAssembly(servicesAssembly: servicesAssembly))
        )
    }
}

