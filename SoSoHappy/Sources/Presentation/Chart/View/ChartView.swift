//
//  ChartView.swift
//  SoSoHappy
//
//  Created by 박민주 on 2023/08/23.
//

import UIKit
import SnapKit
import DGCharts
import Then

final class ChartView: UIView, ChartViewDelegate {
    
    // MARK: - Properties
    private lazy var graphLabel = UILabel().then {
        $0.text = "OO님의 행복 그래프 💖"
        $0.font = UIFont.customFont(size: 16, weight: .medium)
    }
    
    lazy var segmentedControl = UISegmentedControl(items: ["월간", "연간"]).then {
        $0.selectedSegmentIndex = 0
        let selectedTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(named: "AccentColor"), .font: UIFont.customFont(size: 14, weight: .medium)]
        $0.setTitleTextAttributes(selectedTextAttributes as [NSAttributedString.Key : Any], for: .selected)
    }
    
    private lazy var graphView = LineChartView()
    
    private lazy var imageStackView = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .center
        $0.distribution = .fill
        $0.spacing = 5
    }
    
    private lazy var chartStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .center
    }
    
    let months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    var days: [String] = []
    var unitsSold: [Double] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        // 30번 반복하여 랜덤 숫자를 생성하여 배열에 추가합니다.
        for _ in 1...30 {
            // 0부터 5까지의 랜덤한 Int 값을 생성합니다.
            let randomValue = Int.random(in: 0...5)
            
            // 생성된 랜덤 숫자를 배열에 추가합니다.
            unitsSold.append(Double(randomValue))
        }

        setGraphXaxis()
        setUpView()
        segmentedControl.addTarget(self, action: #selector(segmentedControlValueChanged(_:)), for: .valueChanged)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        let selectedSegmentIndex = sender.selectedSegmentIndex
        print("Selected Segment Index: \(selectedSegmentIndex)")
    }
    
    
    
    //  MARK: - 뷰 구성요소 세팅
    private func setUpView() {
        addSubviews(chartStackView, graphLabel, segmentedControl, graphView, imageStackView)
        setConstraints()
        setChart(dataPoints: days, values: unitsSold)
    }
    
    //  MARK: - 뷰 구성요소 제약 설정
    
    private func setConstraints() {
        makeHappyStackView()
        chartStackView.addArrangedSubview(imageStackView)
        chartStackView.addArrangedSubview(graphView)
        
        chartStackView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(30)
            $0.top.equalTo(segmentedControl).offset(45)
            $0.height.equalTo(165)
        }
        
        graphLabel.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(30)
            $0.top.equalToSuperview()
        }
        
        segmentedControl.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.horizontalEdges.equalToSuperview().inset(30)
            $0.top.equalTo(graphLabel).offset(30)
        }
        
        graphView.snp.makeConstraints {
            $0.verticalEdges.equalToSuperview()
        }
        
    }
    
    func makeHappyStackView() {
        let imageNames = ["happy5", "happy4", "happy3", "happy2", "happy1", "nohappy"]
        
        for imageName in imageNames {
            let imageView = UIImageView(image: UIImage(named: imageName))
            imageView.contentMode = .scaleAspectFit
            imageStackView.addArrangedSubview(imageView)
            
            imageView.snp.makeConstraints { make in
                make.width.equalTo(20.0)  // 이미지의 폭을 조절
                make.height.equalTo(20.0) // 이미지의 높이를 조절
            }
        }
    }
    
    func setChart(dataPoints: [String], values: [Double]) {
        
        // 데이터 생성
        var dataEntries: [ChartDataEntry] = []
        
        
//        for i in 0..<dataPoints.count {
//            let dataEntry = ChartDataEntry(x: Double(i), y: Double(values[i]))
//            dataEntries.append(dataEntry)
//        }
        
        let chartDataSet = LineChartDataSet(entries: dataEntries, label: "")
        graphView.legend.enabled = false
        
        
        // y축 값 고정
        let yAxis = graphView.leftAxis
        yAxis.labelCount = 5
        yAxis.axisMinimum = 1.0
        yAxis.axisMaximum = 5.0
    
        yAxis.drawLabelsEnabled = false
        
        // 데이터 삽입
        let chartData = LineChartData(dataSet: chartDataSet)
        graphView.data = chartData
        
        graphView.data?.setDrawValues(false)
        
        
        // 선택 안되게
        chartDataSet.highlightEnabled = false
        // 줌 안되게
        graphView.doubleTapToZoomEnabled = false
        
        
        // X축 레이블 위치 조정
        graphView.xAxis.labelPosition = .bottom
        // X축 레이블 포맷 지정
        graphView.xAxis.valueFormatter = IndexAxisValueFormatter(values: days)
        
        
        // X축 레이블 갯수 최대로 설정 (이 코드 안쓸 시 Jan Mar May 이런식으로 띄엄띄엄 조금만 나옴)
        //        graphView.xAxis.setLabelCount(dataPoints.count, force: false)
        
        
        // 차트 컬러
        chartDataSet.colors = [UIColor(named: "AccentColor")!]
        
        chartDataSet.lineWidth = 2.0  // 원하는 두께로 설정
        
        
        // 노드 크기 및 색상 설정
        chartDataSet.circleRadius = 3.0 // 노드 크기 설정
        chartDataSet.setCircleColor(UIColor(named: "AccentColor")!) // 노드 색상 설정
        
        // 노드 외곽선 설정 (선택 사항)
        chartDataSet.circleHoleRadius = 1.0
        chartDataSet.circleHoleColor = .white
        
        
        // 오른쪽 레이블 제거
        graphView.rightAxis.enabled = false
        
        graphView.leftAxis.drawGridLinesEnabled = false
       
        
        // 기본 애니메이션
        graphView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)

        // 맥시멈
        graphView.leftAxis.axisMaximum = 5
        // 미니멈
        graphView.leftAxis.axisMinimum = 0
        
        // 백그라운드컬러
        graphView.backgroundColor = UIColor(named: "CellColor")
        graphView.xAxis.labelTextColor = UIColor(named: "LightGrayTextColor") ?? .lightGray  // 원하는 색상으로 설정
        graphView.layer.backgroundColor = UIColor.red.cgColor
        
        // noData
        graphView.noDataText = "데이터가 없습니다."
        graphView.noDataFont = UIFont.customFont(size: 20, weight: .medium)
        graphView.noDataTextColor = .lightGray
        
    }
    
    // FIXME: - 희경: reactor에서 데이터 넘기는 방식으로 ref
    // 월간 연간 선택을 파라미터로 받아 그때그때 xaxis 처리 (월간일 경우 한달동안 날짜 , 연간일 경우는 매달 )
    func setGraphXaxis() {
        // 현재 날짜를 가져옵니다.
        let currentDate = Date()

        // 현재 달력을 가져옵니다.
        let calendar = Calendar.current

        // 현재 달의 첫 번째 날을 가져옵니다.
        guard let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentDate)) else {
            fatalError("Failed to get the first day of the month.")
        }

        // 현재 달의 마지막 날을 가져옵니다.
        guard let lastDayOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: firstDayOfMonth) else {
            fatalError("Failed to get the last day of the month.")
        }

        // 현재 달의 모든 날짜를 가져옵니다.
        var currentDateInLoop = firstDayOfMonth
        while currentDateInLoop <= lastDayOfMonth {
            self.days.append(String(calendar.component(.day, from: currentDateInLoop)))
            currentDateInLoop = calendar.date(byAdding: .day, value: 1, to: currentDateInLoop)!
        }
    }
    
    // 누락된 날짜에 대해 더미 데이터를 생성하는 함수
     func fillMissingData(dates: [String], data: [Double]) -> ([String], [Double]) {
         var filledDates: [String] = []
         var filledData: [Double] = []

         for day in 1...30 {
             if let dateIndex = dates.firstIndex(of: "\(day)일") {
                 filledDates.append("\(day)일")
                 filledData.append(data[dateIndex])
             } else {
                 // 누락된 날짜에 대해 더미 데이터를 생성 (예: 0으로 설정)
                 filledDates.append("\(day)일")
                 filledData.append(0.0)
             }
         }
         
         return (filledDates, filledData)
     }

     // 차트에 데이터 설정하는 함수
     func setChartData(dates: [String], data: [Double]) {
         var entries: [ChartDataEntry] = []

         for (index, value) in data.enumerated() {
             let entry = ChartDataEntry(x: Double(index + 1), y: value)
             entries.append(entry)
         }

         let dataSet = LineChartDataSet(entries: entries, label: "데이터")
         let data = LineChartData(dataSet: dataSet)

         graphView.data = data
     }
    
}

extension ChartView {
    func updateChartData() {
        
    }
    
}



