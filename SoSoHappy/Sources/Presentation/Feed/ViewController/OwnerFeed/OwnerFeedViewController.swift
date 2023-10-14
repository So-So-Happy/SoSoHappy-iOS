//
//  OwnerFeedViewController.swift
//  SoSoHappy
//
//  Created by Sue on 2023/08/25.
//

import UIKit
import SnapKit
import Then
import ReactorKit
import RxSwift
import RxCocoa

/*
 1. refreshControl이 여기에서 꼭 필요가 있을까? (없을 것 같긴 함)
 2. profile update가 refresh될 때마다 한 3번 정도 호출이 되는 것 같은데 takeUntil, merge를 쓰면 된다고 하던데 수정해보기
 3. 밑에 cell 선택 -> detailVC1 -> Owner -> detailVC1 하면 "소피들의 소소해피"가 나타남 해결 필요
 */

 
final class OwnerFeedViewController: UIViewController {
    // MARK: - Properties
    var disposeBag = DisposeBag()
    private weak var coordinator: OwnerFeedCoordinatorInterface?
    
    // MARK: - UI Components
    private lazy var refreshControl = UIRefreshControl()
    private lazy var ownerFeedHeaderView = OwnerFeedHeaderView()
    
    private lazy var tableView = UITableView(frame: .zero, style: .grouped).then {
        $0.register(OwnerFeedCell.self, forCellReuseIdentifier: OwnerFeedCell.cellIdentifier)
        $0.separatorStyle = .none
        $0.refreshControl = self.refreshControl
        $0.sectionHeaderHeight = UITableView.automaticDimension
        $0.backgroundColor = UIColor(named: "backgroundColor")
        $0.rowHeight = UITableView.automaticDimension
        $0.estimatedRowHeight = 300
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("OwnerFeedViewController viewDidLoad ---------------")
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("OwnerFeedViewController viewWillAppear ---------------")
    }

    init(reactor: OwnerFeedViewReactor, coordinator: OwnerFeedCoordinatorInterface) {
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
        self.coordinator = coordinator
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - Set Navigation & Add Subviews & Constraints
extension OwnerFeedViewController {
    private func setup() {
        self.navigationItem.title = ""
        setLayout()
    }

    private func setLayout() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

// MARK: - ReactorKit - bind func
extension OwnerFeedViewController: View {
    // MARK: bind - reactor에 새로운 값이 들어올 때만 트리거
    func bind(reactor: OwnerFeedViewReactor) {
        self.tableView.rx.setDelegate(self).disposed(by: self.disposeBag)
        self.rx.viewWillAppear
            .map { Reactor.Action.fetchFeeds } // 해당 유저의 공개 feed fetch
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        self.refreshControl.rx.controlEvent(.valueChanged)
            .map { Reactor.Action.refresh }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        tableView.rx.itemSelected
            .map { Reactor.Action.selectedCell(index: $0.row) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // 이게 refresh될 때마다 한 3번 정도 호출이 되는 것 같은데 takeUntil, merge를 쓰면 된다고 하던데 수정해보기
        reactor.state
            .skip(1)
            .compactMap { $0.profile }
            .subscribe(onNext: { [weak self] profile in
                self?.ownerFeedHeaderView.update(with: profile)
            })
            .disposed(by: disposeBag)
        
        reactor.state
            .skip(1)
            .map { $0.feeds }
            .bind(to: tableView.rx.items(cellIdentifier: OwnerFeedCell.cellIdentifier, cellType: OwnerFeedCell.self)) { [weak self] (row,  feed, cell) in
                guard let self = self else { return }
                print("cell 만드는 중")
                configureCell(cell, with: feed)
            }
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.isRefreshing }
            .bind(to: self.refreshControl.rx.isRefreshing)
            .disposed(by: self.disposeBag)
        
        reactor.state
            .compactMap { $0.selectedFeed }
            .subscribe(onNext: { [weak self] feed in
                guard let self = self else { return }
                print("여기까지 진행완료")
//                print("feed: \(feed), type: \(type(of: feed))")
                self.coordinator?.showDetails(feed: feed)
            })
            .disposed(by: disposeBag)
    }
    
    private func configureCell(_ cell: OwnerFeedCell, with feed: FeedTemp) {
        let cellReactor = FeedReactor(feed: feed)
        cell.reactor = cellReactor
        cell.imageSlideView.tapObservable
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                cell.imageSlideView.slideShowView.presentFullScreenController(from: self)
            })
            .disposed(by: cell.disposeBag) // cell.disposeBag ?
    }
}

// MARK: - UITableView Delegate (Header 설정)
extension OwnerFeedViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return 300
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return ownerFeedHeaderView
    }
}


