//
//  BulkPlayerLiveLiveActivity.swift
//  BulkPlayerLive
//
//  Created by soheil pakgohar on 10/19/26.
//

import ActivityKit
import WidgetKit
import SwiftUI
import AppIntents



struct BulkPlayerLiveLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: BulkPlayerLiveAttributes.self) { context in
            // Lock screen/banner UI goes here
            SongPlayerAcitivityView(duration: context.state.duration, currentTime: context.state.currentTime)
                .activityBackgroundTint(Color.black.opacity(0.25))

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    ExpandedLeading()
                }
                DynamicIslandExpandedRegion(.trailing) {
                    ExpandedTrailing(currentTime: context.state.currentTime)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    ExpandedBottom(duration: context.state.duration, currentTime: context.state.currentTime)
                }
            } compactLeading: {
                CompactLeadingView()
            } compactTrailing: {
                CompactTrailingView(duration: context.state.duration, currentTime: context.state.currentTime)
            } minimal: {
                Text(context.state.currentTime.formattedMinutesSeconds)
            }
//            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

struct CompactLeadingView: View {
    
    
    var body: some View {
        
        Image(systemName: "pause.fill")
            .foregroundStyle(Color.yellow)
        
    }
}

struct CompactTrailingView: View {
    let duration: TimeInterval
    let currentTime: TimeInterval
    var body: some View {
        ProgressView(value: currentTime, total: duration, label: {})
            .labelsHidden()
            .progressViewStyle(.circular)
            
    }
}

struct ExpandedLeading: View {
    
    var body: some View {
        
        Button(intent: StopPlayIntent()) {
            Image(systemName: "pause.fill")
                 .foregroundStyle(Color.yellow)
                 .font(.largeTitle)
                 .padding(.leading)
        }
        .buttonStyle(.plain)
    }
}

struct ExpandedBottom: View {
    
    let duration: TimeInterval
    let currentTime: TimeInterval
    
    var body: some View {
        ProgressView(value: currentTime, total: duration, label: {Text("Now Playing").bold()})
            .padding()
    }
}

struct ExpandedTrailing: View {
    
    let currentTime: TimeInterval
    var body: some View {
        Text(currentTime.formattedMinutesSeconds)
            .monospacedDigit()
            .font(.title2)
            .padding(.trailing)
    }
}

#Preview("Notification", as: .content, using: BulkPlayerLiveAttributes()) {
   BulkPlayerLiveLiveActivity()
} contentStates: {
    BulkPlayerLiveAttributes.ContentState.init(duration: 2.0, currentTime: 1.75, isPlaying: true)
}
