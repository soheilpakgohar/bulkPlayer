//
//  PlayerView.swift
//  BulkPlayer
//
//  Created by soheil pakgohar on 11/11/26.
//

import SwiftUI

struct PlayerView: View {
    
    @Environment(MusicQueuePlayer.self) private var playerManager
    
    var body: some View {
        
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: "music.quarternote.3")
                    .imageScale(.large)
                    .padding(8)
                
                Text(playerManager.currentTitle)
                    .font(.caption)
                    .bold()
                    .monospaced()
                    .lineLimit(1)
                    .padding(.top, 8)
            }
            
            MusicProgressSlider()
                .environment(playerManager)

        }
        .padding()
        .glassEffect(in: .rect(cornerRadius: 20))
    
    }
}

#Preview {
    PlayerView()
        .environment(MusicQueuePlayer.shared)
}


