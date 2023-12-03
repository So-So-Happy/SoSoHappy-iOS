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

final class FeedViewController: UIViewController, UIScrollViewDelegate {
    // MARK: - Properties
    var disposeBag = DisposeBag()
    private weak var coordinator: FeedCoordinatorInterface?
    private var dataSource: RxTableViewSectionedReloadDataSource<UserFeedSection.Model>!

    
    // MARK: - UI Components
    private lazy var feedHeaderView = FeedHeaderView()
    private lazy var refreshControl = UIRefreshControl()
    private lazy var exceptionView = FeedExceptionView(
        title: "등록된 피드가 없습니다.\n 소소한 행복을 공유하고 함께 응원해주세요!",
        topOffset: 300
    )
    
    // MARK: 로딩 뷰 잘 넣어주기
    private lazy var activityIndicatorView = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 27, height: 27), type: .circleStrokeSpin, color: UIColor(named: "GrayTextColor"), padding: 0)
    
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
        tableView.addSubview(activityIndicatorView)
        
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        activityIndicatorView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(feedHeaderView.snp.bottom).offset(50)
        }
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
            .debounce(.milliseconds(300), scheduler: MainScheduler.instance) // Adjust the debounce time as needed
            .skip(1)
            .withLatestFrom(self.tableView.rx.contentOffset)
            .map { [weak self] in
                print("호출2")
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
        
        reactor.state.map(\.sections)
              .distinctUntilChanged()
              .map(Array.init(with:)) // <- extension으로 Array 초기화 시 차원을 하나 늘려주는 코드추가
              .bind(to: self.tableView.rx.items(dataSource: dataSource))
              .disposed(by: self.disposeBag)
        
        reactor.state
            .skip(1)
            .compactMap { $0.sortOption }
            .distinctUntilChanged()
            .bind(onNext: { [weak self] sortOption in
                guard let self = self else { return }
                print("137번째 줄")
                feedHeaderView.updateButtonState(sortOption)
            })
            .disposed(by: disposeBag)
        
    }
    
}

// MARK: - configureCell & ExceptionView 핸들링 메서드
extension FeedViewController {
    private func createDataSource() -> RxTableViewSectionedReloadDataSource<UserFeedSection.Model> {
        return .init { dataSource, tableView, indexPath, item  in
            let cell = tableView.dequeueReusableCell(withIdentifier: FeedCell.cellIdentifier, for: indexPath) as! FeedCell

            switch item {
            case .feed(let reactor):
                cell.reactor = reactor
            }
            
            return cell
        }
    }
    
    
    
    private func configureCell(_ cell: FeedCell, reactor: FeedReactor) {
        // MARK: FeedReactor에 feed 넣어주는 방법1
        
        // MARK: FeedReactor에 feed 넣어주는 방법2
        cell.reactor = reactor
        
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
    
}
