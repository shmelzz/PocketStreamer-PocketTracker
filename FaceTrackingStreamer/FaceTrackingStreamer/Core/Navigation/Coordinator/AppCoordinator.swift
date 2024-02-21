//
//  AppCoordinator.swift
//  FaceTrackingStreamer
//
//  Created by Elizaveta Shelemekh on 21.02.2024.
//

import Foundation

protocol Coordinatable: AnyObject {
    func start()
}

enum LaunchInstructor {
    case authorization
    case main
        
    static func setup() -> LaunchInstructor {
//        switch (Session.isSeenOnboarding, Session.isAuthorized) {
//        case (false, false), (true, false):
//            return .authorization
//        case (true, true):
//            return .main
//        }
        return .authorization
    }
}

final class AppCoordinator: BaseCoordinator {
    
    private let coordinatorFactory: ICoordinatorFactory
    private let router : IRouter
    
    fileprivate var instructor: LaunchInstructor {
        return LaunchInstructor.setup()
    }
    
    init(router: IRouter, factory: ICoordinatorFactory) {
        self.router  = router
        self.coordinatorFactory = factory
    }
    
    func start() {
        switch instructor {
        case .authorization:
            startAuthorizationFlow()
        case .main:
            startMainFlow()
        }
    }
    
    private func startAuthorizationFlow() {
        let coordinator = coordinatorFactory.makeAuthorizationCoordinator(router: router)
        coordinator.finishFlow = { [unowned self, unowned coordinator] in
            self.removeDependency(coordinator)
            self.start()
        }
        addDependency(coordinator)
        coordinator.start()
    }
    
    private func startMainFlow() {
        let coordinator = coordinatorFactory.makeMainCoordinator(router: router)
        coordinator.finishFlow = { [unowned self, unowned coordinator] in
            self.start()
            self.removeDependency(coordinator)
        }
        addDependency(coordinator)
        coordinator.start()
    }
}
