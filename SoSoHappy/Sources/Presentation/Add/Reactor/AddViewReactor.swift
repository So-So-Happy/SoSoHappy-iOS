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
        case testdselectCategory(IndexPath)
        
        case selectCategory(String)
        case deselectCategory(String)
    }
    
    enum Mutation {
        // MARK: Add1
        case setSelectedWeather(Int)
        case setSelectedHappiness(Int)
        
        // MARK: Add2
        case setCategories([String])
        case deselectCategoryItem(Int)
        
        case testsetCategories([IndexPath])
    }
    
    struct State {
        // MARK: Add1
        var selectedWeather: Int?
        var selectedHappiness: Int?
        var selectedCategories: [String] = []
        var deselectCategoryItem: Int?
        
        // MARK: Add2
        var testselectedCategories: [IndexPath] = []
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
            
        case let .selectCategory(category):
            var selectedCategories = currentState.selectedCategories
            selectedCategories.insert(category, at: 0)
            
            
            if selectedCategories.count > 3 {
                print("3 이상")
                let removed = selectedCategories.removeLast()
                let removedItem = categories.firstIndex(of: removed)!
                
                return Observable.concat([
                    Observable.just(.deselectCategoryItem(removedItem)),
                    Observable.just(.setCategories(selectedCategories))
                ])
                
//                return Observable.just(.deselectCategoryIndex(index))
            }
            
            print("String.self SELECT - \(category), selectedCategories : \(selectedCategories)")
        
            return Observable.just(.setCategories(selectedCategories))
            
        case .deselectCategory(let category):
            var selectedCategories = currentState.selectedCategories
            
            if let index = selectedCategories.firstIndex(of: category) {
                selectedCategories.remove(at: index)
                print("String.self DESELECT - \(category), selectedCategories : \(selectedCategories)")
                
                return Observable.just(.setCategories(selectedCategories))
            }
            
            return .empty()
            
            // MARK: - 현재 작업하고 있는 부분
        case let .testselectCategory(indexPath):
            print("IndexPath : \(indexPath)")
            print("IndexPath.section : \(indexPath.section)") // 0
            print("IndexPath.item : \(indexPath.item)") // 15
            
            var selectedCategories = currentState.testselectedCategories
            selectedCategories.append(indexPath)
            
            print("test SELET Category: \(indexPath), arr : \(selectedCategories)")
            
            return Observable.just(.testsetCategories(selectedCategories))
            
        case let .testdselectCategory(indexPath):
            
            var selectedCategories = currentState.testselectedCategories
            if let index = selectedCategories.firstIndex(of: indexPath) {
                selectedCategories.remove(at: index)
                print("test DESELECT Category: \(indexPath), arr : \(selectedCategories)")
                
                return Observable.just(.testsetCategories(selectedCategories))
            }
            
            return .empty()
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case let .setSelectedWeather(tag):
            newState.selectedWeather = tag
        case let .setSelectedHappiness(tag):
            newState.selectedHappiness = tag
        case let .setCategories(categories):
            newState.selectedCategories = categories
            
        case let .deselectCategoryItem(deselectedCategoryItem):
            newState.deselectCategoryItem = deselectedCategoryItem
            
            
        case let .testsetCategories(indexPathArray):


            newState.testselectedCategories = indexPathArray
        }
        return newState
    }
}

extension AddViewReactor {
    private func selectedCategoriesString(indexPathArr: [IndexPath]) -> [String] {
        return [ ]
    }
}

