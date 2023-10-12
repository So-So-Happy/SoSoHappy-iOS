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
    case checkDuplicateNickname(nickName: String)
    case getRefreshToken
    case resign(email: Resign)
    case setProfile(profile: Profile)
    case findProfileImg(nickName: FindProfileImg)
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
            return ""
        case .kakaoLogin:
            return "/auth-service/oauth2/authorization/kakao"
        case .checkDuplicateNickname:
            return ""
        case .getRefreshToken:
            return ""
        case .setProfile:
            return ""
        case .resign:
            return ""
        case .findProfileImg:
            return ""
        }
    }
    
    func getMethod() -> Moya.Method {
        switch self {
        case .googleLogin:
            return .get
        case .kakaoLogin:
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
        }
    }
    
    func getTask() -> Task {
        switch self {
        case .googleLogin:
            return .requestPlain
        case .kakaoLogin:
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
        case .findProfileImg(let nickName):
            return .requestJSONEncodable(nickName)
        }
    }
    
    func getHeader() -> [String : String]? {
        return [:]
    }
}


extension UserAPI: JWTAuthorizable {
    var authorizationType: JWTAuthorizationType? {
        switch self {
        case .googleLogin: return .none
        case .kakaoLogin: return .none
        case .checkDuplicateNickname: return .none
        case .getRefreshToken: return .refreshToken
        case .setProfile: return .accessToken
        case .resign: return .accessToken
        case .findProfileImg: return .accessToken
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
