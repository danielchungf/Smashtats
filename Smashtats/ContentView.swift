//
//  ContentView.swift
//  Smashtats
//
//  Created by Daniel Chung on 14/08/24.
//

import SwiftUI
struct ContentView: View {
    @EnvironmentObject var game: GameModel
    @State private var isSetupComplete = false

    var body: some View {
        NavigationView {
            Group {
                if isSetupComplete {
                    ScoreboardView(isSetupComplete: $isSetupComplete)
                } else {
                    GameSetupView(isSetupComplete: $isSetupComplete)
                }
            }
        }
    }
}

struct GameSetupView: View {
    @EnvironmentObject var game: GameModel
    @Binding var isSetupComplete: Bool
    @State private var setupStep = 1
    
    var body: some View {
        VStack {
            if setupStep == 1 {
                PlayerSelectionView(onComplete: { setupStep = 2 })
            } else {
                FactionSelectionView(
                    onComplete: { isSetupComplete = true },
                    onBack: {
                        setupStep = 1
                        game.resetPlayerSelections()
                    }
                )
            }
        }
        .navigationTitle(setupStep == 1 ? "Select Players" : "Select Factions")
    }
}

struct PlayerSelectionView: View {
    @EnvironmentObject var game: GameModel
    let onComplete: () -> Void
    
    @State private var showCreatePlayerSheet = false
    @State private var showEditPlayerSheet = false
    @State private var editingPlayer: GamePlayer?
    @State private var isEditing = false
    private let columns = [
        GridItem(.adaptive(minimum: 140, maximum: 180), spacing: 20)
    ]
    private let titleColor = Color(hex: "0F468C")
    private let selectedColor = Color(hex: "A62B1F")
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(spacing: 20) {
                    HStack {
                        Text("Select Players")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(titleColor)
                        
                        Spacer()
                        
                        editButton
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                    
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(game.allPlayers) { player in
                            PlayerSelectionBox(
                                player: player,
                                isSelected: Binding(
                                    get: { game.isPlayerSelected(player) },
                                    set: { _ in game.togglePlayerSelection(player) }
                                ),
                                selectedColor: selectedColor,
                                isEditing: isEditing
                            )
                            .onTapGesture {
                                if isEditing {
                                    editingPlayer = player
                                    showEditPlayerSheet = true
                                } else {
                                    game.togglePlayerSelection(player)
                                }
                            }
                        }
                        CreatePlayerBox(action: { showCreatePlayerSheet = true })
                    }
                    .padding(.horizontal)
                    
                    Spacer().frame(height: 80)
                }
            }
            
            if game.selectedPlayers.count >= 2 && game.selectedPlayers.count <= 4 {
                Button(action: onComplete) {
                    Text("Next")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 40)
                        .background(titleColor)
                        .cornerRadius(25)
                }
                .transition(.opacity.animation(.easeInOut(duration: 0.3)))
                .padding(.bottom, 20)
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showCreatePlayerSheet) {
            CreatePlayerSheet(isPresented: $showCreatePlayerSheet, onSave: { newPlayer in
                game.addPlayer(newPlayer)
            })
        }
        .sheet(item: $editingPlayer) { player in
            CreatePlayerSheet(
                isPresented: .constant(true),
                player: player,
                onSave: { updatedPlayer in
                    game.updatePlayer(updatedPlayer)
                    editingPlayer = nil
                },
                onDelete: { playerToDelete in
                    game.deletePlayer(playerToDelete)
                    editingPlayer = nil
                }
            )
        }
    }
    
    private var editButton: some View {
        Button(action: { isEditing.toggle() }) {
            Text(isEditing ? "Done" : "Edit")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(titleColor)
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .background(Color.white)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(titleColor, lineWidth: 1)
                )
        }
    }
}

struct CreatePlayerBox: View {
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                Image(systemName: "plus.circle")
                    .font(.system(size: 40))
                Text("Create player")
                    .font(.headline)
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 140, maxHeight: 180)
            .aspectRatio(1, contentMode: .fit)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color.gray, style: StrokeStyle(lineWidth: 2, dash: [5]))
            )
        }
        .foregroundColor(.gray)
    }
}

struct PlayerSelectionBox: View {
    let player: GamePlayer
    @Binding var isSelected: Bool
    let selectedColor: Color
    let isEditing: Bool
    
    private var selectedBackgroundColor: Color { selectedColor.opacity(0.2) }
    private var selectedTextColor: Color { selectedColor }
    private var selectedStrokeColor: Color { selectedColor }
    private let editStrokeColor = Color(hex: "0F468C")
    
    var body: some View {
        VStack {
            if let uiImage = UIImage(data: player.photo) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 80, height: 80)
                    .clipShape(Circle())
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 80, height: 80)
                    .foregroundColor(.gray)
            }
            
            Text(player.name)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(isSelected ? selectedTextColor : .primary)
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 140, maxHeight: 180)
        .aspectRatio(1, contentMode: .fit)
        .background(isSelected ? selectedBackgroundColor : Color.gray.opacity(0.1))
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(isEditing ? editStrokeColor : (isSelected ? selectedStrokeColor : Color.clear), lineWidth: isEditing ? 2 : 1)
        )
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(), value: isSelected)
    }
}

struct FactionSelectionView: View {
    @EnvironmentObject var game: GameModel
    let onComplete: () -> Void
    let onBack: () -> Void
    
