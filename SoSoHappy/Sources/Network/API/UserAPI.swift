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
    case checkDuplicateNickname(nickName: CheckNickNameRequest)
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
            return Bundle.main.findProfileImgPath
        case .findIntroduction:
            return Bundle.main.findIntrodunction
        }
    }
    
    func getMethod() -> Moya.Method {
        switch self {
        case .getAuthorizeCode:
            return .post
        case .signIn:
            return .post
        case .checkDuplicateNickname:
            return .get
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
            let authorizationCode = data.authorizationCode.data(using: .utf8)!
            let deviceToken = data.deviceToken.data(using: .utf8)!
            
            formData.append(MultipartFormData(provider: .data(email), name: "email"))
            formData.append(MultipartFormData(provider: .data(provider), name: "provider"))
            formData.append(MultipartFormData(provider: .data(providerId), name: "providerId"))
            formData.append(MultipartFormData(provider: .data(codeVerifier), name: "codeVerifier"))
            formData.append(MultipartFormData(provider: .data(authorizeCode), name: "authorizeCode"))
            formData.append(MultipartFormData(provider: .data(authorizationCode), name: "authorizationCode"))
            formData.append(MultipartFormData(provider: .data(deviceToken), name: "deviceToken"))
            
            return .uploadMultipart(formData)
            
        case .checkDuplicateNickname(let nickName):
            return .requestParameters(parameters: nickName.toDictionary(), encoding: URLEncoding.queryString)
            
        case .getRefreshToken:
            return .requestPlain
            
        case .setProfile(let profile):
            let imageData =  MultipartFormData(provider: .data(profile.profileImg.jpegData(compressionQuality: 0.1)!), name: "profileImg", fileName: "jpeg", mimeType: "image/jpeg")
            let nickNameData = MultipartFormData(provider: .data(profile.nickName.data(using: .utf8)!), name: "nickname")
            let emailData = MultipartFormData(provider: .data(profile.email.data(using: .utf8)!), name: "email")
            let introData = MultipartFormData(provider: .data(profile.introduction.data(using: .utf8)!), name: "introduction")
            let formData: [Moya.MultipartFormData] = [emailData, nickNameData, imageData, introData]
            return .uploadMultipart(formData)
            
        case .resign(let data):
            var formData: [Moya.MultipartFormData] = []
            let email = data.email.data(using: .utf8)!
            formData.append(MultipartFormData(provider: .data(email), name: "email"))
            return .uploadMultipart(formData)
            
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
        case .getAuthorizeCode: return .none
        case .signIn: return .none
        case .checkDuplicateNickname: return .accessToken
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
