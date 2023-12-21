//
//  AddStep3ViewController.swift
//  SoSoHappy
//
//  Created by Sue on 10/16/23.
//

import UIKit
import SnapKit
import Then
import ReactorKit
import RxSwift
import RxCocoa
import PhotosUI
import RxKeyboard
import RxGesture

final class AddStep3ViewController: BaseDetailViewController {
    // MARK: - Properties
    private weak var coordinator: AddCoordinatorInterface?
    private var tapSave: Bool = false
    private var selection = [String: PHPickerResult]()
    private var selectedAssetIdentifiers = [String]()
    
    // MARK: - UI Components
    private lazy var statusBarStackView = StatusBarStackView(step: 3)
    
    private lazy var saveButton = UIBarButtonItem(title: "저장", style: .plain, target: self, action: nil).then {
        $0.setTitleTextAttributes([.font: UIFont.customFont(size: 16, weight: .bold)], for: .disabled)
        $0.setTitleTextAttributes([.font: UIFont.customFont(size: 16, weight: .bold)], for: .selected)
    }
    
    private lazy var addKeyboardToolBar = AddKeyboardToolBar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 35))
    
    private lazy var backButton = UIButton().then {
        $0.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        $0.setPreferredSymbolConfiguration(.init(scale: .large), forImageIn: .normal)
    }
    
    private lazy var removeImageButton = UIButton().then {
        $0.setImage(UIImage(systemName: "xmark"), for: .normal)
        $0.setPreferredSymbolConfiguration(.init(scale: .medium), forImageIn: .normal)
        $0.tintColor = .white
        $0.isHidden = true
        $0.layer.cornerRadius = 12
        $0.backgroundColor = .systemGray
        $0.layer.shadowColor = UIColor.black.cgColor
        $0.layer.shadowOpacity = 0.3
        $0.layer.shadowRadius = 3
    }
    
    lazy var textCountLabel = UILabel().then {
        $0.font = UIFont.customFont(size: 13, weight: .light)
        $0.textColor = .lightGray
        $0.textAlignment = .right
    }
    
    private lazy var placeholderLabel = UILabel().then {
        $0.font = UIFont.customFont(size: 16, weight: .medium)
        $0.textColor = .lightGray
        $0.textAlignment = .left
        $0.text = "소소한 행복을 기록해보세요~"
    }
    
    private lazy var saveSpinner = UIActivityIndicatorView().then {
        $0.hidesWhenStopped = true
        $0.color = .black
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
// MARK: - set up
extension AddStep3ViewController {
    private func setup() {
        setAttributes()
        setLayoutForAddStep3()
    }
    
    private func setAttributes() {
        textView.isUserInteractionEnabled = true
        textView.inputAccessoryView = addKeyboardToolBar
        self.navigationItem.rightBarButtonItem = saveButton
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
        
        let swipeGestureRecognizerRight = UISwipeGestureRecognizer(target: self, action: #selector(didSwipe(_:)))
        swipeGestureRecognizerRight.direction = .right
        view.addGestureRecognizer(swipeGestureRecognizerRight)
    }
    
    private func setLayoutForAddStep3() {
        self.contentView.addSubview(statusBarStackView)
        self.contentView.addSubview(textCountLabel)
        textView.addSubview(placeholderLabel)
        imageSlideView.addSubviews(removeImageButton)
        
        statusBarStackView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(self.view.safeAreaLayoutGuide)
        }
        
        categoryStackView.snp.updateConstraints { make in
            make.top.equalToSuperview().offset(70)
        }
        
        // 이미지 설정
        imageSlideView.snp.updateConstraints { make in
            make.top.equalTo(contentBackground.snp.bottom).offset(36)
        }
        
        // 글자 수
        textCountLabel.snp.makeConstraints { make in
            make.top.equalTo(contentBackground.snp.bottom).offset(10)
            make.right.equalTo(contentBackground).inset(5)
        }
        
        // 선택한 이미지 제거 버튼
        removeImageButton.snp.makeConstraints { make in
            make.left.top.equalToSuperview().inset(14)
            make.size.equalTo(24)
        }
        // imageSlideView
        imageSlideView.snp.makeConstraints { make in
            make.height.equalTo(0)
        }
        
        // placeholder
        placeholderLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(5)
            make.top.equalToSuperview().inset(8)
        }
    }
}

