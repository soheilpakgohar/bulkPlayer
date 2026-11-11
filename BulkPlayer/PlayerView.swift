//
//  PlayerView.swift
//  BulkPlayer
//
//  Created by soheil pakgohar on 11/11/26.
//

import SwiftUI

struct PlayerView: View {
    
    @Environment(MusicQueuePlayer.self) private var playerManager
    var songs: [SongTrack]
    
    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size.height
            VStack(alignment: .leading) {
                
                MusicProgressSlider(currentTime: playerManager.currentTime, duration: playerManager.duration, onSeek: playerManager.goTo(_:))
                    .padding(.top, 30)
                
                Text(playerManager.currentTitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .padding(.top, 16)
                
                if size > 150 {
                    Text("Favorits")
                        .font(.title3)
                        .foregroundStyle(Color.gray)
                        .padding(.top, 24)
                    PlaylistView(songs: songs, title: "")
                        .transition(.opacity)
                }
                Spacer(minLength: 0)
            }
            .padding(.horizontal)
        }
        .frame(maxHeight: .infinity)
    }
}

#Preview {
    PlayerView(songs: [])
        .environment(MusicQueuePlayer.shared)
}


