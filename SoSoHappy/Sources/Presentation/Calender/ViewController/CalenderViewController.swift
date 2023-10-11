//
//  CalenderViewController.swift
//  SoSoHappy
//
//  Created by 박민주 on 2023/08/07.
//

import UIKit
import SnapKit
import FSCalendar
import Then
import ReactorKit
import RxCocoa
import RxSwift
import Moya

// uipageViewController 사용?
final class CalendarViewController: UIViewController, View {
    

    //MARK: - Properties
    
    private var coordinator: CalendarCoordinatorInterface
    var disposeBag = DisposeBag()
    
    let happyListData: [Happy] = [
        Happy(date: "2023-08-06", happinessRate: 20),
        Happy(date: "2023-08-01", happinessRate: 40),
        Happy(date: "2023-08-02", happinessRate: 20),
        Happy(date: "2023-08-03", happinessRate: 60),
        Happy(date: "2023-08-04", happinessRate: 80)
    ]
    
    private var monthFeedList: [Feed] = []
    
    
    //MARK: - UI Components
    
    private lazy var calendar = FSCalendar()
    
    private lazy var previousButton = UIButton().then({
        let image = UIImage(named: "previousButton")
        $0.setImage(image, for: .normal)
        $0.addTarget(self, action: #selector(prevCurrentPage), for: .touchUpInside)
    })
    
    private lazy var nextButton = UIButton().then({
        let image = UIImage(named: "nextButton")
        $0.setImage(image, for: .normal)
        $0.addTarget(self, action: #selector(nextCurrentPage), for: .touchUpInside)
    })

    private lazy var alarmButton = UIButton().then {
        let image = UIImage(named: "alarmButton")
        $0.setImage(image, for: .normal)
    }
    
    private lazy var listButton = UIButton().then {
        let image = UIImage(named: "listButton")
        $0.setImage(image, for: .normal)
    }
    
    private lazy var yearLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 14)
        $0.textColor = .gray
        $0.text = "2023"
    }
    
    private lazy var monthLabel = UILabel().then {
        $0.textColor = .gray
        $0.text = "8월"
        $0.font = .boldSystemFont(ofSize: 20)
    }
    
    private lazy var scrollView = UIScrollView()
    
    private lazy var preview = PreviewView()
    
    private lazy var dividerLine = UIImageView().then {
        let image = UIImage(named: "dividerLine")
        $0.image = image
    }
    
    private var selectedDate: DateComponents? = nil
    
    private var currentPage: Date?
    
    private lazy var panGesture = UIPanGestureRecognizer().then {
        $0.addTarget(calendar, action: #selector(calendar.handleScopeGesture(_:)))
    }
    
    private let today: Date = {
        return Date()
    }()
    
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(swipeEvent))
//        swipeUp.direction = .up
//
//        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(swipeEvent))
//        swipeDown.direction = .down
//
//        self.view.addGestureRecognizer(swipeUp)
//        self.view.addGestureRecognizer(swipeDown)
        setup()
        
    }
    
    
    // MARK: - Init
    init(
        reactor: CalendarViewReactor,
        coordinator: CalendarCoordinatorInterface
    ) {
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}


extension CalendarViewController {
    
