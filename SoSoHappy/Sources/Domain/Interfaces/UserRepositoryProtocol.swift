//
//  UserRepositoryProtocol.swift
//  SoSoHappy
//
//  Created by 박민주 on 2023/08/07.
//

import Foundation
import RxSwift

protocol UserRepositoryProtocol {
    func kakaoLogin() -> Single<AuthResponse>
    func googleLogin() -> Single<AuthResponse>
    func checkDuplicateNickname(nickName: String) -> Observable<CheckNickNameResponse>
    func setProfile(profile: Profile) -> Observable<SetProfileResponse>
    func resign(email: ResignRequest) -> Observable<ResignResponse>
    func getRefreshToken() -> Observable<AuthResponse>
    func findProfileImg(nickName: FindProfileImgRequest) -> Observable<FindProfileImgResponse>
}
