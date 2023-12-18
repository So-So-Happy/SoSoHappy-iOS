//
//  DMListViewController.swift
//  SoSoHappy
//
//  Created by Sue on 2023/08/25.
//

import UIKit
import SnapKit

class DMListViewController: UIViewController {
    // MARK: - Properties
    // MARK: - UI Component
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(DMListCell.self, forCellReuseIdentifier: DMListCell.cellIdentifer)
//        tableView.refreshControl = self.refreshControl
        tableView.backgroundColor = UIColor(named: "BGgrayColor")
//        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100

        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        addSubViews()
        setConstraints()
    }
    
}

//MARK: - Add Subviews & Constraints
extension DMListViewController {
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
extension DMListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: DMListCell = tableView.dequeueReusableCell(withIdentifier: DMListCell.cellIdentifer , for: indexPath) as? DMListCell else { fatalError("The tableView could not dequeue DMListCell in DMListViewController.") }
        return cell
    }
}

// MARK: - UITableView Delegate
extension DMListViewController: UITableViewDelegate {
    
}
