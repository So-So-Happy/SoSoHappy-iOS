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
        let imageString = KeychainService.loadData(serviceIdentifier: "sosohappy.userInfo", forKey: "userProfile") ?? ""
        let nickName = KeychainService.getNickName()
        let intro = KeychainService.getUserIntro()
        
        initialState = State (
            profileImage: UIImage(data: Data(base64Encoded: imageString, options: .ignoreUnknownCharacters)!)!,
            nickNameText: nickName,
            selfIntroText: intro, isSameNickName: true
        )
    }
}
