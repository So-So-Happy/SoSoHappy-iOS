//
//  MyFeedDetailViewReactor.swift
//  SoSoHappy
//
//  Created by 박희경 on 2023/11/05.
//

import ReactorKit
import Foundation

final class MyFeedDetailViewReactor: BaseReactor, Reactor {
    
    private let feedRepository: FeedRepositoryProtocol
    
    // MARK: Properties
    let weatherStrings = ["sunny", "partlyCloudy", "cloudy", "rainy", "snowy"]

    let categories: [String] = [
        "beer", "books", "coffee", "cook",
        "dessert", "drive", "exercise", "food",
        "friends", "game", "home", "love",
        "movie", "music", "nature", "ott",
        "pet", "picture", "youtube", "sea",
        "shopping", "sleep", "study", "trip"
    ]
    
    let maximumSelectionCount = 3
    let minimumSelectionCount = 1
    var initialCategories: [String] = []
     
    enum Action {
        case viewWillAppear(MyFeed)
        
        case setWeatherAndHappy
        case setCategories
        
        case weatherButtonTapped(Int)
        case happinessButtonTapped(Int)
        case tapNextButton(AddStep)
       
        case selectCategory(String)
        case deselectCategory(String)

        case fetchDatasForAdd3
        case setContent(String)
        case setSelectedImages([UIImage])
        case tapLockButton
        case tapSaveButton
    }
    
    enum Mutation {
        case setSelectedWeather(Int)
        case setSelectedHappiness(Int)
        case setBeforeMovingToNextStep(AddStep)
        case selectedCategories([String])
        case setDate(String)
        case setImageStackView
        case setContent(String)
        case setInitialImages([UIImage])
        case setSelectedImages([UIImage])
        case isPrivate(Bool)
        case saveFeed(Bool)
        case showNetworkErrorView(Error)
        case showServerErrorAlert(Error)
    }
    
    struct State {
        var selectedWeather: Int?
        var selectedHappiness: Int?
        var date: Date?
        var selectedCategories: [String] = []
        var deselectCategoryItem: Int?
        var happyAndCategory: [String]?
        var dateString: String?
        var weatherString: String?
        var isPrivate: Bool = true 
        var isSaveFeedSuccess: Save?
        var content: String = ""
        var selectedImages: [UIImage]?
    }
    
    let initialState: State
    
    init(feedRepository: FeedRepositoryProtocol) {
        initialState = State()
        self.feedRepository = feedRepository
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        if !Connectivity.isConnectedToInternet() {
            return .just(.showNetworkErrorView(BaseError.networkConnectionError))
        }
        switch action {
        case .viewWillAppear(let feed):
            self.initialCategories = feed.categoryList
            return .concat([
                .just(.setSelectedWeather(getWeatherIndex(for: feed.weather) ?? 0)),
                .just(.setSelectedHappiness(feed.happiness)),
                .just(.selectedCategories(feed.categoryList)),
                .just(.setDate(feed.date)),
                .just(.setImageStackView),
                .just(.setContent(feed.text)),
                feedRepository.getFeedImages(ids: feed.imageIdList)
                    .map { .setInitialImages($0) }
                    .catch { _ in .just(.showServerErrorAlert(BaseError.InternalServerError))
                    },
                .just(.isPrivate(feed.isPulic))
            ])
        case let .weatherButtonTapped(tag):
            return Observable.just(.setSelectedWeather(tag))
            
        case let .happinessButtonTapped(tag):
            return .concat([
                .just(.setSelectedHappiness(tag)),
                .just(.setImageStackView)
            ])
            
        case let .tapNextButton(addStep):
            return Observable.just(.setBeforeMovingToNextStep(addStep))
            
        case let .selectCategory(category):
            return .concat([
                setSelectedCategory(category),
                .just(.setImageStackView)
            ])
            
        case .deselectCategory(let category):
            return .concat([
                setDeselectCategory(category),
                .just(.setImageStackView)
            ])
            
        case .fetchDatasForAdd3:
            return Observable.just(.setImageStackView)
            
        case let .setContent(content):
            let limitedText = String(content.prefix(3000))
            return .just(.setContent(limitedText))
            
        case let .setSelectedImages(images):
            return Observable.just(.setSelectedImages(images))
            
        case .tapLockButton:
            let isPrivate = !currentState.isPrivate
            return Observable.just(.isPrivate(isPrivate))
            
        case .tapSaveButton:
            let saveFeedRequest = SaveFeedRequest(
                text: currentState.content,
                images: currentState.selectedImages,
                categoryList: currentState.selectedCategories,
                isPublic: currentState.isPrivate,
                date: currentState.date!.getFormattedYMDH(),
                weather: weatherStrings[currentState.selectedWeather!],
                happiness: currentState.selectedHappiness!,
                nickname: KeychainService.getNickName())
            return feedRepository.saveFeed(request: saveFeedRequest)
                .map { Mutation.saveFeed($0) }
                .catch { _ in .just(.showServerErrorAlert(BaseError.InternalServerError))
                }
        case .setWeatherAndHappy:
            return .concat([
                .just(.setSelectedHappiness(currentState.selectedHappiness ?? 0)),
                .just(.setSelectedWeather(currentState.selectedWeather ?? 0)),
                .just(.setImageStackView)
            ])
        case .setCategories:
            return .empty()
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
            newState.selectedCategories = categories
            
        case .setImageStackView:
            if let happyInt = state.selectedHappiness {
                let happineesImageName = "happy\(happyInt)"
                let happinessAndCategories = [happineesImageName] + state.selectedCategories
                
                newState.happyAndCategory = happinessAndCategories
            }
            
        case .setDate(let date):
            let date = date.toDate()
            newState.date = date
            newState.dateString = date.getFormattedYMDE()
            
        case let .setContent(content):
            newState.content = content
            
        case let .setInitialImages(images):
            newState.selectedImages = images
            
        case let .setSelectedImages(images):
            newState.selectedImages = images
            
        case let .isPrivate(isPrivate):
            newState.isPrivate = isPrivate
            
        case let .saveFeed(isSuccess):
            newState.isSaveFeedSuccess = isSuccess ? .saved : .notSaved
            
        case .showNetworkErrorView(let error):
            self.showNetworkErrorViewPublisher.accept(error)
            
        case .showServerErrorAlert(let error):
            self.showErrorAlertPublisher.accept(error)
            
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
    
}
