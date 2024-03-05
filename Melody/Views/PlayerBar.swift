//
//  PlayerControlView.swift
//  MusicPlayerUI-VisionOS
//
//  Created by Vinoth Vino on 22/07/23.
//

import SwiftUI

struct PlayerBar: View {
  @ObservedObject var viewModel: SpotifyWebViewState

  var body: some View {
    HStack(spacing: 5) {
      PlayerButton(image: "backward.fill", toggled: false, action: { viewModel.mediaPrevious() })

      PlayerButton(
        image: viewModel.spotifyState.playing ? "pause.fill" : "play.fill", toggled: false,
        action: { viewModel.mediaPlayPause() })

      PlayerButton(image: "forward.fill", toggled: false, action: { viewModel.mediaNext() })

      NowPlaying(viewModel: viewModel)

      PlayerButton(
        image: "list.bullet", toggled: viewModel.spotifyState.queue,
        action: { viewModel.mediaQueue() })

      PlayerButton(
        image: "music.mic", toggled: viewModel.spotifyState.lyrics,
        action: { viewModel.mediaLyrics() })
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

struct TextButton: View {
  let action: () -> Void
  let text: String
  var body: some View {
    Button(action: action) {
      Text(text)
    }
  }
}

struct NowPlaying: View {
  @ObservedObject var viewModel: SpotifyWebViewState
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
          .frame(height: 70)
          .shadow(color: Color.black.opacity(0.5), radius: 3, x: -3, y: -3)
          .shadow(color: Color.white.opacity(0.5), radius: 3, x: 3, y: 3)

        //Song info
        VStack {
          HStack {
            if !isDragging {
              //TODO: State
              AsyncImage(url: URL(string: viewModel.spotifyState.albumImage)) { image in
                image.resizable()
                  .aspectRatio(contentMode: .fit)
                  .frame(width: 50, height: 50)
                  .cornerRadius(5)
              } placeholder: {
                ProgressView()
              }
            } else {
              Text(timeString(seconds: viewModel.spotifyState.songPosition))
                .foregroundColor(.white)
                .font(.caption)
                .frame(minWidth: 40)
                .monospacedDigit()
            }
            if isDragging {
              Spacer()
            }
            VStack(alignment: .leading) {
              Text(viewModel.spotifyState.songName)
                .font(.caption2)
                .foregroundColor(.white)
              if !isDragging {
                Text(viewModel.spotifyState.artistName)
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
                  VStack(spacing: 10) {
                    TextButton(
                      action: { viewModel.goSongInfo() }, text: viewModel.spotifyState.songName)  //Opens the now playing widget on the side
                    TextButton(
                      action: { viewModel.goArtist() }, text: viewModel.spotifyState.artistName)
                    TextButton(action: { viewModel.goAlbum() }, text: "Album")
                    Divider()
                      .background(Color.gray)
                    HStack(spacing: 20) {
                      PlayerButton(
                        image: viewModel.spotifyState.heart ? "heart.fill" : "heart",
                        toggled: viewModel.spotifyState.heart, action: { viewModel.mediaHeart() })

                      PlayerButton(
                        image: "shuffle", toggled: viewModel.spotifyState.shuffle,
                        action: { viewModel.mediaShuffle() })

                      PlayerButton(
                        image: viewModel.spotifyState.repeatMode == SpotifyState.RepeatMode.one
                          ? "repeat.1" : "repeat",
                        toggled: viewModel.spotifyState.repeatMode != SpotifyState.RepeatMode.none,
                        action: { viewModel.mediaRepeat() })
                    }
//                    Divider()
//                      .background(Color.gray)
                    //TODO: Checkboxes instead?
                    //                    TextButton(action: {}, text: "DMR-PC")
                    //                    TextButton(action: {}, text: "nvd-std")
                    //                    TextButton(action: {}, text: "Web Player (Microsoft Edge)")
                    Divider()
                      .background(Color.gray)
                    PlayerButton(
                      image: "x.circle.fill", toggled: false, action: { showingMenu = false })
                  }.padding(15)

                }
            } else {
              Text(
                "-"
                  + timeString(
                    seconds: viewModel.spotifyState.songLength - viewModel.spotifyState.songPosition
                  )
              )
              .foregroundColor(.white)
              .font(.caption)
              .frame(minWidth: 40)
              .monospacedDigit()
            }
          }
          .padding([.leading, .trailing], 10)
          .padding([.top, .bottom], isDragging ? 15 : 5)
          if isDragging {
            Spacer()
          }
        }
        VStack(alignment: .trailing) {
          Spacer()
          Slider(
            value: $viewModel.spotifyState.songPosition,
            in: 0...viewModel.spotifyState.songLength,
            onEditingChanged: { editing in
              isDragging = editing
              if !editing {
                viewModel.songPositionChanged(to: viewModel.spotifyState.songPosition)
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
    .frame(width: 400, height: 70)
    .padding(.horizontal)
  }

  private func timeString(seconds: Double) -> String {
    let totalSeconds = Int(seconds)
    let minutes = totalSeconds / 60
    let remainingSeconds = totalSeconds % 60
    return String(format: "%d:%02d", minutes, remainingSeconds)
  }
}
