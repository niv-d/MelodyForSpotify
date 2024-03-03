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

    let webView = WKWebView(frame: .zero, configuration: configuration)
    webView.navigationDelegate = context.coordinator
    webView.load(URLRequest(url: URL(string: "https://open.spotify.com")!))
    webView.isOpaque = false  // Set the web view to be transparent
    webView.backgroundColor = UIColor.clear  // Set the background color to clear

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

  private func encodeStringTo64(fromString: String) -> String? {
    let plainData = fromString.data(using: .utf8)
    return plainData?.base64EncodedString(options: [])
  }

  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }

  class Coordinator: NSObject, WKNavigationDelegate {
    var parent: WebView

    init(_ parent: WebView) {
      self.parent = parent
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
      let cssFile = parent.readFileBy(name: "theme", type: "css")
      let injectedScripts = """
        (function() {
          var parent = document.getElementsByTagName('head').item(0);
          var style = document.createElement('style');
          style.type = 'text/css';
          style.innerHTML = window.atob('\(parent.encodeStringTo64(fromString: cssFile)!)');
          parent.appendChild(style)}

          var parent = document.getElementsByTagName('head').item(0);
          var script = document.createElement('script');
          script.type = 'text/javascript';
          script.innerHTML = window.atob('\(encodeStringTo64(fromString: jsFile)!)');
          parent.appendChild(script)
        )()
        """
      webView.evaluateJavaScript(injectedScripts) { _, error in
        if let error = error {
          print("Error injecting JavaScript: \(error)")
        }
      }
    }
    func userContentController(
      _ userContentController: WKUserContentController, didReceive message: WKScriptMessage
    ) {
      if message.name == "consoleLog", let log = message.body as? String {
        print("JavaScript Console Log: \(log)")
      }
    }
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
