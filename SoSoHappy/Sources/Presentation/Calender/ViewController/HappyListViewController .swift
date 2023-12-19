//
//  HappyListViewController .swift
//  SoSoHappy
//
//  Created by 박희경 on 2023/08/11.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import ReactorKit
import ImageSlideshow

final class HappyListViewController: UIViewController {
     
    // MARK: - Properties
    var disposeBag = DisposeBag()
    
    private var coordinator: HappyListCoordinatorInterface
    
    private var monthHappinessList = BehaviorRelay(value: [MyFeed]())
    
    private var currentPage: Date
    private let today: Date = {
        return Date()
    }()
    
    // MARK: - UI Components
    private lazy var happyTableView = UITableView().then {
        $0.register(BaseCell.self, forCellReuseIdentifier: BaseCell.cellIdentifier)
        $0.backgroundColor = UIColor(named: "BGgrayColor")
        $0.separatorStyle = .none
        $0.estimatedRowHeight = 30
        $0.rowHeight = UITableView.automaticDimension
        $0.showsVerticalScrollIndicator = false
    }
    
    private lazy var yearMonthLabel = UILabel().then {
        $0.text = "2023.07"
        $0.font = UIFont.customFont(size: 20, weight: .bold)
        $0.textColor = UIColor(named: "DarkGrayTextColor")
    }
    
    private lazy var previousButton = UIButton().then({
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 15, weight: .semibold)
        let image = UIImage(systemName: "chevron.left", withConfiguration: imageConfig)
        $0.setImage(image, for: .normal)
        $0.tintColor = UIColor(named: "AccentColor")
    })
    
    private lazy var nextButton = UIButton().then({
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 15, weight: .semibold)
        let image = UIImage(systemName: "chevron.right", withConfiguration: imageConfig)
        $0.setImage(image, for: .normal)
        $0.tintColor = UIColor(named: "AccentColor")
    })
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("HappyListViewController viewDidLoad start")
        setLayout()
        initialize()
    }
    
    init(reactor: HappyListViewReactor,
         coordinator: HappyListCoordinatorInterface,
         currentPage: Date) {
        self.coordinator = coordinator
        self.currentPage = currentPage
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - Layout & Attribute
private extension HappyListViewController  {
    private func setLayout() {
        self.view.backgroundColor = UIColor(named: "BGgrayColor")
        self.view.addSubviews(happyTableView, yearMonthLabel, nextButton, previousButton)
        
        self.yearMonthLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            $0.centerX.equalToSuperview()
        }
        
        self.previousButton.snp.makeConstraints {
            $0.right.equalTo(yearMonthLabel.snp.left).offset(-30)
            $0.centerY.equalTo(yearMonthLabel)
            $0.width.height.equalTo(20)
        }
        
        self.nextButton.snp.makeConstraints {
            $0.left.equalTo(yearMonthLabel.snp.right).offset(30)
            $0.centerY.equalTo(yearMonthLabel)
            $0.width.height.equalTo(20)
        }
        
        self.happyTableView.snp.makeConstraints {
            $0.bottom.left.right.equalToSuperview()
            $0.top.equalTo(yearMonthLabel.snp.bottom).offset(10)
        }
        
    }
}

// MARK: - ReactorKit - bind func
extension HappyListViewController: View {
    // MARK: bind
    func bind(reactor: HappyListViewReactor) {
        // MARK: Action (View -> Reactor) 인풋
        self.rx.viewDidLoad
            .map { Reactor.Action.viewDidLoad }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        self.nextButton.rx.tap
            .map { Reactor.Action.tapNextButton }
            .filter { [weak self] _ in
                guard let self = self else { return false }
                let nextDate = currentPage.moveToNextMonth()
                return nextDate < today 
              }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        self.previousButton.rx.tap
            .map { Reactor.Action.tapPreviousButton }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // MARK: State (Reactor -> State) 아웃풋
        reactor.state
            .map { $0.date }
            .asDriver(onErrorJustReturn: "")
            .distinctUntilChanged()
            .drive(self.yearMonthLabel.rx.text)
            .disposed(by: disposeBag)

        reactor.state
            .map { $0.monthHappinessData }
            .subscribe { data in
                self.monthHappinessList.accept(data)
            }.disposed(by: disposeBag)
        
        reactor.state
            .map { $0.currentPage }
            .subscribe { [weak self] currentPage in
                guard let self = self else { return }
                self.currentPage = currentPage
            }.disposed(by: disposeBag)
    }
}

extension HappyListViewController {
    
    func initialize() {
        self.bindTableView()
        
    }
    
    func bindTableView() {
        self.monthHappinessList
            .bind(to: self.happyTableView.rx.items(cellIdentifier: BaseCell.cellIdentifier, cellType: BaseCell.self)) { (row, element, cell) in
                cell.setFeedCell(element)
            }
            .disposed(by: disposeBag)
        
        self.happyTableView.rx.modelSelected(MyFeed.self)
        .subscribe(onNext: { feed in
            self.coordinator.pushDetailView(feed: feed)
            // coodinator: go to Detail VC
            //                Observable.just(Reactor.Action.tapHappyListCell)
            //                    .bind(to: self?.reactor!.action)
            //                    .disposed(by: self?.disposeBag)
            //                self.coordinator.pushDetailView(date: )
            //                self.reactor?.action.onNext(.tapHappyListCell(item.))
        }).disposed(by: disposeBag)
        
        self.happyTableView.rx.itemSelected
            .subscribe { indexPath in
                self.happyTableView.deselectRow(at: indexPath, animated: false)
            }.disposed(by: disposeBag)
        
        // Observable 결합
                /*
                Observable.zip(self.tableView.rx.itemSelected, self.tableView.rx.modelSelected(MessageRoomModel.self))
                    .subscribe(onNext: { [weak self] indexPath, item in
                        self?.tableView.deselectRow(at: indexPath, animated: false)
                        Observable.just(Reactor.Action.moveToDetail(item))
                            .bind(to: self?.reactor!.action)
                            .disposed(by: self?.disposeBag)
                    }).disposed(by: self.disposeBag)
                */
        
        
    }
    
}
