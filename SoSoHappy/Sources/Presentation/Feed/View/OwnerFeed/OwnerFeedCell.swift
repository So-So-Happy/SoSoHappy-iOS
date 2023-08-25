//
//  OwnerFeedCell.swift
//  SoSoHappy
//
//  Created by Sue on 2023/08/25.
//

/*
 1. stack 처리 필요 (리팩토링할 때 해주면 될 듯)
 2. heartButton 토글 적용
 */

import UIKit
import SnapKit
import ImageSlideshow

final class OwnerFeedCell: UITableViewCell {
    // MARK: - Properties
    static var cellIdentifer: String {
        return String(describing: Self.self)
    }
    // MARK: - UI Components
    // 1. 피드 cell background
    private lazy var cellBackgroundView: UIView = {
        let bv = UIView()
        bv.backgroundColor = .white
        bv.layer.borderColor = UIColor(white: 0.9, alpha: 1.0).cgColor
        bv.layer.borderWidth = 1
        bv.layer.cornerRadius = 16
        return bv
    }()
    
    // 2. 날짜 - '2023.07.18 화요일'
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 12, weight: .light)
        label.textColor = .gray
        label.text = "2023.07.18 화요일"
        
        return label
    }()
    
    // 3. 좋아요 버튼
    private lazy var heartButton: UIButton = {
        let image = UIImage(systemName: "heart")
        let btn = UIButton(type: .system)
        btn.setImage(image, for: .normal)
        btn.tintColor = .red
        return btn
    }()
    
    // 4. 스택에 들어갈 요소들
    private lazy var happinessImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.image = UIImage(named: "happiness")
        return iv
    }()
    
    private lazy var categoryImageView1: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.image = UIImage(named: "donut")
        return iv
    }()
    
    private lazy var categoryImageView2: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.image = UIImage(named: "coffee")
        return iv
    }()
    
    // 4. 작성 글 - 문장 2줄 제한
    private lazy var contentLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 15, weight: .light)
        label.textColor = .darkGray
        label.numberOfLines = 2
        label.text = "오늘 아아랑 휘낭시에를 머것다..그런데 아아를 먹다가 쏟아버렸다. 커피 냄새가 좋아서 괜찮아지만 옷에 묻은 얼룩은 슬펐다. 휘낭시애는 맛있어서 연달아서 5개를 앉은 자리에서 먹었다. 행복했다! 오늘 하루도 작은 행복을 느낄 수 있어서 너무 감사합니다."
        
        return label
    }()
    
    // 5. 게시물 대표 사진들
    private lazy var pageIndicator: UIPageControl = {
        let pageIndicator = UIPageControl()
        pageIndicator.currentPageIndicatorTintColor = UIColor.orange
        pageIndicator.pageIndicatorTintColor = UIColor.lightGray
        
        return pageIndicator
    }()
    
    private lazy var slideShow: ImageSlideshow = {
        let slideShow = ImageSlideshow()
        slideShow.pageIndicator = pageIndicator
        slideShow.pageIndicatorPosition = PageIndicatorPosition(horizontal: .center)
        slideShow.contentScaleMode = .scaleAspectFill
        slideShow.activityIndicator = DefaultActivityIndicator()
        return slideShow
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setCellAttributes()
        addSubViews()
        setConstraints()
        setDataForCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - Add Subviews & Constraints
extension OwnerFeedCell {
    private func setCellAttributes() {
        backgroundColor = .clear // tableView의 backgroundColor가 보이도록 cell은 .clear
        selectionStyle = .none
    }
    
    public func setDataForCell() {
        slideShow.setImageInputs([
            ImageSource(image: UIImage(named: "pic1")!),
            ImageSource(image: UIImage(named: "pic2")!),
            ImageSource(image: UIImage(named: "pic3")!)
        ])
        
    }
    
    private func addSubViews() {
        self.contentView.addSubview(cellBackgroundView)
        self.contentView.addSubview(dateLabel)
        self.contentView.addSubview(heartButton)
        self.contentView.addSubview(categoryImageView1)
        self.contentView.addSubview(happinessImageView)
        self.contentView.addSubview(categoryImageView2)
        self.contentView.addSubview(contentLabel)
        self.contentView.addSubview(slideShow)
    }
    
    private func setConstraints() {
        cellBackgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16))
            make.bottom.equalTo(slideShow.snp.bottom).offset(40)
        }
        
        dateLabel.snp.makeConstraints { make in
            make.top.left.equalTo(cellBackgroundView).inset(15)
        }
        
        heartButton.snp.makeConstraints { make in
            make.right.equalTo(cellBackgroundView).inset(15)
            make.top.equalTo(dateLabel)
        }
        
        categoryImageView1.snp.makeConstraints { make in
            make.height.width.equalTo(45)
            make.top.equalTo(dateLabel.snp.bottom).offset(32)
            make.left.equalTo(happinessImageView.snp.right).offset(8)
            make.right.equalTo(categoryImageView2.snp.left).offset(-8)
            make.centerX.equalToSuperview()
        }
        
        happinessImageView.snp.makeConstraints { make in
            make.height.width.equalTo(45)
            make.top.equalTo(categoryImageView1)
        }
        
        categoryImageView2.snp.makeConstraints { make in
            make.height.width.equalTo(45)
            make.top.equalTo(categoryImageView1)
        }
        
        contentLabel.snp.makeConstraints { make in
            make.top.equalTo(categoryImageView1.snp.bottom).offset(24)
            make.left.right.equalTo(cellBackgroundView).inset(15)
        }
        
        slideShow.snp.makeConstraints { make in
            make.top.equalTo(contentLabel.snp.bottom).offset(18) // Adjust the spacing as needed
            make.left.right.equalTo(cellBackgroundView).inset(15) // width 설정 완료
            make.height.equalTo(200)
        }
    }
}



//#if DEBUG
//import SwiftUI
//struct OwnerFeedViewControllerRepresentable: UIViewControllerRepresentable {
//
//    func updateUIViewController(_ uiView: UIViewController,context: Context) {
//        // leave this empty
//    }
//    @available(iOS 13.0.0, *)
//    func makeUIViewController(context: Context) -> UIViewController{
//        OwnerFeedViewController()
//    }
//}
//@available(iOS 13.0, *)
//struct OwnerFeedViewControllerRepresentable_PreviewProvider: PreviewProvider {
//    static var previews: some View {
//        Group {
//            OwnerFeedViewControllerRepresentable()
//                .ignoresSafeArea()
//                .previewDisplayName(/*@START_MENU_TOKEN@*/"Preview"/*@END_MENU_TOKEN@*/)
//                .previewDevice(PreviewDevice(rawValue: "iPhone 14 Pro"))
//        }
//
//    }
//} #endif
