//
//  ChartView.swift
//  SoSoHappy
//
//  Created by 박민주 on 2023/08/23.
//

import UIKit
import SnapKit
import DGCharts

final class ChartView: UIView, ChartViewDelegate {
    // MARK: - Properties
    let label = UILabel()
    let titleStack = UIStackView()
    let nameLabel = UILabel()
    let label2 = UILabel()
    
    let awardsLabel = UILabel()
    let awardsStack = UIStackView()
    let detailsAwardsButton = UIButton()
    
    var firstPlaceView = UIView()
    var secondPlaceView = UIView()
    var thirdPlaceView = UIView()
    
    let recommendLabel = UILabel()
    let recommendStack = UIStackView()
    let sophyImageView = UIImageView(image: UIImage(named: "happy40"))
    let speechBubbleView = UIView()
    
    let recommendedHappinessLabel = UILabel()
    let refreshButton = UIButton()
    
    let graphLabel = UILabel()
    let segmentedControl = UISegmentedControl(items: ["월간", "연간"])
    let graphView = LineChartView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpValue()
        setUpView()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 요소 내용 설정
    private func setUpValue() {
        label.text = "오늘도 행복하셨나요?"
        label.textColor = .darkGray
        label.font = .boldSystemFont(ofSize: 15)
        
        nameLabel.text = "OO님"
        nameLabel.textColor = UIColor(named: "AccentColor")
        nameLabel.font = .systemFont(ofSize: 24, weight: .black)
        
        label2.text = "의 행복을 분석해봤어요!"
        label2.font = .systemFont(ofSize: 24, weight: .black)
        
        titleStack.axis = .horizontal
        
        awardsLabel.text = "이번 달 베스트 소확행 어워즈 🏆"
        awardsLabel.font = .systemFont(ofSize: 16, weight: .bold)
        
        firstPlaceView = createPodiumView(position: 2, color: UIColor(named: "AccentColor")!, categori: UIImage(named: "home")!)
        secondPlaceView = createPodiumView(position: 3, color: UIColor(named: "AccentColor")!, categori: UIImage(named: "home")!)
        thirdPlaceView = createPodiumView(position: 1, color: UIColor(named: "AccentColor")!, categori: UIImage(named: "home")!
        )
        
        recommendLabel.text = "OO님이 좋아하실만한 소확행을 찾아봤어요! 👀"
        recommendLabel.font = .systemFont(ofSize: 16, weight: .bold)
        speechBubbleView.backgroundColor = .white
        speechBubbleView.layer.cornerRadius = 20
        
        recommendedHappinessLabel.text = "비 오는 날 산책하기 ☔️🚶🏻‍♀️"
        recommendedHappinessLabel.font = .systemFont(ofSize: 15)
        
        graphLabel.text = "OO님의 행복 그래프 💖"
        graphLabel.font = .systemFont(ofSize: 16, weight: .bold)
    }
    
