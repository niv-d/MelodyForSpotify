//
//  PlayerControlView.swift
//  MusicPlayerUI-VisionOS
//
//  Created by Vinoth Vino on 22/07/23.
//

import SwiftUI

struct PlayerBar: View {
  let viewModel: WebViewModel

  var body: some View {
    HStack(spacing: 2) {
      PlayerButton(image: "backward.fill", toggled: false, action: { viewModel.mediaPrevious() })

      PlayerButton(image: "playpause.fill", toggled: false, action: { viewModel.mediaPlayPause() })

      PlayerButton(image: "forward.fill", toggled: false, action: { viewModel.mediaNext() })

      NowPlaying()

      PlayerButton(image: "heart", toggled: false, action: { viewModel.mediaHeart() })

      PlayerButton(image: "shuffle", toggled: false, action: { viewModel.mediaShuffle() })

      PlayerButton(image: "repeat", toggled: false, action: { viewModel.mediaRepeat() })

      PlayerButton(image: "list.bullet", toggled: false, action: { viewModel.mediaQueue() })

      PlayerButton(image: "music.mic", toggled: false, action: { viewModel.mediaLyrics() })
    }
  }
}

struct PlayerButton: View {
  let image: String
  let toggled: Bool
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      Image(systemName: image)
        .padding()
        .foregroundColor(toggled ? Color.black : Color.white)
        .background(Color.white.opacity(toggled ? 1 : 0))
        .clipShape(Circle())
    }.clipShape(Circle())
  }
}

class PlayerViewModel: ObservableObject {
  @Published var playbackPosition: Double = 30
  @Published var isPlaying: Bool = false
  var totalDuration: Double = 300  // Replace with the actual duration of the media

  // Call this method when the slider value changes
  func sliderValueChanged(to newValue: Double) {
    playbackPosition = newValue
    // Update the playback time of your media player here
  }

  // Call this method to toggle playback state
  func togglePlayPause() {
    isPlaying.toggle()
    // Handle play/pause of your media player here
  }
}
struct NowPlaying: View {
  @ObservedObject var viewModel: PlayerViewModel = PlayerViewModel()
  @State private var isDragging: Bool = false

  var body: some View {
    VStack {
      ZStack {
        RoundedRectangle(cornerRadius: 15)
          .fill(Color.black.opacity(0.2))
          .frame(height: 70)

        //Song info
        VStack {
          HStack {
            if !isDragging {
              //TODO: State
              Image("albumArtwork")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 50, height: 50)
                .cornerRadius(5)
            } else {
              Text(timeString(seconds: viewModel.playbackPosition))
                .foregroundColor(.white)
                .font(.caption)
                .frame(minWidth: 40)
            }
            if isDragging {
              Spacer()
            }
            VStack(alignment: .leading) {
              //TODO: State
              Text("Pretty When You Cry")
                .font(.headline)
                .foregroundColor(.white)
              if !isDragging {
                Text("VAST")
                  .font(.subheadline)
                  .foregroundColor(Color.white.opacity(0.7))
              }

            }
            if isDragging {
              Spacer()
            }
            if !isDragging {
              Spacer()
              Button(action: {
              }) {
                Image(systemName: "ellipsis")
                  .foregroundColor(.white)
              }
            } else {
              Text(timeString(seconds: viewModel.totalDuration))
                .foregroundColor(.white)
                .font(.caption)
                .frame(minWidth: 40)
            }
          }
          .padding([.leading, .trailing], 10)
          .padding([.top, .bottom], isDragging ? 15 : 5)
          if(isDragging){
            Spacer()
          }
        }
        VStack(alignment: .trailing) {
          Spacer()
          Slider(
            value: $viewModel.playbackPosition,
            in: 0...viewModel.totalDuration,
            onEditingChanged: { editing in
              isDragging = editing
              if !editing {
                viewModel.sliderValueChanged(to: viewModel.playbackPosition)
              }
            }
          )
          .controlSize(isDragging ? .regular : .mini)
//          .scaleEffect(CGSize(width: 1.0, height: isDragging ? 1 : 0.1))
          .accentColor(.white).frame(maxHeight: .infinity, alignment: .bottom)
          .offset(CGSize(width:0, height: isDragging ? 0 : 10.0))
        }
//        .ignoresSafeArea().frame(maxHeight: .infinity, alignment: .bottom)
      }.clipShape(RoundedRectangle(cornerRadius: 15))
    }
    .frame(width: 400, height: 70)
    .padding(.horizontal)
  }

  // Convert time in seconds to a formatted string
  private func timeString(seconds: Double) -> String {
    let totalSeconds = Int(seconds)
    let minutes = totalSeconds / 60
    let remainingSeconds = totalSeconds % 60
    return String(format: "%d:%02d", minutes, remainingSeconds)
  }
}
