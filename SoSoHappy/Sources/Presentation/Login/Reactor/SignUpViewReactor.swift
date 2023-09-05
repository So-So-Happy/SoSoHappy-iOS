//
//  SignUpViewReactor.swift
//  SoSoHappy
//
//  Created by Sue on 2023/08/30.
//

import ReactorKit
import RxCocoa
import RxSwift

class SignUpViewReactor: Reactor {
    // MARK: Action
    enum Action {
        case selectImage(UIImage?)
        case nickNameTextChanged(String)
        case selfIntroTextChanged(String)
        case checkDuplicate
        case signUp
    }
    
    // MARK: Mutation
    enum Mutation {
        case setImage(UIImage?)
        case setNickNameText(String)
        case setSelfIntroText(String)
        case isDuplicate(Bool)
        case signUpSuccessed(Bool)
    }
    
    // MARK: State
    struct State {
        var profileImage: UIImage
        var nickNameText: String
        var duplicateMessage: String
        var selfIntroText: String
        var isDuplicate: Bool // 중복 (true) 상태로 초기화
    }
    
    let initialState: State
    
    init() {
        initialState = State(profileImage: UIImage(named: "profile")!, nickNameText: "", duplicateMessage: "", selfIntroText: "", isDuplicate: true)
    }
    
    // MARK: Action -> Mutation
    func mutate(action: Action) -> Observable<Mutation> {
        print("mutate")
        // switch문 (action)
        switch action {
        case let .selectImage(image):
            return Observable.just(Mutation.setImage(image))
            
        case let .nickNameTextChanged(text):
            print("mutate() nickNameTextChanged: \(text)")
            return Observable.just(Mutation.setNickNameText(text))
            
        case let .selfIntroTextChanged(text):
            return Observable.just(Mutation.setSelfIntroText(text))
            
        case .checkDuplicate:
            // 중복 검사 API -> 결과 (중복 - true, 중복 x - false)
            print(".checkDuplicate")
            return Observable.just(Mutation.isDuplicate(true))
            
        case .signUp:
            // 프로필 생성 API -> 결과 (가입 잘 됨 - true, 실패 - false)
            return Observable.just(Mutation.signUpSuccessed(true))
        }
    }
    
    // MARK: Mutation -> State
    func reduce(state: State, mutation: Mutation) -> State {
        print("reduce")
        var newState = state
        
        switch mutation {
        case let .setImage(image):
            print("reduce - setImage")
            if let image = image {
                newState.profileImage = image
            } else {
                newState.profileImage = UIImage(named: "profile")!
            }

        case let .setNickNameText(text):
            newState.nickNameText = String(text.prefix(10))
            
        case let .setSelfIntroText(text):
            newState.selfIntroText = String(text.prefix(60))
            
        case let .isDuplicate(bool):
            print(".isDuplicate: \(bool)")
            newState.isDuplicate = bool
            newState.duplicateMessage = bool ? "사용중인 닉네임입니다" : ""
            
        case let .signUpSuccessed(bool) :
            print("")
            // success 실패했을 때 사용자한테 alert? 이런거 띄워야 할 듯
        }
        
        return newState
    }
}


