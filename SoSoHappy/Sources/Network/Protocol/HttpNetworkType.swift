//
//  HttpNetwork.swift
//  SoSoHappy
//
//  Created by 박희경 on 2023/09/11.
//

import Foundation
import RxSwift
import Moya

protocol HttpNetworkType {
    func request(_ targetType: TargetType) -> Single<Response>
}
