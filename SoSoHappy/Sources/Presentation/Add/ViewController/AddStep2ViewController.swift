//
//  AddStep2ViewController.swift
//  SoSoHappy
//
//  Created by 박민주 on 2023/08/13.
//

import UIKit
import SnapKit

class AddStep2ViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    // MARK: - Properties
    let statusBarStack = UIStackView()
    let statusBarStep1 = UIView()
    let statusBarStep2 = UIView()
    let statusBarStep3 = UIView()
    
    let categoryLabel = UILabel()
    let infoLabel = UILabel()
    
    let categoryImages: [String] = ["home", "home", "home", "home", "home", "home", "home", "home", "home", "home", "home", "home", "home", "home", "home", "home", "home", "home", "home", "home", "home", "home", "home", "home"] // Add more images as needed
    
    let nextButton = UIButton()
    let arrowImage = UIImage(systemName: "arrow.right")?.withTintColor(.white, renderingMode: .alwaysOriginal)
    var arrowImageView = UIImageView()
    
    var selectedIndices: Set<Int> = Set() // Set to track selected indices
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "BGgrayColor")
        
        setUpValue()
        setUpView()
        setConstraints()
    }
    
    // MARK: - 요소 내용 설정
    func setUpValue() {
        statusBarStack.axis = .horizontal
        statusBarStep1.backgroundColor = .white
        statusBarStep2.backgroundColor = UIColor(named: "AccentColor")
        statusBarStep3.backgroundColor = .white
        
        categoryLabel.text = "오늘 당신을 행복하게 해준 것은?"
        categoryLabel.textColor = .darkGray
        
        infoLabel.text = "최대 3개까지 선택할 수 있어요!"
        infoLabel.textColor = .darkGray
        infoLabel.font = UIFont.systemFont(ofSize: 13)
        
        nextButton.backgroundColor = UIColor(named: "AccentColor")
        nextButton.layer.cornerRadius = 40
    }
    
    //  MARK: - 뷰 구성요소 세팅
    func setUpView() {
        statusBarStack.addArrangedSubview(statusBarStep1)
        statusBarStack.addArrangedSubview(statusBarStep2)
        statusBarStack.addArrangedSubview(statusBarStep3)
        statusBarStack.distribution = .fillEqually // 뷰를 동일한 크기로 분배
        view.addSubview(statusBarStack)
        
        view.addSubview(categoryLabel)
        view.addSubview(infoLabel)
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(CategoryButtonCell.self, forCellWithReuseIdentifier: "CategoryButtonCell")
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = true // Show vertical scrollbar -> 작동을 안 함...;
        view.addSubview(collectionView)
        
        view.addSubview(nextButton)
        arrowImageView = UIImageView(image: arrowImage)
        nextButton.addSubview(arrowImageView)
        nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
    }
    
    //  MARK: - 뷰 구성요소 제약 설정
    func setConstraints() {
        statusBarStack.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(self.view.safeAreaLayoutGuide)
            make.height.equalTo(5) // 높이 설정
        }
        
        categoryLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview() // 수평 중앙 정렬
            make.top.equalTo(self.view.safeAreaLayoutGuide).inset(UIEdgeInsets(top: 45, left: 0, bottom: 0, right: 0))
        }
        
        infoLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview() // 수평 중앙 정렬
            make.top.equalTo(categoryLabel).inset(UIEdgeInsets(top: 25, left: 0, bottom: 0, right: 0))
        }
        
        collectionView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 40, bottom: 0, right: 30))
            make.top.equalTo(infoLabel).inset(UIEdgeInsets(top: 45, left: 0, bottom: 0, right: 0))
            make.bottom.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0))
        }
        
        // Next Button 설정
        nextButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview() // 수평 중앙 정렬
            make.bottomMargin.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 0, bottom: 30, right: 0))
            make.width.height.equalTo(80)
        }
        
        arrowImageView.snp.makeConstraints { make in
            make.center.equalTo(nextButton)
            make.width.height.equalTo(30)
        }
    }
    
    // MARK: - UICollectionViewDataSource
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categoryImages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryButtonCell", for: indexPath) as? CategoryButtonCell else {
            return UICollectionViewCell()
        }
        cell.setImage(UIImage(named: categoryImages[indexPath.item])!)
        return cell
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let numberOfColumns: CGFloat = 4 // 가로로 보여줄 아이템 개수
        let spacingBetweenItems: CGFloat = 10 // 아이템 간의 간격
        
        let totalSpacing = (numberOfColumns - 1) * spacingBetweenItems
        let width = (collectionView.frame.width - totalSpacing) / numberOfColumns
        
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    // MARK: - 다음 버튼 클릭될 때 호출되는 메서드
    @objc func nextButtonTapped() {
        // Button tapped action
        print("NextButton tapped!")
        let addStep3VC = AddStep3ViewController()
        navigationController?.pushViewController(addStep3VC, animated: true)
    }
}

#if DEBUG
import SwiftUI
struct AddStep2ViewControllerRepresentable: UIViewControllerRepresentable {
    
    func updateUIViewController(_ uiView: UIViewController,context: Context) {
        // leave this empty
    }
    @available(iOS 13.0.0, *)
    func makeUIViewController(context: Context) -> UIViewController{
        AddStep2ViewController()
    }
}
@available(iOS 13.0, *)
struct AddStep2ViewControllerRepresentable_PreviewProvider: PreviewProvider {
    static var previews: some View {
        Group {
            AddStep2ViewControllerRepresentable()
                .ignoresSafeArea()
                .previewDisplayName(/*@START_MENU_TOKEN@*/"Preview"/*@END_MENU_TOKEN@*/)
                .previewDevice(PreviewDevice(rawValue: "iPhone 11"))
        }
        
    }
} #endif