    func bind(reactor: CalendarViewReactor) {
//        bindAction(reactor)
//        bindState(reactor)
        
        self.rx.viewDidLoad
            .map { Reactor.Action.viewDidLoad }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        self.alarmButton.rx.tap
            .map {
                print("버튼 눌림")
                return Reactor.Action.tapAlertButton
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.year }
            .asDriver(onErrorJustReturn: "")
            .distinctUntilChanged()
            .drive(self.yearLabel.rx.text)
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.month }
            .asDriver(onErrorJustReturn: "")
            .distinctUntilChanged()
            .drive(self.monthLabel.rx.text)
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.monthHappinessData }
            .distinctUntilChanged { lhs, rhs in
                return lhs.count == rhs.count
            }
            .subscribe { [weak self] feeds in
                guard let `self` = self else { return }
                self.monthFeedList = feeds
            }
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$presentAlertView)
            .compactMap { $0 }
            .asDriver(onErrorJustReturn: ())
            .drive { [weak self] _ in
                print("pulse presentAlertView changed")
                self?.coordinator.pushAlertView()
            }
            .disposed(by: disposeBag)
        
        
        reactor.pulse(\.$presentListView)
            .compactMap { $0 }
            .asDriver(onErrorJustReturn: ())
            .drive { [weak self] _ in
                self?.coordinator.pushListView()
            }
            .disposed(by: disposeBag)
        
    }
    
    func bindAction(_ reactor: CalendarViewReactor) {
        // viewDidLoad: month, day data fetch, monthText, yearText
        self.rx.viewDidLoad
            .map { Reactor.Action.viewDidLoad }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        self.alarmButton.rx.tap
            .map { Reactor.Action.tapAlertButton }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
            
//            self.nextButton.rx.tap
//                .map { Reactor.Action.tapNextButton }
//                .bind(to: reactor.action)
//                .disposed(by: disposeBag)
//
//            self.previousButton.rx.tap
//                .map { Reactor.Action.tapPreviousButton }
//                .bind(to: reactor.action)
//                .disposed(by: disposeBag)
//            
        }
        
        func bindState(_ reactor: CalendarViewReactor) {
            reactor.state
                .map { $0.year }
                .asDriver(onErrorJustReturn: "")
                .distinctUntilChanged()
                .drive(self.yearLabel.rx.text)
                .disposed(by: disposeBag)
            
            reactor.state
                .map { $0.month }
                .asDriver(onErrorJustReturn: "")
                .distinctUntilChanged()
                .drive(self.monthLabel.rx.text)
                .disposed(by: disposeBag)
            
            reactor.state
                .map { $0.monthHappinessData }
                .distinctUntilChanged { lhs, rhs in
                    return lhs.count == rhs.count
                }
                .subscribe { [weak self] feeds in
                    guard let `self` = self else { return }
                    self.monthFeedList = feeds
                }
                .disposed(by: disposeBag)
            
            reactor.pulse(\.$presentAlertView)
                .compactMap { $0 }
                .asDriver(onErrorJustReturn: ())
                .drive { [weak self] _ in
                    print("pulse presentAlertView changed")
                    self?.coordinator.pushAlertView()
                }
                .disposed(by: disposeBag)
            
            
            reactor.pulse(\.$presentListView)
                .compactMap { $0 }
                .asDriver(onErrorJustReturn: ())
                .drive { [weak self] _ in
                    self?.coordinator.pushListView()
                }
                .disposed(by: disposeBag)
        }

}


// MARK: - Action
private extension CalendarViewController {
    
    // 뷰 스크롤 제스쳐 - x
    @objc private func swipeEvent(_ swipe: UISwipeGestureRecognizer) {
        if swipe.direction == .up {
            calendar.setScope(.week, animated: true)
        } else if swipe.direction == .down {
            calendar.setScope(.month, animated: true)
        }
    }
    
    // 다음 버튼 액션
    @objc private func nextCurrentPage() {
//        let calendar = Calendar.current
//        var dateComponents = DateComponents()
//        dateComponents.month = 1
//        self.currentPage = calendar.date(byAdding: dateComponents, to: self.currentPage ?? self.today)
//        self.calendar.setCurrentPage(self.currentPage!, animated: true)
        
//        MoyaProvider<TestAPI>().rx.request(TestAPI.list)
//            .asObservable()
//            .subscribe { event in
//                    switch event {
//                    case .next(let response):
//                        // 요청이 성공하면 응답 데이터를 출력하거나 사용할 수 있습니다.
//                        print("Response Data: \(String(data: response.data, encoding: .utf8) ?? "")")
//                    case .error(let error):
//                        // 요청이 실패하면 오류를 처리합니다.
//                        print("Error: \(error.localizedDescription)")
//                    case .completed:
//                        // Observable이 완료되었을 때 처리할 내용
//                        break
//                    }
//                }
//                .disposed(by: disposeBag)
        
        // 성공
        self.getTestAPI() { response, error in
            guard let response = response else {
                print(error ?? #function)
                return
            }

            let listUser = response
            print(listUser)
        }
        
        self.reactor?.action.onNext(.tapListButton)
    }
    
    // 이전 버튼 액션
    @objc private func prevCurrentPage() {
        
        let calendar = Calendar.current
        var dateComponents = DateComponents()
        dateComponents.month = -1
        
        self.currentPage = calendar.date(byAdding: dateComponents, to: self.currentPage ?? self.today)
        self.calendar.setCurrentPage(self.currentPage!, animated: true)
        
        reactor?.action.onNext(.tapAlertButton)
    }
    
}

extension CalendarViewController {
    

