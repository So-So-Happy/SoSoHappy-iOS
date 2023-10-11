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
    // 서버에 보낼 때는 weather를 String으로 보내줘야 해서 인덱스를 뽑아서 사용할 수 있도록 만들었음
    let weatherStrings = ["sunny", "partlyCloudy", "cloudy", "rainy", "snowy"]
    var categories: [String] = [
        "beer", "books", "coffee", "cook",
        "dessert", "drive", "exercise", "food",
        "friends", "game", "home", "love",
        "movie", "music", "nature", "ott",
        "pet", "picture", "poppy", "sea",
        "shopping", "sleep", "study", "trip"
    ]
    
    enum Action {
        case weatherButtonTapped(Int)
        case happinessButtonTapped(Int)
        //        case categorySelected(Int)
        case testselectCategory(IndexPath)
        case testdselectCategory
        case selectCategory(String)
        case deselectCategory(String)
    }
    
    enum Mutation {
        // MARK: Add1
        case setSelectedWeather(Int)
        case setSelectedHappiness(Int)
        
        // MARK: Add2
        case testsetCategories([IndexPath])
        case setCategories([String])
    }
    
    struct State {
        // MARK: Add1
        var selectedWeather: Int?
        var selectedHappiness: Int?
        
        // MARK: Add2
        var testselectedCategories: [IndexPath] = []
        var selectedCategories: [String] = []
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
            
        case .selectCategory(let category):
            print("select")
            // Ensure that we don't select more than 3 categories
//            if currentState.selectedCategories.count < 3 && !currentState.selectedCategories.contains(category) {
//                var newCategories = currentState.selectedCategories
//                newCategories.append(category)
//                return .just(.setCategories(newCategories))
//            }
            var newCategories = currentState.selectedCategories
            newCategories.append(category)
//            print("count : \(newCategories.count)")
//            if newCategories.count > 3 {
//                print("3 넘어감")
//                newCategories.removeFirst()
//            }
            return Observable.just(.setCategories(newCategories))
            
        case .deselectCategory(let category):
            print("deselect")
            var newCategories = currentState.selectedCategories
            if let index = newCategories.firstIndex(of: category) {
                newCategories.remove(at: index)
                return Observable.just(.setCategories(newCategories))
            }
            
            return .empty()
        case let .testselectCategory(indexPath):
            var newIndexPathArray = currentState.testselectedCategories
            newIndexPathArray.append(indexPath)
            
            return Observable.just(.testsetCategories(newIndexPathArray))
            
        case let .testdselectCategory:
            var newIndexPathArray = currentState.testselectedCategories
            newIndexPathArray.removeFirst()
            
            return Observable.just(.testsetCategories(newIndexPathArray))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case let .setSelectedWeather(tag):
            newState.selectedWeather = tag
        case let .setSelectedHappiness(tag):
            newState.selectedHappiness = tag
        case .setCategories(let categories):
            newState.selectedCategories = categories
            
        case let .testsetCategories(indexPathArray):
            newState.testselectedCategories = indexPathArray
        }
        return newState
    }
}


