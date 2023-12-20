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

open class RxImagePickerDelegateProxy
    : RxNavigationControllerDelegateProxy, UIImagePickerControllerDelegate {

    public init(imagePicker: UIImagePickerController) {
        super.init(navigationController: imagePicker)
    }

}

#endif
