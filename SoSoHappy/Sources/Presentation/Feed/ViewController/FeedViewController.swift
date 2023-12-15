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

// TODO: 추가할 사항 throttle 적정 시간 설정
/*
 1. cell에 사진 잘 가져와진 후 throttle 사용하는 곳에 적정 시간 잘 설정해주기
 2. 스크롤이 엄청 빠를 경우, 받아오고 있는 동안 또 바닥에 닿았을 경우 등 고려해야 함
 
 3. 추후에 viewDidLoad에서만 fetch를 하고 viewWillAppear 때 모든 동일 데이터를 동기화하는 방법 적용해보기
 */

final class FeedViewController: UIViewController, UIScrollViewDelegate {
    // MARK: - Properties
    var disposeBag = DisposeBag()
    private weak var coordinator: FeedCoordinatorInterface?
    private var dataSource: RxTableViewSectionedReloadDataSource<UserFeedSection.Model>!

    
    // MARK: - UI Components
    private lazy var feedHeaderView = FeedHeaderView().then {
        $0.backgroundColor = .none
    }
    
    private lazy var refreshControl = UIRefreshControl()
    
    private lazy var tableView = UITableView().then {
        $0.register(FeedCell.self, forCellReuseIdentifier: FeedCell.cellIdentifier)
        $0.refreshControl = self.refreshControl
        $0.tableHeaderView = feedHeaderView
        $0.tableHeaderView?.frame.size.height = 150   // 고정된 값으로 줘도 됨. 94
        $0.backgroundColor = UIColor(named: "BGgrayColor")
        $0.separatorStyle = .none
        $0.rowHeight = UITableView.automaticDimension
        $0.estimatedRowHeight = 30
    }
    
    private lazy var pagingIndicatorView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 50)
    ).then {
        let spinner = UIActivityIndicatorView()
        spinner.center = $0.center
        $0.addSubview(spinner)
        spinner.startAnimating()
    }
    

    private lazy var loadingView = LoadingView().then {
        $0.isHidden = true
    }
    
    private lazy var exceptionView = FeedExceptionView(
        title: "등록된 피드가 없습니다.\n\n 소소한 행복을 공유하고 함께 응원해주세요!",
        inset: 40
    ).then {
        $0.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setLayout()
        print("🐱 FeedViewController viewDidLoad")
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
        view.addSubview(exceptionView)
        
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        loadingView.snp.makeConstraints { make in
            make.horizontalEdges.bottom.equalToSuperview()
            make.top.equalTo(feedHeaderView.snp.bottom)
        }

        exceptionView.snp.makeConstraints { make in
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
        
        // MARK: throttle or debounce
        // 문제점 - 바닥을 닿고 기다리는 동안 올라갔다가 바로 내려오면 또 요청이 된다. 그러면 이제 뒤죽박죽 다 난리남
        // 보통 불러오는데 넉넉히 2초면 불러옴 그러니깐 2초동안은 이벤트를 방출하지 못하도록 하면 되겠다
        
        // paging
        tableView.rx.reachedBottom(offset: -20)
            .skip(1)
            .throttle(.milliseconds(1240), latest: false, scheduler: MainScheduler.instance) // 1.7초
            .debug()
            .map { Reactor.Action.pagination }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // 새로고침
        self.refreshControl.rx.controlEvent(.valueChanged)
            .map { Reactor.Action.refresh }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // 오늘
        feedHeaderView.sortTodayButton.rx.tap
//            .throttle(.milliseconds(1170), latest: false, scheduler: MainScheduler.instance)
            .map { Reactor.Action.fetchFeeds(.today) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    
        // 전체
        feedHeaderView.sortTotalButton.rx.tap
//            .throttle(.milliseconds(1170), latest: false, scheduler: MainScheduler.instance)
            .map { Reactor.Action.fetchFeeds(.total) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // cell 선택
        tableView.rx.modelSelected(UserFeedSection.Item.self)
            .subscribe(onNext: { [weak self] selectedItem in
                guard let self = self else { return }
                switch selectedItem {
                case let .feed(feedReactor):
                    print("modelSelected: \(feedReactor)")
                    coordinator?.showdDetails(feedReactor: feedReactor)
                }
            })
            .disposed(by: disposeBag)
        
        reactor.state
            .map(\.sections)
            .distinctUntilChanged()
            .map(Array.init(with:))
            .bind(to: self.tableView.rx.items(dataSource: dataSource))
            .disposed(by: self.disposeBag)
        
        // paging 중 표시
        reactor.state
            .compactMap { $0.isPaging }
            .distinctUntilChanged()
            .subscribe { [weak self] isPaging in
                guard let self = self else { return }
//                print("here2 - isPaging: \(isPaging)")
                tableView.tableFooterView = isPaging ? pagingIndicatorView : UIView(frame: .zero)
            }
            .disposed(by: disposeBag)
        
        // 새로고침 중 표시
        reactor.state
            .compactMap { $0.isRefreshing }
            .distinctUntilChanged()
            .bind(to: self.refreshControl.rx.isRefreshing)
            .disposed(by: disposeBag)
        
        
        // 정렬에 따른 버튼 설정
        reactor.state
            .compactMap { $0.sortOption }
            .distinctUntilChanged()
            .bind(onNext: { [weak self] sortOption in
                guard let self = self else { return }
                print("reactor.state.sortOption : \(sortOption)")
                feedHeaderView.updateButtonState(sortOption)
            })
            .disposed(by: disposeBag)
        
        // isLoading - false , sections.isEmpty 이면 등록된 뷰가 없습니다.
        // isLoading - true이면 해당 뷰 제거
    
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
                if let userFeed = reactor.currentState.userFeed {
            
                }
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
        
        // Subscribe to profileImageTapSubject here
        cell.profileImageTapSubject
            .subscribe(onNext: { [weak self] nickName in
                guard let self = self else { return }
                coordinator?.showOwner(ownerNickName: nickName)
            })
            .disposed(by: cell.disposeBag)
    }
    
    
    private func updateViewsVisibility(isLoading: Bool, itemsIsEmpty: Bool, dataRenewal: DataRenewal) {
        if isLoading { // 로딩 중
//            print("check3 - 로딩 중 ")
            exceptionView.isHidden = true
            if dataRenewal == .load {
                loadingView.isHidden = false
            }
        } else { // 로딩 끝
//            print("check3 - 로딩 완료 ")
            if dataRenewal == .load {
                loadingView.isHidden = true
            }
            exceptionView.isHidden = !itemsIsEmpty
        }
    }
}
