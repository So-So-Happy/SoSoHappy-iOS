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
    func googleLogin() -> RxSwift.Observable<AuthResponse> {
        return UserRepository.makeProvider().rx.request(.kakaoLogin)
                    .map(AuthResponse.self)
                    .asObservable()
    }
    
    func setProfile(profile: Profile) -> RxSwift.Observable<SetProfileResponse> {
        return UserRepository.makeProvider().rx.request(.kakaoLogin)
                    .map(SetProfileResponse.self)
                    .asObservable()
    }
    
    func resign(email: Resign) -> RxSwift.Observable<ResignResponse> {
        return UserRepository.makeProvider().rx.request(.kakaoLogin)
                    .map(ResignResponse.self)
                    .asObservable()
    }
    
    func findProfileImg(nickName: FindProfileImg) -> RxSwift.Observable<FindProfileImgResponse> {
        return UserRepository.makeProvider().rx.request(.kakaoLogin)
                    .map(FindProfileImgResponse.self)
                    .asObservable()
    }
    
   
    // MARK: - Target
    typealias Target = UserAPI

    
    func kakaoLogin() -> Observable<AuthResponse> {
        return UserRepository.makeProvider().rx.request(.kakaoLogin)
            .map(AuthResponse.self)
            .asObservable()
    }
    
    func checkDuplicateNickname(nickName: String) -> Observable<CheckNickNameResponse> {
        return UserRepository.makeProvider().rx.request(.checkDuplicateNickname(nickName: nickName))
            .map(CheckNickNameResponse.self)
            .asObservable()
    }
    
    func getRefreshToken() -> Observable<AuthResponse> {
        return UserRepository.accessProvider().rx.request(UserAPI.getRefreshToken)
            .map(AuthResponse.self)
            .asObservable()
    }
    
}
