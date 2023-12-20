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
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
        
        self.rx.viewWillAppear
            .map { Reactor.Action.viewWillAppear }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        self.nextButton.rx.tap
            .map { Reactor.Action.tapNextButton }
            .filter {  _ in
                let nowDate = Date().getFormattedYM2()
                return nowDate != reactor.currentState.monthYearText
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        self.previousButton.rx.tap
            .map { Reactor.Action.tapPreviousButton }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        self.recommendView.refreshButton.rx.tap
            .map { Reactor.Action.tapRecommendRefreshButton }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        self.chartView.segmentedControl.rx.selectedSegmentIndex
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] selectedIndex in
                self?.reactor?.action.onNext(.changeChartMode(index: selectedIndex))
            })
            .disposed(by: disposeBag)
        
    }
    
    // MARK: - Output
    func bindState(_ reactor: ChartViewReactor) {
        reactor.state
            .map { $0.monthYearText }
            .asDriver(onErrorJustReturn: "")
            .distinctUntilChanged()
            .drive(self.yearMonthLabel.rx.text)
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.happinessTopThree }
            .subscribe { [weak self] topThree in
                guard let `self` = self else { return }
                if topThree.count == 0 {
                    self.awardsView.privateTop3View.isHidden = false
                } else {
                    self.awardsView.setAwardsCategories(categories: topThree)
                    self.awardsView.privateTop3View.isHidden = true
                }
            }.disposed(by: disposeBag)
        
        reactor.state
            .map { $0.nowRecommendText }
            .asDriver(onErrorJustReturn: "")
            .distinctUntilChanged()
            .drive(onNext: { [weak self] text in
                guard let `self` = self else { return }
                if text == "피드 작성하기" {
                    self.recommendView.recommendedHappinessLabel.text = text
                    self.recommendView.refreshButton.isEnabled = false
                } else {
                    self.recommendView.recommendedHappinessLabel.text = text
                    self.recommendView.refreshButton.isEnabled = true
                }
            })
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
        
        reactor.showErrorAlertPublisher
            .asDriver(onErrorJustReturn: BaseError.unknown)
            .drive { error in
                CustomAlert.presentInternarServerAlert()
            }
            .disposed(by: disposeBag)
        
        reactor.showNetworkErrorViewPublisher
            .asDriver(onErrorJustReturn: BaseError.unknown)
            .drive { error in
                CustomAlert.presentErrorAlertWithoutDescription()
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
            $0.edges.equalToSuperview()
        }
        
        contentView.snp.makeConstraints {
            $0.edges.equalTo(scrollView)
            $0.width.equalTo(view)
            $0.height.equalTo(scrollView).offset(-30)
        }
        
        leftEmptyView.snp.makeConstraints {
            $0.width.equalTo(80)
        }
        
        rightEmptyView.snp.makeConstraints {
            $0.width.equalTo(80)
        }
        
        titleStack.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().inset(17)
        }
        
        previousButton.snp.makeConstraints {
            $0.width.height.equalTo(30)
        }
        
        nextButton.snp.makeConstraints {
            $0.width.height.equalTo(30)
        }
        
        awardsView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(titleStack.snp.bottom).offset(35)
            $0.height.equalTo(255)
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
            $0.height.equalTo(300)
        }
    }
    
    func setNickName() {
        let nickName = KeychainService.getNickName()
        self.nameLabel.text = nickName
        self.chartView.graphLabel.text = "\(nickName)님의 행복 그래프 💖"
    }
    
}
