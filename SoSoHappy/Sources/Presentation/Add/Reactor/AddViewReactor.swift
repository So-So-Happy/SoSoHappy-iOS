//
//  AddViewReactor.swift
//  SoSoHappy
//
//  Created by Sue on 2023/09/29.
//

import ReactorKit
import Foundation

enum AddStep {
    case step1
    case step2
}


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
    
    let maximumSelectionCount = 3
    
    enum Action {
        // MARK: Add1
        case weatherButtonTapped(Int) // 0, 1, 2, 3, 4
        case happinessButtonTapped(Int) // 1, 2, 3, 4, 5
        case tapNextButton(AddStep)
       
        // MARK: Add2
        case selectCategory(String)
        case deselectCategory(String)
        
        // MARK: Add3
        case fetchDatasForAdd3
        case tapLockButton
    }
    
    enum Mutation {
        // MARK: Add1
        case setSelectedWeather(Int)
        case setSelectedHappiness(Int)
        case setBeforeMovingToNextStep(AddStep)
        
        // MARK: Add2
        case selectedCategories([String])
        
        // MARK: Add3
        case setDatasForAdd3
        case isPrivate(Bool)
    }
    
    struct State {
        // MARK: Add1
        var selectedWeather: Int?
        var selectedHappiness: Int?
        var date: Date?

        // MARK: Add2
        var selectedCategories: [String] = []
        var deselectCategoryItem: Int?
        
        // MARK: Add3
        var happyAndCategory: [String]?
        var dateString: String?
        var weatherString: String?
        var isPrivate: Bool = true // true - 비공개 , false - 공개
    }
    
    let initialState: State
    
    init() {
        initialState = State()
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .weatherButtonTapped(tag):
            print("mutate - Weather 버튼 눌림, tag: \(tag)")
            return Observable.just(.setSelectedWeather(tag))
            
        case let .happinessButtonTapped(tag):
            print("muate - Happiness 버튼 눌림, tag: \(tag)")
            return Observable.just(.setSelectedHappiness(tag))
            
        case let .tapNextButton(addStep):
            return Observable.just(.setBeforeMovingToNextStep(addStep))
            
        case let .selectCategory(category):
            print("mutate - selectCategory")
            return setSelectedCategory(category)
            
        case .deselectCategory(let category):
            print("mutate - deselectCategory")
            return setDeselectCategory(category)
            
        case .fetchDatasForAdd3:
            print("muate -  fetchDatasForAdd3")
            return Observable.just(.setDatasForAdd3)
            
        case .tapLockButton:
            print("muate -  tapLockButton")
            let isPrivate = !currentState.isPrivate
            return Observable.just(.isPrivate(isPrivate))
            
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case let .setSelectedWeather(tag):
            newState.selectedWeather = tag
            newState.weatherString = weatherStrings[tag]
            
        case let .setSelectedHappiness(tag):
            newState.selectedHappiness = tag
            
        case let .setBeforeMovingToNextStep(stepNow):
            switch stepNow {
            case .step1:
                newState.selectedCategories = []
            case .step2:
                newState.date = Date()
            }
            
        case let .selectedCategories(categories):
            print("~~~~~~~~~~~~~~~~~~~~  ~~~~~~~~~ ~~~~~~~~ ")
            print("reduce - selectedCategories: \(categories)")
            print("~~~~~~~~~~~~~~~~~~~~  ~~~~~~~~~ ~~~~~~~~ ")
            print("  ")
            print("  ")

            newState.selectedCategories = categories
            
        case .setDatasForAdd3:
            print("reduce - setDatasForAdd3")
            // 행복/카테고리 배열
            print("state.selectedHappiness : \(type(of: state.selectedHappiness))") // Optional<Int>
            print("state.selectedWeather: \(type(of: state.selectedWeather))") // Optional<Int>
            if let happyInt = state.selectedHappiness {
                // 행복 + 카테고리
                let happineesImageName = "happy\(happyInt)"
                let happinessAndCategories = [happineesImageName] + state.selectedCategories
                
                //날짜
                let todayDate = Date()
                let dateToString = todayDate.getFormattedYMDE()
            
                //배경 이미지
                let backgroundImageName = weatherStrings[state.selectedWeather!]
                
                newState.happyAndCategory = happinessAndCategories
                newState.dateString = dateToString
            }
            
        case let .isPrivate(isPrivate):
            newState.isPrivate = isPrivate
        }
        return newState
    }
}

extension AddViewReactor {
    // MARK: selectedCategories에 새로 들어온 category 추가
    private func setSelectedCategory(_ category: String) -> Observable<Mutation> {
        var selectedCategories = currentState.selectedCategories
        selectedCategories.append(category)

        return Observable.just(.selectedCategories(selectedCategories))
    }
    
    // MARK: selectedCategories에 category 제거
    private func setDeselectCategory(_ category: String) -> Observable<Mutation> {
        var selectedCategories = currentState.selectedCategories
        if let index = selectedCategories.firstIndex(of: category) {
            selectedCategories.remove(at: index)
        }
        
        return Observable.just(.selectedCategories(selectedCategories))
    }
}

