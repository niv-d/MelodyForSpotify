//
//  ContentView.swift
//  Melody
//
//  Created by Devin Ratcliffe on 3/2/24.
//

import RealityKit
import RealityKitContent
import SwiftUI
import WebKit

struct SpotifyState: Codable {
  var albumImage: String = ""
  var albumName: String = ""
  var artistName: String = ""
  var device: String = ""
  var heart: Bool = false
  var lyrics: Bool = false
  var playing: Bool = false
  var queue: Bool = false
  var repeatMode: RepeatMode = RepeatMode.none
  var shuffle: Bool = false
  var songLength: Double = 0
  var songName: String = ""
  var songPercent: Double = 0
  var songPosition: Double = 0

  enum CodingKeys: String, CodingKey {
    case playing, songLength, songPercent, songPosition, heart, shuffle, device, songName,
      artistName, albumName, albumImage, queue, lyrics
    case repeatMode = "repeat"
  }

  enum RepeatMode: String, Codable {
    case none = "none"
    case one = "one"
    case all = "all"
  }
}

struct ContentView: View {
  @ObservedObject var viewModel = SpotifyWebViewState()
  @State private var selectedTab = 0
  @State private var visibleControlsMiniPlayer = 1
  var body: some View {
    VStack {
      if viewModel.miniPlayer == 1 {
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
                Image(systemName: "square.and.arrow.up")
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

      } else {
        TabView(selection: $selectedTab) {
          Text("").tabItem {
            Label("Home", systemImage: "house")
          }
          .tag(0)
          .onAppear {
            viewModel.goHome()
          }.onTapGesture {
            viewModel.goHome()
          }

          Text("").tabItem {
            Label("Search", systemImage: "magnifyingglass")
          }
          .tag(1).onAppear {
            viewModel.goSearch()
          }

          Text("").tabItem {
            Label("Reload Player", systemImage: "arrow.clockwise")
          }
          .tag(2).onAppear {
            viewModel.webView.load(
              URLRequest(url: URL(string: "https://accounts.spotify.com/en/login")!))
            selectedTab = 0
          }

        }
        .toolbar {
          ToolbarItemGroup(placement: .bottomOrnament) {
            PlayerBar(viewModel: viewModel)
          }
        }.frame(
          minWidth: 1000,
          minHeight: 700)
      }
    }
    .overlay(
      SpotifyWebView(webView: viewModel.webView, viewModel: viewModel)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity).opacity(
          viewModel.miniPlayer == 1 ? 0 : 1)
    ).aspectRatio(1, contentMode: .fit)
  }
}

#Preview(windowStyle: .automatic) {
  ContentView()
}
