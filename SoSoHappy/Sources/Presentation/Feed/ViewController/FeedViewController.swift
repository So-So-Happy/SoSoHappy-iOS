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
 2. refresh control 한번 더 확인해보기 - 좀 모양새가 이상함
 
 3. AlertReactor 프로젝트처럼 Reactor의 feeds를 [FeedCellReactor]로 해줘서 따로 Reactor 인스턴스를 만들지 않고
 cell.reactor = reactor 바로 주입 가능 (어떤 방법이 더 적합할지 고민해보기)
 
 4.  operator들 좀 더 찾아보고 적용해보면서 리팩토링
    (rxswift: asDriver, drive, distinctUntilChanged, subscribe, do 공부해보기)

 */

/*
 1. refreshcontrol이 navigation title이 large로 해서 그런지 모양새가 이상하게 나와서 코드를 일단 수정해놓음
 */

// delegate 프로퍼티에 weak 키워드를 붙이려면 AnyObject를 써야 했음
// weak의 용도와 AnyObject가 무엇인지 좀 찾아보기
protocol FeedViewControllerDelegate: AnyObject {
    func didSelectCell()
    func didSelectProfileImage()
}


final class FeedViewController: UIViewController {
    // MARK: - Properties
    var disposeBag = DisposeBag()
    
    weak var delegate: FeedViewControllerDelegate?
    
    // MARK: - UI Components
    private lazy var feedHeaderView = FeedHeaderView()
    private lazy var refreshControl = UIRefreshControl()
    
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
        print("FeedViewController viewDidLoad ---------------")
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let contentOffset = self.tableView.contentOffset
        handleTableViewContentOffset(contentOffset)
    }

    // MARK: - 스크롤된 정도에 따라서 navigation title을 줬더니 다음 화면으로 넘어갈 때 Back 대신 title이 뜨길래
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("FeedViewController viewWillDisappear ---------------")
        self.navigationItem.title = ""
    }
    
    init(reactor: FeedViewReactor) {
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - Set Navigation & Add Subviews & Constraints
extension FeedViewController {
    private func setup() {
//        configureNavigation()
        setLayout()
    }
    
    func configureNavigation() {
//        self.navigationItem.title = "소피들의 소소해피"
//        self.navigationController?.navigationBar.prefersLargeTitles = true
    }
    
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
        self.rx.viewDidLoad
            .map { Reactor.Action.fetchFeeds(.today) } // default today
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
            .map { Reactor.Action.fetchFeeds(.today) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        feedHeaderView.sortTotalButton.rx.tap
            .map { Reactor.Action.fetchFeeds(.total) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // asDriver  - 항상 main 스레드에서 관찰하고 에러가 발생하지 않는 것을 보장하여 시퀀스 작업을 간단하게 함
        // subscribe - 구독 관리를 더 세밀하게 제어해야 하는 경우
        tableView.rx.itemSelected
            .asDriver()
            .drive(onNext: { [weak self] indexPath in
                guard let self = self else { return }
                print("indexPath: \(indexPath.row)")
                self.delegate?.didSelectCell()
            })
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
            .map { $0.feeds }
            .bind(to: tableView.rx.items(cellIdentifier: FeedCell.cellIdentifier, cellType: FeedCell.self)) { (row,  feed, cell) in
                // MARK: FeedReactor에 feed 넣어주는 방법1
//                let initialState = FeedReactor.State(feed: feed)
//                let cellReactor = FeedReactor(state: initialState)
                                
                // MARK: FeedReactor에 feed 넣어주는 방법2
                let cellReactor = FeedReactor(feed: feed)
                cell.reactor = cellReactor
                
                cell.didSelectProfileImage = { [weak self] in
                    self?.delegate?.didSelectProfileImage()
                }
                
                
                // - 여기에 코드를 작성한 이유
                // cell의 이미지를 tap했을 때 이미지VC을 'self'(FeedViewController)에서 present해주기 때문
                cell.imageSlideView.tapObservable
                    .subscribe(onNext: { [weak self] in
                        guard let self = self else { return }
                        cell.imageSlideView.slideShowView.presentFullScreenController(from: self)
                    })
                    .disposed(by: cell.disposeBag)
            }
            .disposed(by: disposeBag)
        
        reactor.state
            .skip(1)
            .map { $0.sortOption }
            .subscribe(onNext: { [weak self] sortOption in
                guard let self = self else { return }
                feedHeaderView.updateButtonState(sortOption)
            })
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.isRefreshing }
            .distinctUntilChanged()
            .bind(to: self.refreshControl.rx.isRefreshing)
            .disposed(by: self.disposeBag)
        
    }
    
    private func handleTableViewContentOffset(_ contentOffset: CGPoint) {
        if contentOffset.y < -50 {
            self.navigationItem.title = ""
        } else {
            self.navigationItem.title = "소피들의 소소해피"
        }
    }
}


