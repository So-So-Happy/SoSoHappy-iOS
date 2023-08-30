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
        $0.font = .systemFont(ofSize: 16, weight: .bold)
    }
    
    private lazy var segmentedControl = UISegmentedControl(items: ["월간", "연간"]).then {
        $0.selectedSegmentIndex = 0
        let selectedTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(named: "AccentColor"), .font: UIFont.boldSystemFont(ofSize: 14)] // Change color as needed
        $0.setTitleTextAttributes(selectedTextAttributes as [NSAttributedString.Key : Any], for: .selected)
    }
    
    private lazy var graphView = LineChartView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        setUpView()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    //  MARK: - 뷰 구성요소 세팅
    private func setUpView() {
        addSubview(graphLabel)
        addSubview(segmentedControl)
        setGraph()
    }
    
    //  MARK: - 뷰 구성요소 제약 설정
    private func setConstraints() {
        graphLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 30))
            make.top.equalToSuperview()
        }
        
        segmentedControl.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 30))
            make.top.equalTo(graphLabel).inset(UIEdgeInsets(top: 30, left: 0, bottom: 0, right: 0))
        }
        
        graphView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(30)
            make.top.equalTo(segmentedControl).inset(45)
            make.height.equalTo(200)
        }
    }
    
    // MARK: - 차트 함수
    private func setGraph() {
        let lineChartEntries = [
            ChartDataEntry(x: 1, y: 2),
            ChartDataEntry(x: 2, y: 4),
            ChartDataEntry(x: 3, y: 3),
        ]
        let dataSet = LineChartDataSet(entries: lineChartEntries)
        let data = LineChartData(dataSet: dataSet)
        
        graphView.data = data
        
        // MARK: Custom List
//        // disable grid
//        graphView.xAxis.drawGridLinesEnabled = false
        graphView.leftAxis.drawGridLinesEnabled = false
        graphView.rightAxis.drawGridLinesEnabled = false
        graphView.drawGridBackgroundEnabled = false
//        // disable axis annotations
//        graphView.xAxis.drawLabelsEnabled = false
        graphView.leftAxis.drawLabelsEnabled = false
        graphView.rightAxis.drawLabelsEnabled = false
//        // disable legend
//        graphView.legend.enabled = false
//        // disable zoom
//        graphView.pinchZoomEnabled = false
//        graphView.doubleTapToZoomEnabled = false
//        // remove artifacts around chart area
//        graphView.xAxis.enabled = false
//        graphView.leftAxis.enabled = false
//        graphView.rightAxis.enabled = false
//        graphView.drawBordersEnabled = false
//        graphView.minOffset = 0
//        // setting up delegate needed for touches handling
//        graphView.delegate = self
        
        addSubview(graphView)
    }
}
