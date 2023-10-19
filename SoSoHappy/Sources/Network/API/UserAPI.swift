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
    case getAuthorizeCode(codeChallenge: AuthCodeRequest)
    case signIn(userInfo: SigninRequest)
    case checkDuplicateNickname(nickName: String)
    case getRefreshToken
    case resign(email: ResignRequest)
    case setProfile(profile: Profile)
    case findProfileImg(nickName: FindProfileImgRequest)
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
        case .getAuthorizeCode:
            return Bundle.main.getAuthorizeCodePath
        case .signIn:
            return Bundle.main.signInPath
        case .checkDuplicateNickname:
            return Bundle.main.checkDuplicateNickNamePath
        case .getRefreshToken:
            return Bundle.main.reIssueTokenPath
        case .setProfile:
            return Bundle.main.setProfilePath
        case .resign:
            return Bundle.main.resignPath
        case .findProfileImg:
            return Bundle.main.fineProfileImgPath
        }
    }
    
    func getMethod() -> Moya.Method {
        switch self {
        case .getAuthorizeCode:
            return .post
        case .signIn:
            return .post
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
        case .getAuthorizeCode(let data):
            var formData: [Moya.MultipartFormData] = []
            let codeChallenge = data.codeChallenge.data(using: .utf8)!
            formData.append(MultipartFormData(provider: .data(codeChallenge), name: "codeChallenge"))
            return .uploadMultipart(formData)
            
        case .signIn(let data):
            var formData: [Moya.MultipartFormData] = []
            let email = data.email.data(using: .utf8)!
            let provider = data.provider.data(using: .utf8)!
            let providerId = data.providerId.data(using: .utf8)!
            let codeVerifier = data.codeVerifier.data(using: .utf8)!
            let authorizeCode = data.authorizeCode.data(using: .utf8)!
            
            formData.append(MultipartFormData(provider: .data(email), name: "email"))
            formData.append(MultipartFormData(provider: .data(provider), name: "provider"))
            formData.append(MultipartFormData(provider: .data(providerId), name: "providerId"))
            formData.append(MultipartFormData(provider: .data(codeVerifier), name: "codeVerifier"))
            formData.append(MultipartFormData(provider: .data(authorizeCode), name: "authorizeCode"))
            
            return .uploadMultipart(formData)
            
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
}


extension UserAPI: JWTAuthorizable {
    var authorizationType: JWTAuthorizationType? {
        switch self {
        case .getAuthorizeCode: return .accessToken
        case .signIn: return .accessToken
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
