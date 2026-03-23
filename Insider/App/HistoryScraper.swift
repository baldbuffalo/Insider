import WebKit
import UIKit

// MARK: - History Scraper
/// Loads youtube.com/feed/history in a hidden WKWebView, scrolls several times
/// to let YouTube's JS renderer populate the list, then extracts channel names + counts.
class HistoryScraper: NSObject, ObservableObject, WKNavigationDelegate {

    // Published so views can react, but onComplete closure is the primary callback.
    @Published var channelCounts: [String: Int] = [:]
    @Published var isFinished = false

    private var webView: WKWebView?
    private var holderView: UIView?       // keeps WV in a real hierarchy so JS executes
    private var onComplete: (([String: Int]) -> Void)?
    private var didComplete = false
    private var scrollsRemaining = 5

    // MARK: - Public API
    func scrape(completion: @escaping ([String: Int]) -> Void) {
        guard !didComplete else { completion(channelCounts); return }
        onComplete = completion

        DispatchQueue.main.async { self.setupWebView() }

        // Hard timeout — whatever we have after 18 s is good enough
        DispatchQueue.main.asyncAfter(deadline: .now() + 18) { [weak self] in
            self?.finish()
        }
    }

    // MARK: - Setup
    private func setupWebView() {
        let config = WKWebViewConfiguration()
        // Default data store inherits any cookies the user may already have
        // from a previous Safari / ASWebAuthenticationSession visit to Google/YouTube.
        config.websiteDataStore = .default()

        let wv = WKWebView(frame: CGRect(x: 0, y: 0, width: 390, height: 844), configuration: config)
        wv.navigationDelegate = self
        // Desktop UA gives us the full ytd-* element tree, which is much easier to parse.
        wv.customUserAgent = """
            Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) \
            AppleWebKit/537.36 (KHTML, like Gecko) \
            Chrome/124.0.0.0 Safari/537.36
            """
        self.webView = wv

        // Attach to the live key window (alpha ≈ 0, 1×1 px, clipped) so JS runs.
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let keyWindow = scene.windows.first(where: { $0.isKeyWindow }) {
            let holder = UIView(frame: CGRect(x: -2, y: -2, width: 1, height: 1))
            holder.clipsToBounds = true
            holder.alpha = 0.01
            holder.addSubview(wv)
            keyWindow.addSubview(holder)
            self.holderView = holder
        }

        var req = URLRequest(url: URL(string: "https://www.youtube.com/feed/history")!)
        req.cachePolicy = .reloadIgnoringLocalCacheData
        wv.load(req)
    }

    // MARK: - WKNavigationDelegate
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // Give YouTube's Polymer / LitElement renderer time to paint items.
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            self?.scrollStep()
        }
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        finish()
    }

    func webView(_ webView: WKWebView,
                 didFailProvisionalNavigation navigation: WKNavigation!,
                 withError error: Error) {
        finish()
    }

    // MARK: - Scroll → Extract loop
    private func scrollStep() {
        guard !didComplete else { return }

        let scrollJS = "window.scrollBy(0, window.innerHeight * 6); document.body.scrollHeight;"
        webView?.evaluateJavaScript(scrollJS) { [weak self] _, _ in
            guard let self else { return }
            self.scrollsRemaining -= 1
            let delay: Double = self.scrollsRemaining > 0 ? 1.4 : 0.5
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                if self.scrollsRemaining > 0 {
                    self.scrollStep()
                } else {
                    self.extractChannelNames()
                }
            }
        }
    }

    // MARK: - JS Extraction
    private func extractChannelNames() {
        guard !didComplete else { return }

        // Covers desktop ytd-* elements across several renderer types YouTube uses.
        let js = """
        (function() {
            var counts = {};
            function add(raw) {
                var name = raw.trim();
                if (name.length > 0 && name.length < 120) {
                    counts[name] = (counts[name] || 0) + 1;
                }
            }

            // Primary: standard video renderer channel name
            document.querySelectorAll([
                'ytd-video-renderer #channel-name yt-formatted-string',
                'ytd-video-renderer #channel-name a',
                'ytd-grid-video-renderer #channel-name yt-formatted-string',
                'ytd-grid-video-renderer #channel-name a',
                'ytd-compact-video-renderer #channel-name yt-formatted-string',
                'ytd-compact-video-renderer #channel-name a',
                'ytd-rich-item-renderer #channel-name yt-formatted-string',
                'ytd-rich-item-renderer #channel-name a'
            ].join(', ')).forEach(function(el) { add(el.textContent); });

            // Fallback: any byline / owner text element
            document.querySelectorAll([
                '#owner-text yt-formatted-string',
                '#owner-text a',
                'ytd-channel-name yt-formatted-string',
                'ytd-channel-name a'
            ].join(', ')).forEach(function(el) { add(el.textContent); });

            return JSON.stringify(counts);
        })();
        """

        webView?.evaluateJavaScript(js) { [weak self] result, _ in
            if let jsonStr = result as? String,
               let data = jsonStr.data(using: .utf8),
               let raw = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                var parsed: [String: Int] = [:]
                for (k, v) in raw {
                    if let n = v as? Int        { parsed[k] = n }
                    else if let d = v as? Double { parsed[k] = Int(d) }
                }
                self?.channelCounts = parsed
            }
            self?.finish()
        }
    }

    // MARK: - Teardown
    private func finish() {
        guard !didComplete else { return }
        didComplete = true

        DispatchQueue.main.async { [self] in
            isFinished = true
            onComplete?(channelCounts)
            // Clean up the hidden web view
            webView?.stopLoading()
            webView?.navigationDelegate = nil
            webView?.removeFromSuperview()
            webView = nil
            holderView?.removeFromSuperview()
            holderView = nil
        }
    }
}
