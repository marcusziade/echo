import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebView
        
        init(parent: WebView) {
            self.parent = parent
        }
        
        func webView(
            _ webView: WKWebView,
            decidePolicyFor navigationAction: WKNavigationAction,
            decisionHandler: @escaping (
                WKNavigationActionPolicy
            ) -> Void
        ) {
            debugPrint("1", navigationAction.request.url?.absoluteString ?? "")
            
            if let url = navigationAction.request.url, URLComponents(
                url: url,
                resolvingAgainstBaseURL: false
            )?.queryItems?.contains(where: {
                $0.name == "code"
            }) == true {
                
                debugPrint("2", url.absoluteString)
                
                if let code = URLComponents(
                    url: url,
                    resolvingAgainstBaseURL: false
                )?.queryItems?.first(where: {
                    $0.name == "code"
                })?.value {
                    parent.didReceiveCode(code)
                }
                
                decisionHandler(.cancel)
                return
            }
            
            decisionHandler(.allow)
        }
    }
    
    var didReceiveCode: (String) -> Void
    let request: URLRequest
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.load(request)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
}
