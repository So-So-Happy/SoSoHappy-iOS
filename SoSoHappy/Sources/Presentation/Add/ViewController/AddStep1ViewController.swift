//
//  AddStep1ViewController.swift
//  SoSoHappy
//
//  Created by 박민주 on 2023/08/09.
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

final class AddStep1ViewController: UIViewController {
    // MARK: - Properties
    var disposeBag = DisposeBag()

    // MARK: - UI Components
    private lazy var statusBarStackView = StatusBarStackView(step: 1)
    
    private lazy var weatherLabel = UILabel().then {
        $0.text = "오늘의 날씨는 어땠나요?"
        $0.textColor = .darkGray
    }
    
    private lazy var weatherStackView = WeatherStackView()
    
    private lazy var happinessLabel = UILabel().then {
        $0.text = "OO님, 오늘 얼마나 행복하셨나요?"
        $0.textColor = .darkGray
    }
    
    private lazy var happinessStackView = HappinessStackView()

    private lazy var nextButton = NextButton()
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "BGgrayColor")
        setup()
    }
    
    init(reactor: AddViewReactor) {
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension AddStep1ViewController {
    private func setup() {
        setAttribute()
        addViews()
        setConstraints()
    }
    
    private func setAttribute() {
        view.backgroundColor = UIColor(named: "BGgrayColor")
    }
    
    private func addViews() {
        self.view.addSubview(statusBarStackView)
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
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(90)
        }
    }
}

// MARK: - ReactorKit - bind func
extension AddStep1ViewController: View {
    // MARK: bind
    func bind(reactor: AddViewReactor) {
        weatherStackView.weatherButtonTappedSubject
            .map { Reactor.Action.weatherButtonTapped($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        happinessStackView.happinessButtonTappedSubject
            .map { Reactor.Action.happinessButtonTapped($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.state
            .skip(1)
            .map { $0.selectedWeather }
            .subscribe(onNext: { [weak self] selectedWeather in
                guard let self = self else { return }
                weatherStackView.updateButtonAppearance(selectedWeather)
            })
            .disposed(by: disposeBag)
        
        reactor.state
            .skip(1)
            .map { $0.selectedHappiness }
            .subscribe(onNext: { [weak self] selectedHappiness in
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

