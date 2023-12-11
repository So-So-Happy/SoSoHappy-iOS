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
import NVActivityIndicatorView
import RxDataSources
import RxSwiftExt

/*
 1. refreshControl이 여기에서 꼭 필요가 있을까? (없을 것 같긴 함)
 2. profile update가 refresh될 때마다 한 3번 정도 호출이 되는 것 같은데 takeUntil, merge를 쓰면 된다고 하던데 수정해보기
 3. 밑에 cell 선택 -> detailVC1 -> Owner -> detailVC1 하면 "소피들의 소소해피"가 나타남 해결 필요
 */

 
final class OwnerFeedViewController: UIViewController {
    // MARK: - Properties
    var disposeBag = DisposeBag()
    private weak var coordinator: OwnerFeedCoordinatorInterface?
    private var dataSource: RxTableViewSectionedReloadDataSource<UserFeedSection.Model>!
    
    // MARK: - UI Components
    private lazy var refreshControl = UIRefreshControl()
    private lazy var ownerFeedHeaderView = OwnerFeedHeaderView()
    
    // MARK: 로딩 뷰 잘 넣어주기
    private lazy var activityIndicatorView = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 27, height: 27), type: .circleStrokeSpin, color: .black, padding: 0)
    
    private lazy var tableView = UITableView(frame: .zero, style: .grouped).then {
        $0.register(OwnerFeedCell.self, forCellReuseIdentifier: OwnerFeedCell.cellIdentifier)
        $0.separatorStyle = .none
        $0.refreshControl = self.refreshControl
        $0.sectionHeaderHeight = UITableView.automaticDimension
        $0.backgroundColor = UIColor(named: "BGgrayColor")
        $0.rowHeight = UITableView.automaticDimension
        $0.estimatedRowHeight = 300
    }
    
    private lazy var backButton = UIButton().then {
        $0.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        $0.setPreferredSymbolConfiguration(.init(scale: .large), forImageIn: .normal)
    }
    
    private lazy var blockButton = BlockButton().then {
        $0.delegate = self
    }
    
    private lazy var loadingView = LoadingView().then {
        $0.isHidden = true // true
    }
    
    private lazy var exceptionView = FeedExceptionView(
        title: "등록된 피드가 없습니다.",
        inset: 40
    ).then {
        $0.isHidden = true //true
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
        setup()
        print("OwnerFeedViewcontroller viewDidload")
    }
    // MARK: viewWillAppear에 해주는게 맞음
    // detailViewController 앞 뒤로 갔다왔을 때
    // 하나는 viewDidLoad, viewWillAppear 두 개, 다른 하나는 viewWillAppear
    // 공통적으로 들어가 있는 viewWillAppear에서 처리를 해주는게 맞음
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("OwnerFeedViewcontroller viewWillAppear")
    
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
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: blockButton)
        self.navigationItem.title = ""
        setLayout()
    }

    private func setLayout() {
        view.addSubview(tableView)
        view.addSubview(loadingView)
        tableView.addSubview(exceptionView)
//        tableView.addSubview(loadingView)
        
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        loadingView.snp.makeConstraints { make in
            make.horizontalEdges.bottom.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.6)
        }
        
        exceptionView.snp.makeConstraints { make in
            make.horizontalEdges.bottom.equalToSuperview()
            make.center.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.4)
        }
        
//        activityIndicatorView.snp.makeConstraints { make in
//            make.centerX.equalToSuperview()
//            make.centerY.equalToSuperview()
//        }
        
//        loadingView.snp.makeConstraints { make in
//            make.horizontalEdges.bottom.equalToSuperview()
//            make.top.equalTo(ownerFeedHeaderView.snp.bottom)
//        }
        
    }
}

