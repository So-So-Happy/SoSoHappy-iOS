//
//  BaseDetailViewController.swift
//  SoSoHappy
//
//  Created by Sue on 10/16/23.
//

import UIKit
import SnapKit
import ImageSlideshow
import Then
import ReactorKit
import RxGesture

class BaseDetailViewController: UIViewController {
    // MARK: - Properties
    var disposeBag = DisposeBag()
    
    // MARK: - UI Components
    lazy var scrollView = UIScrollView()
    
    // scrollView에 들어갈 container view
    lazy var contentView = UIView()
    
    // 선택한 카테고리
    lazy var categoryStackView = CategoryStackView()
    
    // 피드 작성 날짜
    lazy var dateLabel = UILabel().then {
        $0.textAlignment = .center
        $0.font = UIFont.customFont(size: 15, weight: .medium)
        $0.textColor = .gray
    }
    
    // 피드 작성 글
    lazy var textView = UITextView().then {
        $0.textAlignment = .left
        $0.font = UIFont.customFont(size: 16, weight: .medium)
        $0.textColor = .black
        $0.backgroundColor = .clear
        $0.isUserInteractionEnabled = false
        $0.isScrollEnabled = false
    }
    
    // 작성 글 잘 보이도록 사용하는 background
    lazy var contentBackground = UIView().then {
        $0.layer.backgroundColor = UIColor(named: "CellColor")?.cgColor
        $0.layer.opacity = 0.4
        $0.layer.cornerRadius = 16
        $0.layer.borderWidth = 0.3
        $0.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    // 피드 이미지
    lazy var imageSlideView = ImageSlideView().then {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTap(sender:)))
        $0.slideShowView.addGestureRecognizer(tapGesture)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setLayout()
    }
    
    func setFeed(feed: FeedType) {
        print("BaseDetailViewController - setFeed: \(feed)")
        let bgName: String = feed.weather + "Bg"
        let image = UIImage(named: bgName)!
        scrollView.backgroundColor = UIColor(patternImage: image)
        
        categoryStackView.addImageViews(images: feed.happinessAndCategoryArray, imageSize: 50)
        dateLabel.text = feed.dateFormattedString
        textView.setAttributedTextWithLineHeight(feed.text, fontSize: 16)
        
        setImageSlideView(ids: feed.imageIdList)
    }
    
    func setImageSlideView(ids: [Int]) {
        if ids.isEmpty {
            imageSlideView.isHidden = true
            imageSlideView.snp.updateConstraints { make in // updateConstraints or makeConstraints
                print("imageSlideView  updateConstraints 사진 없음")
                make.height.equalTo(0)
            }
            
        } else {
            imageSlideView.isHidden = false
            imageSlideView.snp.updateConstraints { make in
                make.height.equalTo(300)
            }
            
            imageSlideView.setImages(ids: ids)
            
        }
    }
    
    // MARK: AddStep3에서 사용 중임 (삭제 X)
    func setImageSlideView(imageList: [UIImage]) {
        if imageList.isEmpty {
            imageSlideView.isHidden = true
            imageSlideView.snp.updateConstraints { make in
                make.height.equalTo(0)
            }
            
        } else {
            imageSlideView.isHidden = false
            imageSlideView.snp.updateConstraints { make in
                make.height.equalTo(300)
            }
            imageSlideView.setContentsWithImageList(imageList: imageList)
        }
    }
}

// MARK: - setLayout()
extension BaseDetailViewController {
    func setLayout() {
        self.view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubviews(categoryStackView, dateLabel, contentBackground, textView, imageSlideView)
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(scrollView.frameLayoutGuide)
            make.bottom.equalTo(imageSlideView).offset(40)
        }
        
        categoryStackView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(140)
        }
        
        dateLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(categoryStackView.snp.bottom).offset(20)
        }
        
        contentBackground.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.top.equalTo(dateLabel.snp.bottom).offset(26)
        }
                
        textView.snp.makeConstraints { make in
            make.verticalEdges.equalTo(contentBackground).inset(12)
            make.horizontalEdges.equalToSuperview().inset(40)
        }
        
        // MARK: 여기에 make.height.equalTo(0) 추가하지 마세요!
        imageSlideView.snp.makeConstraints { make in
            make.top.equalTo(contentBackground.snp.bottom).offset(22)
            make.horizontalEdges.equalToSuperview().inset(30)
        }
    }
}

// MARK: - Action
extension BaseDetailViewController {
    @objc func didTap(sender: UITapGestureRecognizer? = nil) {
        imageSlideView.slideShowView.presentFullScreenController(from: self)
    }
}