    func getTestAPI(completion: @escaping (_ succeed: String?, _ failed: Error?) -> Void) {
        MoyaProvider<TestAPI>().request(.list) { result in
            switch result {
            case .success(let model): return completion(String(decoding: model.data, as: UTF8.self), nil)
            case .failure(let error): return completion(nil, error)
            }
        }
    }
    
    /// page에 해당하는 User 정보 조회
    func getTestString(completion: @escaping (_ succeed: String?, _ failed: Error?) -> Void) {
        MoyaProvider<TestAPI>().request(.list)
        { result in
            switch self.processResponse(result) {
            case .success(let model):
                print("success: \(model)")
                return completion(model, nil)
            case .failure(let error):
                print("fail: \(error)")
                return completion(nil, error)
            }
        }
    }
    
    func processResponse(_ result: Result<Response, MoyaError>) -> Result<String?, Error> {
        switch result {
        case .success(let response):
            do {
                // status code가 200...299인 경우만 success로 체크 (아니면 예외발생)
                _ = try response.filterSuccessfulStatusCodes()

                let commonResponse = try JSONDecoder().decode(String.self, from: response.data)
                return .success(commonResponse)
            } catch {
                return .failure(error)
            }

        case .failure(let error):
            return .failure(error)
        }
    }
}


// MARK: - Layout & Attribute
private extension CalendarViewController {
    
    private func setup() {
        setLayout()
        setAttribute()
        setCalender()
        setCalenderAttribute()
    }
    
    private func setLayout() {
        self.view.backgroundColor = .white
        self.view.addSubviews(alarmButton, listButton, previousButton, nextButton, yearLabel, monthLabel, calendar, preview)
        
        alarmButton.snp.makeConstraints {
            $0.left.equalToSuperview().inset(30)
            $0.top.equalToSuperview().inset(80)
            $0.width.height.equalTo(25)
        }
        
        listButton.snp.makeConstraints {
            $0.right.equalToSuperview().inset(30)
            $0.top.equalToSuperview().inset(80)
            $0.width.height.equalTo(20)
        }
        
        previousButton.snp.makeConstraints {
            $0.left.equalToSuperview().inset(50)
            $0.top.equalToSuperview().inset(180)
            $0.width.height.equalTo(10)
        }
        
        nextButton.snp.makeConstraints {
            $0.right.equalToSuperview().inset(50)
            $0.top.equalToSuperview().inset(180)
            $0.width.height.equalTo(10)
        }
        
        monthLabel.snp.makeConstraints {
            $0.centerY.equalTo(nextButton)
            $0.centerX.equalToSuperview()
        }
        
        yearLabel.snp.makeConstraints {
            $0.bottom.equalTo(monthLabel).offset(-30)
            $0.centerX.equalToSuperview()
        }
        
        calendar.snp.makeConstraints {
            $0.top.equalTo(monthLabel).offset(50)
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.height.equalTo(350)
        }
        
        preview.snp.makeConstraints {
            $0.top.equalTo(calendar.snp.bottom).offset(30)
            $0.horizontalEdges.equalToSuperview().inset(20)
        }
       
    }
    
    private func setAttribute() {
        view.backgroundColor = UIColor(rgb: 0xF5F5F5)
        view.addGestureRecognizer(self.panGesture)
        
        calendar.backgroundColor = .white
        calendar.layer.cornerRadius = 10

        preview.backgroundColor = .white
        preview.layer.cornerRadius = 10
        
    }
}

// MARK: - FSCalendar Set
extension CalendarViewController{
    
    private func setCalender() {
        self.calendar.delegate = self
        self.calendar.dataSource = self
        self.calendar.register(CalendarCell.self, forCellReuseIdentifier: CalendarCell.identifier)
    }
    
