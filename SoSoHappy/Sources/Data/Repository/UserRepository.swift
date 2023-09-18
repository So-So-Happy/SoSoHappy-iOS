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
        <#code#>
    }
    
    func setProfile(profile: Profile) -> RxSwift.Observable<SetProfileResponse> {
        <#code#>
    }
    
    func resign(email: Resign) -> RxSwift.Observable<ResignResponse> {
        <#code#>
    }
    
    func findProfileImg(nickName: FindProfileImg) -> RxSwift.Observable<FindProfileImgResponse> {
        <#code#>
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
