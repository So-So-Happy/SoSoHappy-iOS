//
//  CalendarView.swift
//  SoSoHappy
//
//  Created by 박희경 on 2023/08/17.
//

import Foundation
import FSCalendar


final class CalendarCell: FSCalendarCell {
    
    static var identifier: String {
        return String(describing: Self.self)
    }
    
    private lazy var customImageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setLayout()
    }
    
    required init!(coder aDecoder: NSCoder!) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setLayout() {
        contentView.addSubview(customImageView)
        
        customImageView.snp.makeConstraints {
            $0.width.height.equalTo(40)
            $0.center.equalToSuperview()
        }
    }
    
    func setImage(image: UIImage?) {
        self.customImageView.image = image
    }
}
