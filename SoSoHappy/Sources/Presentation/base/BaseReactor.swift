//
//  BaseReactor.swift
//  SoSoHappy
//
//  Created by 박희경 on 2023/10/02.
//

import RxCocoa

class BaseReactor {
    let showErrorAlertPublisher = PublishRelay<Error>()
    let openURLPublisher = PublishRelay<String>()
    let showLoadingPublisher = PublishRelay<Bool>()
    let showToastPublisher = PublishRelay<String>()
}
