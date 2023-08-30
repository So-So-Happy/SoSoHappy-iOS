//
//  FeedHeaderView.swift
//  SoSoHappy
//
//  Created by Sue on 2023/08/25.
//


import UIKit
import SnapKit
import Then

final class FeedHeaderView: UIView {
    // MARK: - UI Components
    private lazy var feedSubtitle = UILabel().then {
        $0.textAlignment = .left
        $0.font = .systemFont(ofSize: 18, weight: .semibold)
        $0.text = "소피들, 서로의 행복을 응원해보아요! 🫶🏻"
        $0.textColor = .darkGray
    }
    
    private lazy var sortTodayTotalStackView = UIStackView(
        axis: .horizontal,
        alignment: .fill,
        distribution: .fill,
        spacing: 8
    )
    
    private lazy var sortTodayButton = UIButton().then {
        $0.setTitle("오늘", for: .normal)
        $0.setTitleColor(.black, for: .normal)
        $0.titleLabel?.font =  UIFont.systemFont(ofSize: 15)
    }
    
    private lazy var divider = UILabel().then {
        $0.font = .systemFont(ofSize: 12, weight: .regular)
        $0.text = "|"
    }
    
    private lazy var sortTotalButton = UIButton().then {
        $0.setTitle("전체", for: .normal)
        $0.setTitleColor(.gray, for: .normal)
        $0.titleLabel?.font =  UIFont.systemFont(ofSize: 15)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - Add Subviews & Constraints
extension FeedHeaderView {
    private func setView() {
        addSubviews()
        setLayout()
    }
    
    private func addSubviews() {
        sortTodayTotalStackView.addArrangedSubview(sortTodayButton)
        sortTodayTotalStackView.addArrangedSubview(divider)
        sortTodayTotalStackView.addArrangedSubview(sortTotalButton)
        
        addSubview(feedSubtitle)
        addSubview(sortTodayTotalStackView)
    }
    
    private func setLayout() {
        feedSubtitle.snp.makeConstraints { make in
            make.left.equalTo(safeAreaLayoutGuide).inset(16)
            make.top.equalToSuperview().inset(3)
        }
        
        sortTodayTotalStackView.snp.makeConstraints { make in
            make.right.equalTo(safeAreaLayoutGuide).inset(16)
            make.top.equalTo(feedSubtitle.snp.bottom).offset(40)
        }
    }
}


//#if DEBUG
//import SwiftUI
//struct FeedViewControllerRepresentable: UIViewControllerRepresentable {
//
//    func updateUIViewController(_ uiView: UIViewController,context: Context) {
//        // leave this empty
//    }
//    @available(iOS 13.0.0, *)
//    func makeUIViewController(context: Context) -> UIViewController{
//        FeedViewController()
//    }
//}
//@available(iOS 13.0, *)
//struct FeedViewControllerRepresentable_PreviewProvider: PreviewProvider {
//    static var previews: some View {
//        Group {
//            FeedViewControllerRepresentable()
//                .ignoresSafeArea()
//                .previewDisplayName(/*@START_MENU_TOKEN@*/"Preview"/*@END_MENU_TOKEN@*/)
//                .previewDevice(PreviewDevice(rawValue: "iPhone 14 Pro"))
//        }
//
//    }
//} #endif
