//
//  CalendarCell.swift
//  SoSoHappy
//
//  Created by 박희경 on 2023/12/01.
//

import UIKit
import FSCalendar

class CalendarCell: FSCalendarCell {
    
    static var identifier: String {
        return String(describing: Self.self)
    }
    
    // 뒤에 표시될 이미지
    var backImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // 날짜 텍스트가 디폴트로 약간 위로 올라가 있어서, 아예 레이아웃을 잡아준다
        self.titleLabel.snp.makeConstraints { make in
            make.center.equalTo(contentView)
        }
        
        contentView.insertSubview(backImageView, at: 0)
        backImageView.snp.makeConstraints { make in
            make.center.equalTo(contentView)
            make.edges.equalToSuperview().inset(3)
        }
    }
    
    required init(coder aDecoder: NSCoder!) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        backImageView.image = nil
    }
}
