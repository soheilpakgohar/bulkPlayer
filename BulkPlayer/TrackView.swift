//
//  TrackView.swift
//  BulkPlayer
//
//  Created by soheil pakgohar on 10/19/26.
//

import SwiftUI
import SwiftData

struct TrackView: View {
    
    @State private var data: Data? = nil
    @State private var duration: TimeInterval = 0.0
    @State private var isPlaying = false
    @State private var error: Error?
    @Environment(MusicQueuePlayer.self) private var playerManager
    
    @Namespace private var titleSpace
    
    var song: SongTrack
    var playListMode = false
    var compactMode: Bool = false
    
    var body: some View {
        Group {
            if playListMode {
                playlistModeView()
            } else {
                regularView()
            }
        }
        .task {
            do {
                data = try await song.thumbnail()
                duration = try await song.duration()
            } catch {
                self.error = error
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .otherTrackIsPlaying)) { notification in
            if let id = notification.userInfo?["id"] as? UUID, song.id != id {
                isPlaying = false
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .stopAll)) { _ in
            isPlaying = false
        }
    }
    
    @ViewBuilder
    private func artwork() -> some View {
        if let data {
            Image(uiImage: UIImage(data: data)!)
                .resizable()
                .frame(maxWidth: 54, maxHeight: 54)
                .aspectRatio(3/2, contentMode: .fit)
                .padding(.horizontal)
                .accessibilityHidden(true)
        } else {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(
                    Color.blue.gradient
                )
                .overlay {
                    Image(systemName: "music.note")
                        .font(.title2)
                        .imageScale(.large)
                        .foregroundStyle(.white.opacity(0.9))
                }
                .frame(width: 54, height:54)
                .accessibilityHidden(true)
        }
    }
    
    @ViewBuilder
    private func playlistModeView() -> some View {
        HStack {
            artwork()
            
            VStack(alignment: .leading) {
                Text(song.url.lastPathComponent.capitalized)
                    .bold()
                    .lineLimit(1)
                    .animation(.easeInOut, value: compactMode)
                    .matchedGeometryEffect(id: "title", in: titleSpace)
                    .contextMenu {
                        Text(song.url.lastPathComponent.capitalized)
                    }
                
                Text(duration.formattedMinutesSeconds)
                    .font(.footnote)
                    .bold()
                    .matchedGeometryEffect(id: "duration", in: titleSpace)
            }
            
            Spacer(minLength: 0)
            
            Button {
                withAnimation {
                    song.addedToPlaylist = false
                }
            } label: {
                Image(systemName: "trash")
                    .font(.system(size: 24))
            }
            .foregroundStyle(Color.red)
            .accessibilityLabel(
                "delete \(song.url.lastPathComponent)"
            )
            
        }
    }
    
    @ViewBuilder
    private func regularView() -> some View {
        VStack(alignment: .leading) {
            HStack {
                
                Image(systemName: song.addedToPlaylist ? "checkmark.circle.fill" : "circle")
                    .symbolEffect(.bounce, value: song.addedToPlaylist)
                    .imageScale(.large)
                    .foregroundStyle(Color.gray)
                    .hidden(condition: compactMode)
                    .matchedGeometryEffect(id: "selector", in: titleSpace)
                    .onTapGesture {
                        song.addedToPlaylist.toggle()
                    }
                    
                
                
                artwork()
                
                
                VStack(alignment: .leading) {
                    Text(song.url.lastPathComponent.capitalized)
                        .bold()
                        .lineLimit(1)
                        .padding(.trailing)
                        .animation(.easeInOut, value: compactMode)
                        .matchedGeometryEffect(id: "title", in: titleSpace)
                        .contextMenu {
                            Text(song.url.lastPathComponent.capitalized)
                        }
                    
                    Text(duration.formattedMinutesSeconds)
                        .font(.footnote)
                        .bold()
                        .matchedGeometryEffect(id: "duration", in: titleSpace)
                }
                .hidden(condition: compactMode)
                
                Spacer(minLength: 0)
                Button {
                    if isPlaying && playerManager.isPlaying {
                        playerManager.stop()
                        isPlaying = false
                    } else {
                        do {
                            try playerManager.play(urls: [song.url])
                        } catch {
                            self.error = error
                        }
                        isPlaying = true
                        NotificationCenter.default.post(name: .otherTrackIsPlaying, object: nil, userInfo: ["id": song.id])
                    }
                } label: {
                    Image(systemName: isPlaying ? "stop.fill" : "play.fill")
                        .imageScale(.medium)
                        .contentTransition(.symbolEffect(.replace))
                }
                .buttonStyle(.glass)
                .accessibilityLabel(
                    isPlaying
                    ? "Stop \(song.url.lastPathComponent)"
                    : "Play \(song.url.lastPathComponent)"
                )
            }
            
            
            HStack {
                Image(systemName: song.addedToPlaylist ? "checkmark.circle.fill" : "circle")
                    .symbolEffect(.bounce, value: song.addedToPlaylist)
                    .imageScale(.large)
                    .foregroundStyle(Color.gray)
                    .matchedGeometryEffect(id: "selector", in: titleSpace)
                
                VStack(alignment: .leading) {
                    Text(song.url.lastPathComponent.capitalized)
                        .bold()
                        .lineLimit(1)
                        .padding(.top)
                        .animation(.easeInOut, value: compactMode)
                        .matchedGeometryEffect(id: "title", in: titleSpace)
                        .contextMenu {
                            Text(song.url.lastPathComponent.capitalized)
                        }
                    
                    Text(duration.formattedMinutesSeconds)
                        .font(.callout)
                        .bold()
                        .matchedGeometryEffect(id: "duration", in: titleSpace)
                }
            }
            .hidden(condition: !compactMode)
            .onTapGesture {
                song.addedToPlaylist.toggle()
            }
            
        }
        .padding()
    }
}

#Preview {
    let track = SongTrack(path: "12.%20Taher%20Golgon%20-%20Ba%20To%20%5B128%5D.mp3")
    
    return TrackView(song: track, compactMode: true)
        .environment(MusicQueuePlayer.shared)
        
        
}
