//
//  SetWeatherHappinessViewController.swift
//  SoSoHappy
//
//  Created by 박희경 on 2023/12/06.
//

import UIKit
import SnapKit
import Then
import ReactorKit
import RxSwift
import RxCocoa



/*
리팩토링
1. weatherStackView, happinessStackView 버튼 크기가 좀 더 동일하면 좋을 것 같음 (선택)
2. 스택과 함께 각각 label도 넣어줘도 될 것 같음 (선택)
3. happinessLabel 의 oo 님에 UserDefaults에서 닉네임 꺼내서 넣어주면 됨 (필수)
 */

final class SetWeatherHappinessViewController: UIViewController {
    // MARK: - Properties
    var disposeBag = DisposeBag()
    private weak var coordinator: MyFeedDetailCoordinatorInterface?

    // MARK: - UI Components
    private lazy var statusBarStackView = StatusBarStackView(step: 1)
    
    private lazy var introLabel = UILabel().then {
        $0.text = "소소한 행복을 기록해주세요"
        $0.textColor = UIColor(named: "DarkGrayTextColor")
        $0.font = UIFont.customFont(size: 19, weight: .bold)
    }

    private lazy var introSubLabel = UILabel().then {
        $0.text = "하루 1개만 기록할 수 있어요!"
        $0.textColor = UIColor(named: "DarkGrayTextColor")
        $0.font = UIFont.customFont(size: 13, weight: .medium)
    }
    
    private lazy var weatherLabel = UILabel().then {
        $0.text = "오늘의 날씨는 어땠나요?"
        $0.textColor = UIColor(named: "DarkGrayTextColor")
        $0.font = UIFont.customFont(size: 16, weight: .medium)
    }
    
    private lazy var weatherStackView = WeatherStackView()
    
    private lazy var happinessLabel = UILabel().then {
        $0.text = "OO님, 오늘 얼마나 행복하셨나요?"
        $0.textColor = UIColor(named: "DarkGrayTextColor")
        $0.font = UIFont.customFont(size: 16, weight: .medium)
    }
    
    private lazy var happinessStackView = HappinessStackView()

    private lazy var nextButton = NextButton()
    
    private lazy var dismissButton = UIButton().then {
        $0.setImage(UIImage(systemName: "xmark"), for: .normal)
        $0.setPreferredSymbolConfiguration(.init(scale: .large), forImageIn: .normal)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    init(reactor: MyFeedDetailViewReactor, coordinator: MyFeedDetailCoordinatorInterface) {
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
        self.coordinator = coordinator
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - Add Subviews & Constraints
extension SetWeatherHappinessViewController {
    private func setup() {
        setAttribute()
        addViews()
        setConstraints()
    }
    
    private func setAttribute() {
        view.backgroundColor = UIColor(named: "BGgrayColor")
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: dismissButton)
    }
    
    private func addViews() {
        self.view.addSubview(statusBarStackView)
//        self.view.addSubview(introLabel)
//        self.view.addSubview(introSubLabel)
        self.view.addSubview(weatherLabel)
        self.view.addSubview(weatherStackView)
        self.view.addSubview(happinessLabel)
        self.view.addSubview(happinessStackView)
        self.view.addSubview(nextButton)
    }
    
    private func setConstraints() {
        statusBarStackView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(self.view.safeAreaLayoutGuide)
        }
        
//        introLabel.snp.makeConstraints { make in
//            make.centerX.equalToSuperview()
//            make.top.equalTo(statusBarStackView.snp.bottom).offset(40)
//        }
//
//        introSubLabel.snp.makeConstraints { make in
//            make.centerX.equalToSuperview()
//            make.top.equalTo(introLabel.snp.bottom).offset(6)
//        }
        
        weatherLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(statusBarStackView.snp.bottom).offset(120)
        }
        
        weatherStackView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(weatherLabel.snp.bottom).offset(16)
            make.horizontalEdges.equalToSuperview().inset(32)
        }
        
        happinessLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(weatherStackView.snp.bottom).offset(96)
        }
        
        happinessStackView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(happinessLabel.snp.bottom).offset(16)
            make.horizontalEdges.equalToSuperview().inset(32)
        }
        
        nextButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(40)
        }
    }
}

// MARK: - ReactorKit - bind func
extension SetWeatherHappinessViewController: View {
    // MARK: bind
    func bind(reactor: MyFeedDetailViewReactor) {
        weatherStackView.weatherButtonTappedSubject
            .map { Reactor.Action.weatherButtonTapped($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        happinessStackView.happinessButtonTappedSubject
            .map { Reactor.Action.happinessButtonTapped($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        nextButton.rx.tap
            .map { Reactor.Action.tapNextButton(.step1) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        nextButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                print("AddStep 1 - nextButton - subscribe")
                guard let self = self else { return }
//                coordinator?.showNextAdd(reactor: reactor, navigateTo: .addstep2)
            })
            .disposed(by: disposeBag)
        
        dismissButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                print("AddStep 1 - dismissButton - subscribe")
                guard let self = self else { return }
                coordinator?.dismiss()
            })
            .disposed(by: disposeBag)
        
        reactor.state
            .skip(1)
            .map { $0.selectedWeather }
            .bind(onNext: { [weak self] selectedWeather in
                guard let self = self else { return }
                weatherStackView.updateButtonAppearance(selectedWeather)
            })
            .disposed(by: disposeBag)
        
        reactor.state
            .skip(1)
            .map { $0.selectedHappiness }
            .bind(onNext: { [weak self] selectedHappiness in
                guard let self = self else { return }
                happinessStackView.updateButtonAppearance(selectedHappiness)
            })
            .disposed(by: disposeBag)
        
        // weather, happiness 둘 다 선택이 되어야 nextButton 활성화
        reactor.state
            .map { $0.selectedWeather != nil && $0.selectedHappiness != nil }
            .distinctUntilChanged()
            .bind(to: nextButton.rx.isEnabled)
            .disposed(by: disposeBag)
    }
}


