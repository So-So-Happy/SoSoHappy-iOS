//
//  MyPageViewController.swift
//  SoSoHappy
//
//  Created by 박민주 on 2023/08/07.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import ReactorKit
import MessageUI

final class MyPageViewController: UIViewController {
    // MARK: - Properties
    private let coordinator: MyPageCoordinatorProtocol?
    let tabController = TabBarController()
    var disposeBag = DisposeBag()
    
    // MARK: - Init
    init(reactor: MypageViewReactor, coordinator: MyPageCoordinatorProtocol) {
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Components
    private lazy var profileView = ProfileView()
    private lazy var stackView = SettingStackView()
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        bindEvent()
    }
}

// MARK: - Reactor (bind func)
extension MyPageViewController: View {
    func bind(reactor: MypageViewReactor) {
        bindActions(reactor)
        bindState(reactor)
    }
    
    private func bindActions(_ reactor: MypageViewReactor) {
        self.rx.viewWillAppear
            .map { Reactor.Action.viewWillAppear }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }

    private func bindState(_ reactor: MypageViewReactor) {
        reactor.state.compactMap { $0.profile }
            .subscribe(onNext: { [weak self] image in
                guard let self = self else { return }
                profileView.profileImage.profileImageWithBackgroundView.profileImageView.image = image
            })
            .disposed(by: disposeBag)
        
        reactor.state.compactMap { $0.intro }
            .subscribe(onNext: { [weak self] intro in
                guard let self = self else { return }
                profileView.introLabel.text = intro
            })
            .disposed(by: disposeBag)
        
        reactor.state.compactMap { $0.email }
            .subscribe(onNext: { [weak self] text in
                guard let self = self else { return }
                profileView.emailLabel.text = text
            })
            .disposed(by: disposeBag)
        
        reactor.state.compactMap { $0.nickName }
            .subscribe(onNext: { [weak self] text in
                guard let self = self else { return }
                profileView.nickNameLabel.text = text
            })
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.isProfileLoading }
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] shouldRun in
                guard let self = self else { return }
                profileView.skeletonNicknameView.isHidden = shouldRun ? false : true
                profileView.skeletonEmailView.isHidden = shouldRun ? false : true
                profileView.skeletonIntroView.isHidden = shouldRun ? false : true
                
                if shouldRun {
                    profileView.introLabel.text = " "
                    profileView.emailLabel.text = " "
                    profileView.nickNameLabel.text = " "
                }
            })
            .disposed(by: disposeBag)
    }
}

//MARK: - Set Navigation & Add Subviews & Constraints
extension MyPageViewController {
    private func setup() {
        setLayout()
    }
    
    private func setLayout() {
        view.addSubviews(profileView, stackView)
        view.backgroundColor = UIColor(named: "BGgrayColor")
        
        profileView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.centerX.equalToSuperview()
            $0.horizontalEdges.equalToSuperview().inset(25)
        }
        
        stackView.snp.makeConstraints {
            $0.top.equalTo(profileView.snp.bottom).offset(50)
            $0.centerX.equalToSuperview()
            $0.horizontalEdges.equalToSuperview().inset(25)
        }
    }
}

// MARK: - Set RxSwift without Reactor
extension MyPageViewController {
    func bindEvent() {
        self.profileView.profileImage.editButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.coordinator?.pushProfileEditView()
            })
            .disposed(by: disposeBag)
        
        self.stackView.alarmCell.rx.tapGesture()
            .when(.recognized)
            .subscribe(onNext: { _ in
                self.coordinator?.pushNotificationView()
            })
            .disposed(by: disposeBag)
        
        self.stackView.termsCell.rx.tapGesture()
            .when(.recognized)
            .subscribe(onNext: { _ in
                self.coordinator?.pushToSView()
            })
            .disposed(by: disposeBag)
        
        self.stackView.policyCell.rx.tapGesture()
            .when(.recognized)
            .subscribe(onNext: { _ in
                self.coordinator?.pushPrivatePolicyView()
            })
            .disposed(by: disposeBag)
        
        self.stackView.inquiryCell.rx.tapGesture()
            .when(.recognized)
            .subscribe(onNext: { _ in
                self.isTappedInquiry()
            })
            .disposed(by: disposeBag)
        
        self.stackView.accountCell.rx.tapGesture()
            .when(.recognized)
            .subscribe(onNext: { _ in
                self.coordinator?.pushAccountManagementView()
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - Message UI
extension MyPageViewController: MFMailComposeViewControllerDelegate {
    public func mailComposeController(_ controller: MFMailComposeViewController,
                                      didFinishWith result: MFMailComposeResult,
                                      error: Error?) {
        controller.dismiss(animated: true)
    }
    
    private func makeMailViewController() -> MFMailComposeViewController {
        let mailVC = MFMailComposeViewController()
        mailVC.mailComposeDelegate = self
        mailVC.setToRecipients(["sosohappy0206@gmail.com"])
        mailVC.setSubject("소소해피 문의하기")
        mailVC.setMessageBody(Bundle.main.inquiryMessage, isHTML: false)
        
        return mailVC
    }

    private func isTappedInquiry() {
        if MFMailComposeViewController.canSendMail() {
            let mailVC = makeMailViewController()
            self.present(mailVC, animated: true, completion: nil)
        } else {
            CustomAlert.presentCheckAlert(title: "메일 전송에 실패했어요.", message: "아이폰 이메일 설정 확인 후, 다시 시도해주세요.")
        }
    }
}
