//
//  FeedViewController.swift
//  SoSoHappy
//
//  Created by Sue on 12/2/23.
//

import UIKit
import SnapKit
import Then
import ReactorKit
import RxSwift
import RxCocoa
import NVActivityIndicatorView
import RxDataSources
import RxSwiftExt
import RxGesture

final class FeedViewController: UIViewController, UIScrollViewDelegate {
    // MARK: - Properties
    var disposeBag = DisposeBag()
    private weak var coordinator: FeedCoordinatorInterface?
    private var dataSource: RxTableViewSectionedReloadDataSource<UserFeedSection.Model>!

    // MARK: - UI Components
    private lazy var refreshControl = UIRefreshControl()
    private lazy var feedHeaderView = FeedHeaderView().then {
        $0.backgroundColor = .none
    }
    
    private lazy var tableView = UITableView().then {
        $0.register(FeedCell.self, forCellReuseIdentifier: FeedCell.cellIdentifier)
        $0.refreshControl = self.refreshControl
        $0.tableHeaderView = feedHeaderView
        $0.tableHeaderView?.frame.size.height = 120
        $0.backgroundColor = UIColor(named: "BGgrayColor")
        $0.separatorStyle = .none
        $0.rowHeight = UITableView.automaticDimension
        $0.estimatedRowHeight = 30
        $0.showsVerticalScrollIndicator = false
    }
    
    private lazy var loadingView = LoadingView().then {
        $0.isHidden = true
    }
    
    private lazy var noFeedExceptionView = ExceptionView(
        title: "등록된 피드가 없습니다.\n소소한 행복을 공유하고 함께 응원해주세요!",
        inset: 40
    ).then {
        $0.isHidden = true
    }
    
    private lazy var networkNotConnectedView = NetworkNotConnectedView(inset: 100).then {
        $0.isHidden = true
    }
    
    private lazy var pagingIndicatorView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 50)
    ).then {
        let spinner = UIActivityIndicatorView()
        spinner.center = $0.center
        $0.addSubview(spinner)
        spinner.startAnimating()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setLayout()
    }

    init(reactor: FeedViewReactor, coordinator: FeedCoordinatorInterface) {
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
        self.coordinator = coordinator
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - Set Navigation & Add Subviews & Constraints
extension FeedViewController {
    private func setLayout() {
        view.addSubview(tableView)
        view.addSubview(loadingView)
        view.addSubview(noFeedExceptionView)
        view.addSubview(networkNotConnectedView)
        
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        loadingView.snp.makeConstraints { make in
            make.horizontalEdges.bottom.equalToSuperview()
            make.top.equalTo(feedHeaderView.snp.bottom)
        }

        noFeedExceptionView.snp.makeConstraints { make in
            make.horizontalEdges.bottom.equalToSuperview()
            make.top.equalTo(feedHeaderView.snp.bottom)
        }
        
        networkNotConnectedView.snp.makeConstraints { make in
            make.horizontalEdges.bottom.equalToSuperview()
            make.top.equalTo(feedHeaderView.snp.bottom)
        }
        
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 64, right: 0)
    }
}

