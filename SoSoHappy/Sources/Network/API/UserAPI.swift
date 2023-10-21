//
//  UserAPI.swift
//  SoSoHappy
//
//  Created by 박희경 on 2023/09/04.
//

import Moya
import RxSwift
import Alamofire



enum UserAPI {
    case kakaoLogin
    case googleLogin
    case appleLogin
    case checkDuplicateNickname(nickName: String)
    case getRefreshToken
    case resign(email: ResignRequest)
    case setProfile(profile: Profile)
    case findProfileImg(FindProfileImgRequest)
    case findIntroduction(FindIntroductionRequest)
}

// MARK: UserAPI + TargetType
extension UserAPI: BaseTargetType {
    var path: String { self.getPath() }
    var method: Moya.Method { self.getMethod() }
    var task: Moya.Task { self.getTask() }
    var headers: [String : String]? { self.getHeader() }
}

extension UserAPI {
    
    func getPath() -> String {
        switch self {
        case .googleLogin:
            return Bundle.main.googleLoginPath
        case .kakaoLogin:
            return Bundle.main.kakaoLoginPath
        case .appleLogin:
            return Bundle.main.appleLoginPath
        case .checkDuplicateNickname:
            return Bundle.main.checkDuplicateNickNamePath
        case .getRefreshToken:
            return Bundle.main.reIssueTokenPath
        case .setProfile:
            return Bundle.main.setProfilePath
        case .resign:
            return Bundle.main.resignPath
        case .findProfileImg:
            return Bundle.main.findProfileImgPath
        case .findIntroduction:
            return Bundle.main.findIntrodunction
        }
    }
    
    func getMethod() -> Moya.Method {
        switch self {
        case .googleLogin:
            return .get
        case .kakaoLogin:
            return .get
        case .appleLogin:
            return .get
        case .checkDuplicateNickname:
            return .post
        case .getRefreshToken:
            return .get
        case .setProfile:
            return .post
        case .resign:
            return .post
        case .findProfileImg:
            return .post
        case .findIntroduction:
            return .post
        }
    }
    
    func getTask() -> Task {
        switch self {
        case .googleLogin:
            return .requestPlain
        case .kakaoLogin:
            return .requestPlain
        case .appleLogin:
            return .requestPlain
        case .checkDuplicateNickname(let nickName):
            return .requestParameters(parameters: nickName.toDictionary(), encoding: URLEncoding.queryString)
        case .getRefreshToken:
            return .requestPlain
        case .setProfile(let profile):
            let imageData =  MultipartFormData(provider: .data(profile.profileImg.jpegData(compressionQuality: 0.1)!), name: "image", fileName: "jpeg", mimeType: "image/jpeg")
            let nickNameData = MultipartFormData(provider: .data(profile.nickName.data(using: .utf8)!), name: "nickname")
            let emailData = MultipartFormData(provider: .data(profile.email.data(using: .utf8)!), name: "email")
            let introData = MultipartFormData(provider: .data(profile.introduction.data(using: .utf8)!), name: "introduction")
            var formData: [Moya.MultipartFormData] = [imageData, nickNameData, emailData, introData]
            return .uploadMultipart(formData)
        case .resign(let email):
            return .requestJSONEncodable(email)
        case .findProfileImg(let data):
            var formData: [Moya.MultipartFormData] = []
            let nickname = data.nickname.data(using: .utf8)!
            formData.append(MultipartFormData(provider: .data(nickname), name: "nickname"))
            return .uploadMultipart(formData)
        case .findIntroduction(let data):
            var formData: [Moya.MultipartFormData] = []
            let nickname = data.nickname.data(using: .utf8)!
            formData.append(MultipartFormData(provider: .data(nickname), name: "nickname"))
            return .uploadMultipart(formData)
        }
    }
}


extension UserAPI: JWTAuthorizable {
    var authorizationType: JWTAuthorizationType? {
        switch self {
        case .googleLogin: return .none
        case .kakaoLogin: return .none
        case .appleLogin: return .none
        case .checkDuplicateNickname: return .none
        case .getRefreshToken: return .refreshToken
        case .setProfile: return .accessToken
        case .resign: return .accessToken
        case .findProfileImg: return .accessToken
        case .findIntroduction: return .accessToken
        }
    }
}

extension UserAPI {
    public var validationType: ValidationType {
        return .successCodes
    }
}

//
//let parameters = [
//           "userName" : userName
//       ]
//       guard let url = urlComponent?.url else {
//           return
//       }
//
//       Alamofire.upload(multipartFormData: { multipartFormData in
//           for (key, value) in parameters {
//               multipartFormData.append("\(value)".data(using: .utf8)!, withName: key, mimeType: "text/plain")
//           }
