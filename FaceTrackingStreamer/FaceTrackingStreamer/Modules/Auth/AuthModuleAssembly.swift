import Foundation

protocol IAuthModuleAssembly {
    func assemble(for coordinator: ICoordinator) -> any IModule
}

final class AuthModuleAssembly: BaseModuleAssembly, IAuthModuleAssembly {
    
    func assemble(for coordinator: ICoordinator) -> any IModule {
        let view = AuthViewController()
        let presenter = AuthPresenter(
            view: view,
            authService: servicesAssembly.authService,
            sessionStorage: servicesAssembly.sessionStorage,
            sessionProvider: servicesAssembly.sessionProvider,
            coordinator: coordinator
        )
        view.presenter = presenter
        return Module(viewToPresent: view, viewOutput: presenter)
    }
}
