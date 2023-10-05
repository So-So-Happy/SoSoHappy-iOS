//
//  UserRepository.swift
//  SoSoHappy
//
//  Created by 박희경 on 2023/09/04.
//

import Foundation
import RxSwift
import Moya


final class UserRepository: UserRepositoryProtocol, Networkable {
   
    // MARK: - Target
    typealias Target = UserAPI

    // 서버한테 요청
    func kakaoLogin() -> Single<AuthResponse> {
        return makeProvider().rx.request(.kakaoLogin)
            .flatMap { response -> Single<AuthResponse> in
                // 응답 헤더에서 accessToken과 refreshToken 추출
                if let accessToken = response.response?.allHeaderFields["Authorization"] as? String,
                   let refreshToken = response.response?.allHeaderFields["AuthorizationRefresh"] as? String {
                    let authResponse = AuthResponse(Authorization: accessToken, AuthorizationRefresh: refreshToken)
                    return .just(authResponse)
                } else {
                    return .error(HTTPError.unauthorized)
                }
            }
    }
    
    func googleLogin() -> Single<AuthResponse> {
        return makeProvider().rx.request(.googleLogin)
            .flatMap { response -> Single<AuthResponse> in
                // 응답 헤더에서 accessToken과 refreshToken 추출
                if let accessToken = response.response?.allHeaderFields["Authorization"] as? String,
                   let refreshToken = response.response?.allHeaderFields["AuthorizationRefresh"] as? String {
                    let authResponse = AuthResponse(Authorization: accessToken, AuthorizationRefresh: refreshToken)
                    return .just(authResponse)
                } else {
                    return .error(HTTPError.unauthorized)
                }
            }
    }
    
    func checkDuplicateNickname(nickName: String) -> Observable<CheckNickNameResponse> {
        return makeProvider().rx.request(.checkDuplicateNickname(nickName: nickName))
            .map(CheckNickNameResponse.self)
            .asObservable()
    }
    
    func getRefreshToken() -> Observable<AuthResponse> {
        return accessProvider().rx.request(UserAPI.getRefreshToken)
            .map(AuthResponse.self)
            .asObservable()
    }
    
    
    func setProfile(profile: Profile) -> RxSwift.Observable<SetProfileResponse> {
        return makeProvider().rx.request(.kakaoLogin)
                    .map(SetProfileResponse.self)
                    .asObservable()
    }
    
    func resign(email: ResignRequest) -> RxSwift.Observable<ResignResponse> {
        return makeProvider().rx.request(.kakaoLogin)
                    .map(ResignResponse.self)
                    .asObservable()
    }
    
    func findProfileImg(nickName: FindProfileImgRequest) -> RxSwift.Observable<FindProfileImgResponse> {
        return makeProvider().rx.request(.kakaoLogin)
                    .map(FindProfileImgResponse.self)
                    .asObservable()
    }
    
}