// MARK: - ReactorKit - bind func
extension FeedViewController: View {
    func bind(reactor: FeedViewReactor) {
        dataSource = self.createDataSource()

        self.rx.viewWillAppear
            .map { Reactor.Action.fetchFeeds(.currentSort) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        tableView.rx.reachedBottom(offset: -20)
            .skip(1)
            .throttle(.milliseconds(130), latest: false, scheduler: MainScheduler.instance)
            .map { Reactor.Action.pagination }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        self.refreshControl.rx.controlEvent(.valueChanged)
            .map { Reactor.Action.refresh }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        feedHeaderView.sortTodayButton.rx.tap
            .throttle(.milliseconds(500), latest: false, scheduler: MainScheduler.instance)
            .map { Reactor.Action.fetchFeeds(.today) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    
        feedHeaderView.sortTotalButton.rx.tap
            .throttle(.milliseconds(500), latest: false, scheduler: MainScheduler.instance)
            .map { Reactor.Action.fetchFeeds(.total) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        tableView.rx.modelSelected(UserFeedSection.Item.self)
            .subscribe(onNext: { [weak self] selectedItem in
                guard let self = self else { return }
                switch selectedItem {
                case let .feed(feedReactor):
                    coordinator?.showdDetails(feedReactor: feedReactor)
                }
            })
            .disposed(by: disposeBag)
    
        networkNotConnectedView.retryButton.rx.tap
            .map { Reactor.Action.fetchFeeds(.currentSort) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    
        reactor.state
            .map(\.sections)
            .map(Array.init(with:))
            .bind(to: self.tableView.rx.items(dataSource: dataSource))
            .disposed(by: self.disposeBag)
        
        reactor.state
            .compactMap { $0.isPaging }
            .distinctUntilChanged()
            .subscribe { [weak self] isPaging in
                guard let self = self else { return }
                tableView.tableFooterView = isPaging ? pagingIndicatorView : UIView(frame: .zero)
            }
            .disposed(by: disposeBag)
        
        reactor.state
            .compactMap { $0.isRefreshing }
            .bind(to: self.refreshControl.rx.isRefreshing)
            .disposed(by: disposeBag)
        
        reactor.state
            .compactMap { $0.sortOption }
            .distinctUntilChanged()
            .bind(onNext: { [weak self] sortOption in
                guard let self = self else { return }
                feedHeaderView.updateButtonState(sortOption)
            })
            .disposed(by: disposeBag)
    
        reactor.state
            .compactMap { $0.isLoading }
            .distinctUntilChanged()
            .withLatestFrom(reactor.state.map { $0.sections.items.isEmpty }) { isLoading, itemsIsEmpty in
                return (isLoading, itemsIsEmpty)
            }
            .subscribe(onNext: { [weak self] (isLoading, itemsIsEmpty) in
                guard let self = self else { return }
                updateViewsVisibility(isLoading: isLoading, itemsIsEmpty: itemsIsEmpty, dataRenewal: .load)
            })
            .disposed(by: disposeBag)

        reactor.state
            .compactMap { $0.isRefreshing }
            .distinctUntilChanged()
            .withLatestFrom(reactor.state.map { $0.sections.items.isEmpty }) { isRefreshing, itemsIsEmpty in
                return (isRefreshing, itemsIsEmpty)
            }
            .subscribe(onNext: { [weak self] (isRefreshing, itemsIsEmpty) in
                guard let self = self else { return }
                updateViewsVisibility(isLoading: isRefreshing, itemsIsEmpty: itemsIsEmpty, dataRenewal: .refresh)
            })
            .disposed(by: disposeBag)
        
        reactor.state
            .compactMap { $0.showNetworkErrorView }
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] showNetworkErrorView in
                guard let self = self else { return }
                if showNetworkErrorView {
                    loadingView.isHidden = true
                    noFeedExceptionView.isHidden = true
                    networkNotConnectedView.isHidden = false
                }
            })
            .disposed(by: disposeBag)
        
        reactor.state
            .compactMap { $0.showServerErrorAlert }
            .distinctUntilChanged()
            .bind(onNext: { [weak self] showServerErrorAlert in
                guard let self = self else { return }
                if showServerErrorAlert {
                    let asyncAfter: Double = reactor.currentAction == .refresh ? 0.7 : 0
                    DispatchQueue.main.asyncAfter(deadline: .now() + asyncAfter) {
                        CustomAlert.presentErrorAlertWithoutDescription()
                    }
                }
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - createDataSource & ExceptionView 핸들링 메서드
extension FeedViewController {
    private func createDataSource() -> RxTableViewSectionedReloadDataSource<UserFeedSection.Model> {
        return .init { [weak self] dataSource, tableView, indexPath, item  in
            let cell = tableView.dequeueReusableCell(withIdentifier: FeedCell.cellIdentifier, for: indexPath) as! FeedCell

            switch item {
            case .feed(let reactor):
                cell.reactor = reactor
                self?.configureCell(cell)
            }
            return cell
        }
    }
    
    private func configureCell(_ cell: FeedCell) {
        cell.imageSlideView.tapObservable
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                cell.imageSlideView.slideShowView.presentFullScreenController(from: self)
            })
            .disposed(by: cell.disposeBag)
        
        cell.profileImageTapSubject
            .subscribe(onNext: { [weak self] nickName in
                guard let self = self else { return }
                coordinator?.showOwner(ownerNickName: nickName)
            })
            .disposed(by: cell.disposeBag)
    }
    
    private func updateViewsVisibility(isLoading: Bool, itemsIsEmpty: Bool, dataRenewal: DataRenewal) {
        if isLoading {
            networkNotConnectedView.isHidden = true
            noFeedExceptionView.isHidden = true
            if dataRenewal == .load {
                loadingView.isHidden = false
            }
        } else {
            if dataRenewal == .load {
                loadingView.isHidden = true
            }
            noFeedExceptionView.isHidden = !itemsIsEmpty
        }
    }
}

extension FeedViewController: FeedCoordinatorDelegate {
    func showProcessClearedToastMessage() {
        showToast("처리되었습니다", withDuration: 1.8, delay: 1.8, isToastPlacedOnTop: false)
    }
}
