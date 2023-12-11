//
//  FeedDetailViewController.swift
//  SoSoHappy
//
//  Created by Sue on 12/11/23.
//

import UIKit
import SnapKit
import ImageSlideshow
import Then
import ReactorKit
import RxGesture

final class FeedDetailViewController: UIViewController {
    // MARK: - Properties
    private weak var coordinator: FeedDetailCoordinatorInterface?
    var disposeBag = DisposeBag()
    
    // MARK: - UI Components
    lazy var scrollView = UIScrollView()
    
    lazy var contentView = UIView()
    
    lazy var categoryStackView = CategoryStackView()
    
    lazy var dateLabel = UILabel().then {
        $0.textAlignment = .center
        $0.font = UIFont.customFont(size: 15, weight: .medium)
        $0.textColor = .gray
    }
    
    lazy var textView = UITextView().then {
        $0.textAlignment = .left
        $0.font = UIFont.customFont(size: 16, weight: .medium)
        $0.textColor = .black
        $0.backgroundColor = .clear
        $0.isUserInteractionEnabled = false
        $0.isScrollEnabled = false // 얘를 설정해줬더니 TextView에 따로 높이를 지정해주지 않아도 content에 맞게 높이가 설정됨 (label의 numberOfLines을 0으로 넣는 것과 동일
    }
    
    lazy var contentBackground = UIView().then {
        $0.layer.backgroundColor = UIColor(named: "CellColor")?.cgColor
        $0.layer.opacity = 0.4
        $0.layer.cornerRadius = 16
        $0.layer.borderWidth = 0.3
        $0.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    lazy var imageSlideView = ImageSlideView().then {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTap(sender:)))
        $0.slideShowView.addGestureRecognizer(tapGesture)
    }
    
    private lazy var profileImageNameTimeStackView = ProfileImageNameTimeStackView(imageSize: 44)
    private lazy var heartButton = HeartButton()
    
    private lazy var backButton = UIButton().then {
        $0.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        $0.setPreferredSymbolConfiguration(.init(scale: .large), forImageIn: .normal)
    }
    
    private lazy var exceptionView = FeedExceptionView(
        title: "피드가 삭제되었습니다.",
        inset: 200
    ).then {
        $0.isHidden = true
    }
    
    override func viewDidLoad() {
        print("FeedDetailViewController -viewDidLoad ")
        super.viewDidLoad()
//        view.backgroundColor = .red
//        scrollView.backgroundColor = .blue
        exceptionView.backgroundColor = UIColor(named: "BGgrayColor")
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
        
        self.view.addSubview(scrollView)
        self.view.addSubview(exceptionView)
        
        
        scrollView.addSubview(contentView)
        contentView.addSubviews(categoryStackView, dateLabel, contentBackground, textView, imageSlideView)
        
        self.contentView.addSubview(profileImageNameTimeStackView)
        self.contentView.addSubview(heartButton)
        
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        exceptionView.snp.makeConstraints { make in
//            make.horizontalEdges.bottom.equalToSuperview()
//            make.top.equalTo(view.safeAreaLayoutGuide)
            make.edges.equalToSuperview()
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(scrollView.frameLayoutGuide)
            make.bottom.equalTo(imageSlideView).offset(40)
        }
        
        profileImageNameTimeStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(30)
            make.left.equalTo(contentView.safeAreaLayoutGuide).inset(30)
        }
        
        heartButton.snp.makeConstraints { make in
            make.right.equalTo(contentView.safeAreaLayoutGuide).inset(30)
            make.top.equalTo(profileImageNameTimeStackView)
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
        
        imageSlideView.snp.makeConstraints { make in
            print("imageSlideView  makeConstraints")
            make.height.equalTo(0)
            make.top.equalTo(contentBackground.snp.bottom).offset(22)
            make.horizontalEdges.equalToSuperview().inset(30)
        }
    }
    
    init(reactor: FeedReactor, coordinator: FeedDetailCoordinatorInterface) {
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
        self.coordinator = coordinator
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

//MARK: - bind func
extension FeedDetailViewController: View {
    func bind(reactor: FeedReactor) {
        self.rx.viewWillAppear
            .map {
                print("FeedDetailViewController -viewWillAppear - fetch feeds")
                return Reactor.Action.fetchFeed
            } // default today
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        backButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
//                print("back button tapped")
                coordinator?.dismiss()
            })
            .disposed(by: disposeBag)
        
        reactor.state
            .skip(1)
            .map { $0.userFeed }
            .bind { [weak self] userFeed in
                guard let `self` = self else { return }
                print("FeedDetailViewController- userFeed : \(userFeed)")
                if let userFeed = userFeed {
                    setFeed(feed: userFeed)
                } else {
                    exceptionView.isHidden = false
                }
            }
            .disposed(by: disposeBag)
    }
}

extension FeedDetailViewController {
    func setFeed(feed: FeedType) {
        print("FeedDetailViewcontroller - setFeed")
        let bgName: String = feed.weather + "Bg"
        let image = UIImage(named: bgName)!
        let color = UIColor(patternImage: image)
        scrollView.backgroundColor = UIColor(patternImage: image)
        
        categoryStackView.addImageViews(images: feed.happinessAndCategoryArray, imageSize: 50)
        dateLabel.text = feed.dateFormattedString
        textView.setAttributedTextWithLineHeight(feed.text, fontSize: 16)
        
        setImageSlideView(imageList: feed.imageList)
        
        if let userFeed = feed as? UserFeed {
            profileImageNameTimeStackView.setContents(userFeed: userFeed)
            heartButton.setHeartButton(userFeed.isLiked)
            textView.font = UIFont.customFont(size: 16, weight: .medium)
        }
    }
    
    func setImageSlideView(imageList: [UIImage]) {
        if imageList.isEmpty {
            imageSlideView.isHidden = true
            imageSlideView.snp.updateConstraints { make in // updateConstraints or makeConstraints
                print("BaseFeedDetailViewController - imageSlideView  updateConstraints 사진 없음")
                make.height.equalTo(0)
            }
            
        } else {
            imageSlideView.isHidden = false
            imageSlideView.snp.updateConstraints { make in // updateConstraints or makeConstraints
                print("BaseFeedDetailViewController - imageSlideView  updateConstraints 사진 있음")
                make.height.equalTo(300)
            }
            
            imageSlideView.setContentsWithImageList(imageList: imageList)
            
        }
        
    }
}

extension FeedDetailViewController {
    @objc func didTap(sender: UITapGestureRecognizer? = nil) {
        print("ViewController - didTap() called")
        imageSlideView.slideShowView.presentFullScreenController(from: self)
    }
}
