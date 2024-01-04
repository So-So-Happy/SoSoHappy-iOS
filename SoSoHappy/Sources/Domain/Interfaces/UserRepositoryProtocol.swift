//
//  UserRepositoryProtocol.swift
//  SoSoHappy
//
//  Created by 박민주 on 2023/08/07.
//

import Foundation
import RxSwift

protocol UserRepositoryProtocol {
    func getAuthorizeCode() -> Observable<AuthCodeResponse>
    func checkDuplicateNickname(request: CheckNickNameRequest) -> Observable<CheckNickNameResponse>
    func setProfile(profile: Profile) -> Observable<SetProfileResponse>
    func resign(email: ResignRequest) -> Observable<ResignResponse>
    func getRefreshToken() -> Observable<RelssueTokenResponse>
    func findProfileImg(request: FindProfileImgRequest) -> Observable<UIImage>
    func findIntroduction(request: FindIntroductionRequest) -> Observable<String>
    func block(request: BlockRequest) -> Observable<Bool>
    func unblock(request: UnblockRequest) -> Observable<Bool>
}