// MARK: - bind func
extension AddStep3ViewController: View {
    func bind(reactor: AddViewReactor) {
        // MARK: AddStep3 올 때마다 viewDidLoad 호출
        self.rx.viewDidLoad
            .map { Reactor.Action.fetchDatasForAdd3 }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        textView.rx.text.orEmpty
            .skip(1)
            .map { Reactor.Action.setContent($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        self.view.rx.tapGesture().when(.recognized)
            .subscribe { [weak self] _ in
                guard let self = self else { return }
                checkIsTextViewFirstResponder()
            }
            .disposed(by: disposeBag)

        textView.rx.text.orEmpty
            .map { !$0.isEmpty }
            .distinctUntilChanged()
            .bind(to: placeholderLabel.rx.isHidden)
            .disposed(by: disposeBag)

        RxKeyboard.instance.visibleHeight
            .drive(onNext: { [weak self] keyboardVisibleHeight in
                guard let self = self else { return }
                if keyboardVisibleHeight > 0 {
                    scrollView.contentInset.bottom = keyboardVisibleHeight + 15
                } else {
                    scrollView.contentInset.bottom = .zero
                }
            })
            .disposed(by: disposeBag)

        addKeyboardToolBar.photoBarButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                checkIsTextViewFirstResponder()
                setAndPresentPicker()
            })
            .disposed(by: disposeBag)
        
        addKeyboardToolBar.lockBarButton.rx.tap
            .map { Reactor.Action.tapLockButton }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        addKeyboardToolBar.keyboardDownBarButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                checkIsTextViewFirstResponder()
            })
            .disposed(by: disposeBag)
        
        saveButton.rx.tap
            .throttle(.seconds(2), latest: false, scheduler: MainScheduler.instance)
            .map { [weak self] _ in
                self?.checkIsTextViewFirstResponder()
                self?.tapSave = true
                return Reactor.Action.tapSaveButton
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        backButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                coordinator?.navigateBack()
            })
            .disposed(by: disposeBag)
        
        removeImageButton.rx.tap
            .map {
                self.selectedAssetIdentifiers = []
                self.selection = [:]
                return Reactor.Action.setSelectedImages([])
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.state
            .compactMap { $0.happyAndCategory }
            .distinctUntilChanged()
            .bind { [weak self] happyAndCategory in
                guard let self = self else { return }
                categoryStackView.addImageViews(images: happyAndCategory, imageSize: 55)
            }
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.dateString }
            .distinctUntilChanged()
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
            .map { $0.content }
            .bind(to: self.textView.rx.text)
            .disposed(by: disposeBag)

        reactor.state
            .map { "(\($0.content.count) / 3000)" }
            .distinctUntilChanged()
            .bind(to: self.textCountLabel.rx.text)
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.isPublic }
            .distinctUntilChanged()
            .bind { [weak self] isPublic in
                guard let self = self else { return }
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
                setImageSlideView(imageList: images)
                removeImageButton.isHidden = images.isEmpty ? true : false
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
                } else { // 로딩 완료 - 저장 버튼
                    navigationItem.rightBarButtonItem = saveButton
                    saveSpinner.stopAnimating()
                }
                
                saveButton.isEnabled = !isSaveLoading
            })
            .disposed(by: disposeBag)
        
        reactor.state
            .compactMap { self.tapSave ? $0.isSaveFeedSuccess : nil }
            .subscribe(onNext: { [weak self] save in
                guard let self = self else { return }
                showToast(save.rawValue, withDuration: 2.0, delay: 0.8)
                tapSave = false
                
                if save == .saved {
                    Observable<Void>
                        .just(())
                        .delay(.milliseconds(3100), scheduler: MainScheduler.instance)
                        .subscribe(onNext: { [weak self] _ in
                            self?.coordinator?.dismiss()
                        })
                        .disposed(by: disposeBag)
                }
            })
            .disposed(by: disposeBag)
        
        reactor.state
            .compactMap { $0.showServerErrorAlert }
            .distinctUntilChanged()
            .bind(onNext: {[weak self]  showServerErrorAlert in
                guard let self = self else { return }
                if showServerErrorAlert {
                    let alert = CustomAlert.makeAlertController()
                    self.present(alert, animated: true)
                }
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - PHPickerViewControllerDelegate & picker preseent
// 권한 요청이 필요없음
// iOS 14이상부터 지원 가능
extension AddStep3ViewController: PHPickerViewControllerDelegate {
    private func setAndPresentPicker() {
        // configuation - 설정
        var configuation = PHPickerConfiguration(photoLibrary: .shared())
        configuation.selectionLimit = 2
        configuation.filter = .images
        configuation.selection = .ordered
        configuation.preferredAssetRepresentationMode = .current
        configuation.preselectedAssetIdentifiers = selectedAssetIdentifiers
        let picker = PHPickerViewController(configuration: configuation)
        picker.delegate = self
        self.present(picker, animated: true, completion: nil)
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        let existingSelection = self.selection
        var newSelection = [String: PHPickerResult]()
        let newSelectedAssetIdentifiers: [String] = results.map(\.assetIdentifier!)
        
        if selectedAssetIdentifiers == newSelectedAssetIdentifiers {
            return
        }
        
        for result in results {
            let identifier = result.assetIdentifier!
            newSelection[identifier] = existingSelection[identifier] ?? result
        }
        
        selection = newSelection
        selectedAssetIdentifiers = newSelectedAssetIdentifiers
        
        if selection.isEmpty {
            self.reactor?.action.onNext(.setSelectedImages([]))
        } else {
            loadAndAppendImages()
            
        }
    }

    private func loadAndAppendImages() {
        var selectedImages: [UIImage] = []
        let dispatchGroup = DispatchGroup()
        var imagesDict = [String: UIImage]()
        
        for assetIdentifier in selectedAssetIdentifiers {
            dispatchGroup.enter()
            
            let itemProvider = selection[assetIdentifier]!.itemProvider
    
            if itemProvider.canLoadObject(ofClass: UIImage.self) {
                itemProvider.loadObject(ofClass: UIImage.self) { image, error in
                    if let image = image as? UIImage {
                        imagesDict[assetIdentifier] = image
                    }
                    dispatchGroup.leave()
                }
            }
        }
        
        dispatchGroup.notify(queue: DispatchQueue.main) { [weak self] in
            guard let self = self else { return }
            for identifier in self.selectedAssetIdentifiers {
                if let image = imagesDict[identifier] {
                    selectedImages.append(image)
                }
            }
            
            reactor?.action.onNext(.setSelectedImages(selectedImages))
        }
    }
    
    private func checkIsTextViewFirstResponder() {
        if textView.isFirstResponder {
            textView.resignFirstResponder()
        }
    }
    
    @objc private func didSwipe(_ sender: UISwipeGestureRecognizer) {
        coordinator?.navigateBack()
    }
}
