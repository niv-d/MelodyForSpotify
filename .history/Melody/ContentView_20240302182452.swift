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

struct WebView: UIViewRepresentable {
  let webView: WKWebView

  func makeUIView(context: Context) -> WKWebView {
    let configuration = WKWebViewConfiguration()
    configuration.applicationNameForUserAgent =
      "Mozilla/5.0 (Macintosh; Intel Mac OS X 14_3_1) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.3.1 Safari/605.1.15"

    let cssFile = readFileBy(name: "theme", type: "css")
    let cssStyle = """
            javascript:(function() {
            var parent = document.getElementsByTagName('head').item(0);
            var style = document.createElement('style');
            style.type = 'text/css';
            style.innerHTML = "\(cssFile)";
            parent.appendChild(style)})()
        """
    let cssScript = WKUserScript(
      source: cssStyle, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
    
    configuration.userContentController.addUserScript(cssScript)

    let webView = WKWebView(frame: .zero, configuration: configuration)
    webView.load(URLRequest(url: URL(string: "https://open.spotify.com")!))
     injectToPage()
    return webView
  }

  func updateUIView(_ uiView: WKWebView, context: Context) {
  }

    // 2
    // MARK: - Reading contents of files
    private func readFileBy(name: String, type: String) -> String {
        guard let path = Bundle.main.path(forResource: name, ofType: type) else {
            return "Failed to find path"
        }
        
        do {
            return try String(contentsOfFile: path, encoding: .utf8)
        } catch {
            return "Unkown Error"
        }
    }
    
    // 3
    // MARK: - Inject to web page
    func injectToPage() {
        let cssFile = readFileBy(name: "theme", type: "css")
        // let jsFile = readFileBy(name: "bootstrap", type: "js")
        
        let cssStyle = """
            javascript:(function() {
            var parent = document.getElementsByTagName('head').item(0);
            var style = document.createElement('style');
            style.type = 'text/css';
            style.innerHTML = window.atob('\(encodeStringTo64(fromString: cssFile)!)');
            parent.appendChild(style)})()
        """
        
        let jsStyle = """
            javascript:(function() {
            var parent = document.getElementsByTagName('head').item(0);
            var script = document.createElement('script');
            script.type = 'text/javascript';
            script.innerHTML = window.atob('\(encodeStringTo64(fromString: jsFile)!)');
            parent.appendChild(script)})()
        """

        let cssScript = WKUserScript(source: cssStyle, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
        // let jsScript = WKUserScript(source: jsStyle, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
        
        webView.configuration.userContentController.addUserScript(cssScript)
        // webView.configuration.userContentController.addUserScript(jsScript)
    }
    
    // 4
    // MARK: - Encode string to base 64
    private func encodeStringTo64(fromString: String) -> String? {
        let plainData = fromString.data(using: .utf8)
        return plainData?.base64EncodedString(options: [])
    }
}

struct ContentView: View {
  let webView: WKWebView = WKWebView()

  var body: some View {
    VStack {
      WebView(webView: webView)
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
    }
  }
}

#Preview(windowStyle: .automatic) {
  ContentView()
}
