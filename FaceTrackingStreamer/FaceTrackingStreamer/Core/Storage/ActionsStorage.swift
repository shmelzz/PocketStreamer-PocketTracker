import Foundation

protocol IActionsStorage {
    func set(_ actions: [ActionModel])
    func get() -> [ActionModel]
    func contains(with name: String) -> Bool
}

final class ActionsStorage: IActionsStorage {
    
    private var actions: [ActionModel]?
    
    func set(_ actions: [ActionModel]) {
        self.actions = actions
    }
    
    func get() -> [ActionModel] {
        actions ?? []
    }
    
    func contains(with payload: String) -> Bool {
        guard payload.starts(with: "!") else {
            return false
        }
        
        let trimmedPayload = payload.trimmingCharacters(in: ["!"])
        
        return actions?.contains(where: { $0.type ==  trimmedPayload}) ?? false
    }
}
