//
//  NotificationSettingViewController.swift
//  SoSoHappy
//
//  Created by 박민주 on 10/31/23.
//

import UIKit
import RxSwift
import Then
import ReactorKit

class NotificationSettingViewController: UIViewController {

    // MARK: - Properties
    private let coordinator: MyPageCoordinatorProtocol?
    var disposeBag = DisposeBag()
    
    // MARK: - Init
    public init(reactor: NotificationSettingViewReactor, coordinator: MyPageCoordinatorProtocol) {
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Components
    lazy var alarmLabel = UILabel().then {
        $0.text = "알림 설정"
        $0.font = UIFont.customFont(size: 16, weight: .medium)
        $0.textColor = UIColor(named: "DarkGrayTextColor")
    }
    lazy var alarmSwitch = UISwitch()
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
}

// MARK: - Reactor (bind func)
extension NotificationSettingViewController: View {
    // MARK: Reactor를 설정하는 메서드
    func bind(reactor: NotificationSettingViewReactor) {
        bindActions(reactor)
        bindState(reactor)
    }
    
    // MARK: bind actions
    private func bindActions(_ reactor: NotificationSettingViewReactor) {
        self.rx.viewWillAppear
            .map { Reactor.Action.viewWillAppear }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        alarmSwitch.rx.controlEvent(.valueChanged)
            .withLatestFrom(alarmSwitch.rx.value)
            .map { isOn in Reactor.Action.tapSwitch(isOn) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    // MARK: bind state (Reactor의 상태를 바탕으로 로딩 상태 및 다른 UI 업데이트)
    private func bindState(_ reactor: NotificationSettingViewReactor) {
        reactor.state.compactMap { $0.firstSwitch }
            .subscribe(onNext: { [weak self] isOn in
                guard let self = self else { return }

                self.alarmSwitch.setOn(isOn, animated: false)
            })
            .disposed(by: disposeBag)
                
        reactor.state.compactMap { $0.onSwitch }
            .subscribe(onNext: { [weak self] isOn in
                guard let self = self else { return }
                
                if isOn {
                    UNUserNotificationCenter.current().getNotificationSettings { settings in
                        switch settings.authorizationStatus {
                        case .authorized:
                            DispatchQueue.main.async {
                                UserDefaults.standard.setValue(true, forKey: "notificationSetting")
                                self.alarmSwitch.setOn(true, animated: false)
                            }
                        case .denied:
                            DispatchQueue.main.async {
                                CustomAlert.presentCheckAndCancelAlert(title: "알림 허용이 되어있지 않아요.", message: "설정으로 이동하여 알림 허용을 하시겠어요?", buttonTitle: "확인") {
                                    guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
                                    
                                    if UIApplication.shared.canOpenURL(url) {
                                        UIApplication.shared.open(url)
                                    }
                                }
                                self.alarmSwitch.setOn(false, animated: false)
                            }
                        default:
                            break
                        }
                    }
                } else {
                    UserDefaults.standard.setValue(false, forKey: "notificationSetting")
                    self.alarmSwitch.setOn(false, animated: false)
                }
            })
            .disposed(by: disposeBag)
    }
}

//MARK: - Add Subviews & Constraints
extension NotificationSettingViewController {
    private func setup() {
        setAttribute()
        setLayout()
    }
    
    private func setAttribute() {
        view.backgroundColor = UIColor(named: "BGgrayColor")
    }

    private func setLayout() {
        view.addSubviews(alarmLabel, alarmSwitch)
        
        alarmLabel.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide).inset(20)
            make.leading.equalToSuperview().inset(30)
        }
        
        alarmSwitch.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide).inset(15)
            make.trailing.equalToSuperview().inset(30)
        }
    }
}
