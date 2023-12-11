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

// MARK: - 적정 시간 잘 설정 (throttle 사용하는 모드 곳)
// 1. throttle , debounce 공부 후 paging - throttle의 적정 시간 설정해줘야 함
// 2. 스크롤이 엄청 빠를 경우, 받아오고 있는 동안 또 바닥에 닿았을 경우 등 고려해야 함
// 3. isRefreshing, isLoading 리팩토링하기
// 4. 새로운 action이 들어오면 이전 request 취소 (해결)

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
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        dataSource = self.createDataSource()
        
        self.rx.viewWillAppear
            .map {
//                print("viewWillAppear")
                return Reactor.Action.fetchFeeds(.currentSort)
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        

        // MARK: throttle or debounce
        // 문제점 - 바닥을 닿고 기다리는 동안 올라갔다가 바로 내려오면 또 요청이 된다. 그러면 이제 뒤죽박죽 다 난리남
        // 보통 불러오는데 넉넉히 2초면 불러옴 그러니깐 2초동안은 이벤트를 방출하지 못하도록 하면 되겠다
        tableView.rx.reachedBottom(offset: -20)
            .skip(1)
            .throttle(.milliseconds(1240), latest: false, scheduler: MainScheduler.instance) // 1.7초
            .debug()
            .map { Reactor.Action.pagination }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        self.refreshControl.rx.controlEvent(.valueChanged)
            .map { Reactor.Action.refresh }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        feedHeaderView.sortTodayButton.rx.tap
//            .throttle(.milliseconds(1170), latest: false, scheduler: MainScheduler.instance)
            .map { Reactor.Action.fetchFeeds(.today) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    
        feedHeaderView.sortTotalButton.rx.tap
//            .throttle(.milliseconds(1170), latest: false, scheduler: MainScheduler.instance)
            .map { Reactor.Action.fetchFeeds(.total) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
     
        tableView.rx.modelSelected(UserFeedSection.Item.self)
            .subscribe(onNext: { [weak self] selectedItem in
                switch selectedItem {
                case let .feed(feedReactor):
                    print("modelSelected: \(feedReactor)")
                    self?.coordinator?.showdDetails(feedReactor: feedReactor)
                }
            })
            .disposed(by: disposeBag)
//
        reactor.state
            .map(\.sections)
            .distinctUntilChanged()
            .map(Array.init(with:)) // <- extension으로 Array 초기화 시 차원을 하나 늘려주는 코드추가
            .bind(to: self.tableView.rx.items(dataSource: dataSource))
            .disposed(by: self.disposeBag)
        
        reactor.state
            .compactMap { $0.isPaging }
            .distinctUntilChanged()
            .subscribe { [weak self] isPaging in
                guard let self = self else { return }
//                print("here2 - isPaging: \(isPaging)")
                tableView.tableFooterView = isPaging ? pagingIndicatorView : UIView(frame: .zero)
            }
            .disposed(by: disposeBag)
        
        reactor.state
            .skip(1)
            .compactMap { $0.sortOption }
            .distinctUntilChanged()
            .bind(onNext: { [weak self] sortOption in
                guard let self = self else { return }
//                print("reactor.state.sortOption : \(sortOption)")
                feedHeaderView.updateButtonState(sortOption)
            })
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.isRefreshing }
            .distinctUntilChanged()
            .bind(to: self.refreshControl.rx.isRefreshing)
            .disposed(by: disposeBag)
        
        // isLoading - false , sections.isEmpty 이면 등록된 뷰가 없습니다.
        // isLoading - true이면 해당 뷰 제거
        

        // MARK: 이 부분 중복되는 거 리팩토링해주기
        reactor.state
            .compactMap { $0.isLoading }
            .distinctUntilChanged()
            .withLatestFrom(reactor.state.map { $0.sections.items.isEmpty }) { isLoading, itemsIsEmpty in
                return (isLoading, itemsIsEmpty)
            }
            .subscribe(onNext: { [weak self] (isLoading, itemsIsEmpty) in
                guard let self = self else { return }
                updateViewsVisibility(isLoading: isLoading, itemsIsEmpty: itemsIsEmpty, fromRefresh: false)
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
                updateViewsVisibility(isLoading: isRefreshing, itemsIsEmpty: itemsIsEmpty, fromRefresh: true)
            })
            .disposed(by: disposeBag)
        
    }
    
}

// MARK: - configureCell & ExceptionView 핸들링 메서드
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
        
        // - 여기에 코드를 작성한 이유
        // cell의 이미지를 tap했을 때 이미지VC을 'self'(FeedViewController)에서 present해주기 때문
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
                self.coordinator?.showOwner(ownerNickName: nickName)
            })
            .disposed(by: cell.disposeBag)
    }
    
    
    private func updateViewsVisibility(isLoading: Bool, itemsIsEmpty: Bool, fromRefresh: Bool) {
        if isLoading {
//            print("check3 - 로딩 중 ")
            exceptionView.isHidden = true
            if !fromRefresh {
                loadingView.isHidden = false
            }
        } else {
//            print("check3 - 로딩 완료 ")
            if !fromRefresh {
                loadingView.isHidden = true
            }
            exceptionView.isHidden = !itemsIsEmpty
        }
    }
}
