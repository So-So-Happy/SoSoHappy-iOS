//
//  FeedViewController.swift
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
 리팩토링
 1. 버튼을 여러번 클릭했을 때 API 중복 호출을 막아주는 조치 (하트, 오늘, 전체 버튼) - throttle, debouce
 3. AlertReactor 프로젝트처럼 Reactor의 feeds를 [FeedCellReactor]로 해줘서 따로 Reactor 인스턴스를 만들지 않고
 cell.reactor = reactor 바로 주입 가능 (어떤 방법이 더 적합할지 고민해보기)
 */

/*
 1. refresh 할 때 Layout 에러 해결해주기
 2. '등록된 뷰가 없습니다'를 좀 더 자연스럽게 보여줄 수 있으면 좋을 것 같음
 */

final class FeedViewController: UIViewController {
    // MARK: - Properties
    var disposeBag = DisposeBag()
    private weak var coordinator: FeedCoordinatorInterface?
    
    // MARK: - UI Components
    private lazy var feedHeaderView = FeedHeaderView()
    private lazy var refreshControl = UIRefreshControl()
    private lazy var exceptionView = FeedExceptionView(
        title: "등록된 피드가 없습니다.\n 소소한 행복을 공유하고 함께 응원해주세요!",
        topOffset: 300
    )
    
    
    private lazy var tableView = UITableView().then {
        $0.register(FeedCell.self, forCellReuseIdentifier: FeedCell.cellIdentifier)
        $0.refreshControl = self.refreshControl
        $0.tableHeaderView = feedHeaderView
        $0.tableHeaderView?.frame.size.height = 150   // 고정된 값으로 줘도 됨. 94
        $0.backgroundColor = UIColor(named: "backgroundColor")
        $0.separatorStyle = .none
        $0.rowHeight = UITableView.automaticDimension
        $0.estimatedRowHeight = 30
    }
   
    override func viewDidLoad() {
        super.viewDidLoad()
        print("--------------- FeedViewController viewDidLoad ---------------")
        setLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("--------------- FeedViewController viewWillAppear ---------------")
        let contentOffset = self.tableView.contentOffset
        handleTableViewContentOffset(contentOffset)
    }

    // MARK: - 스크롤된 정도에 따라서 navigation title을 줬더니 다음 화면으로 넘어갈 때 Back 대신 title이 뜨길래
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("--------------- FeedViewController viewWillDisappear ---------------")
        self.navigationItem.title = ""
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
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

// MARK: - ReactorKit - bind func
extension FeedViewController: View {
    // MARK: bind
    func bind(reactor: FeedViewReactor) {
        // MARK: Action (View -> Reactor) 인풋
        self.rx.viewWillAppear
            .map { Reactor.Action.fetchFeeds(.currentSort) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        self.refreshControl.rx.controlEvent(.valueChanged)
            .map { Reactor.Action.refresh }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // sortTodayButton, feedHeaderView에 연타방지 연산 필요
        // debouce :
        // throttle :
        feedHeaderView.sortTodayButton.rx.tap
//            .debounce(.milliseconds(600), scheduler: MainScheduler.instance)
            .map {
                print("오늘 누름")
                return Reactor.Action.fetchFeeds(.today)
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        feedHeaderView.sortTotalButton.rx.tap
            .map {
                print("전체 누름")
                return Reactor.Action.fetchFeeds(.total)
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // asDriver  - 항상 main 스레드에서 관찰하고 에러가 발생하지 않는 것을 보장하여 시퀀스 작업을 간단하게 함
        // subscribe - 구독 관리를 더 세밀하게 제어해야 하는 경우
        tableView.rx.itemSelected
            .map { Reactor.Action.selectedCell(index: $0.row) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        tableView.rx.contentOffset
            .subscribe(onNext: { [weak self] contentOffset in
                guard let self = self else { return }
                handleTableViewContentOffset(contentOffset)
            })
            .disposed(by: disposeBag)

        // MARK: State (Reactor -> State) 아웃풋
        reactor.state
            .skip(1)
            .map {
                print("reactor.state - feeds : \($0.userFeeds)")
                return $0.userFeeds
            }
            .bind(to: tableView.rx.items(cellIdentifier: FeedCell.cellIdentifier, cellType: FeedCell.self)) { [weak self] (row,  userFeed, cell) in
                print("tableView cell 세팅중!! - userFeed : \(userFeed)")
                guard let self = self else { return }
                configureCell(cell, with: userFeed)
            }
            .disposed(by: disposeBag)
        
        
        reactor.state
            .skip(1)
            .map {
                print("Feeds updated 되기 전 map : \($0.userFeeds)")
                return $0.userFeeds
            }
            .distinctUntilChanged()
            .bind(onNext: { [weak self] userFeeds in
                guard let self = self else { return }
                print("@@ @@ @@ Feeds updated: \(userFeeds)")
                
                if userFeeds.isEmpty {
                    print("없다")
                    addEmptyView()
                } else {
                    print("있다")
                    removeEmptyView()
                }
                
//                self.noFeedLabel.isHidden = !feeds.isEmpty
            })
            .disposed(by: disposeBag)
        
        reactor.state
            .skip(1)
            .compactMap {
                print("reactor.state - sortOption : \($0.sortOption)")
                return $0.sortOption
            }
            .bind(onNext: { [weak self] sortOption in
                guard let self = self else { return }
                print("sortOption!!")
                feedHeaderView.updateButtonState(sortOption)
            })
            .disposed(by: disposeBag)
        
        reactor.state
            .skip(1)
            .map {
                print("reactor.state - isRefreshing : \($0.isRefreshing)")
                return $0.isRefreshing
                
            }
            .distinctUntilChanged()
            .debug()
            .bind(to: self.refreshControl.rx.isRefreshing)
            .disposed(by: disposeBag)
        
        reactor.state
            .compactMap { $0.selectedFeed }
            .subscribe(onNext: { [weak self] userFeed in
                guard let self = self else { return }
                print("selectedFeed!! : \(userFeed) ")
//                print("feed: \(feed), type: \(type(of: feed))")
                self.coordinator?.showdDetails(userFeed: userFeed)
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - configureCell & ExceptionView 핸들링 메서드
extension FeedViewController {
    private func configureCell(_ cell: FeedCell, with userFeed: UserFeed) {
        // MARK: FeedReactor에 feed 넣어주는 방법1
//        let initialState = FeedReactor.State(feed: feed)
//        let cellReactor = FeedReactor(state: initialState)
        
        // MARK: FeedReactor에 feed 넣어주는 방법2
        let cellReactor = FeedReactor(userFeed: userFeed, feedRepository: FeedRepository())
        cell.reactor = cellReactor
        
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
    
    
    private func handleTableViewContentOffset(_ contentOffset: CGPoint) {
        if contentOffset.y < -50 {
            self.navigationItem.title = ""
        } else {
            self.navigationItem.title = "소피들의 소소해피"
        }
    }
    
    func addEmptyView() {
        self.tableView.addSubview(exceptionView)
        exceptionView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
        }
    }
    
    func removeEmptyView() {
        exceptionView.removeFromSuperview()
    }
}
