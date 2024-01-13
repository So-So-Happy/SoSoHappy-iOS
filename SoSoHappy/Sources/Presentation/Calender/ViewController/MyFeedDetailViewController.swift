//
//  MyFeedDetailViewController.swift
//  SoSoHappy
//
//  Created by 박희경 on 2023/11/04.
//

import UIKit
import SnapKit
import Then
import ReactorKit
import RxSwift
import RxCocoa
import PhotosUI
import RxKeyboard
import Kingfisher

final class MyFeedDetailViewController: BaseDetailViewController {
    
    // MARK: - Properties
    private weak var coordinator: MyFeedDetailCoordinatorInterface?
    var tapSave: Bool = false
    private var selection = [String: PHPickerResult]()
    private var selectedAssetIdentifiers = [String]()
    
    private var feed: MyFeed?
    private var selectedImages: [UIImage] = []
    
    // MARK: - UI Components
    private lazy var saveButton = UIBarButtonItem(title: "저장", style: .plain, target: self, action: nil).then {
        $0.setTitleTextAttributes([.font: UIFont.customFont(size: 16, weight: .bold)], for: .normal)
        $0.setTitleTextAttributes([.font: UIFont.customFont(size: 16, weight: .bold)], for: .disabled)
        $0.setTitleTextAttributes([.font: UIFont.customFont(size: 16, weight: .bold)], for: .selected)
    }
    
    private lazy var saveSpinner = UIActivityIndicatorView().then {
        $0.hidesWhenStopped = true
        $0.color = .black
    }
    
