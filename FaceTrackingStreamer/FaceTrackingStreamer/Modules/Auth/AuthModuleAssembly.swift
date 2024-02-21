import Foundation

protocol IAuthModuleAssembly {
    func assemble() -> any IModule
}

final class AuthModuleAssembly: BaseModuleAssembly, IAuthModuleAssembly {
    
    func assemble() -> any IModule {
        let view = AuthViewController()
        let presenter = AuthPresenter(authService: servicesAssembly.authService)
        view.presenter = presenter
        return Module(viewToPresent: view, viewOutput: presenter)
    }
}
