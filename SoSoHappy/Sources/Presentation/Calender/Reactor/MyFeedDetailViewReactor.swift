//
//  MyFeedDetailViewReactor.swift
//  SoSoHappy
//
//  Created by 박희경 on 2023/11/05.
//



import ReactorKit
import Foundation



final class MyFeedDetailViewReactor: Reactor {
    
    private let feedRepository: FeedRepositoryProtocol
    // MARK: Properties
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
        // Initial Setting
        case viewWillAppear(MyFeed)
        
        // MARK: Add1
        case weatherButtonTapped(Int) // 0, 1, 2, 3, 4
        case happinessButtonTapped(Int) // 1, 2, 3, 4, 5
        case tapNextButton(AddStep)
       
        // MARK: Add2
        case selectCategory(String)
        case deselectCategory(String)
        
        // MARK: Add3
        case fetchDatasForAdd3
        case setContent(String)
        case setSelectedImages([UIImage])
        case tapLockButton
        case tapSaveButton // 저장
    }
    
    enum Mutation {
        // MARK: Add1
        case setSelectedWeather(Int)
        case setSelectedHappiness(Int)
        case setBeforeMovingToNextStep(AddStep)
        
        // MARK: Add2
        case selectedCategories([String])
        case setDate(String)
        
        // MARK: DetailView
        case setImageStackView
        case setContent(String)
        case setSelectedImages([UIImage])
        case isPrivate(Bool)
        case saveFeed(Bool)
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
//        var isSaveFeedSuccess: Bool?
        var isSaveFeedSuccess: Save?
        var content: String = ""
        var selectedImages: [UIImage]?
    }
    
    let initialState: State
    
    init(feedRepository: FeedRepositoryProtocol) {
        initialState = State()
        self.feedRepository = feedRepository
        
    }
    
    // TODO: VC 에 Feed 데이터 넘겨준 후 viewWillAppear 액션에서 init setting
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewWillAppear(let feed):
            return .concat([
                .just(.setSelectedWeather(getWeatherIndex(for: feed.weather) ?? 0)),
                .just(.setSelectedHappiness(feed.happiness)),
                .just(.selectedCategories(feed.categoryList)),
                .just(.setDate(feed.date)),
                .just(.setImageStackView),
                .just(.setContent(feed.text)),
                .just(.setSelectedImages(feed.imageList)),
                .just(.isPrivate(feed.isPulic))
            ])
        case let .weatherButtonTapped(tag):
//            print("mutate - Weather 버튼 눌림, tag: \(tag)")
            return Observable.just(.setSelectedWeather(tag))
            
        case let .happinessButtonTapped(tag):
//            print("muate - Happiness 버튼 눌림, tag: \(tag)")
            return Observable.just(.setSelectedHappiness(tag))
            
        case let .tapNextButton(addStep):
            return Observable.just(.setBeforeMovingToNextStep(addStep))
            
        case let .selectCategory(category):
//            print("mutate - selectCategory")
            return setSelectedCategory(category)
            
        case .deselectCategory(let category):
//            print("mutate - deselectCategory")
            return setDeselectCategory(category)
            
        case .fetchDatasForAdd3:
//            print("muate -  fetchDatasForAdd3")
            return Observable.just(.setImageStackView)
            
        case let .setContent(content):
            let limitedText = String(content.prefix(3000))
//            print("muate -  setContent :\(limitedText)")
            return .just(.setContent(limitedText))
            
        case let .setSelectedImages(images):
            return Observable.just(.setSelectedImages(images))
            
        case .tapLockButton:
//            print("muate -  tapLockButton")
            let isPrivate = !currentState.isPrivate
            return Observable.just(.isPrivate(isPrivate))
            
        case .tapSaveButton:
            // 필요한 것 : text, image, isPublic
            // MARK: 이 부분 강제 언래핑하는거 좀 더 유연하게 처리 필요
            let saveFeedRequest = SaveFeedRequest(
                text: currentState.content,
                images: currentState.selectedImages,
                categoryList: currentState.selectedCategories,
                isPublic: currentState.isPrivate,
                date: currentState.date!.getFormattedYMDH(),
                weather: weatherStrings[currentState.selectedWeather!],
                happiness: currentState.selectedHappiness!,
                nickname: "디저트러버2")
            print("date: \(currentState.date!.getFormattedYMDH())")
            return feedRepository.saveFeed(request: saveFeedRequest)
                .map { Mutation.saveFeed($0) }
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
            
        case .setImageStackView:
            if let happyInt = state.selectedHappiness {
                // 행복 + 카테고리
                let happineesImageName = "happy\(happyInt)"
                let happinessAndCategories = [happineesImageName] + state.selectedCategories
                
                newState.happyAndCategory = happinessAndCategories
            }
            
        case .setDate(let date):
            if let date = date.toDate() {
                newState.date = date
                newState.dateString = date.getFormattedYMDE()
            }
            
        case let .setContent(content):
            newState.content = content
            
        case let .setSelectedImages(images):
            newState.selectedImages = images
            
        case let .isPrivate(isPrivate):
            newState.isPrivate = isPrivate
            
        case let .saveFeed(isSuccess):
            // 네트워크에 연결되어 있지 않습니다.
            // 등록되었습니다.
            print("reduce .saveFeed : \(isSuccess)")
            newState.isSaveFeedSuccess = isSuccess ? .saved : .networkError
            
        }
        return newState
    }
}

extension MyFeedDetailViewReactor {
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


extension MyFeedDetailViewReactor {
    
    func getWeatherIndex(for weatherString: String) -> Int? {
        let lowercaseWeatherString = weatherString.lowercased()
        switch lowercaseWeatherString {
        case "sunny": return Weather.sunny.rawValue
        case "partlycloudy": return Weather.partlyCloudy.rawValue
        case "cloudy": return Weather.cloudy.rawValue
        case "rainy": return Weather.rainy.rawValue
        case "snowy": return Weather.snowy.rawValue
        default: return nil
        }
    }
    
    func getHappinessIndex(for weatherString: String) -> Int? {
        let lowercaseWeatherString = weatherString.lowercased()
        switch lowercaseWeatherString {
        case "sunny": return Weather.sunny.rawValue
        case "partlycloudy": return Weather.partlyCloudy.rawValue
        case "cloudy": return Weather.cloudy.rawValue
        case "rainy": return Weather.rainy.rawValue
        case "snowy": return Weather.snowy.rawValue
        default: return nil
        }
    }
    
    enum Weather: Int {
        case sunny = 0
        case partlyCloudy = 1
        case cloudy = 2
        case rainy = 3
        case snowy = 4
    }
    
    
    enum Happiness: Int {
        case happy1 = 1
        case happy2 = 2
        case happy3 = 3
        case happy4 = 4
        case happy5 = 5
    }
}
