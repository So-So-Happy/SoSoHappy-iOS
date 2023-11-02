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
        return Observable.create { emitter in
            let provider = self.makeProvider()
            
            // 랜덤 문자열 생성
            let codeVerifier = String.createRandomString(length: 20)
            UserDefaults.standard.setValue(codeVerifier, forKey: "codeVerifier")
            
            let disposable = provider.rx.request(.getAuthorizeCode(codeChallenge: AuthCodeRequest(codeChallenge: codeVerifier.sha512())))
                .map(AuthCodeResponse.self)
                .asObservable()
                .subscribe { event in
                    switch event {
                    case .next(let response):
                        UserDefaults.standard.setValue(response.authorizeCode, forKey: "authorizeCode")
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
    
    // MARK: - 로그인 요청 함수
    func signIn(request: SigninRequest) -> Observable<AuthResponse> {
        return Observable.create { emitter in
            let provider = self.makeProvider()
            let disposable = provider.rx.request(.signIn(userInfo: request))
                .map { response in
                    // 헤더 추출 및 매핑
                    let headers = response.response?.allHeaderFields as? [String: String]
                    let accessToken = headers?["Authorization"] ?? ""
                    let refreshToken = headers?["authorization-refresh"] ?? ""
                    let email = headers?["email"] ?? ""
                    let nickName = headers?["nickName"] ?? ""
                    
                    return AuthResponse(authorization: accessToken, authorizationRefresh: refreshToken, email: email, nickName: nickName)
                }
                .asObservable()
                .subscribe { event in
                    switch event {
                    case .next(let response):
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
    
    // MARK: - 닉네임 중복 검사 함수
    func checkDuplicateNickname(request: CheckNickNameRequest) -> Observable<CheckNickNameResponse> {
        return Observable.create { emitter in
            let provider = self.accessProvider()
            let disposable = provider.rx.request(.checkDuplicateNickname(nickName: request))
                .map(CheckNickNameResponse.self)
                .asObservable()
                .subscribe { event in
                    switch event {
                    case .next(let response):
                        print("🔎 닉네임 중복 검사 UserReository checkDuplicateNickname 요청한 닉네임 : \(request.nickname) - \(response.isPresent ? "사용 불가능 ❌" : "사용 가능 ⭕️")")
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
    
    // MARK: - 첫 사용자 프로필 생성 함수
    func setProfile(profile: Profile) -> Observable<SetProfileResponse> {
        return Observable.create { emitter in
            let provider = self.accessProvider()
            let disposable = provider.rx.request(.setProfile(profile: profile))
                .map(SetProfileResponse.self)
                .asObservable()
                .subscribe { event in
                    switch event {
                    case .next(let response):
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
    
    func getRefreshToken() -> Observable<AuthResponse> {
        let provider = accessProvider()
        return provider.rx.request(UserAPI.getRefreshToken)
            .map(AuthResponse.self)
            .asObservable()
    }
    
    func resign(email: ResignRequest) -> RxSwift.Observable<ResignResponse> {
        return Observable.create { emitter in
            let provider = self.accessProvider()
            let disposable = provider.rx.request(.resign(email: email))
                .map(ResignResponse.self)
                .asObservable()
                .subscribe { event in
                    switch event {
                    case .next(let response):
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
    
    // MARK: - 프로필 사진 조회
    func findProfileImg(request: FindProfileImgRequest) -> Observable<UIImage> {
        return Observable.create { emitter in
            let provider = self.accessProvider()
            let disposable = provider.rx.request(.findProfileImg(request))
                .map(FindProfileImgResponse.self)
                .map { $0.toDomain() }
                .asObservable()
                .subscribe { event in
                    switch event {
                    case .next(let response):
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
    
    // MARK: - 프로필 소개글 조회
    func findIntroduction(request: FindIntroductionRequest) -> Observable<String> {
        return Observable.create { emitter in
            let provider = self.accessProvider()
            let disposable = provider.rx.request(.findIntroduction(request))
                .map(FindIntroductionResponse.self)
                .map { $0.Introduction }
                .asObservable()
                .subscribe { event in
                    switch event {
                    case .next(let response):
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
}
