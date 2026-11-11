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
    
    var songs: [SongTrack]
    var title: String = "Play List"
    
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
                .listStyle(.inset)
                .navigationTitle(title)
                .toolbarTitleDisplayMode(.inline)
            }
        }
    }
}

#Preview {
    let song = SongTrack(path: "this-dvice/moc.mp3")
    PlaylistView(songs: [song])
}
