//
//  ToSViewController.swift
//  SoSoHappy
//
//  Created by 박민주 on 12/5/23.
//

import UIKit
import WebKit

class ToSViewController: UIViewController, WKNavigationDelegate, WKUIDelegate {
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
extension ToSViewController {
    private func setup() {
        setWebView()
        setAttribute()
        setLayout()
    }
    
    private func setWebView() {
        webView.navigationDelegate = self
        let request = URLRequest(url: URL(string: Bundle.main.tosPath)!)
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
