//
//  PlaylistView.swift
//  BulkPlayer
//
//  Created by soheil pakgohar on 10/19/26.
//

import SwiftUI
import SwiftData

struct PlaylistView: View  {
    
    @Query(
        FetchDescriptor(
            predicate: #Predicate<SongTrack>{ $0.addedToPlaylist }
        )
    ) private var songs: [SongTrack]
    
    var body: some View {
        NavigationStack {
            List(songs) { song in
                TrackView(song: song, playListMode: true)
                    .listRowSeparator(.hidden)
                    .swipeActions(allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            song.addedToPlaylist = false
                        } label: {
                            Label("Remove", systemImage: "document.on.trash")
                        }
                    }
            }
            .listStyle(.plain)
            .animation(.default, value: songs)
            .overlay {
                if songs.isEmpty {
                    ContentUnavailableView("No Favorits Yet", systemImage: "list.bullet.clipboard.fill")
                        .symbolRenderingMode(.hierarchical)
                }
            }
            .navigationTitle("Favorits")
            .navigationSubtitle("only this play list will play".capitalized)
            .toolbarTitleDisplayMode(.inlineLarge)
            .toolbar {
                Image(systemName: "waveform.mid")
                    .badge(songs.count)
            }
        }
    }
}

#Preview(traits: .previewContainer) {
    PlaylistView()
        .environment(MusicQueuePlayer.shared)
}


#Preview("Empty List") {
    PlaylistView()
        .environment(MusicQueuePlayer.shared)
}
