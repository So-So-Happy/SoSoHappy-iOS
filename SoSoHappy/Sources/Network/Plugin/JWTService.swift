//
//  JWTService.swift
//  SoSoHappy
//
//  Created by 박희경 on 2023/12/15.
//

import UIKit
import Moya
import RxSwift


class JWTService: Networkable {
    
//    static let shared = JWTService()
    
    
    typealias Target = UserAPI
    
    func getRefreshToken() -> Observable<RelssueTokenResponse> {
        return Observable.create { emitter in
            let provider = self.accessProvider()
            let disposable = provider.rx.request(.getRefreshToken)
                .map(RelssueTokenResponse.self)
                .asObservable()
                .subscribe { event in
                    switch event {
                    case .next(let response):
                        print("response: \(response)")
                        emitter.onNext(response)
                    case .error(let error):
                        print("error: \(error.localizedDescription)")
                        emitter.onError(error)
                    case .completed:
                        emitter.onCompleted()
                    }
                }
            
            return Disposables.create() {
                disposable.dispose()
            }
        }
    }
}
