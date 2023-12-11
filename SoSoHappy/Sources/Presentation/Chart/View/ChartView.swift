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
    
//    let monthToIdxDict: [String: Double] = Dictionary(uniqueKeysWithValues: zip(months, 0.0...11.0))
    
    let months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    var days: [String] = []
    var unitsSold: [Double] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setConstraints()
//        setUpView()
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
    private func setUpView(_ data: [ChartEntry]) {
        setConstraints()
//        setChart()
    }
    
    //  MARK: - 뷰 구성요소 제약 설정
    
    private func setConstraints() {
        makeHappyStackView()
        addSubviews(chartStackView, graphLabel, segmentedControl, graphView, imageStackView)
        chartStackView.addArrangedSubview(imageStackView)
        chartStackView.addArrangedSubview(graphView)
        
        segmentedControl.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.horizontalEdges.equalToSuperview().inset(30)
            $0.top.equalTo(graphLabel).offset(30)
        }
        
        chartStackView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(30)
            $0.top.equalTo(segmentedControl).offset(45)
            $0.height.equalTo(165)
        }
        
        graphLabel.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(30)
            $0.top.equalToSuperview()
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
    
    
    // MARK: - Chart Data 생성
    func setChartData(data: [ChartEntry]) {
        var dataEntries: [ChartDataEntry] = []
        
        for i in data {
            if i.y > 0.0 {
                let dataEntry = ChartDataEntry(x: i.x, y: i.y)
                dataEntries.append(dataEntry)
            }
        }
        
        let chartDataSet = LineChartDataSet(entries: dataEntries, label: "")
        
        let chartData = LineChartData(dataSet: chartDataSet)
        graphView.data = chartData
        
        graphView.data?.setDrawValues(false)
        
        // 선택 안되게
        chartDataSet.highlightEnabled = false
        
        // 차트 컬러
        chartDataSet.colors = [UIColor(named: "AccentColor")!]
        chartDataSet.lineWidth = 2.0  // 원하는 두께로 설정
        
        // 노드 크기 및 색상 설정
        chartDataSet.circleRadius = 3.0 // 노드 크기 설정
        chartDataSet.setCircleColor(UIColor(named: "AccentColor")!) // 노드 색상 설정
        
        // 노드 외곽선 설정 (선택 사항)
        chartDataSet.circleHoleRadius = 1.0
        chartDataSet.circleHoleColor = .white
    }
    
    // MARK: - Chart Data + Chart Attibute Setting
    // 파라미터로 [chartEntry] 받고 현재 segmentedControl idx 로 판단
    func setChart(_ data: [ChartEntry]) {
        
        setChartData(data: data)
        
        // year: 1.0 ~ 12.0
        // month: 1.0 ~ 31.0
        // x축 값 설정
        if self.segmentedControl.selectedSegmentIndex == 0 {
            graphView.xAxis.axisMinimum = 1
            graphView.xAxis.axisMaximum = data.last?.x ?? 30
            graphView.xAxis.labelCount = 7
            
            //             X축 레이블 갯수 최대로 설정 (이 코드 안쓸 시 Jan Mar May 이런식으로 띄엄띄엄 조금만 나옴)
//            graphView.xAxis.setLabelCount(dataPoints.count, force: false)
        } else {
            // CustomChartFormatter를 사용하여 X축 레이블을 커스텀 포맷으로 설정
            let customFormatter = YearChartFormatter()
            graphView.xAxis.valueFormatter = customFormatter
            
            graphView.xAxis.axisMinimum = 0
            graphView.xAxis.axisMaximum = 11
            graphView.xAxis.labelCount = 12
        }
        
        graphView.xAxis.forceLabelsEnabled = true
        graphView.xAxis.granularityEnabled = true
        graphView.xAxis.granularity = 1

        
        // y축 값 고정
        graphView.leftAxis.labelCount = 3
        graphView.leftAxis.axisMinimum = 0.0
        graphView.leftAxis.axisMaximum = 5.0
        graphView.leftAxis.drawLabelsEnabled = false
        

        setChartAttribute()
        
    }
    
    func setChartAttribute() {
        
        // X축 레이블 위치 조정
        graphView.xAxis.labelPosition = .bottom
        
        // 오른쪽 레이블 제거
        graphView.rightAxis.enabled = false
        graphView.leftAxis.drawGridLinesEnabled = false
        
        // 기본 애니메이션
        graphView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)
        
        // 백그라운드컬러
        graphView.backgroundColor = UIColor(named: "CellColor")
        graphView.xAxis.labelTextColor = UIColor(named: "LightGrayTextColor") ?? .lightGray  // 원하는 색상으로 설정
        graphView.layer.backgroundColor = UIColor.red.cgColor
        
        // noData
        graphView.noDataText = "데이터가 없습니다."
        graphView.noDataFont = UIFont.customFont(size: 20, weight: .medium)
        graphView.noDataTextColor = .lightGray
        
        // 차트에서 범례(legend)를 비활성화
        graphView.legend.enabled = false
        
        // 줌 안되게
        graphView.doubleTapToZoomEnabled = false
        
        
    }
    
}

// xAxis data , dataSet
public class YearChartFormatter: NSObject, AxisValueFormatter {

    var months: [String] =  ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]

    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return months[Int(value)]
    }
}

public class MonthChartFormatter: NSObject, AxisValueFormatter {
    var days: [String] = []
    
    init(days: [String]) {
        self.days = days
        print("days: \(days)")
    }

    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return days[Int(value)]
    }
}


