import SwiftUI

public class GameModel: ObservableObject {
    @Published var selectedPlayers: [GamePlayer] = []
    @Published var allPlayers: [GamePlayer]
    
    init(players: [GamePlayer]? = nil) {
        if let players = players {
            self.allPlayers = players
        } else {
            self.allPlayers = [
                GamePlayer(name: "Dani", photo: UIImage(named: "dani")?.pngData() ?? Data()),
                GamePlayer(name: "Cami", photo: UIImage(named: "cami")?.pngData() ?? Data()),
                GamePlayer(name: "Gabi", photo: UIImage(named: "gabi")?.pngData() ?? Data()),
                GamePlayer(name: "Fran", photo: UIImage(named: "fran")?.pngData() ?? Data()),
                GamePlayer(name: "Rodri", photo: UIImage(named: "rodri")?.pngData() ?? Data())
            ]
        }
    }
    
    func togglePlayerSelection(_ player: GamePlayer) {
        if let index = selectedPlayers.firstIndex(of: player) {
            selectedPlayers.remove(at: index)
        } else if selectedPlayers.count < 4 {
            selectedPlayers.append(player)
        }
    }
    
    func updatePlayer(at index: Int, with newPlayer: GamePlayer) {
        selectedPlayers[index] = newPlayer
    }
    
    func isPlayerSelected(_ player: GamePlayer) -> Bool {
        selectedPlayers.contains(player)
    }
    
    func resetPlayerSelections() {
        for index in selectedPlayers.indices {
            selectedPlayers[index].faction1 = ""
            selectedPlayers[index].faction2 = ""
        }
    }
    
    func addPlayer(_ player: GamePlayer) {
        allPlayers.append(player)
    }
    
    func updatePlayer(_ updatedPlayer: GamePlayer) {
        if let index = allPlayers.firstIndex(where: { $0.id == updatedPlayer.id }) {
            allPlayers[index] = updatedPlayer
        }
        if let selectedIndex = selectedPlayers.firstIndex(where: { $0.id == updatedPlayer.id }) {
            selectedPlayers[selectedIndex] = updatedPlayer
        }
        objectWillChange.send()
    }
    
    func deletePlayer(_ player: GamePlayer) {
        allPlayers.removeAll { $0.id == player.id }
        selectedPlayers.removeAll { $0.id == player.id }
        objectWillChange.send()
    }
}