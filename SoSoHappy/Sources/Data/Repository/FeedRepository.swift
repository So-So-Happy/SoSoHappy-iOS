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
        return accessProvider().rx.request(.saveFeed(feed))
            .map(SaveFeedResponse.self)
            .asObservable()
    }
    
    func findDayFeed(request: FindFeedRequest) -> Observable<Feed> {
        return accessProvider().rx.request(.findDayFeed(request))
            .map(FindAccountFeedResponse.self)
            .map({ $0.toDomain() })
            .asObservable()
    }
    
    func findMonthFeed(rq: FindFeedRequest) -> Observable<[Feed]> {
        
        let api = FeedAPI.findMonthFeed(rq)
        
        let observable = accessProvider().rx.request(api)
            .map([FindAccountFeedResponse].self)
            .map { $0.map { $0.toDomain() } }
            .asObservable()
            
        let observable2 = accessProvider().rx.request(api)
            .asObservable()
            
            
        observable2
            .subscribe { response in
                switch response {
                case .next(let status):
                    print("success: \(status.statusCode)")
                case .completed:
                    print("complete")
                case .error(let error):
                    print("error: \(error)")
                }
            }.disposed(by: DisposeBag())
        
        return observable
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
