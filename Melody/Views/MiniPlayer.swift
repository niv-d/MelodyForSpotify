//
//  MiniPlayer.swift
//  Melody
//
//  Created by Devin Ratcliffe on 3/10/24.
//

import SwiftUI

struct MiniPlayer: View {
  @ObservedObject var viewModel: SpotifyWebViewState
  @State private var controlOpactiy = 0.0
  @State private var timer: Timer?
  var body: some View {
    ZStack {
      AsyncImage(
        url: URL(
          string: viewModel.spotifyState.hqAlbumImage == ""
            ? viewModel.spotifyState.albumImage : viewModel.spotifyState.hqAlbumImage)
      ) { image in
        image.resizable()
          .aspectRatio(contentMode: .fill)
      } placeholder: {
        ProgressView()
      }.opacity(1 - (controlOpactiy * 0.9)).frame(
        minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity
      )
      .onTapGesture {
        resetTimer()
      }
      VStack(alignment: .leading, spacing: 8) {
        //TODO: break this up, it's stressful
        HStack {
          Button(action: { viewModel.miniPlayer = 0 }) {
            Image(systemName: "square.and.arrow.up.fill")
              .foregroundColor(.white)
          }
          .buttonStyle(PlainButtonStyle())
          Spacer()
          Button(action: {
            viewModel.mediaHeart()
            resetTimer()
          }) {
            Image(systemName: viewModel.spotifyState.heart ? "heart.fill" : "heart")
              .foregroundColor(.white)
          }
          .buttonStyle(PlainButtonStyle())
        }
        .font(.title2)
        .foregroundColor(.white)
        Spacer()
        HStack {
          Spacer()
          VStack(alignment: .center) {
            Text(viewModel.spotifyState.songName)
              .font(.headline)
              .foregroundColor(.white)
            Text(viewModel.spotifyState.artistName)
              .font(.subheadline)
              .foregroundColor(Color.white.opacity(0.7))
          }
          Spacer()
        }
        Spacer()
        Slider(
          value: $viewModel.spotifyState.songPosition,
          in: 0...viewModel.spotifyState.songLength,
          onEditingChanged: { editing in
            if !editing {
              viewModel.songPositionChanged(to: viewModel.spotifyState.songPosition)
            }
          }
        ).accentColor(.white)
          .controlSize(.mini)

        HStack {
          Text(timeString(seconds: viewModel.spotifyState.songPosition))
            .foregroundColor(.white)
            .font(.subheadline)
          Spacer()
          Text(
            "-"
              + timeString(
                seconds: viewModel.spotifyState.songLength - viewModel.spotifyState.songPosition)
          )
          .foregroundColor(.white)
          .font(.subheadline)
        }
        Spacer()
        HStack {
          Spacer()
          Button(action: {
            viewModel.mediaPrevious()
            resetTimer()
          }) {
            Image(systemName: "backward.fill")
              .foregroundColor(.white)
          }
          .buttonStyle(PlainButtonStyle())
          Spacer()
          Button(action: {
            viewModel.mediaPlayPause()
            resetTimer()
          }) {
            Image(systemName: viewModel.spotifyState.playing ? "pause.fill" : "play.fill")
              .foregroundColor(.white)
          }
          .buttonStyle(PlainButtonStyle())
          Spacer()
          Button(action: {
            viewModel.mediaNext()
            resetTimer()
          }) {
            Image(systemName: "forward.fill")
              .foregroundColor(.white)
          }
          .buttonStyle(PlainButtonStyle())
          Spacer()
        }
        .font(.title)
        Spacer()
        //        Slider(value: .constant(0.7), in: 0...1)
        //          .accentColor(.white)
        //          .controlSize(.mini)

        //        HStack {
        //          Image(systemName: "speaker.wave.2.fill")
        //          Spacer()
        //          Image(systemName: "speaker.wave.3.fill")
        //        }
        //        .foregroundColor(.white)
      }
      .padding()
      .cornerRadius(20)
      .padding(.horizontal)
      .opacity(controlOpactiy)
    }
    .frame(
      minWidth: 300, maxWidth: 500,
      minHeight: 300, maxHeight: 500)

  }

  private func startTimer() {
    timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: false) { _ in
      withAnimation {
        controlOpactiy = 0.0
      }
    }
  }

  private func resetTimer() {
    timer?.invalidate()
    withAnimation {
      controlOpactiy = 1.0
    }
    startTimer()
  }

  private func timeString(seconds: Double) -> String {
    let totalSeconds = Int(seconds)
    let minutes = totalSeconds / 60
    let remainingSeconds = totalSeconds % 60
    return String(format: "%d:%02d", minutes, remainingSeconds)
  }
}
