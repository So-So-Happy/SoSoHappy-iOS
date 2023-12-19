//
//  AddStep2ViewController.swift
//  SoSoHappy
//
//  Created by Sue on 10/11/23.
//

import UIKit
import SnapKit
import Then
import ReactorKit
import RxSwift
import RxCocoa

final class AddStep2ViewController: UIViewController, UIScrollViewDelegate {
    // MARK: - Properties
    var disposeBag = DisposeBag()
    private weak var coordinator: AddCoordinatorInterface?

    // MARK: - UI Components
    private lazy var statusBarStackView = StatusBarStackView(step: 2)
    
    private lazy var categoryIntoLabel = UILabel().then {
        $0.text = "오늘 당신을 행복하게 해준 것은?"
        $0.textColor = UIColor(named: "DarkGrayTextColor")
        $0.font = UIFont.customFont(size: 16, weight: .medium)
    }
    
    private lazy var categorySelectionCautionLabel = UILabel().then {
        $0.text = "최대 3개까지 선택할 수 있어요!"
        $0.textColor = UIColor(named: "DarkGrayTextColor")
        $0.font = UIFont.customFont(size: 13, weight: .medium)
    }
 
    private lazy var categoryCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout()).then {
        $0.register(CategoryCell.self, forCellWithReuseIdentifier: CategoryCell.cellIdentifier)
        $0.backgroundColor = .clear
        $0.allowsMultipleSelection = true
        $0.showsVerticalScrollIndicator = false
    }
    
    private lazy var nextButton = NextButton()
    
//    private lazy var backButton = UIButton().then {
//        $0.setImage(UIImage(systemName: "chevron.left"), for: .normal)
//        $0.setPreferredSymbolConfiguration(.init(scale: .large), forImageIn: .normal)
//    }
    
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
extension AddStep2ViewController {
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
        self.view.addSubview(categoryIntoLabel)
        self.view.addSubview(categorySelectionCautionLabel)
        self.view.addSubview(categoryCollectionView)
        self.view.addSubview(nextButton)
    }
    
    private func setConstraints() {
        statusBarStackView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(self.view.safeAreaLayoutGuide)
        }
        
        categoryIntoLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(statusBarStackView.snp.bottom).offset(45)
        }
        
        categorySelectionCautionLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(categoryIntoLabel.snp.bottom).offset(6)
        }
        
        categoryCollectionView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(categorySelectionCautionLabel.snp.bottom).offset(20)
            make.horizontalEdges.equalToSuperview().inset(28)
            make.bottom.equalTo(nextButton.snp.top).inset(-45)
        }
        
        nextButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(50)
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension AddStep2ViewController: UICollectionViewDelegateFlowLayout, UITableViewDelegate {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width
        let numberOfItemsPerRow: CGFloat = 3
        let spacing: CGFloat = 30
        let availableWidth = width - spacing * (numberOfItemsPerRow + 1)
        let itemDimension = floor(availableWidth / numberOfItemsPerRow)
        
        return CGSize(width: itemDimension, height: itemDimension)
    }
    
    // 섹션에서 콘텐츠를 배치하는 데 사용되는 여백
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
    }
    
    // 그리드의 항목 줄 사이에 사용할 최소 간격
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    
    // 같은 행에 있는 항목 사이에 사용할 최소 간격
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
}

// MARK: - ReactorKit - bind func
extension AddStep2ViewController: View {
    // MARK: bind
    func bind(reactor: AddViewReactor) {
        categoryCollectionView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        Observable.of(reactor.categories)
            .bind(to: categoryCollectionView.rx.items(cellIdentifier: CategoryCell.cellIdentifier, cellType: CategoryCell.self)) { index, category, cell in
                cell.setImage(category: category)
            }
            .disposed(by: disposeBag)
        
        categoryCollectionView.rx.modelSelected(String.self)
            .map { Reactor.Action.selectCategory($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        categoryCollectionView.rx.modelDeselected(String.self)
            .map { Reactor.Action.deselectCategory($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        nextButton.rx.tap
            .map { Reactor.Action.tapNextButton(.step2) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        nextButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                coordinator?.showNextAdd(reactor: reactor, navigateTo: .addstep3)
            })
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.selectedCategories.count > 0 }
            .distinctUntilChanged()
            .bind(to: nextButton.rx.isEnabled)
            .disposed(by: disposeBag)
    }
}

// MARK: - CollectionView cell selecting count limit
extension AddStep2ViewController {
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        
        if let indexPathsForSelectedItems = collectionView.indexPathsForSelectedItems, let reactor = reactor {
            return indexPathsForSelectedItems.count < reactor.maximumSelectionCount
        }
        
        return true
    }
}
