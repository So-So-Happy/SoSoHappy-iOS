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
    
    private lazy var awardsView = AwardsView()
    private lazy var recommendView = RecommendView()
    private lazy var chartView = ChartView()
    private lazy var scrollView = UIScrollView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .white
    }
    let contentView = UIView()
    
    var graphArray: [String] = ["09시", "10시", "11시", "12시", "13시", "14시", "15시", "16시", "17시", "18시"]
    
    let barUnitsSold = [10.0, 17.0, 9.0, 1.0, 8.0, 13.0, 16.0, 14.0, 7.0, 1.0]
    let lineUnitsSold = [10.0, 18.0, 7.0, 1.0, 5.0, 15.0, 14.0, 17.0, 7.0, 1.0]
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "BGgrayColor")
        setUpView()
    }
    
//    init(coordinator: ChartCoordinatorInterface) {
//        self.coordinator = coordinator
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
}

extension ChartViewController: View {
    typealias Reactor = ChartViewReactor
    
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
            .map { Reactor.Action.tapPreviousButton }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // month, year segmentedControl
        
//        self.chartView.segmentedControl.rx.selectedSegmentIndex
//            .map { Reactor.Action.tapMonthChartButton }
//            .map { Reactor.Action.}
        
        
    }
    
    // MARK: - Output
    func bindState(_ reactor: ChartViewReactor) {
        // year.month
       
        // top 3
        
        // recommend
        
        // chart x y setting
        
        reactor.state
            .map { $0.chartText }
            .asDriver(onErrorJustReturn: "")
            .distinctUntilChanged()
            .drive(self.yearMonthLabel.rx.text)
            .disposed(by: disposeBag)

//        reactor.state
//            .map { $0.monthHappinessData }
//            .subscribe { data in
//                self.monthHappinessList.accept(data)
//            }.disposed(by: disposeBag)
        
    }
    
}

extension ChartViewController {
    private func setUpView() {
        
        view.addSubview(scrollView)
        
        scrollView.addSubviews(previousButton, nextButton, yearMonthLabel)
        scrollView.addSubview(contentView)
        contentView.addSubview(awardsView)
        contentView.addSubview(recommendView)
        contentView.addSubview(chartView)
        
        
        yearMonthLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(10)
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
        
        scrollView.snp.makeConstraints {
//            $0.horizontalEdges.equalToSuperview() // 스크롤뷰가 뷰에 가득 차도록 설정
//            $0.top.equalTo(yearMonthLabel.snp.bottom).offset(5)
//            $0.bottom.equalToSuperview()
            $0.edges.equalToSuperview()
        }
        
        contentView.snp.makeConstraints {
            $0.edges.equalTo(scrollView) // 컨텐츠뷰도 스크롤뷰와 크기를 같도록 설정
            $0.width.equalTo(view) // 컨텐츠뷰의 너비를 뷰와 같도록 설정
            $0.height.equalTo(scrollView).priority(.low) // 컨텐츠뷰의 높이를 스크롤뷰와 같도록 설정, 우선순위를 낮춤
        }
        
        awardsView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(yearMonthLabel.snp.bottom).offset(20)
            $0.height.equalTo(310) // 이 부분은 awardsView의 높이 계산에 맞게 변경해야 함
        }

        recommendView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(awardsView.snp.bottom)
            $0.height.equalTo(130)
        }

        chartView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(recommendView.snp.bottom)
        }
    }
}
