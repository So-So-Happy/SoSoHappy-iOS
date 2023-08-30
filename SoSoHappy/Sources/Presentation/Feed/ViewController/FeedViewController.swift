//
//  FeedViewController.swift
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

final class FeedViewController: UIViewController {
    // MARK: - Properties
    // MARK: - UI Components
    private lazy var refreshControl = UIRefreshControl().then {
        $0.addTarget(self, action: #selector(handleRefreshControl), for: .valueChanged)
    }
    private lazy var feedHeaderView = FeedHeaderView()
    var imageSlideView = ImageSlideView()
    
    private lazy var tableView = UITableView().then {
        $0.delegate = self
        $0.dataSource = self
        $0.register(FeedCell.self, forCellReuseIdentifier: FeedCell.cellIdentifer)
        
        $0.refreshControl = refreshControl
        $0.tableHeaderView = feedHeaderView
        $0.tableHeaderView?.frame.size.height = 94   // 고정된 값으로 줘도 됨.
        $0.backgroundColor = UIColor(named: "backgroundColor")
        $0.separatorStyle = .none
        $0.rowHeight = UITableView.automaticDimension
        $0.estimatedRowHeight = 30
    }
    
    // MARK: 이미지 크기에 대해서 고민해볼 것 - DM 보류
    private lazy var dmBarButton = UIBarButtonItem(
        image: UIImage(named: "dm"),
        style: .plain,
        target: self,
        action: nil).then {
            
        $0.tintColor = .red
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
}

//MARK: - Set Navigation & Add Subviews & Constraints
extension FeedViewController {
    private func setup() {
        configureNavigation()
        setLayout()
    }
    
    func configureNavigation() {
        self.navigationItem.title = "소피들의 소소해피"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.rightBarButtonItem = dmBarButton
    }
    
    private func setLayout() {
        view.addSubview(tableView)
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
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTap(sender:)))
        cell.imageSlideView.slideShowView.addGestureRecognizer(tapGesture)
        return cell
    }
}

// MARK: - UITableView Delegate
extension FeedViewController: UITableViewDelegate {
    
}


// MARK: - Action
extension FeedViewController {
    @objc func didTap(sender: UITapGestureRecognizer? = nil) {
        print("FeedViewController images - didTap() called")
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




//#if DEBUG
//import SwiftUI
//struct FeedViewControllerRepresentable: UIViewControllerRepresentable {
//    
//    func updateUIViewController(_ uiView: UIViewController,context: Context) {
//        // leave this empty
//    }
//    @available(iOS 13.0.0, *)
//    func makeUIViewController(context: Context) -> UIViewController{
//        FeedViewController()
//    }
//}
//@available(iOS 13.0, *)
//struct FeedViewControllerRepresentable_PreviewProvider: PreviewProvider {
//    static var previews: some View {
//        Group {
//            FeedViewControllerRepresentable()
//                .ignoresSafeArea()
//                .previewDisplayName(/*@START_MENU_TOKEN@*/"Preview"/*@END_MENU_TOKEN@*/)
//                .previewDevice(PreviewDevice(rawValue: "iPhone 14 Pro"))
//        }
//        
//    }
//} #endif

