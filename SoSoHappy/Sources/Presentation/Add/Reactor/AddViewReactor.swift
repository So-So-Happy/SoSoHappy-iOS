//
//  AddViewReactor.swift
//  SoSoHappy
//
//  Created by Sue on 2023/09/29.
//

import ReactorKit
/*
 text: String           // 일기
 imageList: List<File>  // 사진들
 categoryList: [String] // 카테고리
 isPublic: Boole        // 공개 여부
 date: Int              // 작성 날짜
 weather: String        // 날씨
 happiness: Int         // 행복 정도
 nickName: String       // 작성자 닉네임
 
 */

class AddViewReactor: Reactor {
    enum Action {
        case weatherButtonTapped(Int)
        case happinessButtonTapped(Int)
    }
    
    enum Mutation {
        case setSelectedWeather(Int)
        case setSelectedHappiness(Int)
    }
    
    struct State {
        var selectedWeather: Int?
        var selectedHappiness: Int?
    }
    
    let initialState: State
    
    init() {
        initialState = State()
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .weatherButtonTapped(tag):
            print("Weather 버튼 눌림")
            print("tag : \(tag)")
            return Observable.just(.setSelectedWeather(tag))
            
        case let .happinessButtonTapped(tag):
            print("Happiness 버튼 눌림")
            print("tag : \(tag)")
            return Observable.just(.setSelectedHappiness(tag))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case let .setSelectedWeather(tag):
            newState.selectedWeather = tag
        case let .setSelectedHappiness(tag):
            newState.selectedHappiness = tag
        }
        return newState
    }
}
