import SwiftUI
import SwiftData
import AppIntents

@main struct MyApp: App {
    
    private var playerManager: MusicQueuePlayer
    
    init() {
        let player = MusicQueuePlayer.shared
        self.playerManager = player
        
        AppDependencyManager.shared.add(dependency: player)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(playerManager)
                .modelContainer(for: SongTrack.self)
        }
    }
}
