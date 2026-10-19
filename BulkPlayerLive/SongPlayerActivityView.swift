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
                ProgressView(value: currentTime, total: duration, label: {})
                    .labelsHidden()
                Text(currentTime.formattedMinutesSeconds)
            }
            .padding(.top)
            
            HStack {
                Button {
                    
                } label: {
                    Image(systemName: "pause.fill")
                        .font(.title)
                }
                .buttonStyle(.plain)
                .padding()
                 
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
