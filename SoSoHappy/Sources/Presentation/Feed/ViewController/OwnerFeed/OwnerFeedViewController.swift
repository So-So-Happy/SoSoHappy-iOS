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

final class OwnerFeedViewController: UIViewController {
    // MARK: - Properties
    var disposeBag = DisposeBag()
    private weak var coordinator: OwnerFeedCoordinatorInterface?
    private var dataSource: RxTableViewSectionedReloadDataSource<UserFeedSection.Model>!
    
    // MARK: - UI Components
    private lazy var refreshControl = UIRefreshControl()
    private lazy var ownerFeedHeaderView = OwnerFeedHeaderView()
    
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
        $0.isHidden = true
    }
    
    private lazy var noFeedExceptionView = ExceptionView(
        title: "등록된 피드가 없습니다.",
        inset: 40
    ).then {
        $0.isHidden = true
    }
    
    private lazy var networkNotConnectedView = NetworkNotConnectedView(inset: 56).then {
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
        setup()
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
        setAttributes()
        setLayout()
    }
    
    private func setAttributes() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: blockButton)
        self.navigationItem.title = ""
        
        let swipeGestureRecognizerRight = UISwipeGestureRecognizer(target: self, action: #selector(didSwipe(_:)))
        swipeGestureRecognizerRight.direction = .right
        view.addGestureRecognizer(swipeGestureRecognizerRight)
    }

    private func setLayout() {
        view.addSubview(tableView)
        view.addSubview(loadingView)
        tableView.addSubview(noFeedExceptionView)
        tableView.addSubview(networkNotConnectedView)
        
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        loadingView.snp.makeConstraints { make in
            make.horizontalEdges.bottom.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.6)
        }
        
        noFeedExceptionView.snp.makeConstraints { make in
            make.horizontalEdges.bottom.equalToSuperview()
            make.center.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.4)
        }
        
        networkNotConnectedView.snp.makeConstraints { make in
            make.horizontalEdges.bottom.equalToSuperview()
            make.center.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.4)
        }
        
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 64, right: 0)
    }
}

// MARK: - ReactorKit - bind func
extension OwnerFeedViewController: View {
    func bind(reactor: OwnerFeedViewReactor) {
        self.tableView.rx.setDelegate(self).disposed(by: self.disposeBag)
        dataSource = self.createDataSource()

        self.rx.viewWillAppear
            .map { Reactor.Action.fetchFeeds }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        tableView.rx.reachedBottom(offset: -20)
            .skip(1)
            .throttle(.milliseconds(130), latest: false, scheduler: MainScheduler.instance)
            .debug()
            .map { Reactor.Action.pagination }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        self.refreshControl.rx.controlEvent(.valueChanged)
            .map { Reactor.Action.refresh }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        backButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                coordinator?.dismiss()
            })
            .disposed(by: disposeBag)
        
        tableView.rx.modelSelected(UserFeedSection.Item.self)
            .subscribe(onNext: { [weak self] selectedItem in
                guard let self = self else { return }
                switch selectedItem {
                case let .feed(feedReactor):
                    coordinator?.showDetails(feedReactor: feedReactor)
                }
            })
            .disposed(by: disposeBag)
        
        networkNotConnectedView.retryButton.rx.tap
            .map { Reactor.Action.fetchFeeds }
            .debug()
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.state
            .compactMap { $0.profile }
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] profile in
                self?.ownerFeedHeaderView.update(with: profile)
            })
            .disposed(by: disposeBag)
        
        reactor.state
            .map(\.sections)
            .distinctUntilChanged()
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
            .compactMap { $0.isBlockSucceeded }
            .subscribe(onNext: { [weak self] isBlockSucceeded in
                guard let self = self else { return }
                coordinator?.goBackToRoot()
            })
            .disposed(by: disposeBag)
        
        reactor.state
            .compactMap { $0.showNetworkErrorView }
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] showNetworkErrorView in
                guard let self = self else { return }
                print("OwnerFeedViewController showNetworkErrorView : \(showNetworkErrorView)")
                if showNetworkErrorView {
                    loadingView.isHidden = true
                    noFeedExceptionView.isHidden = true
                    networkNotConnectedView.isHidden = false // 보여주기
                }
            })
            .disposed(by: disposeBag)
        
        reactor.state
            .compactMap { $0.showServerErrorAlert }
            .distinctUntilChanged()
            .bind(onNext: { [weak self] showServerErrorAlert in
                guard let self = self else { return }
                print("++++ OwnerFeedViewController showServerErrorAlert \(showServerErrorAlert)")
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
    
    private func configureCell(_ cell: OwnerFeedCell) {
        cell.imageSlideView.tapObservable
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                cell.imageSlideView.slideShowView.presentFullScreenController(from: self)
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
        CustomAlert.presentCheckAndCancelAlert(title: "작성자 차단", message: "차단하시겠습니까? 차단하면 차단한 작성자의 피드를 볼 수 없습니다.(차단 여부는 상대방이 알 수 없습니다)", buttonTitle: "차단") { self.reactor?.action.onNext(.block)
        }
    }
    
    @objc private func didSwipe(_ sender: UISwipeGestureRecognizer) {
        coordinator?.dismiss()
    }
}
