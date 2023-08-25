//
//  FeedViewController.swift
//  SoSoHappy
//
//  Created by Sue on 2023/08/25.
//

import UIKit
import SnapKit

/*
 1. private lazy var refreshControl = UIRefreshControl()
 2. tableView.tableHeaderView?.frame.size.height를 어떻게 설정해줄 것인지
 */


final class FeedViewController: UIViewController {
    // MARK: - Properties
    // MARK: - UI Components
    private lazy var refreshControl = UIRefreshControl()
    private lazy var feedHeaderView = FeedHeaderView()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(FeedCell.self, forCellReuseIdentifier: FeedCell.cellIdentifer)
//        tableView.refreshControl = self.refreshControl
        tableView.tableHeaderView = feedHeaderView
        tableView.tableHeaderView?.frame.size.height = 70
        
        tableView.backgroundColor = UIColor(named: "backgroundColor")
        tableView.separatorStyle = .none
    
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 300
        return tableView
    }()
    
    // MARK: 이미지 크기에 대해서 고민해볼 것
    private lazy var dmBarButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: UIImage(named: "dm"),
                                     style: .plain,
                                     target: self,
                                     action: nil)
        
        button.tintColor = .red
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigation()
        addSubViews()
        setConstraints()
    }
}

//MARK: - Set Navigation & Add Subviews & Constraints
extension FeedViewController {
    func configureNavigation() {
        self.navigationItem.title = "소피들의 소소해피"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.rightBarButtonItem = dmBarButton
    }
    
    private func addSubViews() {
        view.addSubview(tableView)
    }
    
    private func setConstraints() {
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

// MARK: - UITableView DataSource
extension FeedViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: FeedCell = tableView.dequeueReusableCell(withIdentifier: FeedCell.cellIdentifer , for: indexPath) as? FeedCell else { fatalError("The tableView could not dequeue FeedCell in FeedViewController.") }
        return cell
    }
}

// MARK: - UITableView Delegate
extension FeedViewController: UITableViewDelegate {
    
}


#if DEBUG
import SwiftUI
struct FeedViewControllerRepresentable: UIViewControllerRepresentable {
    
    func updateUIViewController(_ uiView: UIViewController,context: Context) {
        // leave this empty
    }
    @available(iOS 13.0.0, *)
    func makeUIViewController(context: Context) -> UIViewController{
        FeedViewController()
    }
}
@available(iOS 13.0, *)
struct FeedViewControllerRepresentable_PreviewProvider: PreviewProvider {
    static var previews: some View {
        Group {
            FeedViewControllerRepresentable()
                .ignoresSafeArea()
                .previewDisplayName(/*@START_MENU_TOKEN@*/"Preview"/*@END_MENU_TOKEN@*/)
                .previewDevice(PreviewDevice(rawValue: "iPhone 14 Pro"))
        }
        
    }
} #endif

