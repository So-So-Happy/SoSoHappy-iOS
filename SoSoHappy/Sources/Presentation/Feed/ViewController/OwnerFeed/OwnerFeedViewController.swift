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
 1. refreshControl이 여기에서 꼭 필요가 있을까?
 2. profile update가 refresh될 때마다 한 3번 정도 호출이 되는 것 같은데 takeUntil, merge를 쓰면 된다고 하던데 수정해보기
 */
 
final class OwnerFeedViewController: UIViewController {
    // MARK: - Properties
    var disposeBag = DisposeBag()
    
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
        print("view did load")
        setup()
    }

    init(reactor: OwnerFeedViewReactor) {
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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

// MARK: - ReactorKit - bind func
extension OwnerFeedViewController: View {
    // MARK: bind - reactor에 새로운 값이 들어올 때만 트리거
    func bind(reactor: OwnerFeedViewReactor) {
        self.tableView.rx.setDelegate(self).disposed(by: self.disposeBag)
    
        self.rx.viewDidLoad
            .map { Reactor.Action.refresh } // 해당 유저의 공개 feed fetch
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        self.refreshControl.rx.controlEvent(.valueChanged)
            .map { Reactor.Action.refresh }
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
            .bind(to: tableView.rx.items(cellIdentifier: OwnerFeedCell.cellIdentifier, cellType: OwnerFeedCell.self)) { (row,  feed, cell) in
                print("cell 만드는 중")

                let cellReactor = FeedReactor(feed: feed)
                cell.reactor = cellReactor

                cell.imageSlideView.tapObservable
                    .subscribe(onNext: { [weak self] in
                        guard let self = self else { return }
                        cell.imageSlideView.slideShowView.presentFullScreenController(from: self)
                    })
                    .disposed(by: cell.disposeBag) // cell.disposeBag ?
            }
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.isRefreshing }
            .bind(to: self.refreshControl.rx.isRefreshing)
            .disposed(by: self.disposeBag)
        
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