// MARK: - ReactorKit - bind func
extension OwnerFeedViewController: View {
    // MARK: bind - reactor에 새로운 값이 들어올 때만 트리거
    func bind(reactor: OwnerFeedViewReactor) {
        self.tableView.rx.setDelegate(self).disposed(by: self.disposeBag)
        dataSource = self.createDataSource()

        self.rx.viewWillAppear
            .map { Reactor.Action.fetchFeeds } // 해당 유저의 공개 feed fetch
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        self.refreshControl.rx.controlEvent(.valueChanged)
            .map { Reactor.Action.refresh }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        tableView.rx.reachedBottom(offset: -20)
            .skip(1)
            .throttle(.milliseconds(1240), latest: false, scheduler: MainScheduler.instance) // 1.7초
            .debug()
            .map { Reactor.Action.pagination }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        backButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
//                print("back button tapped")
                coordinator?.dismiss()
            })
            .disposed(by: disposeBag)
        
        tableView.rx.modelSelected(UserFeedSection.Item.self)
            .subscribe(onNext: { [weak self] selectedItem in
                switch selectedItem {
                case let .feed(feedReactor):
                    print("modelSelected: \(feedReactor)")
                    self?.coordinator?.showDetails(feedReactor: feedReactor)
                }
            })
            .disposed(by: disposeBag)
        
        reactor.state
//            .skip(1)
            .compactMap {
                print("OwnerFeedVC - reactor.state - profile : \($0.profile)")
                return $0.profile
            }
            .subscribe(onNext: { [weak self] profile in
                print("OwnerFeedVC - reactor.state - profile - inside subscribe)")
                self?.ownerFeedHeaderView.update(with: profile)
            })
            .disposed(by: disposeBag)
        
        reactor.state
            .map(\.sections)
            .distinctUntilChanged()
            .map(Array.init(with:)) // <- extension으로 Array 초기화 시 차원을 하나 늘려주는 코드추가
            .bind(to: self.tableView.rx.items(dataSource: dataSource))
            .disposed(by: self.disposeBag)
        
        reactor.state
            .map { $0.isRefreshing }
            .distinctUntilChanged()
            .bind(to: self.refreshControl.rx.isRefreshing)
            .disposed(by: disposeBag)
        
        reactor.state
            .compactMap { $0.isPaging }
            .distinctUntilChanged()
            .subscribe { [weak self] isPaging in
                guard let self = self else { return }
                print("here2 - isPaging: \(isPaging)")
                tableView.tableFooterView = isPaging ? pagingIndicatorView : UIView(frame: .zero)
            }
            .disposed(by: disposeBag)
        
        reactor.state
            .compactMap { $0.isLoading }
            .distinctUntilChanged()
            .withLatestFrom(reactor.state.map { $0.sections.items.isEmpty }) { isLoading, itemsIsEmpty in
                return (isLoading, itemsIsEmpty)
            }
            .subscribe(onNext: { [weak self] (isLoading, itemsIsEmpty) in
                print("owner - itemsIsEmpty : \(itemsIsEmpty)")
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
    
    
    
    private func configureCell(_ cell: OwnerFeedCell) {
        cell.imageSlideView.tapObservable
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                cell.imageSlideView.slideShowView.presentFullScreenController(from: self)
            })
            .disposed(by: cell.disposeBag) // cell.disposeBag ?
    }
}

extension OwnerFeedViewController {
    private func createDataSource() -> RxTableViewSectionedReloadDataSource<UserFeedSection.Model> {
        return .init { [weak self] dataSource, tableView, indexPath, item  in
            let cell = tableView.dequeueReusableCell(withIdentifier: OwnerFeedCell.cellIdentifier, for: indexPath) as! OwnerFeedCell

            switch item {
            case .feed(let reactor):
                cell.reactor = reactor
                self?.configureCell(cell)
            }
            
            return cell
        }
    }
    
    private func updateViewsVisibility(isLoading: Bool, itemsIsEmpty: Bool, fromRefresh: Bool) {
        if isLoading {
            print("check3 - 로딩 중 ")
            exceptionView.isHidden = true
            if !fromRefresh {
                loadingView.isHidden = false
            }
        } else {
            print("check3 - 로딩 완료 ")
            if !fromRefresh {
                loadingView.isHidden = true
            }
            exceptionView.isHidden = !itemsIsEmpty
        }
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

extension OwnerFeedViewController: BlockButtonDelegate {
    func blockButtonDidTap(_ blockButton: BlockButton) {
        CustomAlert.presentCheckAlert(title: "작성자 차단", message: "차단하시겠습니까? 차단하면 차단한 작성자의 피드를 볼 수 없습니다.(차단 여부는 상대방이 알 수 없습니다)", buttonTitle: "차단") { self.reactor?.action.onNext(.block)
        }
    }
}
