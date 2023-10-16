//
//  FeedRepositoryProtocol.swift
//  SoSoHappy
//
//  Created by 박희경 on 2023/10/02.
//


import Foundation
import RxSwift
import Moya

protocol FeedRepositoryProtocol {
    func saveFeed(feed: MyFeed) -> Observable<SaveFeedResponse>
    func findDayFeed(request: FindFeedRequest) -> Observable<MyFeed>
    func findMonthFeed(request: FindFeedRequest) -> Observable<[MyFeed]>
    func findDetailFeed(request: FindDetailFeedRequest) -> Observable<UserFeed>
    func findOtherFeed(request: FindOtherFeedRequest) -> Observable<FindOtherFeedResponse>
    func findUserFeed(request: FindUserFeedRequest) -> Observable<FindUserFeedResponse>
    func analysisHappiness(request: HappinessRequest) -> Observable<AnalysisHappinessResponse>
    func findMonthHappiness(request: HappinessRequest) -> Observable<FindMonthFeedResponse>
    func findYearHappiness(request: HappinessRequest) -> Observable<FindDayFeedResponse>
    func updatePublicStatus(request: UpdatePublicStatusRequest) -> Observable<UpdatePublicStatusResponse>
    func updateLike(request: UpdateLikeRequest) -> Observable<UpdateLikeResponse>
}

