import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    private var coordinator: ICoordinator?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        window.makeKeyAndVisible()
        
        let rootVC = UINavigationController()
        window.rootViewController = rootVC
        
        coordinator = makeCoordinator(rootController: rootVC)
        coordinator?.startFlow()
    }
    
    private func makeCoordinator(rootController: UINavigationController) -> ICoordinator {
        let requestBuilder = RequestBuilder()
        let urlSession = URLSession(configuration: .default)
        
        let requestManager = RequestManager(requestBuilder: requestBuilder, urlSession: urlSession)
        let endpointProvider = EndpointProvider(apiEndpointStorage: ApiEndpointStorage(suiteName: "PocketTracker"))
        
        let servicesAssembly = ServicesAssembly(requestManager: requestManager, endpointProvider: endpointProvider)
        requestBuilder.setSessionProvider(servicesAssembly.sessionProvider)
        
        return AppCoordinator(
            router: Router(rootController: rootController),
            factory: CoordinatorFactory(modulesAssembly: ModulesAssembly(servicesAssembly: servicesAssembly))
        )
    }
}

