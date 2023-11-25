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

final class HappyListViewController : UIViewController {
    
    
    // MARK: - Properties
    private var coordinator: HappyListCoordinatorInterface
    var disposeBag = DisposeBag()
    
    private var currentPage: Date
    private var monthHappinessList = BehaviorRelay(value: [MyFeed]())
    
    // MARK: - UI Components
    private lazy var happyTableView = UITableView().then {
        $0.register(HappyListCell.self, forCellReuseIdentifier: HappyListCell.cellIdentifier)
        $0.backgroundColor = UIColor(named: "BGgrayColor")
        $0.separatorStyle = .none
        $0.estimatedRowHeight = 30
        $0.rowHeight = UITableView.automaticDimension
    }
    
    private lazy var yearMonthLabel = UILabel().then {
        $0.text = "2023.07"
        $0.font = .systemFont(ofSize: 22)
        $0.textColor = UIColor(named: "DarkGrayTextColor")
    }
    
    private lazy var previousButton = UIButton().then({
        let image = UIImage(named: "previousButton")
        $0.setImage(image, for: .normal)
    })
    
    private lazy var nextButton = UIButton().then({
        let image = UIImage(named: "nextButton")
        $0.setImage(image, for: .normal)
    })
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
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
            $0.width.height.equalTo(10)
        }
        
        self.nextButton.snp.makeConstraints {
            $0.left.equalTo(yearMonthLabel.snp.right).offset(30)
            $0.centerY.equalTo(yearMonthLabel)
            $0.width.height.equalTo(10)
        }
        
        self.happyTableView.snp.makeConstraints {
            $0.bottom.left.right.equalToSuperview()
            $0.top.equalTo(yearMonthLabel.snp.bottom).offset(20)
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
        
//        reactor.state
//            .skip(1)
//            .map { $0.feeds }
//            .bind(to: happyTableView.rx.items(cellIdentifier: HappyListCell.cellIdentifier, cellType: HappyListCell.self)) { (row,  feed, cell) in
//                // viewcontroller에서 직접 feed로 데이터를 전달해주는게 적합한지 잘 모르겠음
//                // 이것마저 Reactor에서 다루는 참고 코드가 있는지 확인하고 적용해보면 좋을 듯
//                let cellReactor = HappyListCellReactor(feed: feed)
//                cell.reactor = cellReactor
//                
//                cell.imageSlideView.tapObservable
//                    .subscribe(onNext: { [weak self] in
//                        guard let self = self else { return }
//                        cell.imageSlideView.slideShowView.presentFullScreenController(from: self)
//                    })
//                    .disposed(by: cell.disposeBag)
//                
//            }
//            .disposed(by: disposeBag)
    }
}

extension HappyListViewController {
    
    func initialize() {
        self.bindTableView()
        
        
    }
    
    func bindTableView() {
        self.monthHappinessList
            .bind(to: self.happyTableView.rx.items(
                cellIdentifier: "Cell",
                cellType: HappyListCell.self)) {
                _, element, cell in
//                cell.item = element
                    
                }.disposed(by: disposeBag)
        
        
        self.happyTableView.rx.modelSelected(MyFeed.self)
            .subscribe { item in
                // coodinator: go to Detail VC
//                
//                Observable.just(Reactor.Action.moveToDetail(item))
//                                    .bind(to: self?.reactor!.action)
//                                    .disposed(by: self?.disposeBag)
            }.disposed(by: disposeBag)
        
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