    private func setCalenderAttribute() {
        calendar.locale = Locale(identifier: "ko_KR")
        calendar.appearance.selectionColor = .white
        calendar.appearance.titleSelectionColor = .black
        calendar.appearance.todayColor = .gray
        calendar.appearance.titleTodayColor = .black
        calendar.appearance.weekdayTextColor = .gray
        calendar.placeholderType = .none
        calendar.headerHeight = 0.0
        
        // 상단 요일을 한글로 변경
        self.calendar.calendarWeekdayView.weekdayLabels[0].text = "일"
        self.calendar.calendarWeekdayView.weekdayLabels[1].text = "월"
        self.calendar.calendarWeekdayView.weekdayLabels[2].text = "화"
        self.calendar.calendarWeekdayView.weekdayLabels[3].text = "수"
        self.calendar.calendarWeekdayView.weekdayLabels[4].text = "목"
        self.calendar.calendarWeekdayView.weekdayLabels[5].text = "금"
        self.calendar.calendarWeekdayView.weekdayLabels[6].text = "토"
        
        
        // 월~일 글자 폰트 및 사이즈 지정
        //        self.calendar.appearance.weekdayFont = UIFont.SpoqaHanSans(type: .Regular, size: 14)
        // 숫자들 글자 폰트 및 사이즈 지정
        //             self.calendar.appearance.titleFont = UIFont.SpoqaHanSans(type: .Regular, size: 16)
        
        // 캘린더 스크롤 가능하게 지정
        self.calendar.scrollEnabled = true
        // 캘린더 스크롤 방향 지정
        self.calendar.scrollDirection = .horizontal
    }
}

extension CalendarViewController: UIGestureRecognizerDelegate {
    // 스크롤 제스쳐
//    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
//        let velocity = self.panGesture.velocity(in: self.view)
//        switch self.calendar.scope {
//        case .month:
//            return velocity.y < 0
//        case .week :
//            return velocity.y > 0
//        default:
//            return false
//        }
//    }
}

// MARK: - FSCalendar DataSource, Delegate
extension CalendarViewController: FSCalendarDelegate, FSCalendarDataSource {
    
    //FIXME: subscribe에서 data fetch -> data 저장 -> refresh 메서드 호출
    
    // 캘린더 셀 정의
    func calendar(_ calendar: FSCalendar, cellFor date: Date, at position: FSCalendarMonthPosition) -> FSCalendarCell {
        
        let cell = calendar.dequeueReusableCell(withIdentifier: CalendarCell.identifier, for: date, at: position)
        
        if let customCell = cell as? CalendarCell {
            if let image = isHappyDay(String(date.getFormattedYMDH())) {
                customCell.setImage(image: image)
            } else {
                // cell 초기화
                customCell.setImage(image: nil)
            }
        }
        
        return cell
    }
    
    func isHappyDay(_ dateStr: String) -> UIImage? {
        
        if let date = monthFeedList.first(where: { $0.date == dateStr })
        {
            if let image = UIImage(named: date.happyImage) { return  image }
        }
        
        return nil
    }
    
    //FIXME: 데이터 선택 메서드 호출가능한지 알아보기
    
    // 캘린더 선택
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        // 서버에서 날짜에 해당하는 데이터 api 통신 (day data)
        
        // preview에 데이터 바인딩
        /// 현재는 일단 filtering -> api통신으로 바꿀예정
        if let data = happyListData.first(where: {
            $0.date == date.getFormattedDefault()
        }) {
            // UpdateUI
            
        }
    }
    
    
    //FIXME: onNext 로 reactor action 전달
    // 캘린더 페이지 변경시 year, month update
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        let date = calendar.currentPage.getFormattedYM()
        
        if calendar.scope == .week {
            if let dateAfter = Calendar.current.date(byAdding: .day, value: 6, to: calendar.currentPage ) {
                if date != dateAfter.getFormattedYM() {
//                    viewModel.getWeeklyList(date, dateAfter.getFormattedYM())
                }
            }
        } else {
//            viewModel.getMonthlyList(date)
        }
        
        self.setMonth(calendar.currentPage)
    }
    
    func setMonth(_ date: Date) {
        let year = date.getFormattedDate(format: "yyyy")
        let month = date.getFormattedDate(format: "M월")
        if Date().getFormattedDate(format: "yyyy") != year {
            yearLabel.text = year
            monthLabel.text = month
        } else {
            monthLabel.text = month
        }
    }
    
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        calendar.snp.updateConstraints {
            $0.height.equalTo(bounds.height)
        }
    }
}


