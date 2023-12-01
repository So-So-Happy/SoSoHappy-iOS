//
//  FeedAPI.swift
//  SoSoHappy
//
//  Created by 박희경 on 2023/09/30.
//

import Moya
import RxSwift
import Alamofire


enum FeedAPI {
    case saveFeed(SaveFeedRequest)
    case findDayFeed(FindFeedRequest)
    case findMonthFeed(FindFeedRequest)
    case findDetailFeed(FindDetailFeedRequest)
    case findOtherFeed(FindOtherFeedRequest)
    case findUserFeed(FindUserFeedRequest)
    case analysisHappiness(HappinessRequest)
    case findMonthHappiness(HappinessRequest)
    case findYearHappiness(HappinessRequest)
    case updatePublicStatus(UpdatePublicStatusRequest)
    case updateLike(UpdateLikeRequest)
}

// MARK: UserAPI + TargetType
extension FeedAPI: BaseTargetType {
    var path: String { self.getPath() }
    var method: Moya.Method { self.getMethod() }
    var task: Moya.Task { self.getTask() }
    var headers: [String : String]? { self.getHeader() }
}

extension FeedAPI {
    
    func getPath() -> String {
        switch self {
        case .saveFeed:
            return Bundle.main.saveFeedPath
        case .findDayFeed:
            return Bundle.main.findDayFeedPath
        case .findMonthFeed:
            return Bundle.main.findMonthFeedPath
        case .findDetailFeed:
            return Bundle.main.findDetailFeed
        case .findOtherFeed:
            return Bundle.main.findOtherFeed
        case .findUserFeed:
            return Bundle.main.findUserFeed
        case .analysisHappiness:
            return Bundle.main.analysisHappinessPath
        case .findMonthHappiness:
            return Bundle.main.findMonthHappinessPath
        case .findYearHappiness:
            return Bundle.main.findYearHappinessPath
        case .updatePublicStatus:
            return Bundle.main.updatePublicStatusPath
        case .updateLike:
            return Bundle.main.updateLikePath
        }
    }
    
    func getMethod() -> Moya.Method {
        switch self {
        case .saveFeed:
            return .post
        case .findDayFeed:
            return .post
        case .findMonthFeed:
            return .post
        case .findDetailFeed:
            return .post
        case .findOtherFeed:
            return .get
        case .findUserFeed:
            return .get
        case .analysisHappiness:
            return .post
        case .findMonthHappiness:
            return .post
        case .findYearHappiness:
            return .post
        case .updatePublicStatus:
            return .post
        case .updateLike:
            return .post
        }
    }
    
    
    func getTask() -> Task {
        switch self {
        case .saveFeed(let data):
            var formData: [Moya.MultipartFormData] = saveFeedMultiparFormData(data: data)

            return .uploadMultipart(formData)
        case .findDayFeed(let data):
            return .requestJSONEncodable(data)
        case .findMonthFeed(let data):
            var formData: [Moya.MultipartFormData] = []
            let nickName = data.nickName.data(using: .utf8)!
            let date = String(data.date).data(using: .utf8)!
            formData.append(MultipartFormData(provider: .data(nickName), name: "nickname"))
            formData.append(MultipartFormData(provider: .data(date), name: "date"))
            return .uploadMultipart(formData)
//            return .requestJSONEncodable(data)
        case .findDetailFeed(let param):
            return .requestParameters(parameters: param.toDictionary(), encoding: URLEncoding.queryString)
        case .findOtherFeed(let param):
            return .requestParameters(parameters: param.params, encoding: URLEncoding.queryString)
        case .findUserFeed(let param):
            return .requestParameters(parameters: param.toDictionary(), encoding: URLEncoding.queryString)
        case .analysisHappiness(let data):
            return .requestJSONEncodable(data)
        case .findMonthHappiness(let data):
            return .requestJSONEncodable(data)
        case .findYearHappiness(let data):
            return .requestJSONEncodable(data)
        case .updatePublicStatus(let data):
            return .requestJSONEncodable(data)
        case .updateLike(let data):
            var formData: [Moya.MultipartFormData] = []
            let srcNickname = data.srcNickname.data(using: .utf8)!
            let date = String(data.date).data(using: .utf8)!
            let nickname = data.nickname.data(using: .utf8)!
            formData.append(MultipartFormData(provider: .data(nickname), name: "nickname"))
            formData.append(MultipartFormData(provider: .data(date), name: "date"))
            formData.append(MultipartFormData(provider: .data(srcNickname), name: "srcNickname"))
            return .uploadMultipart(formData)
        }
    }
    
}


