//
//  OwnerFeedViewController.swift
//  SoSoHappy
//
//  Created by Sue on 2023/08/25.
//

import UIKit
import SnapKit
import Then
/*
 1. heartButton 토글 적용
 */
 
final class OwnerFeedViewController: UIViewController {
    // MARK: - Properties
    // MARK: - UI Components
    private lazy var refreshControl = UIRefreshControl().then {
        $0.addTarget(self, action: #selector(handleRefreshControl), for: .valueChanged)
    }
    var imageSlideView = ImageSlideView()
    
    private lazy var tableView = UITableView(frame: .zero, style: .grouped).then {
        $0.delegate = self
        $0.dataSource = self
        $0.register(OwnerFeedCell.self, forCellReuseIdentifier: FeedCell.cellIdentifer)
        $0.separatorStyle = .none
        $0.refreshControl = self.refreshControl
        $0.sectionHeaderHeight = UITableView.automaticDimension
        $0.backgroundColor = UIColor(named: "backgroundColor")
        $0.rowHeight = UITableView.automaticDimension
        $0.estimatedRowHeight = 300
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
}

//MARK: - Set Navigation & Add Subviews & Constraints
extension OwnerFeedViewController {
    private func setup() {
        setLayout()
    }

    private func setLayout() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

// MARK: - UITableView DataSource
extension OwnerFeedViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: OwnerFeedCell = tableView.dequeueReusableCell(withIdentifier: OwnerFeedCell.cellIdentifer , for: indexPath) as? OwnerFeedCell else { fatalError("The tableView could not dequeue OwnerFeedCell in OwnerFeedViewController.") }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTap(sender:)))
        cell.imageSlideView.slideShowView.addGestureRecognizer(tapGesture)
        return cell
    }
}

// MARK: - UITableView Delegate
extension OwnerFeedViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return 200
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return OwnerFeedHeaderView()
    }
}

// MARK: - Action
extension OwnerFeedViewController {
    @objc func didTap(sender: UITapGestureRecognizer? = nil) {
        print("OwnerFeedViewController images - didTap() called")
        imageSlideView.slideShowView.presentFullScreenController(from: self)
    }
    
    // 실제로 서버로부터 다시 데이터를 받아오는 작업을 해보면서 수정하면 될 것 같음
    @objc func handleRefreshControl() {
        print("refreshTable")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { // .main ? .global?
            self.tableView.reloadData()
            self.tableView.refreshControl?.endRefreshing() // Refresh 작업이 끝났음을 control에 알림 (이 타이밍도 다시 한번 확인 필요할 듯)
        }
    }
}

