//
//  ChartViewController.swift
//  SoSoHappy
//
//  Created by 박민주 on 2023/08/07.
//

import UIKit
import SnapKit
import Then
import RxSwift
import ReactorKit

final class ChartViewController: UIViewController {
    // MARK: - Properties
//    private var coordinator: ChartCoordinatorInterface
    var disposeBag = DisposeBag()
    
    // MARK: - UI Components
    private lazy var titleStack = UIStackView().then {
        $0.spacing = 0
        $0.addArrangedSubview(nameLabel)
        $0.addArrangedSubview(label2)
        $0.distribution = .fillProportionally
        $0.axis = .horizontal
    }
    
    private lazy var nameLabel = UILabel().then {
        $0.text = ""
        $0.textColor = UIColor(named: "AccentColor")
        $0.font = UIFont.customFont(size: 25, weight: .bold)
    }
    
    private lazy var label2 = UILabel().then {
        $0.text = "님의 행복 분석"
        $0.font = UIFont.customFont(size: 25, weight: .bold)
    }
    
    private lazy var yearMonthLabel = UILabel().then {
        $0.text = "2023년 8월"
        $0.font = UIFont.customFont(size: 19, weight: .bold)
        $0.textColor = UIColor(named: "DarkGrayTextColor")
        $0.textAlignment = .center
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
    
    private lazy var leftEmptyView = UIView()
    private lazy var rightEmptyView = UIView()
    
    private lazy var testView = UIView()
    
    private lazy var awardsView = AwardsView()
    private lazy var recommendView = RecommendView()
    private lazy var chartView = ChartView()
    private lazy var scrollView = UIScrollView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = UIColor(named: "BGgrayColor")
        $0.showsVerticalScrollIndicator = false
    }
    let contentView = UIView()
    
    
    private var nickName: String = ""
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
        
    }
    
    init(reactor: ChartViewReactor
    ) {
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension ChartViewController: View {
    
    // MARK: - Binding
    func bind(reactor: ChartViewReactor) {
        bindAction(reactor)
        bindState(reactor)
    }
    
    // MARK: - Input
    func bindAction(_ reactor: ChartViewReactor) {
        
        // viewdidload
        self.rx.viewDidLoad
            .map { Reactor.Action.viewDidLoad }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // previousButton
        self.nextButton.rx.tap
            .map { Reactor.Action.tapNextButton }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // nextButton
        self.previousButton.rx.tap
            .map { Reactor.Action.tapPreviousButton }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // recommend refreshButton
        self.recommendView.refreshButton.rx.tap
            .map { Reactor.Action.tapRecommendRefreshButton }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // UISegmentedControl의 선택이 바뀔 때마다 Reactor에게 전달
        self.chartView.segmentedControl.rx.selectedSegmentIndex
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] selectedIndex in
                self?.reactor?.action.onNext(.changeChartMode(index: selectedIndex))
            })
            .disposed(by: disposeBag)
        
    }
    
    // MARK: - Output
    func bindState(_ reactor: ChartViewReactor) {
        // year.month
        reactor.state
            .map { $0.monthYearText }
            .asDriver(onErrorJustReturn: "")
            .distinctUntilChanged()
            .drive(self.yearMonthLabel.rx.text)
            .disposed(by: disposeBag)
       
        // top 3
        reactor.state
            .map { $0.happinessTopThree }
            .distinctUntilChanged()
            .subscribe { [weak self] topThree in
                if topThree.count == 3 {
                   // TODO: - 텅뷰처리
                } else {
                    self?.awardsView.setAwardsCategories(categories: topThree)
                }
            }.disposed(by: disposeBag)
        
        // recommend
        reactor.state
            .map { $0.nowRecommendText }
            .asDriver(onErrorJustReturn: "")
            .distinctUntilChanged()
            .drive(self.recommendView.recommendedHappinessLabel.rx.text)
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.chartText }
            .asDriver(onErrorJustReturn: "")
            .distinctUntilChanged()
            .drive(self.yearMonthLabel.rx.text)
            .disposed(by: disposeBag)

        reactor.state
            .map { $0.happinessChartData }
            .distinctUntilChanged()
            .subscribe { [weak self] data in
                guard let `self` = self else { return }
                self.chartView.setChart(data)
            }
            .disposed(by: disposeBag)
    }
    
}

extension ChartViewController {
    
    private func setUp() {
        setUpView()
        setNickName()
    }
    
    private func setUpView() {
        navigationItem.titleView = yearMonthLabel
        self.navigationItem.leftBarButtonItems = [UIBarButtonItem(customView: leftEmptyView),  UIBarButtonItem(customView: previousButton)]
        self.navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: rightEmptyView), UIBarButtonItem(customView: nextButton)]
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(titleStack)
        contentView.addSubview(awardsView)
        contentView.addSubview(recommendView)
        contentView.addSubview(chartView)
        
        scrollView.snp.makeConstraints {
            $0.edges.equalToSuperview() // 스크롤뷰가 뷰에 가득 차도록 설정
        }
        
        contentView.snp.makeConstraints {
            $0.edges.equalTo(scrollView) // 컨텐츠뷰도 스크롤뷰와 크기를 같도록 설정
            $0.width.equalTo(view) // 컨텐츠뷰의 너비를 뷰와 같도록 설정
            $0.height.equalTo(scrollView).priority(.low) // 컨텐츠뷰의 높이를 스크롤뷰와 같도록 설정, 우선순위를 낮춤
        }
        
        leftEmptyView.snp.makeConstraints {
            $0.width.equalTo(90)
        }
        
        rightEmptyView.snp.makeConstraints {
            $0.width.equalTo(90)
        }
        
        titleStack.snp.makeConstraints {
            $0.centerX.equalToSuperview()
//            $0.leading.equalToSuperview().inset(20)
            $0.top.equalToSuperview().inset(17)
        }
        
        awardsView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(titleStack.snp.bottom).offset(35)
            $0.height.equalTo(255) // 이 부분은 awardsView의 높이 계산에 맞게 변경해야 함
        }

        recommendView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(awardsView.snp.bottom)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(140)
        }

        chartView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(recommendView.snp.bottom)
            $0.height.equalTo(250)
        }
    }
    
    func setNickName() {
        let provider = KeychainService.loadData(
            serviceIdentifier: "sosohappy.userInfo",
            forKey: "provider"
        ) ?? ""
        
        let nickName = KeychainService.loadData(
            serviceIdentifier: "sosohappy.userInfo\(provider)",
            forKey: "userNickName"
        ) ?? ""
        
        self.nameLabel.text = nickName
        
    }
}
