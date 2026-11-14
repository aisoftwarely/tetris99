import SwiftUI
import WebKit
import AVFoundation

@main
struct Tetris99App: App {
    init() {
        // 游戏音效：即使打开静音开关也出声；同时不打断别的 App 的音乐
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
        try? session.setActive(true)
    }

    var body: some Scene {
        WindowGroup {
            GameWebView()
                .ignoresSafeArea()
                .statusBarHidden(true)
                .persistentSystemOverlays(.hidden)
                .preferredColorScheme(.dark)
        }
    }
}

struct GameWebView: UIViewRepresentable {
    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        config.defaultWebpagePreferences.allowsContentJavaScript = true
        config.userContentController.addUserScript(
            WKUserScript(
                source: "document.addEventListener('gesturestart', function(e){ e.preventDefault(); });",
                injectionTime: .atDocumentEnd,
                forMainFrameOnly: true
            )
        )

        let webView = WKWebView(frame: .zero, configuration: config)
        let bg = UIColor(red: 0.027, green: 0.012, blue: 0.059, alpha: 1)
        webView.isOpaque = false
        webView.backgroundColor = bg
        webView.scrollView.backgroundColor = bg
        webView.scrollView.isScrollEnabled = false
        webView.scrollView.bounces = false
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        webView.scrollView.showsVerticalScrollIndicator = false
        webView.scrollView.showsHorizontalScrollIndicator = false
        webView.allowsBackForwardNavigationGestures = false

        if let url = Bundle.main.url(forResource: "index", withExtension: "html") {
            webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
        }
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}
}
