//
//  HomeView.swift
//  BulkPlayer
//
//  Created by soheil pakgohar on 11/13/26.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        TabView {
            Tab {
                ContentView()
            } label: {
                Label("Songs", systemImage: "music.note.list")
            }
            
            Tab {
                PlaylistView()
            } label: {
                Label("Favorits", systemImage: "heart.fill")
            }

        }
    }
}

#Preview(traits: .previewContainer) {
    HomeView()
        .environment(MusicQueuePlayer.shared)
}
