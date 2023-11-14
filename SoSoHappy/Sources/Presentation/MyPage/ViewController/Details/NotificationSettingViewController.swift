//
//  NotificationSettingViewController.swift
//  SoSoHappy
//
//  Created by 박민주 on 10/31/23.
//

import UIKit
import RxSwift
import Then

class NotificationSettingViewController: UIViewController {

    // MARK: - Properties
    private let coordinator: MyPageCoordinatorProtocol?
    var disposeBag = DisposeBag()
    
    lazy var alarmLabel = UILabel().then {
        $0.text = "리마인더 알림 설정"
        $0.font = .systemFont(ofSize: 16)
        $0.textColor = .darkGray
    }
    lazy var alarmSwitch = UISwitch()
    lazy var timePicker = UIDatePicker().then {
        $0.datePickerMode = .time
        $0.isHidden = true
        $0.alpha = 0.0
    }
    
    // MARK: - Init
    public init(coordinator: MyPageCoordinatorProtocol) {
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        alarmSwitch.addTarget(self, action: #selector(switchStateChanged), for: .valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
        if let tabBarController = self.tabBarController as? TabBarController {
            tabBarController.addButton.isHidden = true
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
        if let tabBarController = self.tabBarController as? TabBarController {
            tabBarController.addButton.isHidden = false
        }
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
        view.addSubviews(alarmLabel, alarmSwitch, timePicker)
        
        alarmLabel.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide).inset(20)
            make.leading.equalToSuperview().inset(30)
        }
        
        alarmSwitch.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide).inset(15)
            make.trailing.equalToSuperview().inset(30)
        }
        
        timePicker.snp.makeConstraints { make in
            make.top.equalTo(alarmSwitch.snp.bottom).offset(15)
            make.leading.trailing.equalToSuperview().inset(30)
        }
    }
    
    @objc func switchStateChanged() {
        if alarmSwitch.isOn {
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                switch settings.authorizationStatus {
                case .authorized:
                    print("알림이 허용됨")
                    DispatchQueue.main.async {
                        self.timePicker.isHidden = false
                        UIView.animate(withDuration: 0.3) {
                            self.timePicker.alpha = 1.0
                        }
                    }
                case .denied:
                    print("알림이 거부됨")
                    DispatchQueue.main.async {
                        CustomAlert.presentCheckAlert(title: "알림 허용이 되어있지 않습니다.", message: "설정으로 이동하여 알림 허용을 하시겠습니까?", buttonTitle: "확인") {
                            guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
                            
                            if UIApplication.shared.canOpenURL(url) {
                                UIApplication.shared.open(url)
                            }
                        }
                        self.alarmSwitch.setOn(false, animated: false)
                    }
                case .notDetermined:
                    print("아직 알림 권한이 결정되지 않음")
                default:
                    break
                }
            }
        } else {
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.3) {
                    self.timePicker.alpha = 0.0
                } completion: { _ in
                    self.timePicker.isHidden = true
                }
            }
        }
    }
}
