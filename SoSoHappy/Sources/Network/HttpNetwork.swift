//
//  HttpNetwork.swift
//  SoSoHappy
//
//  Created by 박희경 on 2023/09/11.
//


import Foundation
import RxSwift
import Moya


final class HttpNetwork: MoyaProvider<MultiTarget>, HttpNetworkType, Networkable {
    func request(_ targetType: TargetType) -> Single<Response> {
        self.rx.request(.target(targetType))
            .filterSuccessfulStatusCodes()
        // status 200번대가 아닐시 Moya 내부에서 에러 처리
    }
}




