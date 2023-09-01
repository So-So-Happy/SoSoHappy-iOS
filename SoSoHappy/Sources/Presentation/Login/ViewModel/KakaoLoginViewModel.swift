//
//  KakaoLoginViewModel.swift
//  SoSoHappy
//
//  Created by 박민주 on 2023/08/07.
//

import Foundation
import Combine
import RxKakaoSDKAuth
import RxKakaoSDKUser
import KakaoSDKAuth
import KakaoSDKUser
import RxSwift

class KakaoLoginViewModel: ObservableObject {
    
    // Class member property
    let disposeBag = DisposeBag()
    
    init() {
        print("LoginVM - init() called")
    }
    
    // MARK: - Login (카카오톡 & 카카오계정)
    func handleKakaoLogin() {
        print("LoginVM - handleKakaoLogin() called")

        // Check the availability of Kakao Talk
        if (UserApi.isKakaoTalkLoginAvailable()) {
            UserApi.shared.rx.loginWithKakaoTalk()
                .subscribe(onNext:{ (oauthToken) in
                    print("loginWithKakaoTalk() success.")
                    
                    // 성공 시 사용자 정보 가져오기
                    self.getUserInfo()
                    
                    _ = oauthToken
                }, onError: {error in
                    print("loginWithKakaoTalk() error :", error)
                })
                .disposed(by: disposeBag)
        } else { // If you don't have Kakaotalk installed
            UserApi.shared.rx.loginWithKakaoAccount()
                .subscribe(onNext:{ (oauthToken) in
                    print("loginWithKakaoAccount() success.")
                    
                    // 성공 시 사용자 정보 가져오기
                    self.getUserInfo()
                    
                    _ = oauthToken
                }, onError: {error in
                    print("loginWithKakaoAccount() error :", error)
                })
                .disposed(by: disposeBag)
        }
    }
    
    // MARK: - 토큰 정보 보기
    func checkToken() { // 사용자 액세스 토큰 정보 조회
        UserApi.shared.rx.accessTokenInfo()
            .subscribe(onSuccess:{ (accessTokenInfo) in
                print("accessTokenInfo() success.")
                
                //do something
                _ = accessTokenInfo
                
            }, onFailure: {error in
                print(error)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - 사용자 정보 가져오기
    func getUserInfo() {
        UserApi.shared.rx.me()
            .subscribe (onSuccess:{ user in
                print("me() success.")
                print("user's kakaoAccount :", user.kakaoAccount ?? "사용자 정보 조회 실패")
                //do something
                _ = user
            }, onFailure: {error in
                print(error)
            })
            .disposed(by: disposeBag)
    }
}
