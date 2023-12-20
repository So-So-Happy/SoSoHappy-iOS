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
    
    // MARK: - Class member property
    let disposeBag = DisposeBag()
    var initialState: State
    private let userRepository = UserRepository()
    
    // MARK: - Action
    enum Action {
        case selectImage(UIImage?)
        case nickNameTextChanged(String)
        case selfIntroTextChanged(String)
        case checkDuplicate
        case tapSignUpButton
        case signUp
    }
    
    // MARK: - Mutation
    enum Mutation {
        case setImage(UIImage?)
        case setNickNameText(String)
        case setSelfIntroText(String)
        case isDuplicate(Bool)
        case showFinalAlert(Bool)
        case showErrorAlert(Error)
        case clearAlert
        case goToMain(Bool)
    }
    
    // MARK: - State
    struct State {
        var profileImage: UIImage
        var nickNameText: String
        var selfIntroText: String
        var isDuplicate: Bool?
        var showFinalAlert: Bool?
        var showErrorAlert: Error?
    
        var goToMain: Bool?
        var isSameNickName: Bool
    }
    
    // MARK: - Init
    init() {
        initialState = State (
            profileImage: UIImage(named: "profile")!,
            nickNameText: "",
            selfIntroText: "", isSameNickName: true
        )
    }
    
    // MARK: - Action -> Mutation
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .selectImage(image):
            return Observable.just(Mutation.setImage(image))
            
        case let .nickNameTextChanged(text):
            return Observable.just(Mutation.setNickNameText(text))
            
        case let .selfIntroTextChanged(text):
            return Observable.just(Mutation.setSelfIntroText(text))
            
        case .checkDuplicate:
            return .concat([checkDuplicateNickname(), .just(Mutation.clearAlert)])
            
        case .tapSignUpButton:
            return .concat([.just(Mutation.showFinalAlert(true)), .just(Mutation.clearAlert)])
        
        case .signUp:
            return .concat([setProfile(), .just(Mutation.clearAlert)])
        }
    }
    
    // MARK: - Mutation -> State
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case let .setImage(image):
            if let image = image {
                newState.profileImage = image
            }

        case let .setNickNameText(text):
            let textWithoutSpace = text.replacingOccurrences(of: " ", with: "")
            let newText = String(textWithoutSpace.prefix(10))
            newState.nickNameText = newText

            if currentState.nickNameText != newText {
                newState.isDuplicate = nil
            }

            let nickNameFromKeychain = KeychainService.getNickName()
            newState.isSameNickName = nickNameFromKeychain == newText
            
        case let .setSelfIntroText(text):
            newState.selfIntroText = String(text.prefix(60))
            
        case let .isDuplicate(bool):
            newState.isDuplicate = bool
            
        case let .showFinalAlert(bool):
            newState.showFinalAlert = bool
            
        case let .goToMain(bool):
            newState.showFinalAlert = false
            newState.goToMain = bool
            
        case let .showErrorAlert(error):
            newState.showErrorAlert = error
            newState.showFinalAlert = false
            
        case .clearAlert:
            newState.showErrorAlert = nil
            newState.showFinalAlert = nil
        }
        
        return newState
    }
}

// MARK: - Custom functions
extension SignUpViewReactor {
    
    // MARK: 닉네임 중복 검사
    func checkDuplicateNickname() -> Observable<Mutation> {
        return userRepository.checkDuplicateNickname(request: CheckNickNameRequest(nickname: currentState.nickNameText))
            .do(onNext: { _ in })
            .flatMap { [weak self] response -> Observable<Mutation> in
                guard self != nil else { return .error(BaseError.unknown) }
                guard KeychainService.getNickName() == self?.currentState.nickNameText else {
                    return .just(.isDuplicate(Bool(response.isPresent)))
                }
                return .just(.isDuplicate(false))
            }
            .catch { return .just(.showErrorAlert($0)) }
    }
    
    // MARK: 프로필 설정 완료 후 서버와의 통신 결과 받아오기 & 키체인에 닉네임 저장
    func setProfile() -> Observable<Mutation> {
        let provider = KeychainService.getProvider()
        let trimmedSelfIntroText = currentState.selfIntroText.trimTrailingWhitespaces()
        let email = KeychainService.getUserEmail()
        let nickName = currentState.nickNameText
        let profileImage = currentState.profileImage
        let intro = trimmedSelfIntroText
        
        return userRepository.setProfile(profile: Profile(email: email, nickName: nickName, profileImg: profileImage, introduction: intro))
            .do(onNext: { signupResponse in
                KeychainService.saveData(serviceIdentifier: "sosohappy.userInfo\(provider)", forKey: "userNickName", data: nickName)
                KeychainService.saveData(serviceIdentifier: "sosohappy.userInfo", forKey: "userIntro", data: intro)
            })
            .flatMap { [weak self] signupResponse -> Observable<Mutation> in
                guard self != nil else { return .error(BaseError.unknown) }
                return .just(.goToMain(signupResponse.success))
            }
            .catch { return .just(.showErrorAlert($0)) }
    }
}
