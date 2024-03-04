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
    HStack(spacing: 5) {
      PlayerButton(image: "backward.fill", toggled: false, action: { viewModel.mediaPrevious() })

      //pause.circle.fill
      PlayerButton(image: "play.fill", toggled: false, action: { viewModel.mediaPlayPause() })

      PlayerButton(image: "forward.fill", toggled: false, action: { viewModel.mediaNext() })

      NowPlaying()

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
        .imageScale(.medium)
    }
    .clipShape(Circle())
    .frame(width: 35, height: 35)
    .padding(.horizontal, 10)
  }
}

struct TextButton: View{
  let action: ()->Void
  let text: String
  var body: some View {
    Button(action: action){
      Text(text)
    }
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
  @State private var showingMenu = false
  var body: some View {
    VStack {
      ZStack {
//        RoundedRectangle(cornerRadius: 15)
//          .fill(Color.black.opacity(0.2))
//          .frame(height: 60)
        
        RoundedRectangle(cornerRadius: 15)
          .fill(Color.black.opacity(0.1))
          .frame(height: 60)
          .shadow(color: Color.black.opacity(0.5), radius: 3, x: -3, y: -3)
          .shadow(color: Color.white.opacity(0.5), radius: 3, x: 3, y: 3)
        
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
                .monospacedDigit()
            }
            if isDragging {
              Spacer()
            }
            VStack(alignment: .leading) {
              //TODO: State
              Text("Pretty When You Cry")
                .font(.caption2)
                .foregroundColor(.white)
              if !isDragging {
                Text("VAST")
                  .font(.caption2)
                  .foregroundColor(Color.white.opacity(0.7))
              }

            }
            if isDragging {
              Spacer()
            }
            if !isDragging {
              Spacer()
              PlayerButton(image: "ellipsis", toggled: false, action: { showingMenu = true })
              .sheet(isPresented: $showingMenu) {
                VStack(spacing: 10){
                  TextButton(action: {}, text:"Song") //Opens the now playing widget on the side
                  TextButton(action: {}, text:"Author")
                  TextButton(action: {}, text:"Album")
                  Divider()
                    .background(Color.gray)
                  HStack(spacing: 20){
                    PlayerButton(image: "heart", toggled: false, action: {  })
                    
                    PlayerButton(image: "shuffle", toggled: false, action: {  })
                    
                    PlayerButton(image: "repeat", toggled: false, action: {  })
                  }
                  Divider()
                    .background(Color.gray)
                  //TODO: Checkboxes instead?
                  TextButton(action: {}, text:"DMR-PC")
                  TextButton(action: {}, text:"nvd-std")
                  TextButton(action: {}, text:"Web Player (Microsoft Edge)")
                  Divider()
                    .background(Color.gray)
                  PlayerButton(image: "x.circle.fill", toggled: false, action: { showingMenu = false })
                }.padding(15)
                
              }
            } else {
              Text("-" + timeString(seconds: viewModel.totalDuration-viewModel.playbackPosition))
                .foregroundColor(.white)
                .font(.caption)
                .frame(minWidth: 40)
                .monospacedDigit()
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
          .controlSize(isDragging ? .small : .mini)
          .accentColor(.white)
          .padding(.vertical, isDragging ? -5 : -10)
          .padding(.horizontal, -10)
        }
      }.clipShape(RoundedRectangle(cornerRadius: 15))
    }
    .frame(width: 400, height: 60)
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
