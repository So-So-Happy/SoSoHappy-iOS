//
//  EditProfileViewReactor.swift
//  SoSoHappy
//
//  Created by 박민주 on 11/3/23.
//

import ReactorKit
import RxCocoa
import RxSwift

class EditProfileViewReactor: SignUpViewReactor {
    override init() {
        super.init()
        let provider = KeychainService.loadData(serviceIdentifier: "sosohappy.userInfo", forKey: "provider") ?? ""
        let imageString = KeychainService.loadData(serviceIdentifier: "sosohappy.userInfo", forKey: "userProfile") ?? ""
        let nickName = KeychainService.loadData(serviceIdentifier: "sosohappy.userInfo\(provider)", forKey: "userNickName") ?? ""
        let intro = KeychainService.loadData(serviceIdentifier: "sosohappy.userInfo", forKey: "userIntro") ?? ""
        
        initialState = State (
            profileImage: UIImage(data: Data(base64Encoded: imageString, options: .ignoreUnknownCharacters)!)!,
            nickNameText: nickName,
            selfIntroText: intro
        )
    }
}
