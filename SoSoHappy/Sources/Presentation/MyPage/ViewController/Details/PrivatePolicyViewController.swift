//
//  PrivatePolicyViewController.swift
//  SoSoHappy
//
//  Created by 박민주 on 12/6/23.
//

import UIKit
import WebKit

class PrivatePolicyViewController: UIViewController, WKNavigationDelegate {
    // MARK: - UI Components
    private var webView = WKWebView()
    private lazy var activityIndicator = UIActivityIndicatorView().then {
        $0.hidesWhenStopped = true
        $0.color = UIColor(named: "MainTextColor")
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
        if let tabBarController = self.tabBarController as? TabBarController {
            tabBarController.addButton.isHidden = true
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
        if let tabBarController = self.tabBarController as? TabBarController {
            tabBarController.addButton.isHidden = false
        }
    }
}

// MARK: - Layout & Attribute
extension PrivatePolicyViewController {
    private func setup() {
        setWebView()
        setAttribute()
        setLayout()
    }
    
    private func setWebView() {
        webView.navigationDelegate = self
        let request = URLRequest(url: URL(string: Bundle.main.privatePolicyPath)!)
        webView.load(request)
    }
    
    private func setAttribute() {
        view.backgroundColor = UIColor(named: "BGgrayColor")
    }
    
    private func setLayout() {
        view.addSubview(webView)
        view.addSubview(activityIndicator)
        
        webView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.horizontalEdges.bottom.equalToSuperview()
        }
        
        activityIndicator.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.horizontalEdges.bottom.equalToSuperview()
        }
    }
}

// MARK: - WebView Settings
extension PrivatePolicyViewController {
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
//        activityIndicator.startAnimating()
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
//        activityIndicator.stopAnimating()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
//        activityIndicator.stopAnimating()
    }
}

