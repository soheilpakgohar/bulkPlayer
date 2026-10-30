import SwiftUI
import AVFoundation
import SwiftData
import Playgrounds

struct ContentView: View {
    
    @AppStorage("columns") private var columns = false
    @State private var fileImporterPresent = false
    @State private var showPlayList = false
    @State private var error: Error?
    @State private var importing = false
    @Environment(MusicQueuePlayer.self) private var playerManager
    
    
    @Query var songs: [SongTrack]
    
    @Environment(\.modelContext) private var context
    @Environment(\.colorScheme) private var scheme
    
    var items: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 12, alignment: .leading), count: columns ? 2 : 1)
    }

    var body: some View {
        
        NavigationStack {
            songsView()
            .background(scheme == .light ? Color.white.gradient : Color.black.gradient)
            .navigationTitle("songs".capitalized)
            .toolbarTitleDisplayMode(.inlineLarge)
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing){
                    if playerManager.isPlaying && playerManager.queuedItemCount > 1 {
                        Button {
                            playerManager.next()
                        } label: {
                            Label("next", systemImage: "forward.end")
                                .animation(.easeInOut, value: playerManager.isPlaying)
                        }
                    }
                    
                    Button {
                        menuPrimaryAction()
                    } label: {
                        Label("Play/Stop", systemImage: playerManager.isPlaying ? "stop" : "play")
                    }
                    .badge(songs.filter {$0.addedToPlaylist}.count)
                }
                    
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        withAnimation {
                            columns.toggle()
                        }
                    } label: {
                        Label("Arrange", systemImage: columns ? "app.grid.2x2" : "rectangle.grid.1x3")
                    }
                }
                ToolbarSpacer(placement: .bottomBar)
                ToolbarItem(placement: .bottomBar) {
                    Button {
                        showPlayList.toggle()
                    } label: {
                        Label("Play list", systemImage: "list.bullet.clipboard")
                    }
                }
                ToolbarItem(placement: .topBarPinnedTrailing) {
                    Button {
                        fileImporterPresent.toggle()
                    } label: {
                        if importing {
                            ProgressView()
                        } else {
                            Label("Import", systemImage: "plus")
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
        .fileImporter(isPresented: $fileImporterPresent, allowedContentTypes: [.audio], allowsMultipleSelection: true) { result in
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
        .alert(error: $error) {}
        .sheet(isPresented: $showPlayList) {
            PlaylistView(songs: songs.filter {$0.addedToPlaylist})
                .presentationDetents([.medium, .large])
        }
        .environment(playerManager)
    }
    
    // Mark: file handler
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
    
    private func menuPrimaryAction() {
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
            print(error.localizedDescription)
        }
    }
    
    private func songsView() -> some View {
        VStack {
            if playerManager.isPlaying {
                VStack(alignment: .leading) {
                    HStack {
                        MusicProgressSlider(currentTime: playerManager.currentTime, duration: playerManager.duration, onSeek: playerManager.goTo(_:))
                    }
                    .padding(.horizontal)
                    Text(playerManager.currentTitle)
                        .font(.footnote)
                        .padding(.leading)
                }
            }
            ScrollView {
                LazyVGrid(columns: items, spacing: 20) {
                    ForEach(songs, id: \.self) { song in
                        TrackView(song: song, compactMode: columns)
                            .background(scheme == .light ? LinearGradient(colors: [.white, .gray.opacity(0.2)], startPoint: .top, endPoint: .bottomTrailing) : LinearGradient(colors: [.gray.opacity(0.2), .black.opacity(0.5)], startPoint: .topLeading, endPoint: .bottomTrailing) ,in: RoundedRectangle(cornerRadius: 12))
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
                .animation(.default, value: songs)
                .animation(.default, value: columns)
                .swipeActionsContainer()
                .padding()
                
            }
        }
        .overlay {
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
            }
        } description: {
            Text("to add a song use plus button")
        } actions: {
            Button {
                fileImporterPresent.toggle()
            } label: {
                Label("add new".capitalized, systemImage: "plus")
                    .symbolRenderingMode(.hierarchical)
                    .font(.headline)
                    .imageScale(.large)
            }
            .buttonStyle(.borderedProminent)
            
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

struct RealHiddenModifier: ViewModifier {
    let condition: Bool
    func body(content: Content) -> some View {
        if condition {
            content.hidden()
        } else {
            content
        }
    }
}

extension View {
    func realHidden(condition: Bool) -> some View {
        return self.modifier(RealHiddenModifier(condition: condition))
    }
}

#Preview(traits: .previewContainer) {
    ContentView()
        .environment(MusicQueuePlayer.shared)
}
