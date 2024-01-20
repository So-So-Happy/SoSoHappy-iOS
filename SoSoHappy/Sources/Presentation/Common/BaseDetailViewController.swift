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
    lazy var scrollView = UIScrollView().then {
        $0.showsVerticalScrollIndicator = false
    }
    
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
    
    lazy var lockImageView = UIImageView().then {
        $0.layer.masksToBounds = true
        $0.image = UIImage(systemName: "lock")
        $0.contentMode = .scaleAspectFit
    }
    
    // 피드 작성 글
    lazy var textView = UITextView().then {
        $0.textAlignment = .left
        $0.font = UIFont.customFont(size: 16, weight: .medium)
        $0.textColor = UIColor(named: "MainTextColor")
        $0.backgroundColor = .clear
        $0.isUserInteractionEnabled = false
        $0.isScrollEnabled = false
    }
    
    // 작성 글 잘 보이도록 사용하는 background
    lazy var contentBackground = UIView()
    
    // 피드 이미지
    lazy var imageSlideView = ImageSlideView().then {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTap(sender:)))
        $0.slideShowView.addGestureRecognizer(tapGesture)
        $0.layer.cornerRadius = 16
        $0.slideShowView.backgroundColor = UIColor.white
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setLayout()
    }
    
    func setFeed(feed: FeedType) {
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
            imageSlideView.snp.updateConstraints {
                $0.height.equalTo(0)
            }
            
        } else {
            imageSlideView.isHidden = false
            imageSlideView.snp.updateConstraints {
                $0.height.equalTo(300)
            }
            imageSlideView.setImages(ids: ids)
            
        }
    }
    
    // MARK: AddStep3에서 사용 중임 (삭제 X)
    func setImageSlideView(imageList: [UIImage]) {
        if imageList.isEmpty {
            imageSlideView.isHidden = true
            imageSlideView.snp.updateConstraints {
                $0.height.equalTo(0)
            }
            
        } else {
            imageSlideView.isHidden = false
            imageSlideView.snp.updateConstraints {
                $0.height.equalTo(300)
            }
            imageSlideView.setContentsWithImageList(imageList: imageList)
        }
    }
    
    func setLockImageVIew(isPublic: Bool) {
        let imageName = isPublic ? "lock.open" : "lock"
        lockImageView.image = UIImage(systemName: imageName)
    }
}

// MARK: - setLayout()
extension BaseDetailViewController {
    func setLayout() {
        self.view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubviews(categoryStackView, dateLabel, contentBackground, textView, imageSlideView, lockImageView)
        
        scrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        contentView.snp.makeConstraints {
            $0.edges.equalTo(scrollView.contentLayoutGuide)
            $0.width.equalTo(scrollView.frameLayoutGuide)
            $0.bottom.equalTo(imageSlideView).offset(40)
        }
        
        categoryStackView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().inset(112)
        }
        
        dateLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(categoryStackView.snp.bottom).offset(20)
        }
        
        lockImageView.snp.makeConstraints {
            $0.centerY.equalTo(dateLabel)
            $0.width.height.equalTo(20)
            $0.leading.equalTo(dateLabel.snp.trailing).offset(5)
        }
        
        contentBackground.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.top.equalTo(dateLabel.snp.bottom).offset(21)
        }
                
        textView.snp.makeConstraints {
            $0.verticalEdges.equalTo(contentBackground).inset(12)
            $0.horizontalEdges.equalToSuperview().inset(20)
        }
        
        // MARK: 여기에 make.height.equalTo(0) 추가하지 마세요!
        imageSlideView.snp.makeConstraints {
            $0.top.equalTo(contentBackground.snp.bottom)
            $0.horizontalEdges.equalToSuperview().inset(20)
        }
    }
}

// MARK: - Action
extension BaseDetailViewController {
    @objc func didTap(sender: UITapGestureRecognizer? = nil) {
        imageSlideView.slideShowView.presentFullScreenController(from: self)
    }
}
