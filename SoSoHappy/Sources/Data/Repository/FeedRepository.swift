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

// 오타문제
// request - form
// config
// imageList type
// reacotr mutate subscribe

final class FeedRepository: FeedRepositoryProtocol, Networkable {
    // MARK: - Target
    typealias Target = FeedAPI

    func saveFeed(request: SaveFeedRequest) -> Observable<Bool> {
        return Observable.create { emitter in
            let provider = self.accessProvider()
            let disposable = provider.rx.request(.saveFeed(request))
                .map(SaveFeedResponse.self)
                .map { $0.success }
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
    
    func findDayFeed(request: FindFeedRequest) -> Observable<MyFeed> {
        return Observable.create { emitter in
            let provider = self.accessProvider()
            let disposable = provider.rx.request(.findDayFeed(request))
                .map(FindAccountFeedResponse.self)
                .map({ $0.toDomain() })
                .asObservable()
                .catchAndReturn(MyFeed())
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
    
    // 유저가 이번 달 올린 피드
    func findMonthFeed(request: FindFeedRequest) -> Observable<[MyFeed]> {
        return Observable.create { emitter in
            let provider = self.accessProvider()
            let disposable = provider.rx.request(.findMonthFeed(request))
                .map([FindAccountFeedResponse].self)
                .map { $0.map { $0.toDomain() }}
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
    
    /// findDetailFeed: 디테일 피드 데이터 fetch (삭제된 경우 200 nil로 내려옴)
    func findDetailFeed(request: FindDetailFeedRequest) -> Observable<UserFeed?> {
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
    func findOtherFeed(request: FindOtherFeedRequest) -> Observable<([UserFeed], Bool)> {
        return Observable.create { emitter in
            let provider = self.accessProvider()
            let disposable = provider.rx.request(.findOtherFeed(request))
                .map(FindOtherFeedResponse.self)
                .map { ($0.content.map { $0.toDomain() }, $0.isLast) }
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
    
    /// findUserFeed: 특정 유저 피드 데이터 fetch (추후에 등록된 피드가 없을 경우 고려해서 코드 수정해줘야 함)
    func findUserFeed(request: FindUserFeedRequest) -> Observable<([UserFeed], Bool)>{
        return Observable.create { emitter in
            let provider = self.accessProvider()
            let disposable = provider.rx.request(.findUserFeed(request))
                .map(FindUserFeedResponse.self)
                .map { ($0.content.map { $0.toDomain() }, $0.isLast) }
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
    
    func findFeedImage(request: FindFeedImageRequest) -> Observable<UIImage?> {
        let provider = accessProvider()
        return Observable.create { emitter in
            let disposable = provider.rx.request(.findFeedImage(request))
                .map(FindFeedImageResponse.self)
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
    
    func getFeedImages(ids: [Int]) -> Observable<[UIImage]> {
        return Observable.from(ids)
            .flatMap { i in self.findFeedImage(request: FindFeedImageRequest(imageId: i)).catchAndReturn(nil) }
            .compactMap { $0 }
            .toArray()
            .asObservable()
    }
    
    func analysisHappiness(request: HappinessRequest) -> Observable<AnalysisHappinessResponse> {
        return Observable.create { emitter in
            let provider = self.accessProvider()
            let disposable = provider.rx.request(.analysisHappiness(request))
                .map(AnalysisHappinessResponse.self)
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
    
    // FIXME: - UseCase refectoring please
    func findMonthHappiness(request: HappinessRequest) -> Observable<[ChartEntry]> {
        return Observable.create { emitter in
            let provider = self.accessProvider()
            let disposable = provider.rx.request(.findMonthHappiness(request))
                .map([FindMonthHappinessResponse].self)
//                .map { responses in
//                    return responses.filter { $0.happiness != 0.0 }
//                }
                .map { $0.map { $0.toDomain() }}
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
    
    func findYearHappiness(request: HappinessRequest) -> Observable<[ChartEntry]> {
        return Observable.create { emitter in
            let provider = self.accessProvider()
            let disposable = provider.rx.request(.findYearHappiness(request))
                .map([FindYearHappinessResponse].self)
//                .map { responses in
//                    return responses.filter { $0.happiness != 0.0 }
//                }
                .map { $0.map { $0.toDomain() }}
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
    
    func updatePublicStatus(request: UpdatePublicStatusRequest) -> Observable<UpdatePublicStatusResponse> {
        let provider = accessProvider()
        return provider.rx.request(.updatePublicStatus(request))
            .map(UpdatePublicStatusResponse.self)
            .asObservable()
    }
    
    /// updateLike: 좋아요 여부 업데이트
    func updateLike(request: UpdateLikeRequest) -> Observable<Bool> {
        return Observable.create { emitter in
            let provider = self.accessProvider()
            let disposable = provider.rx.request(.updateLike(request))
                .map(UpdateLikeResponse.self)
                .map { $0.like }
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
