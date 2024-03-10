//
//  MiniPlayer.swift
//  Melody
//
//  Created by Devin Ratcliffe on 3/10/24.
//

import SwiftUI

struct MiniPlayer: View {
  @ObservedObject var viewModel: SpotifyWebViewState
    var body: some View {
      ZStack {
        AsyncImage(url: URL(string: viewModel.spotifyState.albumImage)) { image in
          image.resizable()
            .aspectRatio(contentMode: .fit)
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        } placeholder: {
          ProgressView()
        }
        VStack(alignment: .leading, spacing: 8) {
          HStack {
            Button(action: { viewModel.miniPlayer = 0 }) {
              Image(systemName: "square.and.arrow.up.fill")
                .foregroundColor(.white)
            }
            .buttonStyle(PlainButtonStyle())
            Spacer()
            Button(action: { viewModel.mediaHeart() }) {
              Image(systemName: viewModel.spotifyState.heart ? "heart" : "heart.fill")
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
          Slider(value: .constant(0.3), in: 0...1)
            .accentColor(.white)
            .controlSize(.mini)
          
          HStack {
            Text("1:21")
              .foregroundColor(.white)
              .font(.subheadline)
            Spacer()
            Text("-3:37")
              .foregroundColor(.white)
              .font(.subheadline)
          }
          Spacer()
          HStack {
            Spacer()
            Button(action: { viewModel.mediaPrevious() }) {
              Image(systemName: "backward.fill")
                .foregroundColor(.white)
            }
            .buttonStyle(PlainButtonStyle())
            Spacer()
            Button(action: { viewModel.mediaPlayPause() }) {
              Image(systemName: viewModel.spotifyState.playing ? "pause.fill" : "play.fill")
                .foregroundColor(.white)
            }
            .buttonStyle(PlainButtonStyle())
            Spacer()
            Button(action: { viewModel.mediaNext() }) {
              Image(systemName: "forward.fill")
                .foregroundColor(.white)
            }
            .buttonStyle(PlainButtonStyle())
            Spacer()
          }
          .font(.title)
          Spacer()
          Slider(value: .constant(0.7), in: 0...1)
            .accentColor(.white)
            .controlSize(.mini)
          
          HStack {
            Image(systemName: "speaker.wave.2.fill")
            Spacer()
            Image(systemName: "speaker.wave.3.fill")
          }
          .foregroundColor(.white)
        }
        .padding()
        .cornerRadius(20)
        .padding(.horizontal)
      }
      .aspectRatio(1, contentMode: .fit)
      .frame(
        minWidth: 300, maxWidth: 500,
        minHeight: 300, maxHeight: 500)

    }
}

#Preview {
    MiniPlayer()
}
