import Foundation

protocol IDebugMenuModuleAssembly {
    func assemble(for coordinator: ICoordinator) -> any IModule
}

final class DebugMenuModuleAssembly: BaseModuleAssembly, IDebugMenuModuleAssembly {
    
    func assemble(for coordinator: ICoordinator) -> any IModule {
        let view = DebugMenuViewController()
        let presenter = DebugMenuPresenter(
            endpointStorage: servicesAssembly.endpointStorage,
            authStorage: servicesAssembly.sessionStorage,
            view: view,
            coordinator: coordinator
        )
        view.presenter = presenter
        return Module(viewToPresent: view, viewOutput: presenter)
    }
}
