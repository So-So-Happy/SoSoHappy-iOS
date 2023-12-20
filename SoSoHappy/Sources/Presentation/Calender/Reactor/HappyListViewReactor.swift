
import ReactorKit

class HappyListViewReactor: BaseReactor, Reactor {
     
    //MARK: - Properties
    let initialState: State
    
    private let feedRepository: FeedRepositoryProtocol
    private let userRepository: UserRepositoryProtocol
    private var currentPage: Date
    
    // MARK: - Init
    init (feedRepository: FeedRepositoryProtocol,
          userRepository: UserRepositoryProtocol,
          currentPage: Date,
          state: State = State(
            monthHappinessData: [],
            currentPage: Date(),
            date: "",
            detailViewDate: ""
         )
    ) {
        self.feedRepository = feedRepository
        self.userRepository = userRepository
        self.currentPage = currentPage
        self.initialState = state
    }
    
    // MARK: - Action
    enum Action {
        case viewWillAppear
        case tapNextButton
        case tapPreviousButton
        case tapHappyListCell(String)
    }
    
    // MARK: - Mutation
    enum Mutation {
        case setFeedList([MyFeed])
        case setDate(Date)
        case presentDetailView(String)
        case showNetworkErrorView(Error)
        case showServerErrorAlert(Error)
    }
    
    // MARK: - State
    struct State {
        var monthHappinessData: [MyFeed]
        var currentPage: Date
        var date: String
        var detailViewDate: String
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        if !Connectivity.isConnectedToInternet() {
            return .just(.showNetworkErrorView(BaseError.networkConnectionError))
        }
        let nickName = KeychainService.getNickName()
        switch action {
        case .viewWillAppear:
            return .concat([
                .just(.setDate(currentPage)),
                feedRepository.findMonthFeed(request: FindFeedRequest(date: currentPage.getFormattedYMDH(), nickName: nickName))
                    .map { Mutation.setFeedList($0) }
                    .catch { _ in .just(.showServerErrorAlert(BaseError.InternalServerError))
                    }
            ])
        case .tapNextButton:
            self.currentPage = currentPage.moveToNextMonth()
            return .concat([
                .just(.setDate(currentPage)),
                feedRepository.findMonthFeed(request: FindFeedRequest(date: currentPage.getFormattedYMDH(), nickName: nickName))
                    .map { Mutation.setFeedList($0) }
                    .catch { _ in .just(.showServerErrorAlert(BaseError.InternalServerError))
                    }
            ])
        case .tapPreviousButton:
            self.currentPage = currentPage.moveToPreviousMonth()
            return .concat([
                .just(.setDate(currentPage)),
                feedRepository.findMonthFeed(request: FindFeedRequest(date: currentPage.getFormattedYMDH(), nickName: nickName))
                    .map { Mutation.setFeedList($0) }
                    .catch { _ in .just(.showServerErrorAlert(BaseError.InternalServerError))
                    }
            ])
        case .tapHappyListCell(let date):
            return .just(.presentDetailView(date))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setFeedList(let feeds):
            newState.monthHappinessData = feeds
        case .setDate(let date):
            newState.currentPage = date
            newState.date = date.getFormattedYM()
        case .presentDetailView(let date):
            newState.detailViewDate = date
        case .showNetworkErrorView(let error):
            self.showNetworkErrorViewPublisher.accept(error)
        case .showServerErrorAlert(let error):
            self.showErrorAlertPublisher.accept(error)
        }
        
        return newState
    }
}