    var body: some View {
        VStack {
            ForEach(Array(game.selectedPlayers.enumerated()), id: \.element.id) { index, player in
                PlayerFactionSelection(player: binding(for: index))
            }
            
            Button("Start Game", action: onComplete)
                .disabled(!allPlayersHaveSelectedFactions())
        }
        .navigationTitle("Select Factions")
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: backButton)
    }
    
    private var backButton: some View {
        Button(action: onBack) {
            Image(systemName: "arrow.left")
                .foregroundColor(.blue)
        }
    }
    
    private func binding(for index: Int) -> Binding<GamePlayer> {
        return Binding(
            get: { game.selectedPlayers[index] },
            set: { game.updatePlayer(at: index, with: $0) }
        )
    }
    
    private func allPlayersHaveSelectedFactions() -> Bool {
        game.selectedPlayers.allSatisfy { !$0.faction1.isEmpty && !$0.faction2.isEmpty }
    }
    
    private func selectedFactionsExcept(_ index: Int) -> [String] {
        game.selectedPlayers.flatMap { $0.faction1 == "" ? [] : [$0.faction1] + ($0.faction2 == "" ? [] : [$0.faction2]) }
            .filter { $0 != game.selectedPlayers[index].faction1 && $0 != game.selectedPlayers[index].faction2 }
    }
}

struct PlayerFactionSelection: View {
    @Binding var player: GamePlayer
    let allFactions = ["Pirates", "Ninjas", "Zombies", "Robots", "Aliens", "Wizards"]
    
    var body: some View {
        VStack {
            Text(player.name)
            Picker("Faction 1", selection: $player.faction1) {
                ForEach(allFactions, id: \.self) { Text($0) }
            }
            Picker("Faction 2", selection: $player.faction2) {
                ForEach(allFactions, id: \.self) { Text($0) }
            }
        }
    }
}

struct ScoreboardView: View {
    @EnvironmentObject var game: GameModel
    @Binding var isSetupComplete: Bool

    private let columns = [GridItem(.flexible())]

    var body: some View {
        VStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 0) {
                    ForEach(game.selectedPlayers.indices, id: \.self) { index in
                        PlayerRow(player: $game.selectedPlayers[index])
                    }
                }
            }
            
            Button("New Game") {
                game.selectedPlayers = []
                isSetupComplete = false
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding(.bottom)
        }
        .navigationTitle("Smash Up Scoreboard")
    }
}

struct PlayerRow: View {
    @Binding var player: GamePlayer

    var body: some View {
        HStack {
            if let uiImage = UIImage(data: player.photo) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.gray, lineWidth: 1))
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .foregroundColor(.gray)
            }
            
            VStack(alignment: .leading) {
                Text(player.name)
                    .font(.headline)
                Text("\(player.faction1) + \(player.faction2)")
                    .font(.subheadline)
            }
            
            Spacer()
            
            VStack {
                Text("\(player.victoryPoints)")
                    .font(.system(size: 24, weight: .bold))
                    .padding(.bottom, 5)
                
                HStack {
                    Button(action: {
                        if player.victoryPoints > 0 {
                            player.victoryPoints -= 1
                        }
                    }) {
                        Image(systemName: "minus.circle")
                            .font(.system(size: 24))
                    }
                    
                    Button(action: {
                        player.victoryPoints += 1
                    }) {
                        Image(systemName: "plus.circle")
                            .font(.system(size: 24))
                    }
                }
            }
        }
        .padding(.vertical, 8)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

// Add this extension to support hex color codes
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct CreatePlayerSheet: View {
    @Binding var isPresented: Bool
    @State private var name: String
    @State private var image: UIImage?
    @State private var showImagePicker = false
    @State private var showDeleteConfirmation = false
    var player: GamePlayer?
    var onSave: (GamePlayer) -> Void
    var onDelete: ((GamePlayer) -> Void)?
    
    init(isPresented: Binding<Bool>, player: GamePlayer? = nil, onSave: @escaping (GamePlayer) -> Void, onDelete: ((GamePlayer) -> Void)? = nil) {
        self._isPresented = isPresented
        self.player = player
        self.onSave = onSave
        self.onDelete = onDelete
        self._name = State(initialValue: player?.name ?? "")
        if let playerPhoto = player?.photo, let uiImage = UIImage(data: playerPhoto) {
            self._image = State(initialValue: uiImage)
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Name", text: $name)
                
                Button(action: { showImagePicker = true }) {
                    HStack {
                        Text("Select Photo")
                        Spacer()
                        if let image = image {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 40)
                                .clipShape(Circle())
                        } else {
                            Image(systemName: "photo")
                        }
                    }
                }
                
                if player != nil {
                    Section {
                        Button("Delete Player") {
                            showDeleteConfirmation = true
                        }
                        .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle(player == nil ? "Create New Player" : "Edit Player")
            .navigationBarItems(
                leading: Button("Cancel") { isPresented = false },
                trailing: Button("Save") {
                    if let image = image, let imageData = image.pngData() {
                        let updatedPlayer = GamePlayer(id: player?.id ?? UUID(), name: name, photo: imageData)
                        onSave(updatedPlayer)
                        isPresented = false
                    }
                }.disabled(name.isEmpty || image == nil)
            )
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $image)
        }
        .alert(isPresented: $showDeleteConfirmation) {
            Alert(
                title: Text("Delete Player"),
                message: Text("Are you sure you want to delete this player?"),
                primaryButton: .destructive(Text("Delete")) {
                    if let player = player {
                        onDelete?(player)
                        isPresented = false
                    }
                },
                secondaryButton: .cancel()
            )
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            picker.dismiss(animated: true)
        }
    }
}
