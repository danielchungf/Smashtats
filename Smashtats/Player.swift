import Foundation

struct GamePlayer: Identifiable, Hashable {
    let id: UUID
    let name: String
    let photo: Data
    var faction1: String = ""
    var faction2: String = ""
    var victoryPoints: Int = 0
    
    init(id: UUID = UUID(), name: String, photo: Data) {
        self.id = id
        self.name = name
        self.photo = photo
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: GamePlayer, rhs: GamePlayer) -> Bool {
        lhs.id == rhs.id
    }
}