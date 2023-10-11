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

final class AddViewReactor: Reactor {
    // MARK: Properties
    // 서버에 보낼 때는 weather를 String으로 보내줘야 해서 인덱스를 뽑아서 사용할 수 있도록 만들었음
    let weatherStrings = ["sunny", "partlyCloudy", "cloudy", "rainy", "snowy"]
    var categories: [String] = [
        "beer", "books", "coffee", "cook",
        "dessert", "drive", "exercise", "food",
        "friends", "game", "home", "love",
        "movie", "music", "nature", "ott",
        "pet", "picture", "youtube", "sea",
        "shopping", "sleep", "study", "trip"
    ]
    let maxSelectedCategories = 3
    
    enum Action {
        // MARK: Add1
        case weatherButtonTapped(Int)
        case happinessButtonTapped(Int)
       
        // MARK: Add2
        case selectCategory(String)
        case deselectCategory(String)
    }
    
    enum Mutation {
        // MARK: Add1
        case setSelectedWeather(Int)
        case setSelectedHappiness(Int)
        
        // MARK: Add2
        case selectedCategories([String])
        case deselectCategoryItem(Int)
    }
    
    struct State {
        // MARK: Add1
        var selectedWeather: Int?
        var selectedHappiness: Int?

        // MARK: Add2
        var selectedCategories: [String] = []
        var deselectCategoryItem: Int?
    }
    
    let initialState: State
    
    init() {
        initialState = State()
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .weatherButtonTapped(tag):
            print("Weather 버튼 눌림, tag: \(tag)")
            return Observable.just(.setSelectedWeather(tag))
            
        case let .happinessButtonTapped(tag):
            print("Happiness 버튼 눌림, tag: \(tag)")
            return Observable.just(.setSelectedHappiness(tag))
            
        case let .selectCategory(category):
            return selectCategory(category)
            
        case .deselectCategory(let category):
            return deselectCategory(category)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case let .setSelectedWeather(tag):
            newState.selectedWeather = tag
            
        case let .setSelectedHappiness(tag):
            newState.selectedHappiness = tag
            
        case let .selectedCategories(categories):
            print("~~~~~~~~~~~~~~~~~~~~  ~~~~~~~~~ ~~~~~~~~ ")
            print("reduce - selectedCategories: \(categories)")
            print("~~~~~~~~~~~~~~~~~~~~  ~~~~~~~~~ ~~~~~~~~ ")
            print("  ")
            print("  ")

            newState.selectedCategories = categories
            
        case let .deselectCategoryItem(deselectedCategoryItem):
            newState.deselectCategoryItem = deselectedCategoryItem
            
        }
        return newState
    }
}

extension AddViewReactor {
    private func selectCategory(_ category: String) -> Observable<Mutation> {
        var selectedCategories = currentState.selectedCategories
        selectedCategories.insert(category, at: 0)
        
        if selectedCategories.count > 3 {
            
            let removed = selectedCategories.removeLast()
            if let removedItem = categories.firstIndex(of: removed){
                print("3 이상, \(selectedCategories) ")
                // 추가되고 제거된 내용을 State의 selectedCategories에 업데이트를 시켜줘야 하기 때문에 .selectedCategories Mutation도 해줘야 함
                return Observable.concat([
                    Observable.just(.deselectCategoryItem(removedItem)),
                    Observable.just(.selectedCategories(selectedCategories))
                ])
                
            }
        }
        
        print("String.self SELECT - \(category), selectedCategories : \(selectedCategories)")
    
        return Observable.just(.selectedCategories(selectedCategories))
    }
    
    private func deselectCategory(_ category: String) -> Observable<Mutation> {
        var selectedCategories = currentState.selectedCategories
        
        if let index = selectedCategories.firstIndex(of: category) {
            selectedCategories.remove(at: index)
            print("String.self DESELECT - \(category), selectedCategories : \(selectedCategories)")
            
            return Observable.just(.selectedCategories(selectedCategories))
        }
        
        return Observable.empty()
    }
}
