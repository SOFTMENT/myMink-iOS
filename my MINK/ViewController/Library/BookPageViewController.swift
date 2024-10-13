import UIKit
import WebKit

class BookPageViewController: UIViewController {

    var pageContent: String?
    var baseURL: URL?

    private let webView: WKWebView = {
        let webView = WKWebView()
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.scrollView.isScrollEnabled = true // Enable scrolling
        webView.scrollView.showsHorizontalScrollIndicator = false // Hide horizontal scroll indicator
        webView.scrollView.alwaysBounceHorizontal = false // Prevent horizontal bouncing
        return webView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupWebView()
        if let content = pageContent, let baseURL = baseURL {
            let styledContent = addCSS(to: content)
            webView.loadHTMLString(styledContent, baseURL: baseURL)
        }
    }

    private func setupWebView() {
        view.addSubview(webView)
        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func addCSS(to content: String) -> String {
        let css = """
        <style>
        body {
            margin: 20px;
            overflow-x: hidden;
            word-wrap: break-word;
        }
        img {
            max-width: 100%;
            height: auto;
        }
        </style>
        """
        return css + content
    }
}

