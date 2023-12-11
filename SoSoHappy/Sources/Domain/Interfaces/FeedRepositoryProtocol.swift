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
    func saveFeed(request: SaveFeedRequest) -> Observable<Bool>
    func findDayFeed(request: FindFeedRequest) -> Observable<MyFeed>
    func findMonthFeed(request: FindFeedRequest) -> Observable<[MyFeed]>
    func findDetailFeed(request: FindDetailFeedRequest) -> Observable<UserFeed?>
    func findOtherFeed(request: FindOtherFeedRequest) -> Observable<([UserFeed], Bool)>
    func findUserFeed(request: FindUserFeedRequest) -> Observable<([UserFeed], Bool)>
    func analysisHappiness(request: HappinessRequest) -> Observable<AnalysisHappinessResponse>
    func findMonthHappiness(request: HappinessRequest) -> Observable<[ChartEntry]>
    func findYearHappiness(request: HappinessRequest) -> Observable<[ChartEntry]>
    func updatePublicStatus(request: UpdatePublicStatusRequest) -> Observable<UpdatePublicStatusResponse>
    func updateLike(request: UpdateLikeRequest) -> Observable<Bool>
    func findFeedImage(request: FindFeedImageRequest) -> Observable<UIImage?>
}

