//
//  FeedExceptionView.swift
//  SoSoHappy
//
//  Created by Sue on 10/14/23.
//

import UIKit

// 올라온 피드가 없습니다
final class FeedExceptionView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .blue
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
