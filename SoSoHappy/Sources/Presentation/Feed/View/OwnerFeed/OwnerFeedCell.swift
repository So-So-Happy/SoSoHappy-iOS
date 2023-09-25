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

/*
 1. 하트 버튼 연타 처리 (debounce, throttle)
 */

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
    
    override func setFeedCell(_ feed: FeedTemp) {
        super.setFeedCell(feed)
        heartButton.setHeartButton(feed.isLike)
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
        guard let currentFeed = reactor.currentState.feed else { return }
        setFeedCell(currentFeed)
        
        heartButton.rx.tap
            .map { Reactor.Action.toggleLike }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        
        reactor.state
            .skip(1)
            .compactMap { $0.feed?.isLike } // Optional 벗기고 nil 값 filter
            .bind { [weak self] isLike in
                guard let `self` = self else { return }
                heartButton.setHeartButton(isLike)
            }
            .disposed(by: disposeBag)
    }
}
