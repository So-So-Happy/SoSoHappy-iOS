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
    private weak var coordinator: HappyListCoordinatorInterface?

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
    }
    
    private lazy var nextButton = NextButton()
    
    private lazy var backButton = UIButton().then {
        $0.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        $0.setPreferredSymbolConfiguration(.init(scale: .large), forImageIn: .normal)
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        
        print("--------AddSTEP2---------")
        print("reactor.initialState.selectedWeather: \(reactor?.currentState.selectedWeather)")
        print("reactor.initialState.selectedHappiness : \(reactor?.currentState.selectedHappiness)")
        print("--------------------------")
    }
    
    init(reactor: AddViewReactor, coordinator: HappyListCoordinatorInterface) {
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
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
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
            make.top.equalTo(statusBarStackView.snp.bottom).offset(40)
        }
        
        categorySelectionCautionLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(categoryIntoLabel.snp.bottom).offset(6)
        }
        
        categoryCollectionView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(categorySelectionCautionLabel.snp.bottom).offset(30)
            make.horizontalEdges.equalToSuperview().inset(28)
            make.bottom.equalTo(nextButton.snp.top).inset(-40)// 여기 값 더 수정해줘야 함
        }
        
        nextButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(40)
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
// 이 사이즈를 좀 더 조정해주면 좋을 것 같음. 선택될 때 약간 짤린 듯한 느낌 남 (비행기)
extension SetCategoryViewController: UICollectionViewDelegateFlowLayout, UITableViewDelegate {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let numberOfColumns: CGFloat = 4
        let numberOfRows: CGFloat = 6
        let spacingBetweenItems: CGFloat = 10
        let totalHorizontalSpacing = (numberOfColumns - 1) * spacingBetweenItems
        let totalVerticalSpacing = (numberOfRows - 1) * spacingBetweenItems
        
        let width = (collectionView.bounds.width - totalHorizontalSpacing) / numberOfColumns
        let height = (collectionView.bounds.height - totalVerticalSpacing) / numberOfRows
        
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10 // Adjust the spacing between rows as needed
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10 // Adjust the spacing between columns as needed
    }
}

// MARK: - ReactorKit - bind func
extension SetCategoryViewController: View {
    // MARK: bind
    func bind(reactor: AddViewReactor) {
        categoryCollectionView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        Observable.of(reactor.categories)
            .bind(to: categoryCollectionView.rx.items(cellIdentifier: CategoryCell.cellIdentifier, cellType: CategoryCell.self)) { index, category, cell in
//                print("1")
                cell.setImage(category: category)
            }
            .disposed(by: disposeBag)
        
        categoryCollectionView.rx.modelSelected(String.self)
            .map {
                print("model Selected")
                return Reactor.Action.selectCategory($0)
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        categoryCollectionView.rx.modelDeselected(String.self)
            .map {
                print("model Deselected")
                return Reactor.Action.deselectCategory($0)
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        nextButton.rx.tap
            .map { Reactor.Action.tapNextButton(.step2) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        nextButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                print("AddStep2 - move to step3")
//                coordinator?.showNextAdd(reactor: reactor, navigateTo: .addstep3)
            })
            .disposed(by: disposeBag)
        
        backButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                print("AddStep2 - navigate Back")
//                coordinator?.navigateBack()
            })
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.selectedCategories.count > 0 }
            .distinctUntilChanged()
            .bind(to: nextButton.rx.isEnabled)
            .disposed(by: disposeBag)
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

}



