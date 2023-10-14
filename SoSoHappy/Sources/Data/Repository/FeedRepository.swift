//
//  Repository.swift
//  SoSoHappy
//
//  Created by 박민주 on 2023/08/07.
//

import Foundation
import Moya
import RxSwift
import RxCocoa


final class FeedRepository: FeedRepositoryProtocol, Networkable {
    
    
    // MARK: - Target
    typealias Target = FeedAPI
    
    func saveFeed(feed: Feed) -> Observable<SaveFeedResponse> {
        let provider = accessProvider()
        return provider.rx.request(.saveFeed(feed))
            .map(SaveFeedResponse.self)
            .asObservable()
    }
    
    func findDayFeed(request: FindFeedRequest) -> Observable<Feed> {
        let provider = accessProvider()
        return provider.rx.request(.findDayFeed(request))
            .map(FindAccountFeedResponse.self)
            .map({ $0.toDomain() })
            .asObservable()
    }
    
    func findMonthFeed(request: FindFeedRequest) -> Observable<[Feed]> {
        let provider = accessProvider()
        return Observable.create { emitter in
            let provider = self.accessProvider()
            let disposable = provider.rx.request(.findMonthFeed(request))
                .map([FindAccountFeedResponse].self)
                .map { $0.map { $0.toDomain() } }
                .asObservable()
                .subscribe { event in
                    switch event {
                    case .next(let response):
                        print("response: \(response)")
                        emitter.onNext(response)
                    case .error(let error):
                        emitter.onError(error)
                    case .completed:
                        emitter.onCompleted()
                    }
                }
            
            return Disposables.create() {
                disposable.dispose()
            }
        }
    }
    
    func findDayFeedTest(request: FindFeedRequest) {
        let provider = accessProvider()
        provider.rx.request(.findMonthFeed(request))
            .asObservable()
            .map([FindAccountFeedResponse].self)
            .map { $0.map { $0.toDomain() } }
            .subscribe { data in
                print("findDayFeedTest success: \(data)")
            }
    }
    
    func findOtherFeed(request: FindOtherFeedRequest) -> Observable<FindOtherFeedResponse> {
        let provider = accessProvider()
        return provider.rx.request(.findOtherFeed(request))
            .map(FindOtherFeedResponse.self)
            .asObservable()
    }
    
    func findUserFeed(request: FindUserFeedRequest) -> Observable<FindUserFeedResponse> {
        let provider = accessProvider()
        return provider.rx.request(.findUserFeed(request))
            .map(FindUserFeedResponse.self)
            .asObservable()
    }
    
    func analysisHappiness(request: HappinessRequest) -> Observable<AnalysisHappinessResponse> {
        let provider = accessProvider()
        return provider.rx.request(.analysisHappiness(request))
            .map(AnalysisHappinessResponse.self)
            .asObservable()
    }
    
    func findMonthHappiness(request: HappinessRequest) -> Observable<FindMonthFeedResponse> {
        let provider = accessProvider()
        return provider.rx.request(.findMonthHappiness(request))
            .map(FindMonthFeedResponse.self)
            .asObservable()
    }
    
    func findYearHappiness(request: HappinessRequest) -> Observable<FindDayFeedResponse> {
        let provider = accessProvider()
        return provider.rx.request(.findYearHappiness(request))
            .map(FindDayFeedResponse.self)
            .asObservable()
    }
    
    func updatePublicStatus(request: UpdatePublicStatusRequest) -> Observable<UpdatePublicStatusResponse> {
        let provider = accessProvider()
        return provider.rx.request(.updatePublicStatus(request))
            .map(UpdatePublicStatusResponse.self)
            .asObservable()
    }
    
    func updateLike(request: UpdateLikeRequest) -> Observable<UpdateLikeResponse> {
        let provider = accessProvider()
        return provider.rx.request(.updateLike(request))
            .map(UpdateLikeResponse.self)
            .asObservable()
    }
    
    
}
