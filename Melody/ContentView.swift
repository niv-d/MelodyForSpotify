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

struct ContentView: View {
  @ObservedObject var viewModel = SpotifyWebViewState()
  @State private var selectedTab = 0
  @State private var visibleControlsMiniPlayer = 1
  var body: some View {
    VStack {
      if viewModel.miniPlayer == 1 {
        MiniPlayer(viewModel: viewModel)
      } else {
        TabView(selection: $selectedTab) {
          Text("").tabItem {
            Label("Spotify", systemImage: "house")
          }
          .tag(0)
          .onAppear {
            viewModel.goHome()
            selectedTab = 0
          }
          Text("").tabItem {
            Label("Home", systemImage: "house")
          }
          .tag(1)
          .onAppear {
            viewModel.goHome()
            selectedTab = 0
          }

          Text("").tabItem {
            Label("Search", systemImage: "magnifyingglass")
          }
          .tag(2).onAppear {
            viewModel.goSearch()
            selectedTab = 0
          }

          Text("").tabItem {
            Label("Mini", systemImage: "square.and.arrow.down.fill")
          }
          .tag(3).onAppear {
            viewModel.miniPlayer = 1
            selectedTab = 0
          }

          Text("").tabItem {
            Label("Reload Player", systemImage: "arrow.clockwise")
          }
          .tag(4).onAppear {
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