    private lazy var addKeyboardToolBar = AddKeyboardToolBarForCalender(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 35))

    private lazy var backButton = UIButton().then {
        $0.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        $0.setPreferredSymbolConfiguration(.init(scale: .large), forImageIn: .normal)
    }
    
    lazy var textCountLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 13)
        $0.textColor = .lightGray
        $0.textAlignment = .right
    }
    
    private lazy var placeholderLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 16)
        $0.textColor = .lightGray
        $0.textAlignment = .left
           $0.text = "소소한 행복을 기록해보세요~"
       }
    
    private let happyTapGesture = UITapGestureRecognizer()
    private let categoryTapGesture1 = UITapGestureRecognizer()
    private let categoryTapGesture2 = UITapGestureRecognizer()
    private let categoryTapGesture3 = UITapGestureRecognizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    init(reactor: MyFeedDetailViewReactor,
         coordinator: MyFeedDetailCoordinatorInterface,
         feed: MyFeed
    ) {
        super.init(nibName: nil, bundle: nil)
        self.reactor = MyFeedDetailViewReactor(feedRepository: FeedRepository() )
        self.coordinator = coordinator
        self.feed = feed
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - set up
extension MyFeedDetailViewController {
    
    private func setup() {
        setAttributes()
        setLayoutForAddStep3()
        addSwipeGesture()
    }
    
    private func setAttributes() {
        textView.isUserInteractionEnabled = true
        textView.inputAccessoryView = addKeyboardToolBar
        self.navigationItem.rightBarButtonItem = saveButton
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
    }
    
    private func setLayoutForAddStep3() {
        self.contentView.addSubview(textCountLabel)
        textView.addSubview(placeholderLabel)
        
        categoryStackView.snp.updateConstraints { make in
            make.top.equalToSuperview().offset(50)
        }
        
        imageSlideView.snp.makeConstraints { make in
            make.height.equalTo(0)
        }
        
        imageSlideView.snp.updateConstraints { make in
            make.top.equalTo(contentBackground.snp.bottom).offset(36)
        }

        textCountLabel.snp.makeConstraints { make in
            make.top.equalTo(contentBackground.snp.bottom).offset(10)
            make.right.equalTo(contentBackground).inset(5)
        }
         
        placeholderLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(5)
            make.top.equalToSuperview().offset(10)
        }
    }
    
    private func addSwipeGesture() {
        let swipeGestureRecognizerRight = UISwipeGestureRecognizer(target: self, action: #selector(didSwipe(_:)))
        swipeGestureRecognizerRight.direction = .right
        view.addGestureRecognizer(swipeGestureRecognizerRight)
    }
}

// MARK: - bind func
extension MyFeedDetailViewController: View {
    
    func bind(reactor: MyFeedDetailViewReactor) {
        bindAction(reactor)
        bindState(reactor)
        setGestureRecognizer()
    }
    
    func bindAction(_ reactor: MyFeedDetailViewReactor) {
        
        self.rx.viewWillAppear
            .map { Reactor.Action.viewWillAppear(self.feed ?? MyFeed()) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        textView.rx.text.orEmpty
            .skip(1)
            .map {
                return Reactor.Action.setContent($0)
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        self.view.rx.tapGesture().when(.recognized)
            .subscribe { [weak self] _ in
                guard let self = self else { return }
                if textView.isFirstResponder {
                    textView.resignFirstResponder()
                }
            }
            .disposed(by: disposeBag)

        textView.rx.text.orEmpty
            .map { !$0.isEmpty }
            .distinctUntilChanged()
            .bind(to: placeholderLabel.rx.isHidden)
            .disposed(by: disposeBag)
       
        RxKeyboard.instance.visibleHeight
            .drive(onNext: { [scrollView] keyboardVisibleHeight in
                if keyboardVisibleHeight > 0 {
                    scrollView.contentInset.bottom = keyboardVisibleHeight + 15
                } else {
                    scrollView.contentInset.bottom = .zero
                }
            })
            .disposed(by: disposeBag)
        
        addKeyboardToolBar.lockBarButton.rx.tap
            .map { Reactor.Action.tapLockButton }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        addKeyboardToolBar.keyboardDownBarButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.view.endEditing(true)
            })
            .disposed(by: disposeBag)
        
        saveButton.rx.tap
            .map {
                self.view.endEditing(true)
                self.tapSave = true
                return Reactor.Action.tapSaveButton
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
          
        backButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                coordinator?.finished()
            })
            .disposed(by: disposeBag)
          
    }
    
    func bindState(_ reactor: MyFeedDetailViewReactor) {
        
        reactor.state
            .compactMap { $0.happyAndCategory }
            .distinctUntilChanged()
            .bind { [weak self] happyAndCategory in
                guard let self = self else { return }
                categoryStackView.addImageViews(images: happyAndCategory, imageSize: 55)
                categoryStackView.layoutIfNeeded()
                self.setGestureRecognizer()
            }
            .disposed(by: disposeBag)
        
        happyTapGesture.rx.event
            .subscribe { [weak self] _ in
                guard let self = self else { return }
                self.coordinator?.showAdd1Modal(reactor: reactor)
            }
            .disposed(by: disposeBag)
        
        categoryTapGesture1.rx.event
            .subscribe { [weak self] _ in
                guard let self = self else { return }
                self.coordinator?.showAdd2Modal(reactor: reactor)
            }
            .disposed(by: disposeBag)
        
        categoryTapGesture2.rx.event
            .subscribe { [weak self] _ in
                guard let self = self else { return }
                self.coordinator?.showAdd2Modal(reactor: reactor)
            }
            .disposed(by: disposeBag)
        
        categoryTapGesture3.rx.event
            .subscribe { [weak self] _ in
                guard let self = self else { return }
                self.coordinator?.showAdd2Modal(reactor: reactor)
            }
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.dateString }
//            .distinctUntilChanged()
            .bind(to: self.dateLabel.rx.text)
            .disposed(by: disposeBag)
        
        reactor.state
            .compactMap { $0.weatherString }
            .distinctUntilChanged()
            .bind { [weak self] weather in
                guard let self = self else { return }
                let imageName = weather + "Bg"
                let image = UIImage(named: imageName)!
                
                let color = UIColor(patternImage: image)
                scrollView.backgroundColor = color
            }
            .disposed(by: disposeBag)
        
        reactor.state
            .map {
                return $0.content
            }
            .bind(to: self.textView.rx.text)
            .disposed(by: disposeBag)
        
        reactor.state
            .map { "(\($0.content.count) / 3000)" }
            .distinctUntilChanged()
            .bind(to: self.textCountLabel.rx.text)
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.isPrivate }
            .distinctUntilChanged()
            .bind { [weak self] isPublic in
                guard let self = self else { return }
                setLockImageVIew(isPublic: isPublic)
                addKeyboardToolBar.setPublicTo(isPublic)
            }
            .disposed(by: disposeBag)

        reactor.state
            .map { !$0.content.isEmpty }
            .distinctUntilChanged()
            .bind(to: self.saveButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        reactor.state
            .compactMap { $0.selectedImages }
            .distinctUntilChanged()
            .bind(onNext: { [weak self] images in
                guard let self = self else { return }
                setImageSlideView(imageList: images )
            })
            .disposed(by: disposeBag)
        
        reactor.state
            .compactMap{ $0.isSaveLoading }
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] isSaveLoading in
                guard let self = self else { return }
                if isSaveLoading {
                    navigationItem.rightBarButtonItem = UIBarButtonItem(customView: saveSpinner)
                    saveSpinner.startAnimating()
                } else {
                    navigationItem.rightBarButtonItem = saveButton
                    saveSpinner.stopAnimating()
                }
                
                saveButton.isEnabled = !isSaveLoading
            })
            .disposed(by: disposeBag)
        
        reactor.state
            .compactMap { self.tapSave ? $0.isSaveFeedSuccess : nil }
            .subscribe(onNext: { [weak self] save in
                self?.showToast(save.rawValue, withDuration: 2.0, delay: 0.8)
                self?.tapSave = false
                
                if save == .saved {
                    Observable<Void>
                        .just(())
                        .delay(.milliseconds(3100), scheduler: MainScheduler.instance)
                        .subscribe(onNext: { [weak self] _ in
                            self?.coordinator?.finished()
                        })
                        .disposed(by: self?.disposeBag ?? DisposeBag())
                }
            })
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
    
    func setGestureRecognizer() {
        let tapGestureArray = [categoryTapGesture1, categoryTapGesture2, categoryTapGesture3]
        
        for (index, subview) in categoryStackView.stackView.arrangedSubviews.enumerated() {
            guard let imageView = subview as? UIImageView else { continue }
            
            imageView.isUserInteractionEnabled = true
            
            let tapGesture = (index == 0) ? happyTapGesture : tapGestureArray[index - 1]
            imageView.addGestureRecognizer(tapGesture)
        }
    }
    
    @objc private func didSwipe(_ sender: UISwipeGestureRecognizer) {
        coordinator?.finished()
    }
}
