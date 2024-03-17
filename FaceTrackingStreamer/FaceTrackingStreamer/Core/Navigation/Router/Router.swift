//
//  Router.swift
//  FaceTrackingStreamer
//
//  Created by Elizaveta Shelemekh on 21.02.2024.
//

import Foundation
import UIKit

typealias RouterCompletions = [UIViewController : CompletionBlock]

final class Router: IRouter {
    
    private weak var rootController: UINavigationController?
    
    private var completions: RouterCompletions
    
    init(rootController: UINavigationController) {
        self.rootController = rootController
        completions = [:]
    }
    
    var viewToPresent: UIViewController? {
        return rootController
    }
    
    // MARK: - IRouter
    
    func present(_ module: any IModule) {
        present(module, animated: true)
    }
    
    func present(_ module: any IModule, animated: Bool) {
        guard let controller = module.viewToPresent else { return }
        rootController?.present(controller, animated: animated, completion: nil)
    }
    
    func push(_ module: any IModule)  {
        push(module, animated: true)
    }
    
    func push(_ module: any IModule, animated: Bool)  {
        push(module, animated: animated, completion: nil)
    }
    
    func push(_ module: any IModule, animated: Bool, completion: CompletionBlock?) {
        guard let controller = module.viewToPresent,
              !(controller is UINavigationController)
        else { return }
        
        if let completion = completion {
            completions[controller] = completion
        }
        rootController?.pushViewController(controller, animated: animated)
    }
    
    func popModule()  {
        popModule(animated: true)
    }
    
    func popModule(animated: Bool)  {
        if let controller = rootController?.popViewController(animated: animated) {
            runCompletion(for: controller)
        }
    }
    
    func dismissModule() {
        dismissModule(animated: true, completion: nil)
    }
    
    func dismissModule(animated: Bool, completion: CompletionBlock?) {
        rootController?.dismiss(animated: animated, completion: completion)
    }
    
    func setRootModule(_ module: any IModule) {
        setRootModule(module, hideBar: false)
    }
    
    func setRootModule(_ module: any IModule, hideBar: Bool) {
        guard let controller = module.viewToPresent else { return }
        rootController?.setViewControllers([controller], animated: false)
        rootController?.isNavigationBarHidden = hideBar
    }
    
    func popToRootModule(animated: Bool) {
        if let controllers = rootController?.popToRootViewController(animated: animated) {
            controllers.forEach { controller in
                runCompletion(for: controller)
            }
        }
    }
    
    func presentOKAlert(with text: String) {
        let alert = UIAlertController(
            title: "Info",
            message: text,
            preferredStyle: .alert
        )
        
        let alertOKAction = UIAlertAction(
            title:"OK",
            style: .default,
            handler: { [weak self] _ in
                self?.rootController?.dismiss(animated: true)
        })
        
        alert.addAction(alertOKAction)
        rootController?.present(alert, animated: true)
    }
    
    func presentRetryAlert(with text: String, nextModule: any IModule) {
        let alert = UIAlertController(
            title: "Error",
            message: text,
            preferredStyle: .alert
        )
        
        let alertContinueAction = UIAlertAction(
            title:"Continue",
            style: .default,
            handler: { [weak self] _ in
                self?.push(nextModule, animated: true)
        })
        
        let alertRetryAction = UIAlertAction(
            title:"Retry",
            style: .default,
            handler: { [weak self] _ in
                self?.rootController?.dismiss(animated: true)
        })

        alert.addAction(alertRetryAction)
        alert.addAction(alertContinueAction)
        rootController?.present(alert, animated: true)
    }
    
    private func runCompletion(for controller: UIViewController) {
        guard let completion = completions[controller] else { return }
        completion()
        completions.removeValue(forKey: controller)
    }
}
