//
//  Rx+ UIImageView.swift
//  SoSoHappy
//
//  Created by Sue on 2023/09/09.
//

import RxSwift
import RxCocoa
import UIKit

extension Reactive where Base: UIImageView {
    var tap: ControlEvent<Void> {
        let tapGestureRecognizer = UITapGestureRecognizer()
        base.isUserInteractionEnabled = true
        base.addGestureRecognizer(tapGestureRecognizer)
        
        return ControlEvent(events: tapGestureRecognizer.rx.event.map { _ in })
    }
}
