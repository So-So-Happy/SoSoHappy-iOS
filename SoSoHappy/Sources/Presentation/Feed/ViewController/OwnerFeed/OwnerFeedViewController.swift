//
//  OwnerFeedViewController.swift
//  SoSoHappy
//
//  Created by Sue on 2023/08/25.
//

import UIKit
import SnapKit

/*
 1. tableView.tableHeaderView?.frame.size.height 설정 어떻게 해줄 것인지 (동적으로)
 2. private lazy var refreshControl = UIRefreshControl()
 */

final class OwnerFeedViewController: UIViewController {
    // MARK: - Properties
    // MARK: - UI Components
    private lazy var refreshControl = UIRefreshControl()
    private lazy var ownerFeedHeaderView = OwnerFeedHeaderView()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(OwnerFeedCell.self, forCellReuseIdentifier: OwnerFeedCell.cellIdentifer)
        tableView.separatorStyle = .none
//        tableView.refreshControl = self.refreshControl
        
        tableView.tableHeaderView = ownerFeedHeaderView
        tableView.tableHeaderView?.frame.size.height = 400
        tableView.sectionHeaderHeight = UITableView.automaticDimension
        
        tableView.backgroundColor = UIColor(named: "backgroundColor")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 300
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSubViews()
        setConstraints()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
//        sizeHeaderToFit()
    }
    
//    func sizeHeaderToFit() {
//        let headerView = tableView.tableHeaderView!
//
//        headerView.setNeedsLayout()
//        headerView.layoutIfNeeded()
//
//        let height = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
//        var frame = headerView.frame
//        frame.size.height = height
//        headerView.frame = frame
//
//        tableView.tableHeaderView = headerView
//    }


}

//MARK: - Set Navigation & Add Subviews & Constraints
extension OwnerFeedViewController {
    
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
extension OwnerFeedViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: OwnerFeedCell = tableView.dequeueReusableCell(withIdentifier: OwnerFeedCell.cellIdentifer , for: indexPath) as? OwnerFeedCell else { fatalError("The tableView could not dequeue OwnerFeedCell in OwnerFeedViewController.") }
        return cell
    }
}

// MARK: - UITableView Delegate
extension OwnerFeedViewController: UITableViewDelegate {
    
}
