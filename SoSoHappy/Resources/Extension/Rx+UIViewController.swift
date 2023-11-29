//
//  Rx+UIViewController.swift
//  SoSoHappy
//
//  Created by Sue on 2023/09/07.
//
import UIKit
import RxCocoa
import RxSwift

extension Reactive where Base: UIViewController {
    var viewDidLoad: ControlEvent<Void> {
        let viewDidLoadEvent = self.methodInvoked(#selector(base.viewWillAppear)).map { _ in }
        return ControlEvent(events: viewDidLoadEvent)
    }
    
    var viewWillAppear: ControlEvent<Void> {
        let viewWillAppearEvent = self.methodInvoked(#selector(base.viewWillAppear)).map { _ in }
        return ControlEvent(events: viewWillAppearEvent)
    }
}
