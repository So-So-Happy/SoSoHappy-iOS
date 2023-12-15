//
//  setProfile.swift
//  SoSoHappy
//
//  Created by 박희경 on 2023/09/13.
//

import UIKit

struct Profile: Equatable {
    let email: String
    let nickName: String
    let profileImg: UIImage
    let introduction: String
    
    init(email: String, nickName: String, profileImg: UIImage, introduction: String) {
        self.email = email
        self.nickName = nickName
        self.profileImg = profileImg
        self.introduction = introduction
    }
}

extension Profile {
    static func ==(lhs: Profile, rhs: Profile) -> Bool {
        return lhs.email == rhs.email &&
        lhs.nickName == rhs.nickName &&
        lhs.introduction == rhs.introduction &&
        lhs.profileImg.isEqual(rhs.profileImg)
        
    }
}
