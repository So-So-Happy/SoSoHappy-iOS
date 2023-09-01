//
//  AppleLoginViewModel.swift
//  SoSoHappy
//
//  Created by 박민주 on 2023/08/31.
//

import AuthenticationServices
import RxSwift
import RxCocoa

class AppleLoginViewModel {
    
//    private let appleSignInProvider = ASAuthorizationAppleIDProvider()
//    private let disposeBag = DisposeBag()
//
//    var loginResult: Observable<AppleLoginResult> {
//        return _loginResult.asObservable()
//    }
//    private let _loginResult = PublishSubject<AppleLoginResult>()
//
//    func performAppleLogin() {
//        let request = appleSignInProvider.createRequest()
//        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
//
//        authorizationController.rx.didComplete
//            .subscribe(onNext: { [weak self] response in
//                if let credential = response.authorization.credential as? ASAuthorizationAppleIDCredential {
//                    // 애플 로그인 성공 처리
//                    let user = AppleUser(credential: credential)
//                    self?._loginResult.onNext(.success(user: user))
//                }
//            })
//            .disposed(by: disposeBag)
//
//        authorizationController.rx.didCompleteWithError
//            .subscribe(onNext: { error in
//                // 애플 로그인 실패 처리
//                self._loginResult.onNext(.failure(error: error))
//            })
//            .disposed(by: disposeBag)
//
//        authorizationController.performRequests()
//    }
}

enum AppleLoginResult {
    case success(user: AppleUser)
    case failure(error: Error)
}
