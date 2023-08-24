//
//  ChartViewController.swift
//  SoSoHappy
//
//  Created by 박민주 on 2023/08/07.
//

import UIKit

class ChartViewController: UIViewController {
    let chartView = ChartView()
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "BGgrayColor")
        
        setUpUI()
        
    }
    
    func setUpUI() {
        // Add the custom view to the view controller's view
        view.addSubview(chartView)
        
        // Set up constraints using SnapKit to make the custom view fill the screen
        chartView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

