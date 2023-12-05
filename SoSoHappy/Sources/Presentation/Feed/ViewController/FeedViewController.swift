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

/*
 self.scrollView.scrollIndicatorInsets
 정렬 버튼 - throttle (연타방지 넣기)
 */

// 로딩 중 또는 paging 중
// 문제 - 로딩 중에 다른 tab으로 옮겼을 때 겹침 현상
// 전체에서 로딩 중에 오늘로 넘겼다고 했을 때

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
    
    // MARK: 리팩할 때 잘 제거해주기
//    private lazy var activityIndicatorView = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 27, height: 27), type: .circleStrokeSpin, color: UIColor(named: "GrayTextColor"), padding: 0).then {
//        $0.startAnimating()
//    }
    
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
        print("--------------- FeedViewController viewDidLoad ---------------")
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
//        tableView.addSubview(activityIndicatorView)
        view.addSubview(loadingView)
        view.addSubview(exceptionView)
        
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
//        activityIndicatorView.snp.makeConstraints { make in
//            make.centerX.equalToSuperview()
//            make.top.equalTo(feedHeaderView.snp.bottom).offset(50)
//        }
        
        loadingView.snp.makeConstraints { make in
            make.horizontalEdges.bottom.equalToSuperview()
            make.top.equalTo(feedHeaderView.snp.bottom)
        }

        exceptionView.snp.makeConstraints { make in
            make.horizontalEdges.bottom.equalToSuperview()
            make.top.equalTo(feedHeaderView.snp.bottom)
        }
        
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 85, right: 0)
        
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
                print("호출1")
                return Reactor.Action.fetchFeeds(.currentSort)
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        
        self.tableView.rx.didScroll
            .debounce(.milliseconds(270), scheduler: MainScheduler.instance) // Adjust the debounce time as needed
//            .throttle(.seconds(4), scheduler: MainScheduler.instance) //
            .skip(1)
            .withLatestFrom(self.tableView.rx.contentOffset)
            .map { [weak self] in
                print("didScroll")

                return Reactor.Action.pagination(
                    contentHeight: self?.tableView.contentSize.height ?? 0,
                    contentOffsetY: $0.y,
                    scrollViewHeight: UIScreen.main.bounds.height
                )
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        
        self.refreshControl.rx.controlEvent(.valueChanged)
            .map { Reactor.Action.refresh }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // TODO: throttle 적용
        feedHeaderView.sortTodayButton.rx.tap
            .map { Reactor.Action.fetchFeeds(.today) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        feedHeaderView.sortTotalButton.rx.tap
            .map { Reactor.Action.fetchFeeds(.total) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
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
                print("1 -- isPaging")
                tableView.tableFooterView = isPaging ? pagingIndicatorView : UIView(frame: .zero)
            }
            .disposed(by: disposeBag)
        
        reactor.state
            .skip(1)
            .compactMap { $0.sortOption }
            .distinctUntilChanged()
            .bind(onNext: { [weak self] sortOption in
                guard let self = self else { return }
                print("sort : 137번째 줄 : \(sortOption)")
                print("1 -- sort")
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
        
        
        reactor.state
            .compactMap { $0.isLoading }
            .distinctUntilChanged()
            .withLatestFrom(reactor.state.map { $0.sections.items.isEmpty }) { isLoading, itemsIsEmpty in
                return (isLoading, itemsIsEmpty)
            }
            .subscribe(onNext: { [weak self] (isLoading, itemsIsEmpty) in
                guard let self = self else { return }
                updateViewsVisibility(isLoading: isLoading, itemsIsEmpty: itemsIsEmpty)
            })
            .disposed(by: disposeBag)
        
        
//        reactor.state
//            .compactMap { $0.isLoading }
//            .distinctUntilChanged()
//            .bind { [weak self] isLoading in
//                guard let self = self else { return }
//                
//                if isLoading { // 로딩 중
//                    print("check3 - 로딩 중 ")
//                    exceptionView.isHidden = true
//                    loadingView.isHidden = false
//                } else { // 로딩 완료
//                    print("check3 - 로딩 완료 ")
//                    loadingView.isHidden = true
//                    if reactor.currentState.sections.items.isEmpty {
//                        print("check3 - 로딩 완료 - items 비어있다 ")
//                        exceptionView.isHidden = false
//                    }
//                }
//            }
//            .disposed(by: disposeBag)
        
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
    
    
    private func updateViewsVisibility(isLoading: Bool, itemsIsEmpty: Bool) {
        if isLoading {
            print("check3 - 로딩 중 ")
            exceptionView.isHidden = true
            loadingView.isHidden = false
        } else {
            print("check3 - 로딩 완료 ")
            loadingView.isHidden = true
            exceptionView.isHidden = !itemsIsEmpty
        }
    }
}
