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

final class AddStep1ViewController: UIViewController {
    // MARK: - Properties
    var disposeBag = DisposeBag()
    private weak var coordinator: AddCoordinatorInterface?

    // MARK: - UI Components
    private lazy var statusBarStackView = StatusBarStackView(step: 1)

    private lazy var weatherLabel = UILabel().then {
        $0.text = "오늘의 날씨는 어땠나요?"
        $0.textColor = UIColor(named: "DarkGrayTextColor")
        $0.font = UIFont.customFont(size: 16, weight: .medium)
    }
    
    private lazy var weatherStackView = WeatherStackView()
    
    private lazy var happinessLabel = UILabel().then {
        let nickname = KeychainService.getNickName()
        $0.text = "\(nickname)님, 오늘 얼마나 행복하셨나요?"
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
    
    init(reactor: AddViewReactor, coordinator: AddCoordinatorInterface) {
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
        self.coordinator = coordinator
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Add Subviews & Constraints
extension AddStep1ViewController {
    private func setup() {
        setAttribute()
        addViews()
        setConstraints()
    }
    
    private func setAttribute() {
        view.backgroundColor = UIColor(named: "BGgrayColor")
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: dismissButton)
        
        let swipeGestureRecognizerDown = UISwipeGestureRecognizer(target: self, action: #selector(didSwipe(_:)))
        swipeGestureRecognizerDown.direction = .down
        view.addGestureRecognizer(swipeGestureRecognizerDown)
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
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(50)
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
        
        nextButton.rx.tap
            .map { Reactor.Action.tapNextButton(.step1) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        nextButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                coordinator?.showNextAdd(reactor: reactor, navigateTo: .addstep2)
            })
            .disposed(by: disposeBag)
        
        dismissButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
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
        
        reactor.state
            .map { $0.selectedWeather != nil && $0.selectedHappiness != nil }
            .distinctUntilChanged()
            .bind(to: nextButton.rx.isEnabled)
            .disposed(by: disposeBag)
    }
}

extension AddStep1ViewController {
    @objc private func didSwipe(_ sender: UISwipeGestureRecognizer) {
        coordinator?.dismiss()
    }
}
