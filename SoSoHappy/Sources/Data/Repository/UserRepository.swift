//
//  UserRepository.swift
//  SoSoHappy
//
//  Created by 박희경 on 2023/09/04.
//

import Foundation
import RxSwift
import RxCocoa
import Moya
import Alamofire


final class UserRepository: UserRepositoryProtocol, Networkable {
    // MARK: - Target
    typealias Target = UserAPI
    
    // MARK: - 랜덤 문자열을 만들어서 서버에 인증 코드 발급을 요청하는 함수
    func getAuthorizeCode() -> Observable<AuthCodeResponse> {
        print("UserRepository getAuthorizeCode() started ..")
        return Observable.create { emitter in
            let provider = self.accessProvider()
            
            // 랜덤 문자열 생성
            let codeChallenge = String.createRandomString(length: 20)
            print("UserRepository getAuthorizeCode() codeChallenge: \(codeChallenge)")
            UserDefaults.standard.setValue(codeChallenge, forKey: "codeVerifier")

            let disposable = provider.rx.request(.getAuthorizeCode(codeChallenge: AuthCodeRequest(codeChallenge: codeChallenge)))
                .map(AuthCodeResponse.self)
                .asObservable()
                .subscribe { event in
                    switch event {
                    case .next(let response):
                        print("UserRepository getAuthorizeCode() subscribe event's response: \(response)")
                        emitter.onNext(response)
                    case .error(let error):
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
    
    func checkDuplicateNickname(nickName: String) -> Observable<CheckNickNameResponse> {
        let provider = makeProvider()
        return provider.rx.request(.checkDuplicateNickname(nickName: nickName))
            .map(CheckNickNameResponse.self)
            .asObservable()
    }
    
    func getRefreshToken() -> Observable<AuthResponse> {
        let provider = accessProvider()
        return provider.rx.request(UserAPI.getRefreshToken)
            .map(AuthResponse.self)
            .asObservable()
    }
    
    
    func setProfile(profile: Profile) -> RxSwift.Observable<SetProfileResponse> {
        let provider = makeProvider()
        return provider.rx.request(.setProfile(profile: profile))
                    .map(SetProfileResponse.self)
                    .asObservable()
    }
    
    func resign(email: ResignRequest) -> RxSwift.Observable<ResignResponse> {
        let provider = makeProvider()
        return provider.rx.request(.resign(email: email))
                    .map(ResignResponse.self)
                    .asObservable()
    }
    
    func findProfileImg(nickName: FindProfileImgRequest) -> RxSwift.Observable<FindProfileImgResponse> {
        let provider = makeProvider()
        return provider.rx.request(.findProfileImg(nickName: nickName))
                    .map(FindProfileImgResponse.self)
                    .asObservable()
    }
    
}
