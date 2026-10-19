//
//  MusicProgressSlider.swift
//  BulkPlayer
//
//  Created by soheil pakgohar on 10/19/26.
//

import SwiftUI

struct MusicProgressSlider: View {
    let currentTime: TimeInterval
    let duration: TimeInterval
    let onSeek: (TimeInterval) async -> Void

    @State private var sliderValue: Double = 0
    @State private var isEditing = false
    @State private var isSeeking = false

    private var hasValidDuration: Bool {
        duration.isFinite && duration > 0
    }

    private var sliderRange: ClosedRange<Double> {
        0...max(hasValidDuration ? duration : 1, 1)
    }

    var body: some View {
        VStack(spacing: 2) {
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
                "\(formatTime(sliderValue)) of \(formatTime(duration))"
            )

            HStack {
                Text(formatTime(sliderValue))

                Spacer()

                Text("−\(formatTime(max(0, duration - sliderValue)))")
            }
            .font(.caption.monospacedDigit())
            .foregroundStyle(.secondary)
        }
        .onAppear {
            sliderValue = clamped(currentTime)
        }
        .onChange(of: currentTime) { _, newTime in
            guard !isEditing, !isSeeking else { return }
            sliderValue = clamped(newTime)
        }
        .onChange(of: duration) {
            sliderValue = clamped(sliderValue)
        }
    }

    // MARK: - Seeking

    private func handleEditingChanged(_ editing: Bool) {
        if editing {
            isEditing = true
            sliderValue = clamped(currentTime)
            return
        }

        let target = clamped(sliderValue)
        isSeeking = true

        Task { @MainActor in
            await onSeek(target)

            // Keep the chosen position until playback updates again.
            sliderValue = target
            isSeeking = false
            isEditing = false
        }
    }

    private func clamped(_ time: TimeInterval) -> Double {
        guard hasValidDuration else { return 0 }

        let validTime = time.isFinite ? time : 0
        return min(max(validTime, 0), duration)
    }

    private func formatTime(_ time: TimeInterval) -> String {
        let seconds = Int(max(0, time.isFinite ? time : 0))
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let remainder = seconds % 60

        if hours > 0 {
            return String(
                format: "%d:%02d:%02d",
                hours, minutes, remainder
            )
        }

        return String(
            format: "%d:%02d",
            minutes, remainder
        )
    }
}

#Preview {
    MusicProgressSlider(currentTime: 2.0, duration: 2.5) { interval in
        
    }
}
