//
//  SetCategoryViewController.swift
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

// MARK: 그때 24개로 하기로 해서 카테고리 중에서 1개 빼야할 것 같음
final class SetCategoryViewController: UIViewController, UIScrollViewDelegate {
    // MARK: - Properties
    var disposeBag = DisposeBag()
    private weak var coordinator: MyFeedDetailCoordinatorInterface?

    // MARK: - UI Components
    private lazy var categoryIntoLabel = UILabel().then {
        $0.text = "당신을 행복하게 해준 것은?"
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
    
    private lazy var saveButton = UIButton().then {
        $0.setTitle("저장", for: .normal)
        $0.titleLabel?.font = UIFont.customFont(size: 16, weight: .bold)
        $0.setTitleColor(UIColor(named: "AccentColor"), for: .normal)
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
extension SetCategoryViewController {
    private func setup() {
        setAttribute()
        addViews()
        setConstraints()
    }
    
    private func setAttribute() {
        view.backgroundColor = UIColor(named: "BGgrayColor")
    }
    
    private func addViews() {
        self.view.addSubview(categoryIntoLabel)
        self.view.addSubview(categorySelectionCautionLabel)
        self.view.addSubview(categoryCollectionView)
        self.view.addSubview(saveButton)
    }
    
    private func setConstraints() {
        
        categoryIntoLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(80)
        }
        
        categorySelectionCautionLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(categoryIntoLabel.snp.bottom).offset(6)
        }
        
        categoryCollectionView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(categorySelectionCautionLabel.snp.bottom).offset(30)
            make.horizontalEdges.equalToSuperview().inset(28)
            make.bottom.equalToSuperview().inset(40)
        }
        
        saveButton.snp.makeConstraints {
            $0.width.height.equalTo(50)
            $0.top.equalToSuperview().inset(12)
            $0.trailing.equalToSuperview().inset(12)
        }
        
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
// 이 사이즈를 좀 더 조정해주면 좋을 것 같음. 선택될 때 약간 짤린 듯한 느낌 남 (비행기)
extension SetCategoryViewController: UICollectionViewDelegateFlowLayout, UITableViewDelegate {
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
extension SetCategoryViewController: View {
    // MARK: bind
    func bind(reactor: MyFeedDetailViewReactor) {
        categoryCollectionView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        self.rx.viewWillAppear
            .map { Reactor.Action.setCategories }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        Observable.of(reactor.categories)
            .bind(to: categoryCollectionView.rx.items(cellIdentifier: CategoryCell.cellIdentifier, cellType: CategoryCell.self)) { index, category, cell in
                cell.setImage(category: category)
                if reactor.currentState.selectedCategories.contains(category) {
                    self.categoryCollectionView.selectItem(at: IndexPath(item: index, section: 0), animated: false, scrollPosition: [])
                }
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
        
        saveButton.rx.tap
            .subscribe { [weak self] _ in
                guard let self = self else { return }
                coordinator?.dismiss()
            }.disposed(by: disposeBag)
        
    }
}

// MARK: - CollectionView의 cell 선택에 Limit 설정
extension SetCategoryViewController {
    // cell을 선택할 때마다 호출 (deselect일 때는 호출되지 않음)
    // didSelectItemAt 이전에 동작함
    // cell의 isSelected를 true/false로 만드는 것을 결정
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        print("activated ")
        
        if let indexPathsForSelectedItems = collectionView.indexPathsForSelectedItems, let reactor = reactor {
            print("activated 1 : \(indexPathsForSelectedItems.count < reactor.maximumSelectionCount)")
            print("~~~")
            return indexPathsForSelectedItems.count < reactor.maximumSelectionCount
        }
        print("activated2 - true")
        print("~~~")
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {

        if let indexPathsForSelectedItems = collectionView.indexPathsForSelectedItems, let reactor = reactor {
            return indexPathsForSelectedItems.count > reactor.minimumSelectionCount
        }
        
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? CategoryCell else {
            return
        }

        cell.isSelected = true
    }

}
