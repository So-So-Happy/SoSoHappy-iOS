//
//  RxImagePickerDelegateProxy.swift
//  SoSoHappy
//
//  Created by Sue on 2023/09/01.
//

#if os(iOS)

import UIKit
import RxSwift
import RxCocoa

/*
 Delegate Proxy
 1. delegate를 사용하는 부분을 RxSwift로 표현할 수 있도록 한 것
 */


/// UIImagePickerControllerDelagate  - delegate 등록 필요
open class RxImagePickerDelegateProxy
    : RxNavigationControllerDelegateProxy, UIImagePickerControllerDelegate {

    public init(imagePicker: UIImagePickerController) {
        super.init(navigationController: imagePicker)
    }

}

#endif
