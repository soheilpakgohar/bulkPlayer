//
//  MusicProgressSlider.swift
//  BulkPlayer
//
//  Created by soheil pakgohar on 10/19/26.
//

import SwiftUI

struct MusicProgressSlider: View {

    @State private var sliderValue: Double = 0
    @State private var isEditing = false
    @State private var isSeeking = false
    
    @Environment(MusicQueuePlayer.self) private var playerManager

    private var hasValidDuration: Bool {
        playerManager.duration.isFinite && playerManager.duration > 0
    }

    private var sliderRange: ClosedRange<Double> {
        0...max(hasValidDuration ? playerManager.duration : 1, 1)
    }

    var body: some View {
        VStack(spacing: 2) {
            HStack {
                Text(sliderValue.formattedMinutesSeconds)
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
                Slider(
                    value: $sliderValue,
                    in: sliderRange,
                    label: {
                        Text("Playback position")
                    },
                    onEditingChanged: handleEditingChanged
                )
                .tint(.primary)
                .sliderThumbVisibility(
                    isEditing ? .visible : .hidden
                )
                .disabled(!hasValidDuration || isSeeking)
                .accessibilityValue(
                    "\(sliderValue.formattedMinutesSeconds) of \(playerManager.duration.formattedMinutesSeconds)"
                )
                
                Text("−\((max(0, playerManager.duration - sliderValue)).formattedMinutesSeconds)")
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
            }
                
            seekingButtons()

            
        }
        .onAppear {
            sliderValue = clamped(playerManager.currentTime)
        }
        .onChange(of: playerManager.currentTime) { _, newTime in
            guard !isEditing, !isSeeking else { return }
            sliderValue = clamped(newTime)
        }
        .onChange(of: playerManager.duration) {
            sliderValue = clamped(sliderValue)
        }
    }
    
    private func seekingButtons() -> some View {
        HStack(spacing: 35) {
            Button {
                withAnimation {
                    sliderValue -= 10
                }
                handleEditingChanged(false)
            } label: {
                Image(systemName: "10.arrow.trianglehead.counterclockwise")
            }
            
            Button {
                playerManager.next()
            } label: {
                Image(systemName: playerManager.queue > 1 ? "forward.end.fill" : "stop.fill")
                    .imageScale(.large)
            }
            
            Button {
                withAnimation {
                    sliderValue += 30
                }
                handleEditingChanged(false)
            } label: {
                Image(systemName: "30.arrow.trianglehead.clockwise")
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Seeking

    private func handleEditingChanged(_ editing: Bool) {
        if editing {
            isEditing = true
            sliderValue = clamped(playerManager.currentTime)
            return
        }

        let target = clamped(sliderValue)
        isSeeking = true

        Task { @MainActor in
            playerManager.goTo(target)

            // Keep the chosen position until playback updates again.
            sliderValue = target
            isSeeking = false
            isEditing = false
        }
    }

    private func clamped(_ time: TimeInterval) -> Double {
        guard hasValidDuration else { return 0 }

        let validTime = time.isFinite ? time : 0
        return min(max(validTime, 0), playerManager.duration)
    }
}

#Preview {
    MusicProgressSlider()
    .environment(MusicQueuePlayer.shared)
}
