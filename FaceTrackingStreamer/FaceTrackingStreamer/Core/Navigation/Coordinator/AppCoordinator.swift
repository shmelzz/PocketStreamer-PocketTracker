//
//  AppCoordinator.swift
//  FaceTrackingStreamer
//
//  Created by Elizaveta Shelemekh on 21.02.2024.
//

import Foundation

enum LaunchFlow {
    case auth
    case main
        
    static func setup() -> LaunchFlow {
//        switch (Session.isSeenOnboarding, Session.isAuthorized) {
//        case (false, false), (true, false):
//            return .authorization
//        case (true, true):
//            return .main
//        }
        return .auth
    }
}

final class AppCoordinator: BaseCoordinator {
    
    private let coordinatorFactory: ICoordinatorFactory
    private let router : IRouter
    
    private var flow: LaunchFlow = {
        return LaunchFlow.setup()
    }()
    
    init(router: IRouter, factory: ICoordinatorFactory) {
        self.router  = router
        self.coordinatorFactory = factory
    }
    
    override func startFlow() {
        switch flow {
        case .auth:
            startAuthorizationFlow()
        case .main:
            startMainFlow()
        }
    }
    
    private func startAuthorizationFlow() {
        let coordinator = coordinatorFactory.buildAuthorizationCoordinator(router: router)
        coordinator.onFinish = { [weak self] in
            self?.removeDependency(coordinator)
            self?.flow = .main
            self?.startFlow()
        }
        addDependency(coordinator)
        coordinator.startFlow()
    }
    
    private func startMainFlow() {
        let coordinator = coordinatorFactory.buildMainFlowCoordinator(router: router)
        coordinator.onFinish = { [weak self, weak coordinator] in
            self?.startFlow()
            self?.removeDependency(coordinator)
        }
        addDependency(coordinator)
        coordinator.startFlow()
    }
}
