import Foundation

protocol UserDefaultsStorable: Codable {
    static var key: String { get }
}

class UserDefaultsStorage<Object: UserDefaultsStorable> {
    
    lazy var storage: UserDefaults? = {
        UserDefaults(suiteName: suiteName)
    }()
    
    private let suiteName: String?
    
    init(suiteName: String?) {
        self.suiteName = suiteName
    }
    
    func set(_ value: Object?) {
        guard let storage = storage else { return }
        
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(value) {
            storage.setValue(encoded, forKey: Object.key)
        }
    }
    
    func get() -> Object? {
        guard let storage = storage else { return nil }
        
        if let object = storage.object(forKey: Object.key) as? Data {
            let decoder = JSONDecoder()
            if let decoded = try? decoder.decode(Object.self, from: object) {
                return decoded
            }
        }
        
        return nil
    }
}
