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

  var body: some View {
    VStack {

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
          viewModel.webView.load(URLRequest(url: URL(string: "https://accounts.spotify.com/en/login")!))
          selectedTab = 0
        }

      }
      .toolbar {
        ToolbarItemGroup(placement: .bottomOrnament) {
          PlayerBar(viewModel: viewModel)
        }
      }
    }
    .overlay(
      SpotifyWebView(webView: viewModel.webView, viewModel: viewModel)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
    )
  }
}

#Preview(windowStyle: .automatic) {
  ContentView()
}
