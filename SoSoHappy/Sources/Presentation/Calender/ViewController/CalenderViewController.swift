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
final class CalendarViewController: UIViewController {
    
    // MARK: - Properties
    private var coordinator: CalendarCoordinatorInterface
    var disposeBag = DisposeBag()
    
    let happyListData: [Happy] = [
        Happy(date: "2023-08-06", happinessRate: 20),
        Happy(date: "2023-08-01", happinessRate: 40),
        Happy(date: "2023-08-02", happinessRate: 20),
        Happy(date: "2023-08-03", happinessRate: 60),
        Happy(date: "2023-08-04", happinessRate: 80)
    ]
    
    private var monthFeedList: [MyFeed] = []
    
    //MARK: - UI Components
    private lazy var calendarBackgroundView = UIView().then {
        $0.backgroundColor = UIColor(named: "CellColor")
        $0.layer.cornerRadius = 20
    }
    private lazy var calendar = FSCalendar()
    
    private lazy var previousButton = UIButton().then({
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 15, weight: .semibold)
        let image = UIImage(systemName: "chevron.left", withConfiguration: imageConfig)
        $0.setImage(image, for: .normal)
        $0.tintColor = UIColor(named: "GrayTextColor")
    })
    
    private lazy var nextButton = UIButton().then({
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 15, weight: .semibold)
        let image = UIImage(systemName: "chevron.right", withConfiguration: imageConfig)
        $0.setImage(image, for: .normal)
        $0.tintColor = UIColor(named: "GrayTextColor")
    })
    
    private lazy var alarmButton = UIButton().then {
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 25, weight: .regular)
        let image = UIImage(systemName: "bell.fill", withConfiguration: imageConfig)
        $0.setImage(image, for: .normal)
    }
    
    private lazy var listButton = UIButton().then {
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 25, weight: .regular)
        let image = UIImage(systemName: "list.bullet", withConfiguration: imageConfig)
        $0.setImage(image, for: .normal)
    }
    
    private lazy var yearLabel = UILabel().then {
        $0.font = UIFont.customFont(size: 14, weight: .medium)
        $0.textColor = UIColor(named: "GrayTextColor")
        $0.text = Date().getFormattedDate(format: "yyyy")
    }
    
    private lazy var monthLabel = UILabel().then {
        $0.font = UIFont.customFont(size: 25, weight: .bold)
        $0.text = Date().getFormattedDate(format: "M월")
    }
    
    private lazy var scrollView = UIScrollView()
    
    private lazy var preview = Preview()
    
    private lazy var dividerLine = UIImageView().then {
        let image = UIImage(named: "dividerLine")
        $0.image = image
    }
    
    private var selectedDate: DateComponents? = nil
    
    private var currentPage: Date?
    private var previousPage: Date = Date()

    private let today: Date = {
        return Date()
    }()
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
//        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: alarmButton)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: listButton)
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    // MARK: - Init
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

extension CalendarViewController: View {
    
    func bind(reactor: CalendarViewReactor) {
        bindAction(reactor)
        bindState(reactor)
    }
    
    func bindAction(_ reactor: CalendarViewReactor) {
        // viewDidLoad: month, day data fetch, monthText, yearText
        self.rx.viewWillAppear
            .map { Reactor.Action.viewWillAppear }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        self.alarmButton.rx.tap
            .map { Reactor.Action.tapAlarmButton }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        self.listButton.rx.tap
            .map { Reactor.Action.tapListButton }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        self.nextButton.rx.tap
            .map { Reactor.Action.tapNextButton }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        self.previousButton.rx.tap
            .map { Reactor.Action.tapPreviousButton }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        self.preview.rx.tapGesture()
            .when(.recognized)
            .map { _ in Reactor.Action.tapPreview }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
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
            .map { $0.currentPage }
            .distinctUntilChanged()
            .filter { [weak self] date in
                guard let self = self else { return false }
                return self.currentPage != date
            }
            .subscribe { [weak self] date in
                guard let `self` = self else { return }
                self.currentPage = date
                self.calendar.setCurrentPage(date, animated: true)
            }
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.monthHappinessData }
            .subscribe { [weak self] feeds in
                guard let `self` = self else { return }
                self.monthFeedList = feeds
                calendar.reloadData()
            }
            .disposed(by: disposeBag)
        
        reactor.state
            .map{ $0.dayFeed }
            .subscribe { [weak self] feed in
                guard let `self` = self else { return }
                self.preview.setFeedCell(feed)
            }
        // setFeedCell(FeedType) 일 경우 Argument type 'Event<Date>' does not conform to expected type 'FeedType' 에러 이슈 -> setFeedCell(MyFeed)로 타입매개변수 타입 변경함.
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$presentAlertView)
            .compactMap { $0 }
            .asDriver(onErrorJustReturn: ())
            .drive { [weak self] _ in
                self?.coordinator.pushAlarmView()
            }
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$presentListView)
            .compactMap { $0 }
            .asDriver(onErrorJustReturn: ())
            .drive { [weak self] _ in
                self?.coordinator.pushListView(date: reactor.currentState.currentPage)
            }
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$presentDetailView)
            .compactMap { $0 }
            .asDriver(onErrorJustReturn: ())
            .drive { [weak self] _ in
                // FIXME: - detailview coordintator
                self?.coordinator.pushDetailView(feed: reactor.currentState.dayFeed)
            }
            .disposed(by: disposeBag)
        
        reactor.state
            .compactMap { $0.likedFeed }
            .subscribe { [weak self] likedFeed in
                print("🐵 gets called")
                self?.coordinator.pushDetailView(feed: likedFeed)
            }
            .disposed(by: disposeBag)
    }
}