extension FeedAPI: JWTAuthorizable {
    var authorizationType: JWTAuthorizationType? {
        return .accessToken
    }
}

extension FeedAPI {
    public var validationType: ValidationType {
        return .successCodes
    }
}

extension FeedAPI {
    public func saveFeedMultiparFormData(data: SaveFeedRequest) -> [Moya.MultipartFormData] {
        var formData: [Moya.MultipartFormData] = []
        
        for (index, imageData) in (data.imageList ?? []).enumerated() {
            formData.append(MultipartFormData(provider: .data(imageData), name: "imageList[\(index)]", fileName: "image.png", mimeType: "image/png"))
        }
        
        let text = data.text.data(using: .utf8)!
        let categoryListData = data.categoryList.joined(separator: ",").data(using: .utf8)!
        let isPublic = String(data.isPublic).data(using: .utf8)!
        let date = String(data.date).data(using: .utf8)!
        let weather = data.weather.data(using: .utf8)!
        let happiness = String(data.happiness).data(using: .utf8)!
        let nickname = data.nickname.data(using: .utf8)!
        
        formData.append(MultipartFormData(provider: .data(text), name: "text"))
        formData.append(MultipartFormData(provider: .data(categoryListData), name: "categoryList"))
        formData.append(MultipartFormData(provider: .data(isPublic), name: "isPublic"))
        formData.append(MultipartFormData(provider: .data(date), name: "date"))
        formData.append(MultipartFormData(provider: .data(weather), name: "weather"))
        formData.append(MultipartFormData(provider: .data(happiness), name: "happiness"))
        formData.append(MultipartFormData(provider: .data(nickname), name: "nickname"))

        return formData
    }
    
    public func reuturnFeedMultiparFormData(feed: MyFeed) -> [Moya.MultipartFormData] {
        var formData: [Moya.MultipartFormData] = []
        
        for image in feed.imageList {
            let imageData = image.jpegData(compressionQuality: 0.1)!
            formData.append(MultipartFormData(provider: .data(imageData),
                                              name: "image",
                                              fileName: "image.jpeg",
                                              mimeType: "image/jpeg")
            )
        }
        
        let textData = feed.text.data(using: .utf8)!
        let categoryListData = feed.categoryList.joined(separator: ",").data(using: .utf8)!
        let isPublicData = String(feed.isPulic).data(using: .utf8)!
        let dateData = String(feed.date).data(using: .utf8)!
        let weatherData = feed.weather.data(using: .utf8)!
        let happinessData = String(feed.happiness).data(using: .utf8)!
        let nickNameData = feed.nickName.data(using: .utf8)!
       
        formData.append(MultipartFormData(provider: .data(textData), name: "text"))
        formData.append(MultipartFormData(provider: .data(categoryListData), name: "categoryList"))
        formData.append(MultipartFormData(provider: .data(isPublicData), name: "isPublic"))
        formData.append(MultipartFormData(provider: .data(dateData), name: "date"))
        formData.append(MultipartFormData(provider: .data(weatherData), name: "weather"))
        formData.append(MultipartFormData(provider: .data(happinessData), name: "happiness"))
        formData.append(MultipartFormData(provider: .data(nickNameData), name: "nickName"))

        return formData
    }
}

