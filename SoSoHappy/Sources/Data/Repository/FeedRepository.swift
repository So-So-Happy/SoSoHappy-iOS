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
    // MARK: 이미지 넣는거 성공하면 동환님이랑 이 경로 설정에 대해서 이야기 해보기
    // FeedAPI - 이미지 경로 문제
    // SaveFeedResponse - success(true, false), message (성공 or nil)
    // 추후에 에러 처리는 필요
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
                        print("saveFeed - success :")
                        emitter.onNext(response)
                    case .error(let error):
                        print("saveFeed - error: \(error.localizedDescription)")
                        emitter.onError(error)
                    case .completed:
                        print("saveFeed - completed")
                        emitter.onCompleted()
                    }
                }
            
            return Disposables.create() {
                disposable.dispose()
            }
        }
    }
    
    func findDayFeed(request: FindFeedRequest) -> Observable<MyFeed> {
//        let provider = accessProvider()
//        return provider.rx.request(.findDayFeed(request))
//            .map(FindAccountFeedResponse.self)
//            .map({ $0.toDomain() })
//            .asObservable()
//        
        print("FindDayFeed start")
        return Observable.create { emitter in
            let provider = self.accessProvider()
            let disposable = provider.rx.request(.findDayFeed(request))
                .map(FindAccountFeedResponse.self)
                .map({ $0.toDomain() })
                .asObservable()
                .subscribe { event in
                    switch event {
                    case .next(let response):
                        print("FindDayFeed success: \(response)")
                        emitter.onNext(response)
                    case .error(let error):
                        print("FindDayFeed error: \(error.localizedDescription)")
                        emitter.onError(error)
                    case .completed:
                        print("FindDayFeed completed")
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
                        print("respsonse")
                        print("findMonthFeed response: \(response)")
                        emitter.onNext(response)
                    case .error(let error):
                        print("error: \(error.localizedDescription)")
                        emitter.onError(error)
                    case .completed:
                        print("completed")
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
//            print("findDetailFeed 메서드 시작")
            let provider = self.accessProvider()
            let disposable = provider.rx.request(.findDetailFeed(request))
                .map(FindDetailFeedResponse.self)
                .map { $0.toDomain() }
                .asObservable()
                .subscribe { event in
                    switch event {
                    case .next(let response):
//                        print("findDetailFeed success : \(response)")
                        emitter.onNext(response)
                    case .error(let error):
//                        print("findDetailFeed error : \(error.localizedDescription)")
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
//        print("여기 FeedRepository  - findOtherFeed")
        return Observable.create { emitter in
            let provider = self.accessProvider()
//            print("FeedRepository  - findOtherFeed - Observable")
            let disposable = provider.rx.request(.findOtherFeed(request))
                .debug()
                .map(FindOtherFeedResponse.self)
                .map { ($0.content.map { $0.toDomain() }, $0.isLast) }
                .asObservable()
                .subscribe { event in
//                    print("event: \(event)")
                    switch event {
                    case .next(let response):
//                        print("~~~findOtherfeed response : \(response) ")
                        emitter.onNext(response)
                    case .error(let error):
//                        print("FeedRepository  - findOtherFeed - 에러 남: \(error.localizedDescription)")
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
        func findUserFeed(request: FindUserFeedRequest) -> Observable<[UserFeed]> {
            return Observable.create { emitter in
                let provider = self.accessProvider()
                let disposable = provider.rx.request(.findUserFeed(request))
                    .map(FindUserFeedResponse.self)
                    .map { $0.content.map { $0.toDomain() }}
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
    
    // 이 코드 가능하면 이걸로 change
    //    func findUserFeed(request: FindUserFeedRequest) -> Observable<[UserFeed]> {
//           return self.provider.rx
//               .request(.findUserFeed(request))
//               .map(FindUserFeedResponse.self)
//               .map { $0.content.map { $0.toDomain() } }
//               .asObservable()
//               .do(onSuccess: { response in
//                   print("findUserFeed success: \(response)")
//               })
//               .catchError { error in
//                   return Observable.error(error)
//               }
//       }
    
    func analysisHappiness(request: HappinessRequest) -> Observable<AnalysisHappinessResponse> {
        let provider = accessProvider()
        return provider.rx.request(.analysisHappiness(request))
            .map(AnalysisHappinessResponse.self)
            .asObservable()
    }
    
    func findMonthHappiness(request: HappinessRequest) -> Observable<[FindHappinessResponse]> {
        let provider = accessProvider()
        return provider.rx.request(.findMonthHappiness(request))
            .map([FindHappinessResponse].self)
            .asObservable()
    }
    
    func findYearHappiness(request: HappinessRequest) -> Observable<[FindHappinessResponse]> {
        let provider = accessProvider()
        return provider.rx.request(.findYearHappiness(request))
            .map([FindHappinessResponse].self)
            .asObservable()
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
                        print("updateLike response success : \(response)")
                        emitter.onNext(response)
                    case .error(let error):
                        print("updateLike error : \(error.localizedDescription)")
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
