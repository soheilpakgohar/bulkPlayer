//
//  PlaylistView.swift
//  BulkPlayer
//
//  Created by soheil pakgohar on 10/19/26.
//

import SwiftUI
import SwiftData

struct PlaylistView: View {
    
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    var songs: [SongTrack]
    
    var body: some View {
        NavigationStack {
            if songs.isEmpty  {
                ContentUnavailableView("No Songs Yet", systemImage: "list.bullet.clipboard.fill")
                    .symbolRenderingMode(.hierarchical)
            } else {
                List {
                    ForEach(songs) { song in
                        TrackView(song: song, playListMode: true)
                    }
                }
                .listStyle(.inset)
                .navigationTitle("Play List")
                .toolbarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button(role: .close) {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    let song = SongTrack(url: URL(string: "file///this-dvice/moc.mp3")!)
    return PlaylistView(songs: [song])
        .environment(MusicQueuePlayer.shared)
    
}
