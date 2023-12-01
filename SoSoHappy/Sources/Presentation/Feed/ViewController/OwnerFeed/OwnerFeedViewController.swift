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

/*
 1. refreshControl이 여기에서 꼭 필요가 있을까? (없을 것 같긴 함)
 2. profile update가 refresh될 때마다 한 3번 정도 호출이 되는 것 같은데 takeUntil, merge를 쓰면 된다고 하던데 수정해보기
 3. 밑에 cell 선택 -> detailVC1 -> Owner -> detailVC1 하면 "소피들의 소소해피"가 나타남 해결 필요
 */

 
final class OwnerFeedViewController: UIViewController {
    // MARK: - Properties
    var disposeBag = DisposeBag()
    private weak var coordinator: OwnerFeedCoordinatorInterface?
    
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
        self.navigationItem.title = ""
        setLayout()
    }

    private func setLayout() {
        view.addSubview(tableView)
        tableView.addSubview(activityIndicatorView)
        
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        activityIndicatorView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
    }
}

// MARK: - ReactorKit - bind func
extension OwnerFeedViewController: View {
    // MARK: bind - reactor에 새로운 값이 들어올 때만 트리거
    func bind(reactor: OwnerFeedViewReactor) {
        self.tableView.rx.setDelegate(self).disposed(by: self.disposeBag)
        self.rx.viewWillAppear
            .map { Reactor.Action.fetchFeeds } // 해당 유저의 공개 feed fetch
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        self.refreshControl.rx.controlEvent(.valueChanged)
            .map { Reactor.Action.refresh }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        tableView.rx.itemSelected
            .map { Reactor.Action.selectedCell(index: $0.row) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        backButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
//                print("back button tapped")
                coordinator?.dismiss()
            })
            .disposed(by: disposeBag)
        
        reactor.state
            .compactMap {
                print("OwnerFeedVC - reactor.state - isLoading : \($0.isLoading)")
                return $0.isLoading
            }
            .distinctUntilChanged()
            .bind(onNext: { [weak self] isLoading in
                guard let self = self else { return }
                print("OwnerFeedVC - isLoading: \(isLoading), type: \(type(of: isLoading))")
                if isLoading {
                    print("OwnerFeedVC - animating")
                    activityIndicatorView.startAnimating()
                } else {
                    print("OwnerFeedVC - animating stop")
                    activityIndicatorView.stopAnimating()
                }
            })
            .disposed(by: disposeBag)
        
        // 이게 refresh될 때마다 한 3번 정도 호출이 되는 것 같은데 takeUntil, merge를 쓰면 된다고 하던데 수정해보기
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
            .skip(1)
            .compactMap {
                print("OwnerFeedVC - reactor.state - userFeeds : \($0.userFeeds)")
                return $0.userFeeds
            }
            .distinctUntilChanged()
            .debug()
            .bind(to: tableView.rx.items(cellIdentifier: OwnerFeedCell.cellIdentifier, cellType: OwnerFeedCell.self)) { [weak self] (row,  userFeed, cell) in
                guard let self = self else { return }
                print("OwnerFeedVC - cell 만드는 중")
                configureCell(cell, with: userFeed)
            }
            .disposed(by: disposeBag)
        
        reactor.state
            .compactMap {
                print("OwnerFeedVC - reactor.state - isRefreshing : \($0.isRefreshing)")
                return $0.isRefreshing
            }
            .distinctUntilChanged()
            .bind(to: self.refreshControl.rx.isRefreshing)
            .disposed(by: self.disposeBag)
        
        reactor.state
            .compactMap {
                print("OwnerFeedVC - reactor.state - selectedFeed : \($0.selectedFeed)")
                print("--------------------------------------")
                return $0.selectedFeed
            }
            .subscribe(onNext: { [weak self] userFeed in
                guard let self = self else { return }
                print("OwnerFeedVC - feed 고름 - 여기까지 진행완료")
//                print("feed: \(feed), type: \(type(of: feed))")
                self.coordinator?.showDetails(userFeed: userFeed)
            })
            .disposed(by: disposeBag)
        
        
        //        reactor.state
        //            .skip(1)
        //            .compactMap { $0.profileImage }
        //            .bind(to: ownerFeedHeaderView.profileImageWithBackgroundView.profileImageView.rx.image)
        //            .disposed(by: disposeBag)
        //
        //        reactor.state
        //            .skip(1)
        //            .compactMap { $0.ownerNickName }
        //            .bind(to: ownerFeedHeaderView.profileNickNameLabel.rx.text)
        //            .disposed(by: disposeBag)
        //
        //        reactor.state
        //            .skip(1)
        //            .compactMap { $0.selfIntroduction }
        //            .bind(onNext: { [weak self] selfIntro in
        //
        //                self?.ownerFeedHeaderView.update(selfIntro: selfIntro)
        //            })
        //            .disposed(by: disposeBag)
    }
    
    private func configureCell(_ cell: OwnerFeedCell, with userFeed: UserFeed) {
        let cellReactor = FeedReactor(userFeed: userFeed, feedRepository: FeedRepository(), userRepository: UserRepository())
        cell.reactor = cellReactor

        cell.imageSlideView.tapObservable
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                cell.imageSlideView.slideShowView.presentFullScreenController(from: self)
            })
            .disposed(by: cell.disposeBag) // cell.disposeBag ?
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


