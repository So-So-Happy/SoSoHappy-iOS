//
//  OwnerFeedCell.swift
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

final class OwnerFeedCell: BaseCell {
    private lazy var heartButton = HeartButton()
    
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
            let nickName = KeychainService.getNickName()
            if nickName == userFeed.nickName { heartButton.isHidden = true }
            heartButton.setHeartButton(userFeed.isLiked)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        heartButton.isHidden = false
    }
}

extension OwnerFeedCell {
    private func setupHeartButton() {
        self.contentView.addSubview(heartButton)

        heartButton.snp.makeConstraints { make in
            make.top.right.equalTo(cellBackgroundView).inset(20)
        }
        
        weatherDateStackView.snp.updateConstraints { make in
            make.top.equalTo(cellBackgroundView).inset(65)
        }
    }
}

extension OwnerFeedCell: View {
    func bind(reactor: FeedReactor) {
        if let currentFeed = reactor.currentState.userFeed {
            setFeedCell(currentFeed)
        }

        heartButton.rx.tap
            .map { Reactor.Action.toggleLike }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.state
            .compactMap { $0.isLike }
            .bind { [weak self] isLike in
                guard let `self` = self else { return }
                heartButton.setHeartButton(isLike)
            }
            .disposed(by: disposeBag)
        
        reactor.state
            .compactMap { $0.showServerErrorAlert }
            .distinctUntilChanged()
            .bind(onNext: { showServerErrorAlert in
                if showServerErrorAlert {
                    CustomAlert.presentErrorAlertWithoutDescription()
                }
            })
            .disposed(by: disposeBag)
        
    }
}
