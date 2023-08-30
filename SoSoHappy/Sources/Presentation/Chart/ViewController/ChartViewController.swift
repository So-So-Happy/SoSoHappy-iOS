//
//  ChartViewController.swift
//  SoSoHappy
//
//  Created by 박민주 on 2023/08/07.
//

import UIKit
import SnapKit
import Then

final class ChartViewController: UIViewController {
    
    private lazy var awardsView = AwardsView()
    private lazy var recommendView = RecommendView()
    private lazy var chartView = ChartView()
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "BGgrayColor")
        
        setUpView()
    }
    
    private func setUpView() {
        view.addSubview(awardsView)
        view.addSubview(recommendView)
        view.addSubview(chartView)
        
        awardsView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.height.equalTo(310) // 이 부분은 awardsView의 높이 계산에 맞게 변경해야 함
            
        }

        recommendView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(awardsView.snp.bottom)
            make.height.equalTo(130)
        }

        chartView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(recommendView.snp.bottom)
        }
    }
}

