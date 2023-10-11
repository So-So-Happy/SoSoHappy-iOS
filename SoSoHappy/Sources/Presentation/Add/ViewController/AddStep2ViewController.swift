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

// 버그 있었는데 제대로 추적 못함 (시뮬에서 계속 눌러보면서 찾고 해결하기)

// MARK: 그때 24개로 하기로 해서 카테고리 중에서 1개 빼야할 것 같음
final class AddStep2ViewController: UIViewController, UIScrollViewDelegate {
    // MARK: - Properties
    var disposeBag = DisposeBag()
    
    
    // MARK: - UI Components
    private lazy var statusBarStackView = StatusBarStackView(step: 2)
    
    private lazy var categoryIntoLabel = UILabel().then {
        $0.text = "오늘 당신을 행복하게 해준 것은?"
        $0.textColor = .darkGray
    }
    
    private lazy var categorySelectionCautionLabel = UILabel().then {
        $0.text = "최대 3개까지 선택할 수 있어요!"
        $0.textColor = .darkGray
        $0.font = UIFont.systemFont(ofSize: 13)
    }
 
    private lazy var categoryCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout()).then {
        $0.register(CategoryCell.self, forCellWithReuseIdentifier: CategoryCell.cellIdentifier)
        $0.backgroundColor = .clear
        $0.allowsMultipleSelection = true
    }
    
    private lazy var nextButton = NextButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
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

//MARK: - Add Subviews & Constraints
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

// 이 사이즈를 좀 더 조정해주면 좋을 것 같음. 선택될 때 약간 짤린 듯한 느낌 남 (비행기)
extension AddStep2ViewController: UICollectionViewDelegateFlowLayout, UITableViewDelegate {
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
extension AddStep2ViewController: View {
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
        
        reactor.state
            .map { $0.selectedCategories.count > 0 }
            .distinctUntilChanged()
            .bind(to: nextButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        reactor.state
            .compactMap { $0.deselectCategoryItem }
            .bind(to: categoryCollectionView.rx.deselectItem)
            .disposed(by: disposeBag)
        
    }
}



