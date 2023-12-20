//
//  SetDarkModeViewController.swift
//  SoSoHappy
//
//  Created by 박희경 on 2023/08/21.
//

import UIKit
import RxSwift
import RxCocoa

final class SetAppThemeController: UIViewController {
    
    // MARK: - Properties
    private lazy var stackView = UIStackView(axis: .vertical,
                                             alignment: .fill,
                                             distribution: .fillEqually,
                                             spacing: 10)
    private lazy var darkModeCell = SetAppThemeCell(theme: .dark)
    private lazy var lightModeCell = SetAppThemeCell(theme: .light)
    private lazy var systemModeCell = SetAppThemeCell(theme: .system)
    
    private var selectedTheme: AppTheme = .system
    
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        bind()
    }
    
}

extension SetAppThemeController {
    
    // MARK: - Layout & Attribute
    func setup() {
        setLayout()
        setAttribute()
        setUI()
    }
    
    func setLayout() {
        let views = [systemModeCell, darkModeCell, lightModeCell]
        
        self.view.addSubview(stackView)
        self.stackView.addArrangedSubviews(views)
        
        stackView.snp.makeConstraints {
            $0.left.right.equalTo(view.safeAreaLayoutGuide).inset(30)
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(50)
        }
        
        views.forEach { view in
            view.snp.makeConstraints {
                $0.horizontalEdges.equalToSuperview()
                $0.height.equalTo(30)
            }
        }
    }
    
    func setAttribute() {
        self.view.backgroundColor = selectedTheme.themeColor()
    }
    
    func setUI() {
        let cells = [darkModeCell, lightModeCell, systemModeCell]
        cells.forEach { cell in
            cell.setTextLabel(cell.theme.text)
            cell.setImage(selectedTheme: self.selectedTheme)
        }
    }
}

extension SetAppThemeController {
    func bind() {
        darkModeCell.button.rx.tap
            .bind { [weak self] in
                self?.selectDarkMode()
            }.disposed(by: disposeBag)
        
        lightModeCell.button.rx.tap
            .bind { [weak self] in
                self?.selectLightMode()
            }.disposed(by: disposeBag)
        
        systemModeCell.button.rx.tap
            .bind { [weak self] in
                self?.selectSystemMode()
            }.disposed(by: disposeBag)
    }
}

extension SetAppThemeController {
    @objc func selectDarkMode() {
        self.selectedTheme = .dark
        let cells = [darkModeCell, lightModeCell, systemModeCell]
        cells.forEach { cell in
            cell.setImage(selectedTheme: self.selectedTheme)
        }
    }
    
    @objc func selectLightMode() {
        self.selectedTheme = .light
        let cells = [darkModeCell, lightModeCell, systemModeCell]
        cells.forEach { cell in
            cell.setImage(selectedTheme: self.selectedTheme)
        }
    }
    
    @objc func selectSystemMode() {
        self.selectedTheme = .system
        let cells = [darkModeCell, lightModeCell, systemModeCell]
        cells.forEach { cell in
            cell.setImage(selectedTheme: self.selectedTheme)
        }
    }
}

final class SetAppThemeCell: UIView {
    fileprivate lazy var textLabel = UILabel()
    fileprivate lazy var button = UIButton()
    
    fileprivate var theme: AppTheme
    
    override init(frame: CGRect) {
        self.theme = .system
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        self.theme = .system
        super.init(coder: coder)
        setup()
    }
    
    convenience init(theme: AppTheme) {
        self.init(frame: .zero)
        self.theme = theme
    }
}

extension SetAppThemeCell {
    
    func setup() {
        setLayout()
        setAttribute()
    }
    
    func setLayout() {
        self.addSubviews(textLabel, button)
        
        textLabel.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
        
        button.snp.makeConstraints {
            $0.right.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(20)
        }
    }
    
    func setAttribute() {
        self.textLabel.font = UIFont.customFont(size: 18, weight: .medium)
        self.textLabel.textColor = UIColor(rgb: 0x626262)
    }
    
    func setImage(selectedTheme: AppTheme) {
        if theme == selectedTheme {
            self.button.setImage(UIImage(named: "selected"), for: .normal)
        } else {
            self.button.setImage(UIImage(named: "notSelected"), for: .normal)
        }
    }

    func setTextLabel(_ text: String) {
        self.textLabel.text = text
    }
    
}

// 앱 테마를 나타내는 Enum 정의
enum AppTheme {
    case system  // 시스템 설정에 따라 (iOS 13 이상에서만 지원)
    case light   // 라이트 모드
    case dark    // 다크 모드
    
    var text: String {
        switch self {
        case .dark: return "다크모드"
        case .light: return "라이트모드"
        case .system: return "시스템설정"
        }
    }

    // 테마에 따라 앱의 색상을 반환하는 메서드
    func themeColor() -> UIColor {
        switch self {
        case .system:
            if #available(iOS 13.0, *) {
                return UIColor { (traitCollection) -> UIColor in
                    if traitCollection.userInterfaceStyle == .dark {
                        return .darkThemeColor
                    } else {
                        return .lightThemeColor
                    }
                }
            } else {
                return .lightThemeColor // iOS 12 및 그 이전 버전에서는 기본적으로 라이트 모드
            }
        case .light:
            return .lightThemeColor
        case .dark:
            return .darkThemeColor
        }
    }
}
