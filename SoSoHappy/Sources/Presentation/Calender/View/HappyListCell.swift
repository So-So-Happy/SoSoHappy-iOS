//
//  HappyListCell.swift
//  SoSoHappy
//
//  Created by 박희경 on 2023/08/09.
//

import UIKit
import SnapKit
import ImageSlideshow
import Then
import ReactorKit

final class HappyListCell: BaseCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setFeedCell(_ feed: FeedType) {
        super.setFeedCell(feed)
    }
}

//MARK: - ReactorKit - bind function
extension HappyListCell: View {
    func bind(reactor: HappyListCellReactor) {
        // TODO: 여기 HappyListCellReactor 수정됨에 맞게 고쳐주면 됨
        guard let currentFeed = reactor.currentState.feed else { return }
//        setFeedCell(currentFeed)
    }
}