// MARK: - Action
private extension CalendarViewController {
    
    func setUiViewTabGesture() {
        let tapGesture = UITapGestureRecognizer()
        self.preview.addGestureRecognizer(tapGesture)
    }
    
    // 뷰 스크롤 제스쳐 - x
    @objc private func swipeEvent(_ swipe: UISwipeGestureRecognizer) {
        if swipe.direction == .up {
            calendar.setScope(.week, animated: true)
        } else if swipe.direction == .down {
            calendar.setScope(.month, animated: true)
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
        setUiViewTabGesture()
    }
    
    private func setLayout() {
        self.view.addSubviews(calendarBackgroundView, previousButton, nextButton, yearLabel, monthLabel, preview)
        
        calendarBackgroundView.addSubview(calendar)
        
        alarmButton.snp.makeConstraints {
            $0.width.height.equalTo(40)
        }
        
        listButton.snp.makeConstraints {
            $0.width.height.equalTo(40)
        }
        
        previousButton.snp.makeConstraints {
            $0.left.equalToSuperview().inset(120)
            $0.top.equalToSuperview().inset(140)
            $0.width.height.equalTo(20)
        }
        
        nextButton.snp.makeConstraints {
            $0.right.equalToSuperview().inset(120)
            $0.top.equalToSuperview().inset(140)
            $0.width.height.equalTo(20)
        }
        
        monthLabel.snp.makeConstraints {
            $0.centerY.equalTo(nextButton)
            $0.centerX.equalToSuperview()
        }
        
        yearLabel.snp.makeConstraints {
            $0.bottom.equalTo(monthLabel).offset(-35)
            $0.centerX.equalToSuperview()
        }
        
        calendarBackgroundView.snp.makeConstraints {
            $0.top.equalTo(monthLabel).offset(42)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(350)
        }
        
        calendar.snp.makeConstraints {
            $0.bottom.equalToSuperview()
            $0.top.equalToSuperview().inset(20)
            $0.horizontalEdges.equalToSuperview().inset(13)
        }
        
        preview.snp.makeConstraints {
            $0.top.equalTo(calendar.snp.bottom).offset(15)
            $0.horizontalEdges.equalToSuperview().inset(20)
        }
        
    }
    
    private func setAttribute() {
        view.backgroundColor = UIColor(named: "BGgrayColor")
        
        calendar.backgroundColor = UIColor(named: "CellColor")
        calendar.layer.cornerRadius = 20

        preview.backgroundColor = UIColor(named: "CellColor")
        preview.layer.cornerRadius = 20
    }
}

// MARK: - FSCalendar Set
extension CalendarViewController {
    
    private func setCalender() {
        self.calendar.delegate = self
        self.calendar.dataSource = self
        self.calendar.register(CalendarCell.self, forCellReuseIdentifier: CalendarCell.identifier)
    }
    
    private func setCalenderAttribute() {
        calendar.locale = Locale(identifier: "ko_KR")
        calendar.appearance.titleDefaultColor = UIColor(named: "DarkGrayTextColor")
        calendar.appearance.selectionColor = UIColor(named: "LightGrayTextColor")
        calendar.appearance.titleSelectionColor = UIColor(named: "ReverseMainTextColor")
        calendar.appearance.todayColor = UIColor(named: "DarkGrayTextColor")
        calendar.appearance.titleTodayColor = .white
        calendar.appearance.todayColor = UIColor(named: "AccentColor")
        calendar.appearance.weekdayTextColor = UIColor(named: "DarkGrayTextColor")
        calendar.placeholderType = .none
        calendar.headerHeight = 0.0
        self.calendar.scope = .month

        // 상단 요일을 한글로 변경
        self.calendar.calendarWeekdayView.weekdayLabels[0].text = "일"
        self.calendar.calendarWeekdayView.weekdayLabels[1].text = "월"
        self.calendar.calendarWeekdayView.weekdayLabels[2].text = "화"
        self.calendar.calendarWeekdayView.weekdayLabels[3].text = "수"
        self.calendar.calendarWeekdayView.weekdayLabels[4].text = "목"
        self.calendar.calendarWeekdayView.weekdayLabels[5].text = "금"
        self.calendar.calendarWeekdayView.weekdayLabels[6].text = "토"
        
        // 월~일 글자 폰트 및 사이즈 지정
        self.calendar.appearance.weekdayFont = UIFont.customFont(size: 17, weight: .bold)
        // 숫자들 글자 폰트 및 사이즈 지정
        self.calendar.appearance.titleFont = UIFont.customFont(size: 16, weight: .medium)
        
        // 캘린더 스크롤 가능하게 지정
        self.calendar.scrollEnabled = true
        // 캘린더 스크롤 방향 지정
        self.calendar.scrollDirection = .horizontal
    }
}

// MARK: - FSCalendar DataSource, Delegate
extension CalendarViewController: FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
    
