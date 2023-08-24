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

// uipageViewController 사용?
final class CalendarViewController: UIViewController {
    
    // dummy data
    let happyListData: [Happy] = [
        Happy(date: "2023-08-06", happinessRate: 20),
        Happy(date: "2023-08-01", happinessRate: 40),
        Happy(date: "2023-08-02", happinessRate: 20),
        Happy(date: "2023-08-03", happinessRate: 60),
        Happy(date: "2023-08-04", happinessRate: 80)
    ]
    
    private lazy var calendar = FSCalendar()
    private lazy var previousButton = UIButton()
    
    private lazy var nextButton = UIButton().then({
        let image = UIImage(named: "previousButton")
        $0.setImage(image, for: .normal)
        $0.addTarget(self, action: #selector(prevCurrentPage), for: .touchUpInside)
    })

    private lazy var alarmButton = UIButton().then {
        let image = UIImage(named: "alarmButton")
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
        let calendar = Calendar.current
        var dateComponents = DateComponents()
        dateComponents.month = 1
        self.currentPage = calendar.date(byAdding: dateComponents, to: self.currentPage ?? self.today)
        self.calendar.setCurrentPage(self.currentPage!, animated: true)
    }
    
    // 이전 버튼 액션
    @objc private func prevCurrentPage() {
        let calendar = Calendar.current
        var dateComponents = DateComponents()
        dateComponents.month = -1
        
        self.currentPage = calendar.date(byAdding: dateComponents, to: self.currentPage ?? self.today)
        self.calendar.setCurrentPage(self.currentPage!, animated: true)
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
        self.view.addSubviews(alarmButton, previousButton, nextButton, yearLabel, monthLabel, calendar, preview)
        
        alarmButton.snp.makeConstraints {
            $0.left.equalToSuperview().inset(30)
            $0.top.equalToSuperview().inset(80)
            $0.width.height.equalTo(25)
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
        
//        dividerLine.snp.makeConstraints {
//            $0.top.equalTo(calendar.snp.bottom).offset(20)
//            $0.horizontalEdges.equalToSuperview().inset(10)
//            $0.height.equalTo(2)
//        }
        
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
        
        previousButton = previousButton.then({
            let image = UIImage(named: "previousButton")
            $0.setImage(image, for: .normal)
            $0.addTarget(self, action: #selector(prevCurrentPage), for: .touchUpInside)
        })
        
        nextButton = nextButton.then({
            let image = UIImage(named: "nextButton")
            $0.setImage(image, for: .normal)
            $0.addTarget(self, action: #selector(nextCurrentPage), for: .touchUpInside)
        })
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
    
    // 캘린더 셀 정의
    func calendar(_ calendar: FSCalendar, cellFor date: Date, at position: FSCalendarMonthPosition) -> FSCalendarCell {
        
        let cell = calendar.dequeueReusableCell(withIdentifier: CalendarCell.identifier, for: date, at: position)
        
        if let customCell = cell as? CalendarCell {
            if let image = isHappyDay(date.getFormattedDefault()) {
                customCell.setImage(image: image)
            } else {
                // cell 초기화
                customCell.setImage(image: nil)
            }
        }
        
        return cell
    }
    
    func isHappyDay(_ dateStr: String) -> UIImage? {
        
        if let date = happyListData.first(where: { $0.date == dateStr })
        {
            if let image = UIImage(named: date.charactor) { return  image }
        }
        
        return nil
    }
    
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


