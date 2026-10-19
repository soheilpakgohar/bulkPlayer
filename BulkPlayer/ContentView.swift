import SwiftUI
import Playgrounds
import AVFoundation
import SwiftData

struct ContentView: View {
    
    @State private var columns = false
    @State private var fileImporterPresent = false
    @State private var showPlayList = false
    @State private var error: Error?
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
                if playerManager.isPlaying && playerManager.queuedItemCount > 1 {
                    
                    ToolbarItem {
                        Button {
                            playerManager.next()
                        } label: {
                            Label("next", systemImage: "forward.end")
                                .animation(.easeInOut, value: playerManager.isPlaying)
                        }
                    }
                }
                if !songs.isEmpty {
                    ToolbarItem {
                        Menu {
                            Button {
                                showPlayList.toggle()
                            } label: {
                                Label("Play list", systemImage: "list.bullet.clipboard")
                            }
                            
                            Button {
                                withAnimation {
                                    columns.toggle()
                                }
                            } label: {
                                Label("Arrange", systemImage: columns ? "square.grid.2x2" : "rectangle.grid.1x3")
                            }
                        } label: {
                            Label("Play/Stop", systemImage: playerManager.isPlaying ? "stop" : "play")
                            
                        } primaryAction: {
                            menuPrimaryAction()
                        }
                        .badge(songs.filter {$0.addedToPlaylist}.count)
                        
                    }
                    
                    ToolbarItem(placement: .topBarPinnedTrailing) {
                        Button {
                            fileImporterPresent.toggle()
                        } label: {
                            Label("Import", systemImage: "plus")
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
            }
        }
        .fileImporter(isPresented: $fileImporterPresent, allowedContentTypes: [.mp3], allowsMultipleSelection: true) { result in
            switch result {
            case .success(let urls):
                do {
                    try handleFile(urls: urls)
                } catch {
                    self.error = error
                }
            case .failure(let error):
                self.error = error
            }
        }
        .alert(error: $error) {
            Button("Dismiss", role: .close){}
        }
        .sheet(isPresented: $showPlayList) {
            PlaylistView(songs: songs.filter {$0.addedToPlaylist})
                .presentationDetents([.medium, .large])
        }
        .environment(playerManager)
    }
    
    func handleFile(urls: [URL]) throws {
        for url in urls {
            // 1. Start accessing the security-scoped resource
            guard url.startAccessingSecurityScopedResource() else {
                throw FileImporterError.permision
            }
            
            defer {
                // 2. Stop accessing when finished
                url.stopAccessingSecurityScopedResource()
            }
            
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let destinationURL = documentsDirectory.appendingPathComponent(url.lastPathComponent)
            
            do {
                // Copy file to your app's Documents directory
                try FileManager.default.copyItem(at: url, to: destinationURL)
                let song = SongTrack(url: destinationURL)
                context.insert(song)
                try context.save()
                
                // Update state to enable playback
            } catch {
                throw error
            }
        }
    }
    
    func delete(_ song: SongTrack) {
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
    
    func menuPrimaryAction() {
        do {
            if playerManager.isPlaying {
                playerManager.stop()
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
    
    func songsView() -> some View {
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
                        TrackView(song: song)
                            .background(scheme == .light ? LinearGradient(colors: [.white, .gray.opacity(0.2)], startPoint: .top, endPoint: .bottomTrailing) : LinearGradient(colors: [.black, .gray.opacity(0.2)], startPoint: .top, endPoint: .bottomTrailing) ,in: RoundedRectangle(cornerRadius: 10))
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
                .swipeActionsContainer()
                .padding()
                
            }
        }
        .overlay {
            if songs.isEmpty {
                emptySongsView()
            }
        }
    }
    
    func emptySongsView() -> some View {
        ContentUnavailableView {
            Label("No Song Yet", systemImage: "music.note.slash")
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

enum FileImporterError: Error {
    case permision
}


#Preview(traits: .previewContainer) {
    return ContentView()
        .environment(MusicQueuePlayer.shared)
}