    //FIXME: subscribe에서 data fetch -> data 저장 -> refresh 메서드 호출
    // 캘린더 셀 정의
    func calendar(_ calendar: FSCalendar, cellFor date: Date, at position: FSCalendarMonthPosition) -> FSCalendarCell {
        
        guard let cell = calendar.dequeueReusableCell(
            withIdentifier: CalendarCell.identifier,
            for: date,
            at: position
        ) as? CalendarCell else { return FSCalendarCell() }
        
        if let image = isHappyDay(String(date.getFormattedYMD())) {
            cell.backImageView.image = image
            cell.titleLabel.isHidden = true
            
            if calendar.gregorian.isDateInToday(date) {
                calendar.appearance.todayColor = .clear
            }
            cell.backImageView.alpha = reactor?.currentState.selectedDate == date ? 0.5 : 1
            cell.titleLabel.isHidden = !(reactor?.currentState.selectedDate == date)

        } else {
            cell.titleLabel.isHidden = false
        }

        return cell
    }
    
    // 오늘 이후의 날짜는 선택이 불가능하게 세팅
    func maximumDate(for calendar: FSCalendar) -> Date {
        return Date()
    }
    
    func isHappyDay(_ dateStr: String) -> UIImage? {
        
        if let date = self.monthFeedList.first(where: { $0.date.prefix(8) == dateStr })
        {
            if let image = UIImage(named: date.happyImage) { return  image }
        }
        
        return nil
    }
    
    // FIXME: 데이터 선택 메서드 호출가능한지 알아보기
    // 캘린더 선택
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        // 서버에서 날짜에 해당하는 데이터 api 통신 (day data)
        self.reactor?.action.onNext(.selectDate(date))
        
        if isHappyDay(String(date.getFormattedYMD())) != nil {
            if let cell = calendar.cell(for: date, at: monthPosition) as? CalendarCell {
                UIImageView.animate(withDuration: 0.15) {
                    cell.backImageView.alpha = 0.5
                    cell.titleLabel.isHidden = false
                    cell.appearance.titleSelectionColor = UIColor(named: "MainTextColor")
                }
            }
            calendar.appearance.selectionColor = .clear
        } else {
            // TODO: 텅 뷰 세팅 + 프리뷰 터치 불가능하게 세팅
            calendar.appearance.selectionColor = UIColor(named: "LightGrayTextColor")
            calendar.appearance.titleSelectionColor = UIColor(named: "ReverseMainTextColor")
        }
    }
    
    public func calendar(_ calendar: FSCalendar, didDeselect date: Date, at monthPosition: FSCalendarMonthPosition) {
        if isHappyDay(String(date.getFormattedYMD())) != nil {
            if let cell = calendar.cell(for: date, at: monthPosition) as? CalendarCell {
                UIImageView.animate(withDuration: 0.15) {
                    cell.backImageView.alpha = 1
                    if self.isHappyDay(String(date.getFormattedYMD())) != nil {
                        cell.titleLabel.isHidden = true
                        cell.appearance.titleSelectionColor = UIColor(named: "ReverseMainTextColor")
                    }
                }
            }
            calendar.appearance.selectionColor = .clear
        } else {
            calendar.appearance.selectionColor = UIColor(named: "LightGrayTextColor")
        }
        
    }

    // FIXME: onNext 로 reactor action 전달
    // 캘린더 페이지 변경시 year, month update, data, cell update
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        
        let currentPage = calendar.currentPage
        print(reactor?.currentState.selectedDate ?? Date())
//        if currentPage > previousPage {
//            print("페이지가 증가했습니다.")
//            self.reactor?.action.onNext(.changeCurrentPage(currentPage))
//        } else if currentPage < previousPage {
//            print("페이지가 감소했습니다.")
//            self.reactor?.action.onNext(.tapPreviousButton)
//        }
        
        self.reactor?.action.onNext(.changeCurrentPage(currentPage))
        self.previousPage = currentPage
    }
    
    // MARK: 텍스트 색 설정
        func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
            let weekday = Calendar.current.component(.weekday, from: date)
            
            if weekday == 1 {
                return calendar.maximumDate < date ? .systemRed.withAlphaComponent(0.3) : .systemRed
            } else if weekday == 7 {
                return calendar.maximumDate < date ? .systemBlue.withAlphaComponent(0.3) : .systemBlue
            } else if calendar.gregorian.isDateInToday(date) {
                return .white
            } else if calendar.maximumDate < date {
                return UIColor(named: "ReverseLightGrayColor")
            } else {
                return appearance.titleDefaultColor
            }
        }
}