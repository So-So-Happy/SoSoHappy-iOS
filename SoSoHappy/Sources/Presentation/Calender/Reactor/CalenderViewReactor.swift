//
//  CalendarViewReactor.swift
//  SoSoHappy
//
//  Created by 박희경 on 2023/10/02.
//

import Foundation
import RxSwift
import ReactorKit
import Moya


final class CalendarViewReactor: Reactor {
    
    // MARK: - property
    let disposeBag = DisposeBag()
    
    let initialState: State
    
    private let feedRepository: FeedRepositoryProtocol
    private let userRepository: UserRepositoryProtocol
    
    private var monthFeed: [Feed] = []
//    private var dayFeed: FindDayFeedResponse
    
    
    // MARK: - Init
    init(
        feedRepository: FeedRepositoryProtocol,
        userRepository: UserRepositoryProtocol,
        state: State = State(
            year: "",
            month: "",
            monthHappinessData: [])
    ) {
        self.feedRepository = feedRepository
        self.userRepository = userRepository
        self.initialState = state
    }
    
    // MARK: - Action
    enum Action {
        case viewDidLoad
        case tapAlertButton
        case tapListButton
//        case tapPreviousButton
//        case tapNextButton
//        case selectDate
    }
    
    // MARK: - Mutaion
    enum Mutation {
        case setCalendarCell([Feed])
        case presentListView
        case presentAlertView
//        case setPreview(Feed)
//        case setMonth(String)
//        case setYear(String)
//        case showErrorAlert(Error)
    }
    
    // MARK: - State
    struct State {
        var year: String
        var month: String
        var monthHappinessData: [Feed]
        @Pulse var presentAlertView: Void?
        @Pulse var presentListView: Void?
//        var happinessPreviewData: Feed
    }
    
    
    // MARK: - mutate func
    func mutate(action: Action) -> Observable<Mutation> {
        print("mutate func start: action: \(action)")
        switch action {
        case .viewDidLoad:
            feedRepository.findDayFeedTest(request: FindFeedRequest(date: Int64(2023091519321353), nickName: "wonder") )
            
            let ob = feedRepository.findMonthFeed(request: FindFeedRequest(date: Int64(2023091519321353), nickName: "wonder"))
                .map { Mutation.setCalendarCell($0) }
              
            return ob
        case .tapAlertButton:
            print("mutate tapAlertButton action")
            let obser = Observable.just(Mutation.presentAlertView)
            return .just(.presentAlertView)
        case .tapListButton:
            print("mutate tabListButton action")
            // 성공
            let provider = MoyaProvider<TestAPI>()
            let sersr = MoyaProvider<TestAPI>().rx.request(.list)
                .subscribe { event in
                    switch event {
                    case let .success(response):
                        print("success: \(response.data)")
                        
                    case let .failure(error):
                        print("error: \(error)")
                    }
                }
            
//                .map(String.self)
//                .subscribe { data in
//                    let dt = data.event.element!
//                    print(dt)
//                }
            
//                .map(String.self)
//                .asObservable()
//                .subscribe { [weak self] (event) in
//                        switch event {
//                        case .success(let response):
//                            print("response: \(response)")
//                        case .error(let error):
//                            print(error.localizedDescription)
//                        }
//                    }
//                    .disposed(by: disposeBag)
            
            
            return .just(.presentListView)
        }
    }

    //MARK: - reduce func
    func reduce(state: State, mutation: Mutation) -> State {
        print("reduce func start, state: \(state), mutation: \(mutation)")
        var newState = state
        switch mutation {
        case .setCalendarCell(let feeds):
            print("reduce setCalendarCell ")
            newState.monthHappinessData = feeds
        case .presentAlertView:
            print("reduce presentAlertView ")
            newState.presentListView = ()
        case .presentListView:
            print("reduce presentAlertView ")
            newState.presentListView = ()
//        case .setPreview(_):
//            <#code#>
//        case .setMonth(_):
//            <#code#>
//        case .setYear(_):
//            <#code#>
//        case .showErrorAlert(_):
//            <#code#>
        }
        
        return newState
    }
    
}


extension CalendarViewReactor {
    func getTestAPI(completion: @escaping (_ succeed: String?, _ failed: Error?) -> Void) {
        MoyaProvider<TestAPI>().request(.list) { result in
            switch result {
            case .success(let model): return completion(String(decoding: model.data, as: UTF8.self), nil)
            case .failure(let error): return completion(nil, error)
            }
        }
    }
    
    func fetchMonthFeedTest() -> Observable<[Feed]> {
        
        return .empty()
    }
    
    
    func fetchMonthFeed() -> Single<[Feed]> {
        let tokenClosure: (TargetType) -> HeaderType = { _ in
            let accessToken = "Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJBY2Nlc3NUb2tlbiIsImV4cCI6MTY5NzI5MDQxMiwiZW1haWwiOiJwa2t5dW5nMjZAZ21haWwuY29tIn0.J_Qh_SmbCm6pdZNbXgwHFx48t7Vb71T3Jnr9Bu9zF1RN4d6RTGCeGUDGFdKuZdtSYuiuYbTIykBxgrzZrRqyEw"
            let refreshToken = "Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJSZWZyZXNoVG9rZW4iLCJleHAiOjE3MDkzNTA0MTIsImVtYWlsIjoicGtreXVuZzI2QGdtYWlsLmNvbSJ9.-xloQBVlGOSD0p5K_7NV4jVoKPYRr8N0k-NYsb7KCsosQyvoAb8I3ECJwd2CjqKzrBov-L1O4Hvgf8LnGZxkpQ"
            
            let email = "pkkyung26@gmail.com"
            
            return HeaderType(email: email, accessToken: accessToken, refreshToken: refreshToken)
        }
        
        let authPlugin = JWTPlugin(tokenClosure)
        let provider = MoyaProvider<FeedAPI>(plugins: [authPlugin])
        let observable = provider.rx.request(.findMonthFeed(FindFeedRequest(date: Int64(2023091519321353), nickName: "wonder")))
            .asObservable()
            .map { response -> [Feed] in
                let jsonDecoder = JSONDecoder()
                do {
                    let decodedData = try jsonDecoder.decode([FindAccountFeedResponse].self, from: response.data)
                    return decodedData.compactMap { $0.toDomain() }
                } catch {
                    return []
                }
            }
        
        
        return Single<[Feed]>.create { single in
            let disposable = observable
                .asSingle()
                .subscribe { data in
                    single(.success(data))
                }
            
            return Disposables.create {
                disposable.dispose()
            }
        }
        
    }
}



