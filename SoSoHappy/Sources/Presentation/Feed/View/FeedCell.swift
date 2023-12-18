//
//  FeedCell.swift
//  SoSoHappy
//
//  Created by Sue on 2023/08/25.
//

import UIKit
import SnapKit
import ImageSlideshow
import Then
import ReactorKit
import RxSwift
import RxCocoa

/*
 1. 하트 버튼 연타 처리 (debounce, throttle) - 서버 요청 , local ui update
 */
final class FeedCell: BaseCell {
    // MARK: - Properties
    let profileImageTapSubject = PublishSubject<String>()

    // MARK: - UI Components
    private lazy var heartButton = HeartButton()
    private lazy var profileImageNameTimeStackView = ProfileImageNameTimeStackView(imageSize: 38)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupHeartButton()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setFeedCell(_ feed: FeedType) {
        super.setFeedCell(feed)
        
        if let userFeed = feed as? UserFeed {
            heartButton.setHeartButton(userFeed.isLiked)
            profileImageNameTimeStackView.setContents(userFeed: userFeed)
        }
    }
}

//MARK: - setCellAttributes & Add Subviews & Constraints
extension FeedCell {
    private func setupHeartButton() {
        self.contentView.addSubview(heartButton)
        self.contentView.addSubview(profileImageNameTimeStackView)

        heartButton.snp.makeConstraints { make in
            make.top.right.equalTo(cellBackgroundView).inset(15)
        }
        
        profileImageNameTimeStackView.snp.makeConstraints { make in
            make.top.left.equalTo(cellBackgroundView).inset(15)
        }
        
        weatherDateStackView.snp.updateConstraints { make in
            make.top.equalTo(cellBackgroundView).inset(80)
        }
    }
}

extension FeedCell: View {
    func bind(reactor: FeedReactor) {
        if let currentFeed = reactor.currentState.userFeed {
            setFeedCell(currentFeed)
        }
        
        heartButton.rx.tap
            .map { Reactor.Action.toggleLike}
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        profileImageNameTimeStackView.profileImageView.rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let nickName = self?.profileImageNameTimeStackView.profileNickNameLabel.text else { return }
                self?.profileImageTapSubject.onNext(nickName)
            })
            .disposed(by: disposeBag)
        
        reactor.state
            .compactMap { $0.isLike } 
            .bind { [weak self] isLike in
                guard let `self` = self else { return }
                print("Feed cell heartButton : \(isLike)")
                heartButton.setHeartButton(isLike)
            }
            .disposed(by: disposeBag)
        
        reactor.state
            .compactMap { $0.handleFeedError }
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] handleFeedError in
                guard let self = self else { return }
                if handleFeedError == .showServerErrorAlert {
                    print("Feed cell heart error : \(handleFeedError)")
                    CustomAlert.presentErrorAlertWithoutDescription()
                }
            })
            .disposed(by: disposeBag)
    }
}
