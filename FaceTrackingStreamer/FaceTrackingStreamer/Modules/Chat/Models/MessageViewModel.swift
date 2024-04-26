import Foundation

struct MessageViewModel: Hashable {
    let id: String
    let username: String
    let message: String
    let isAction: Bool
}
