//
//  TabBarController.swift
//  SoSoHappy
//
//  Created by 박희경 on 2023/08/28.
//

import UIKit
import Then

protocol TabBarAddButtonDelegate: AnyObject {
    func addButtonTapped()
}

// MARK: 왜 앞에 public을 붙일까?
public final class TabBarController: UITabBarController {
    weak var addDelegate: TabBarAddButtonDelegate?
    let addButton = AnimationButton(frame: CGRect(x: 0, y: 0, width: 75, height: 75)).then {
        $0.setImage(UIImage(named: "naviIcon"), for: .normal)
        $0.addTarget(self, action: #selector(addButtonTapped(sender:)), for: .touchUpInside)
  
    public init() {
        super.init(nibName: nil, bundle: nil)
        object_setClass(self.tabBar, TabBar.self)
        setTabBar()
        setupMiddleButton()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    class TabBar: UITabBar {
        override func sizeThatFits(_ size: CGSize) -> CGSize {
            return CGSize(width: UIScreen.main.bounds.width, height: 96)
        }
    }
}

// MARK: - Functions
extension TabBarController {
    // MARK: Tab bar settings
    private func setTabBar() {
        tabBar.layer.shadowColor = UIColor.black.cgColor
        tabBar.layer.shadowOpacity = 0.3
        tabBar.layer.shadowOffset = CGSize(width: 0, height: 0)
        tabBar.layer.shadowRadius = 0.33
        tabBar.barTintColor = UIColor.white
        let fontAttributes = [NSAttributedString.Key.font: UIFont.customFont(size: 12, weight: .medium)]
        UITabBarItem.appearance().setTitleTextAttributes(fontAttributes, for: .normal)
    }
    
    // MARK: Set custom middle button
    private func setupMiddleButton() {
        // MARK: frame 구체화
        var addButtonFrame = addButton.frame
        addButtonFrame.origin.y = view.bounds.height - addButtonFrame.height - 47
        addButtonFrame.origin.x = view.bounds.width / 2 - addButtonFrame.size.width / 2
        addButton.frame = addButtonFrame
        addButton.layer.cornerRadius = addButtonFrame.height / 2
        
        addButton.adjustsImageWhenHighlighted = false
        
        // 이 버튼이 TabBarPage.add와 관련되어 있음을 나타내기 위해 태그를 2로 설정합니다
        addButton.tag = TabBarPage.add.pageOrderNumber()
        view.addSubview(addButton)
        view.layoutIfNeeded()
    }
    
    // MARK: Actions
    @objc private func addButtonTapped(sender: UIButton) {
        addDelegate?.addButtonTapped()
    }
}
