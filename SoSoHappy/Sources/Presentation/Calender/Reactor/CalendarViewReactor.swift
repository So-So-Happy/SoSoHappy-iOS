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
        switch action {
        case .viewDidLoad:
            print("mutate viewdidload action")
            let fetchFeed = feedRepository.findMonthFeed(request: FindFeedRequest(date: Date().getFormattedYMDH(), nickName: "wonder"))
                .do(onNext: { [weak self] monthFeed in
                    print("monthFeed: \(monthFeed)")
                    self?.monthFeed = monthFeed
                })
                .map { Mutation.setCalendarCell($0) }
//                            .catch { .just(.showErrorAlert($0)) }
            return fetchFeed
        case .tapAlertButton:
            print("mutate tapAlertButton action")
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
        var newState = state
        
        switch mutation {
        case .setCalendarCell(let feeds):
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
}
