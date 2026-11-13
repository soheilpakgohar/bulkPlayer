//
//  PlaylistView.swift
//  BulkPlayer
//
//  Created by soheil pakgohar on 10/19/26.
//

import SwiftUI
import SwiftData

struct PlaylistView: View  {
    
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    
    @Query(
        FetchDescriptor(
            predicate: #Predicate<SongTrack>{ $0.addedToPlaylist }
        )
    ) private var songs: [SongTrack]
    
    var title: String = "Favorits"
    
    var body: some View {
        NavigationStack {
            if songs.isEmpty  {
                ContentUnavailableView("No Favorits Yet", systemImage: "list.bullet.clipboard.fill")
                    .symbolRenderingMode(.hierarchical)
            } else {
                List {
                    ForEach(songs) { song in
                        TrackView(song: song, playListMode: true)
                            .listRowSeparator(.hidden)
                            .swipeActions(allowsFullSwipe: true){
                                Button {
                                    withAnimation {
                                        song.addedToPlaylist = false
                                    }
                                } label: {
                                    Label("Remove", systemImage: "document.on.trash")
                                }
                                .tint(.red)
                            }
                    }
                }
                .animation(.default, value: songs)
                .navigationTitle(title)
                .toolbarTitleDisplayMode(.inlineLarge)
            }
        }
    }
}

#Preview(traits: .previewContainer) {
    PlaylistView()
        .environment(MusicQueuePlayer.shared)
}
