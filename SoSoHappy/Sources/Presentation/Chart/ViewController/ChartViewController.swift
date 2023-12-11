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
    
    private lazy var awardsImageView = UIImageView(image: UIImage(named: "awards"))
    private lazy var image1 = UIImageView(image: UIImage(named: "food"))
    private lazy var image2 = UIImageView(image: UIImage(named: "dessert"))
    private lazy var image3 = UIImageView(image: UIImage(named: "coffee"))
    
    
    private lazy var yearMonthLabel = UILabel().then {
        $0.text = "2023.07"
        $0.font = UIFont.customFont(size: 22, weight: .medium)
        $0.textColor = UIColor(rgb: 0x626262)
    }
    
    private lazy var previousButton = UIButton().then({
        let image = UIImage(named: "previousButton")
        $0.setImage(image, for: .normal)
    })
    
    private lazy var nextButton = UIButton().then({
        let image = UIImage(named: "nextButton")
        $0.setImage(image, for: .normal)
    })
    
    private lazy var testView = UIView()
    
    private lazy var awardsView = AwardsView()
    private lazy var recommendView = RecommendView()
    private lazy var chartView = ChartView()
    private lazy var scrollView = UIScrollView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .white
    }
    let contentView = UIView()
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "BGgrayColor")
        setUpView()
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

        
        // FIXME: - recommend refresh Button 누를때 chart reload 됨. -> take 사용해서 한번만 호출되게
        reactor.state
            .map { $0.happinessChartData }
            .subscribe { [weak self] data in
                guard let `self` = self else { return }
                self.chartView.setChart(data)
            }
            .disposed(by: disposeBag)
        
    }
    
}

extension ChartViewController {
    private func setUpView() {
        
        view.addSubview(scrollView)
        
        scrollView.addSubview(contentView)
//        contentView.addSubview(awardsView)
        contentView.addSubviews(previousButton, nextButton, yearMonthLabel)
//        contentView.addSubview(testView)
        contentView.addSubview(awardsImageView)
        contentView.addSubview(recommendView)
        contentView.addSubview(chartView)
        
        contentView.addSubviews(image1, image2, image3)
        
        scrollView.snp.makeConstraints {
            $0.edges.equalToSuperview() // 스크롤뷰가 뷰에 가득 차도록 설정
        }
        
        contentView.snp.makeConstraints {
            $0.edges.equalTo(scrollView) // 컨텐츠뷰도 스크롤뷰와 크기를 같도록 설정
            $0.width.equalTo(view) // 컨텐츠뷰의 너비를 뷰와 같도록 설정
            $0.height.equalTo(scrollView).priority(.low) // 컨텐츠뷰의 높이를 스크롤뷰와 같도록 설정, 우선순위를 낮춤
        }
        
        yearMonthLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(30)
            $0.centerX.equalToSuperview()
        }
        
        previousButton.snp.makeConstraints {
            $0.right.equalTo(yearMonthLabel.snp.left).offset(-30)
            $0.centerY.equalTo(yearMonthLabel)
            $0.width.height.equalTo(10)
        }
        
        nextButton.snp.makeConstraints {
            $0.left.equalTo(yearMonthLabel.snp.right).offset(30)
            $0.centerY.equalTo(yearMonthLabel)
            $0.width.height.equalTo(10)
        }
        
//        awardsView.snp.makeConstraints {
//            $0.leading.trailing.equalToSuperview()
//            $0.top.equalTo(yearMonthLabel.snp.bottom).offset(20)
//            $0.height.equalTo(310) // 이 부분은 awardsView의 높이 계산에 맞게 변경해야 함
//        }
        
        
        // FIXME: -
        awardsImageView.snp.makeConstraints {
            $0.height.equalTo(80) // height fix
            $0.top.equalTo(yearMonthLabel.snp.bottom).offset(120)
//            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.width.equalTo(contentView.snp.width).offset(-40)
            $0.centerX.equalToSuperview()
        }
        
        image1.snp.makeConstraints {
            $0.width.height.equalTo(60)
            $0.centerX.equalTo(contentView.snp.centerX).offset(-110)
            $0.bottom.equalTo(awardsImageView.snp.top).offset(30)
//            $0.centerX.equalTo(awardsImageView.snp.width).multipliedBy(3.0 / 1.0)
        }
        
        image2.snp.makeConstraints {
            $0.width.height.equalTo(60)
            $0.centerX.equalTo(contentView.snp.centerX)
            $0.bottom.equalTo(awardsImageView.snp.top)
            
        }
        
        image3.snp.makeConstraints {
            $0.width.height.equalTo(60)
            $0.centerX.equalTo(contentView.snp.centerX).offset(110)
            $0.bottom.equalTo(awardsImageView.snp.top).offset(50)
            
        }

        recommendView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(awardsImageView.snp.bottom).offset(60)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(130)
        }

        chartView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(recommendView.snp.bottom)
        }
    }
}
