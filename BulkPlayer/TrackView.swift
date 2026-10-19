//
//  TrackView.swift
//  BulkPlayer
//
//  Created by soheil pakgohar on 10/19/26.
//

import SwiftUI
import SwiftData

struct TrackView: View {
    
    @State private var data: Data?
    @State private var isPlaying = false
    @State private var error: Error?
    @Environment(MusicQueuePlayer.self) private var playerManager
    
    
    var song: SongTrack
    var playListMode = false
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                if !playListMode {
                    Image(systemName: song.addedToPlaylist ? "checkmark.circle.fill" : "circle")
                        .symbolEffect(.bounce, value: song.addedToPlaylist)
                        .imageScale(.large)
                        .foregroundStyle(Color.gray)
                }
                if let data {
                    Image(uiImage: UIImage(data: data)!)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 40)
                        .padding(.vertical)
                } else {
                    Image(systemName: "music.quarternote.3")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 40)
                        .padding(.vertical)
                }
                Text(song.url.lastPathComponent.capitalized)
                    .bold()
                Spacer(minLength: 0)
                if !playListMode {
                    Button {
                        if isPlaying && playerManager.isPlaying {
                            playerManager.stop()
                            isPlaying = false
                        } else {
                            do {
                                try playerManager.play(urls: [song.url])
                            } catch {
                                print(error.localizedDescription)
                            }
                            isPlaying = true
                            NotificationCenter.default.post(name: .otherTrackIsPlaying, object: nil, userInfo: ["id": song.id])
                        }
                    } label: {
                        Image(systemName: isPlaying ? "stop.fill" : "play.fill")
                            .imageScale(.large)
                            .symbolEffect(.rotate, options: .speed(30), value: isPlaying)
                    }
                    .buttonStyle(.plain)
                } else {
                    Button {
                        song.addedToPlaylist = false
                    } label: {
                        Image(systemName: "trash")
                            .font(.system(size: 24))
                    }
                    .foregroundStyle(Color.red)
                }
            }
            
        }
        .padding(.horizontal)
        .onTapGesture {
            song.addedToPlaylist.toggle()
        }
        .onReceive(NotificationCenter.default.publisher(for: .otherTrackIsPlaying), perform: { payload in
            if let id = payload.userInfo?["id"] as? UUID {
                isPlaying = song.id == id
            }
        })
        .alert(error: $error, actions: {
            Button("dismiss", role: .cancel){}
        })
        .task {
            do {
                data = try await song.thumbnail()
            } catch {
                self.error = error
            }
        }
    }
}

#Preview {
    TrackView(song: SongTrack(url: URL(string: "file///this-dvice/moc.mp3")!))
        .environment(MusicQueuePlayer.shared)
        
        
}
