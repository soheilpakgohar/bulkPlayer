import SwiftUI
import AVFoundation
import SwiftData

struct ContentView: View {
    
    @AppStorage("columns") private var columns = false
    @State private var fileImporterPresent = false
    @State private var error: Error?
    @State private var importing = false
    @Environment(MusicQueuePlayer.self) private var playerManager
    
    @Query var songs: [SongTrack]
    
    @Environment(\.modelContext) private var context
    @Environment(\.colorScheme) private var scheme
    @Environment(\.dismiss) private var dismiss
    var items: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 12, alignment: .leading), count: columns ? 2 : 1)
    }

    var body: some View {
        
        NavigationStack {
            songsView()
                .background(scheme == .light ? Color.gray.gradient.tertiary : Color.purple.mix(with: .black, by: 0.7).gradient.tertiary)
                .navigationTitle("songs".capitalized)
                .toolbarTitleDisplayMode(.inlineLarge)
                .toolbar {
                    
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            fileImporterPresent.toggle()
                        } label: {
                            if importing {
                                ProgressView()
                            } else {
                                Label("Import", systemImage: "plus")
                            }
                        }
                    }
                    
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            playPause()
                        } label: {
                            Label("Play/Stop", systemImage: playerManager.isPlaying ? "stop.fill" : "play.fill")
                        }
                        .badge(songs.filter {$0.addedToPlaylist}.count)
                        .tint(Color.blue.mix(with: .black, by: 0.2))
                        .hidden(condition: songs.isEmpty)
                    }
                        
                    ToolbarItemGroup(placement: .bottomBar) {
                        Button {
                            withAnimation {
                                columns.toggle()
                            }
                        } label: {
                            Label("Arrange", systemImage: columns ? "list.dash" : "app.grid.2x2")
                        }
                        .tint(Color.blue.mix(with: .black, by: 0.2))
                        .hidden(condition: songs.isEmpty)
                        
                        Spacer(minLength: 0)
                    }
                }
        }
        .fileImporter(isPresented: $fileImporterPresent, allowedContentTypes: [.audio], allowsMultipleSelection: true, onCompletion: importManager(_:))
        .alert(error: $error) {}
        .environment(playerManager)
    }
    
    // Mark: file handler
    private func importManager(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            Task {
                do {
                    try await handleFile(urls: urls)
                } catch {
                    self.error = error
                }
            }
        case .failure(let error):
            self.error = error
        }
    }
    
    private func handleFile(urls: [URL]) async throws {
        importing = true
        for url in urls {
            // 1. Start accessing the security-scoped resource
            let permission = url.startAccessingSecurityScopedResource()
            
            defer {
                // 2. Stop accessing when finished
                url.stopAccessingSecurityScopedResource()
                importing = false
            }
            
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            guard permission else { throw FileImporterError.permision }
           let destinationURL = documentsDirectory.appendingPathComponent(url.lastPathComponent)
            // Copy file to your app's Documents directory
            try FileManager.default.copyItem(at: url, to: destinationURL)
            let song = SongTrack(path: destinationURL.lastPathComponent)
            context.insert(song)
        }
        try context.save()
    }
    
    private func delete(_ song: SongTrack) {
        do {
            try FileManager.default.removeItem(at: song.url)
            withAnimation {
                context.delete(song)
            }
            try context.save()
        } catch {
            self.error = error
        }
    }
    
    private func playPause() {
        do {
            if playerManager.isPlaying {
                playerManager.stop()
                NotificationCenter.default.post(name: .stopAll, object: nil)
            } else {
                if (songs.filter {$0.addedToPlaylist}).isEmpty {
                    try playerManager.play(urls: songs.map {$0.url})
                } else {
                    try playerManager.play(urls: songs.filter({$0.addedToPlaylist}).map({$0.url}))
                }
            }
        } catch {
            self.error = error
        }
    }
    
    private func songsView() -> some View {
        VStack {
            if playerManager.isPlaying {
                PlayerView()
                    .padding(.horizontal)
                    .transition(.push(from: .trailing))
            }
            ScrollView(showsIndicators: false) {
                LazyVGrid(columns: items, spacing: 20) {
                    ForEach(songs, id: \.self) { song in
                        TrackView(song: song, compactMode: columns)
                            .background(scheme == .light ? Color.gray.tertiary : Color.purple.mix(with: .black, by: 0.3).tertiary, in: .rect(cornerRadius: 20))
                            .environment(playerManager)
                            .swipeActions {
                                Button(role: .destructive) {
                                    delete(song)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                        .labelStyle(.iconOnly)
                                }
                                .tint(.red)
                            }
                    }
                }
                .animation(.default, value: columns)
                .swipeActionsContainer()
                .padding()
                
            }
        }
        .overlay(alignment: .bottom) {
            if songs.isEmpty {
                emptySongsView(isLoading: importing)
            }
        }
    }
    
    private func emptySongsView(isLoading: Bool = false) -> some View {
        ContentUnavailableView {
            switch isLoading {
            case true:
                ProgressView()
            default:
                Label("No Song Yet", systemImage: "music.note.slash")
                    .symbolRenderingMode(.hierarchical)
            }
        } description: {
            Text("to add some tap plus button")
        } actions: {
            Button {
                fileImporterPresent.toggle()
            } label: {
                Label("add new".capitalized, systemImage: "plus.circle.fill")
                    .symbolRenderingMode(.hierarchical)
                    .font(.headline)
                    .imageScale(.large)
            }
        }
    }
}

enum FileImporterError: LocalizedError {
    case permision
    
    
    var errorDescription: String? {
        switch self {
        case .permision:
            "Permission error."
        }
    }
}

enum SheetType: String, Identifiable {
    case playList, player
    
    var id: String {
        self.rawValue
    }
}

#Preview(traits: .previewContainer) {
    ContentView()
        .environment(MusicQueuePlayer.shared)
}
