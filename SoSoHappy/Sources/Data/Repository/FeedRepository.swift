//
//  Repository.swift
//  SoSoHappy
//
//  Created by 박민주 on 2023/08/07.
//

import Foundation
import RxSwift
import Moya


final class FeedRepository: FeedRepositoryProtocol, Networkable {
    
    
    // MARK: - Target
    typealias Target = FeedAPI
    
    func saveFeed(feed: Feed) -> Observable<SaveFeedResponse> {
        return accessProvider().rx.request(.saveFeed(feed))
            .map(SaveFeedResponse.self)
            .asObservable()
    }
    
    func findDayFeed(request: FindFeedRequest) -> Observable<FindDayFeedResponse> {
        return accessProvider().rx.request(.findDayFeed(request))
            .map(FindDayFeedResponse.self)
            .asObservable()
    }
    
    func findMonthFeed(request: FindFeedRequest) -> Observable<[FindMonthFeedResponse]> {
        return accessProvider().rx.request(.findMonthFeed(request))
            .map([FindMonthFeedResponse].self)
            .asObservable()
    }
    
    func findOtherFeed(request: FindOtherFeedRequest) -> Observable<FindOtherFeedResponse> {
        return accessProvider().rx.request(.findOtherFeed(request))
            .map(FindOtherFeedResponse.self)
            .asObservable()
    }
    
    func findUserFeed(request: FindUserFeedRequest) -> Observable<FindUserFeedResponse> {
        return accessProvider().rx.request(.findUserFeed(request))
            .map(FindUserFeedResponse.self)
            .asObservable()
    }
    
    func analysisHappiness(request: HappinessRequest) -> Observable<AnalysisHappinessResponse> {
        return accessProvider().rx.request(.analysisHappiness(request))
            .map(AnalysisHappinessResponse.self)
            .asObservable()
    }
    
    func findMonthHappiness(request: HappinessRequest) -> Observable<FindMonthFeedResponse> {
        return accessProvider().rx.request(.findMonthHappiness(request))
            .map(FindMonthFeedResponse.self)
            .asObservable()
    }
    
    func findYearHappiness(request: HappinessRequest) -> Observable<FindDayFeedResponse> {
        return accessProvider().rx.request(.findYearHappiness(request))
            .map(FindDayFeedResponse.self)
            .asObservable()
    }
    
    func updatePublicStatus(request: UpdatePublicStatusRequest) -> Observable<UpdatePublicStatusResponse> {
        return accessProvider().rx.request(.updatePublicStatus(request))
            .map(UpdatePublicStatusResponse.self)
            .asObservable()
    }
    
    func updateLike(request: UpdateLikeRequest) -> Observable<UpdateLikeResponse> {
        return accessProvider().rx.request(.updateLike(request))
            .map(UpdateLikeResponse.self)
            .asObservable()
    }
    
}
