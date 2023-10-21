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
    
    func saveFeed(feed: MyFeed) -> Observable<SaveFeedResponse> {
        let provider = accessProvider()
        return provider.rx.request(.saveFeed(feed))
            .map(SaveFeedResponse.self)
            .asObservable()
    }
    
    func findDayFeed(request: FindFeedRequest) -> Observable<MyFeed> {
        let provider = accessProvider()
        return provider.rx.request(.findDayFeed(request))
            .map(FindAccountFeedResponse.self)
            .map({ $0.toDomain() })
            .asObservable()
    }
    
    func findMonthFeed(request: FindFeedRequest) -> Observable<[MyFeed]> {
        return Observable.create { emitter in
            let provider = self.accessProvider()
            let disposable = provider.rx.request(.findMonthFeed(request))
                .map([FindAccountFeedResponse].self)
                .map { $0.map { $0.toDomain() } }
                .asObservable()
                .subscribe { event in
                    switch event {
                    case .next(let response):
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
    
    /// findDetailFeed: 디테일 피드 데이터 fetch
    func findDetailFeed(request: FindDetailFeedRequest) -> Observable<UserFeed> {
        return Observable.create { emitter in
            let provider = self.accessProvider()
            let disposable = provider.rx.request(.findDetailFeed(request))
                .map(FindDetailFeedResponse.self)
                .map { $0.toDomain() }
                .asObservable()
                .subscribe { event in
                    switch event {
                    case .next(let response):
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
    
    
    /// findOtherFeed: 피드 전체 데이터 fetch
    func findOtherFeed(request: FindOtherFeedRequest) -> Observable<FindOtherFeedResponse> {
        return Observable.create { emitter in
            let provider = self.accessProvider()
            let disposable = provider.rx.request(.findOtherFeed(request))
                .map(FindOtherFeedResponse.self)
                .asObservable()
                .subscribe { event in
                    switch event {
                    case .next(let response):
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
    
    /// findUserFeed: 특정 유저 피드 데이터 fetch
    func findUserFeed(request: FindUserFeedRequest) -> Observable<FindUserFeedResponse> {
        return Observable.create { emitter in
            let provider = self.accessProvider()
            let disposable = provider.rx.request(.findUserFeed(request))
                .map(FindUserFeedResponse.self)
                .asObservable()
                .subscribe { event in
                    switch event {
                    case .next(let response):
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
    
    /// updateLike: 좋아요 여부 업데이트
    func updateLike(request: UpdateLikeRequest) -> Observable<UpdateLikeResponse> {
        return Observable.create { emitter in
            let provider = self.accessProvider()
            let disposable = provider.rx.request(.updateLike(request))
                .map(UpdateLikeResponse.self)
                .asObservable()
                .subscribe { event in
                    switch event {
                    case .next(let response):
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
    
    
}