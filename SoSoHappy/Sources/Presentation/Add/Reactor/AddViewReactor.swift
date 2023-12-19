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

enum Save: String {
    case saved = "저장되었습니다."
    case notSaved = "피드 등록에 실패했습니다."
    case wifiNotConnected = "네트워크에 연결할 수 없습니다."
}

final class AddViewReactor: Reactor {
    private let feedRepository: FeedRepositoryProtocol
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
        case setContent(String)
        case setSelectedImages([UIImage])
        case tapLockButton // 잠금
        case tapSaveButton // 저장
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
        case setContent(String)
        case setSelectedImages([UIImage])
        case isPublic(Bool)
        case isSaveLoading(Bool)
        case saveFeed(Save)
        case showServerErrorAlert(Bool)
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
        var isPublic: Bool = false // 기본 false (비공개)
        var content: String = ""
        var selectedImages: [UIImage]?
        var isSaveLoading: Bool?
        var isSaveFeedSuccess: Save?
        var showServerErrorAlert: Bool?
    }
    
    let initialState: State
    
    init(feedRepository: FeedRepositoryProtocol) {
        initialState = State()
        self.feedRepository = feedRepository
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .weatherButtonTapped(tag):
            return Observable.just(.setSelectedWeather(tag))
            
        case let .happinessButtonTapped(tag):
            return Observable.just(.setSelectedHappiness(tag))
            
        case let .tapNextButton(addStep):
            return Observable.just(.setBeforeMovingToNextStep(addStep))
            
        case let .selectCategory(category):
            return setSelectedCategory(category)
            
        case .deselectCategory(let category):
            return setDeselectCategory(category)
            
        case .fetchDatasForAdd3:
            return Observable.just(.setDatasForAdd3)
            
        case let .setContent(content):
            let limitedText = String(content.prefix(3000))
            return .just(.setContent(limitedText))
            
        case let .setSelectedImages(images):
            return Observable.just(.setSelectedImages(images))
            
        case .tapLockButton:
            let isPublic = !currentState.isPublic
            return Observable.just(.isPublic(isPublic))
            
        case .tapSaveButton:
            if !Connectivity.isConnectedToInternet() {
                return .just(.saveFeed(.wifiNotConnected))
            }
            
            let nickname = KeychainService.getNickName()
            
            let saveFeedRequest = SaveFeedRequest(
                text: currentState.content,
                images: currentState.selectedImages,
                categoryList: currentState.selectedCategories,
                isPublic: currentState.isPublic,
                date: currentState.date!.getFormattedYMDH(),
                weather: weatherStrings[currentState.selectedWeather!],
                happiness: currentState.selectedHappiness!,
                nickname: nickname)
            
            return .concat([
                .just(.isSaveLoading(true)),
                feedRepository.saveFeed(request: saveFeedRequest)
                    .map { Mutation.saveFeed($0 ? .saved : .notSaved) }
                    .catch { _ in
                        return .concat([
                            .just(.showServerErrorAlert(true)),
                            .just(.showServerErrorAlert(false))
                        ])
                    },
                .just(.isSaveLoading(false))
            ])
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {
        case let .setSelectedWeather(tag):
            state.selectedWeather = tag
            state.weatherString = weatherStrings[tag]
            
        case let .setSelectedHappiness(tag):
            state.selectedHappiness = tag
            
        case let .setBeforeMovingToNextStep(stepNow):
            switch stepNow {
            case .step1:
                state.selectedCategories = []
            case .step2:
                state.date = Date()
            }
            
        case let .selectedCategories(categories):
            state.selectedCategories = categories
            
        case .setDatasForAdd3:
            if let happyInt = state.selectedHappiness, let todayDate = state.date {
                let happineesImageName = "happy\(happyInt)"
                let happinessAndCategories = [happineesImageName] + state.selectedCategories
                
                let dateToString = todayDate.getFormattedYMDE()
            
                state.happyAndCategory = happinessAndCategories
                state.dateString = dateToString
            }
            
        case let .setContent(content):
            state.content = content
            
        case let .setSelectedImages(images):
            state.selectedImages = images
            
        case let .isPublic(isPublic):
            state.isPublic = isPublic
            
        case .isSaveLoading(let isSaveLoading):
            state.isSaveLoading = isSaveLoading
            
        case let .saveFeed(isSuccess):
            state.isSaveFeedSuccess = isSuccess
                    
        case .showServerErrorAlert(let showServerErrorAlert):
            state.showServerErrorAlert = showServerErrorAlert
        }
        
        return state
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
