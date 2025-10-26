import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    let url: URL

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()

        // JavaScript and content settings
        if #available(iOS 14.0, *) {
            config.defaultWebpagePreferences.allowsContentJavaScript = true
        } else {
            // For iOS 13, JS is enabled by default; nothing needed.
        }
        config.allowsInlineMediaPlayback = true
        if #available(iOS 10.0, *) {
            config.mediaTypesRequiringUserActionForPlayback = []
        }

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator

        // Better scrolling experience
        webView.scrollView.isScrollEnabled = true
        webView.scrollView.bounces = true

        // Back/forward swipe
        webView.allowsBackForwardNavigationGestures = true

        // Use a Mobile Safari user agent to match site expectations
        webView.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1"

        // Inject viewport meta if missing
        let viewportScript = WKUserScript(
            source: """
            (function() {
                var meta = document.querySelector('meta[name=viewport]');
                if (!meta) {
                    meta = document.createElement('meta');
                    meta.name = 'viewport';
                    meta.content = 'width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no';
                    document.head.appendChild(meta);
                }
            })();
            """,
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: true
        )
        webView.configuration.userContentController.addUserScript(viewportScript)

        // Fit CSS
        let fitCSS = WKUserScript(
            source: """
            (function() {
                var style = document.createElement('style');
                style.innerHTML = 'html, body { overflow-x: hidden; } body { -webkit-text-size-adjust: 100%; }';
                document.head.appendChild(style);
            })();
            """,
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: true
        )
        webView.configuration.userContentController.addUserScript(fitCSS)

        // Show a small progress indicator during load (optional)
        webView.addObserver(context.coordinator, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)

        // Load
        let request = URLRequest(url: url)
        webView.load(request)

        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        // No-op
    }

    static func dismantleUIView(_ uiView: WKWebView, coordinator: Coordinator) {
        // Clean up observer to avoid KVO crashes when view deallocates
        uiView.removeObserver(coordinator, forKeyPath: #keyPath(WKWebView.estimatedProgress))
    }

    // MARK: - Coordinator
    final class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
        // Handle target=_blank by loading in the same webView
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            if navigationAction.targetFrame == nil, let url = navigationAction.request.url {
                webView.load(URLRequest(url: url))
                decisionHandler(.cancel)
                return
            }
            decisionHandler(.allow)
        }

        // Handle window.open by returning the current webView
        func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
            if navigationAction.targetFrame == nil {
                webView.load(navigationAction.request)
            }
            return nil
        }

        // Optional: basic JS dialogs
        func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
            completionHandler()
        }

        func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
            completionHandler(true)
        }

        func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
            completionHandler(defaultText)
        }

        // Optional: observe failures for debugging
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            print("WKWebView didFail navigation: \(error)")
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            print("WKWebView didFailProvisionalNavigation: \(error)")
        }

        // KVO for progress (optional)
        override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
            guard keyPath == #keyPath(WKWebView.estimatedProgress) else { return }
            // You could publish progress to SwiftUI via NotificationCenter or other means if needed.
        }
    }
}
