//
//  LoginViewModel.swift
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

class LoginViewModel: ObservableObject {
    var subscriptions = Set<AnyCancellable>()
    
    init() {
        print("LoginVM - init() called")
    }
    
    // MARK: - Login
    func handleKakaoLogin() {
        print("LoginVM - handleKakaoLogin() called")
        
        // Class member property
        let disposeBag = DisposeBag()
        
        // Check the availability of Kakao Talk
        if (UserApi.isKakaoTalkLoginAvailable()) {
            UserApi.shared.rx.loginWithKakaoTalk()
                .subscribe(onNext:{ (oauthToken) in
                    print("loginWithKakaoTalk() success.")
                    
                    //do something
                    _ = oauthToken
                }, onError: {error in
                    print(error)
                })
                .disposed(by: disposeBag)
        } else { // If you don't have Kakaotalk installed
            UserApi.shared.rx.loginWithKakaoAccount()
                .subscribe(onNext:{ (oauthToken) in
                    print("loginWithKakaoAccount() success.")
                    
                    //do something
                    _ = oauthToken
                }, onError: {error in
                    print(error)
                })
                .disposed(by: disposeBag)
        }
    }
}