    //  MARK: - 뷰 구성요소 세팅
    private func setUpView() {
        addSubview(label)
        
        titleStack.spacing = 0
        titleStack.addArrangedSubview(nameLabel)
        titleStack.addArrangedSubview(label2)
        titleStack.distribution = .fillProportionally
        addSubview(titleStack)
        
        addSubview(awardsLabel)
        awardsStack.addArrangedSubview(firstPlaceView)
        awardsStack.addArrangedSubview(secondPlaceView)
        awardsStack.addArrangedSubview(thirdPlaceView)
        awardsStack.distribution = .fillEqually // 뷰를 동일한 크기로 분배
        addSubview(awardsStack)
        
        addSubview(detailsAwardsButton)
        detailsAwardsButton.setImage(UIImage(systemName: "arrow.right"), for: .normal)
        detailsAwardsButton.addTarget(self, action: #selector(detailsAwardsButtonTapped), for: .touchUpInside)
        
        addSubview(recommendLabel)
        recommendStack.spacing = 10
        recommendStack.addArrangedSubview(sophyImageView)
        recommendStack.addArrangedSubview(speechBubbleView)
        addSubview(recommendStack)
        
        refreshButton.setImage(UIImage(systemName: "arrow.clockwise"), for: .normal)
        refreshButton.addTarget(self, action: #selector(refreshButtonTapped), for: .touchUpInside)
        speechBubbleView.addSubview(recommendedHappinessLabel)
        speechBubbleView.addSubview(refreshButton)
        
        addSubview(graphLabel)
        addSubview(segmentedControl)
        
        segmentedControl.selectedSegmentIndex = 0
        let selectedTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(named: "AccentColor"), .font: UIFont.boldSystemFont(ofSize: 14)] // Change color as needed
        segmentedControl.setTitleTextAttributes(selectedTextAttributes as [NSAttributedString.Key : Any], for: .selected)
        
        setGraph()
        
    }
    
    //  MARK: - 뷰 구성요소 제약 설정
    private func setConstraints() {
        label.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 30))
            make.top.equalTo(self.safeAreaLayoutGuide).inset(UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0))
        }
        
        titleStack.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 30))
            make.top.equalTo(label).inset(UIEdgeInsets(top: 25, left: 0, bottom: 0, right: 0))
        }
        
        awardsLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 0))
            make.top.equalTo(titleStack).inset(UIEdgeInsets(top: 60, left: 0, bottom: 0, right: 0))
        }
        
        detailsAwardsButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 30))
            make.top.equalTo(titleStack).inset(UIEdgeInsets(top: 60, left: 0, bottom: 0, right: 0))
        }
        
        awardsStack.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 30))
            make.top.equalTo(awardsLabel).inset(40)
        }
        
        recommendLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 30))
            make.top.equalTo(awardsStack.snp.bottom).offset(30)
        }
        
        recommendStack.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 30))
            make.top.equalTo(recommendLabel).inset(UIEdgeInsets(top: 35, left: 0, bottom: 0, right: 0))
        }
        
        sophyImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.height.width.equalTo(60)
        }
        
        speechBubbleView.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.height.equalTo(60)
        }
        
        // Set constraints for recommendedHappinessLabel within speechBubbleView
        recommendedHappinessLabel.translatesAutoresizingMaskIntoConstraints = false
        recommendedHappinessLabel.leadingAnchor.constraint(equalTo: speechBubbleView.leadingAnchor, constant: 20).isActive = true
        recommendedHappinessLabel.centerYAnchor.constraint(equalTo: speechBubbleView.centerYAnchor).isActive = true
        
        // Set constraints for refreshButton next to recommendedHappinessLabel
        refreshButton.translatesAutoresizingMaskIntoConstraints = false
        refreshButton.trailingAnchor.constraint(equalTo: speechBubbleView.trailingAnchor, constant: -20).isActive = true
        refreshButton.centerYAnchor.constraint(equalTo: speechBubbleView.centerYAnchor).isActive = true
        
        graphLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 30))
            make.top.equalTo(recommendStack).inset(UIEdgeInsets(top: 90, left: 0, bottom: 0, right: 0))
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
    
    
    // MARK: - Functions
    private func createPodiumView(position: Int, color: UIColor, categori: UIImage) -> UIView {
        let stackView = UIStackView()
        let categoriImage = UIImageView(image: categori)
        let podiumView = UIView()
        
        stackView.axis = .vertical
//        stackView.distribution = .fillProportionally
        categoriImage.contentMode = .scaleAspectFit
        podiumView.backgroundColor = UIColor(named: "LightAccentColor")
        podiumView.layer.cornerRadius = 8
        
        stackView.addArrangedSubview(categoriImage)
        stackView.addArrangedSubview(podiumView)
        
        addSubview(stackView)
        
        categoriImage.snp.makeConstraints { make in
            make.height.equalTo(60) // 높이 설정
            make.top.equalTo(stackView).inset((3 - position) * 30)
        }
        
        podiumView.snp.makeConstraints { make in
            make.height.equalTo(position * 30) // 높이 설정 50 100 150 , 100 50 0
        }
        
        stackView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
        }
        
        return stackView
    }
    
    // MARK: - 다음 버튼 클릭될 때 호출되는 메서드
    @objc func detailsAwardsButtonTapped() {
        // Button tapped action
        print("detailsAwardsButton tapped!")
    }
    
    // MARK: - 새로고침 버튼 클릭될 때 호출되는 메서드
    @objc func refreshButtonTapped() {
        // Button tapped action
        print("refreshButton tapped!")
    }
    
    // MARK: - 차트 함수
    func setGraph() {
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
