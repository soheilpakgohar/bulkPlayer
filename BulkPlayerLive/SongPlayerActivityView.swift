//
//  SongPlayerActivityView.swift
//  BulkPlayer
//
//  Created by soheil pakgohar on 10/19/26.
//

import SwiftUI
import AppIntents

struct SongPlayerAcitivityView: View {
    
    let duration: TimeInterval
    let currentTime: TimeInterval
    
    var body: some View {
        
        VStack {
            HStack {
                Image(systemName: "music.note.list")
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(Color.white)
                    .imageScale(.large)
                    .padding()
                    .background(Color.purple.gradient, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                VStack(alignment: .leading) {
                    Text("Bulk Player")
                        .bold()
                    Text("a place for your own songs".capitalized)
                        .font(.footnote)
                        .foregroundStyle(Color.gray)
                }
                Spacer(minLength: 0)
            }
            HStack {
                ProgressView(value: currentTime, total: duration, label: {})
                    .labelsHidden()
                Text(currentTime.formattedMinutesSeconds)
            }
            
            HStack(spacing: 25) {
                Button{} label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                }
                .buttonStyle(.plain)
                Button(intent: StopPlayIntent()) {
                    Image(systemName: "pause.fill")
                        .font(.title)
                }
                .buttonStyle(.plain)
                
                 
                Button {
                    
                } label: {
                    Image(systemName: "forward.end.fill")
                        .font(.title2)
                }
                .buttonStyle(.plain)
            }
        }
        .padding()
    }
}
