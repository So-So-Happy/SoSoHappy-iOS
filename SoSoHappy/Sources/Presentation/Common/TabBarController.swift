//
//  TabBarController.swift
//  SoSoHappy
//
//  Created by 박희경 on 2023/08/28.
//

import UIKit

public final class TabBarController: UITabBarController {
    
    let addButton = AnimationButton(frame: CGRect(x: 0, y: 0, width: 75, height: 75))
    
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
        let appearance = tabBar.standardAppearance
        appearance.backgroundColor = UIColor(named: "CellColor")
        tabBar.standardAppearance = appearance
        
        let fontAttributes = [NSAttributedString.Key.font: UIFont.customFont(size: 12, weight: .medium)]
        UITabBarItem.appearance().setTitleTextAttributes(fontAttributes, for: .normal)
    }
    
    // MARK: Set custom middle button
    private func setupMiddleButton() {
        var addButtonFrame = addButton.frame
        addButtonFrame.origin.y = view.bounds.height - addButtonFrame.height - 47
        addButtonFrame.origin.x = view.bounds.width / 2 - addButtonFrame.size.width / 2
        addButton.frame = addButtonFrame
        addButton.layer.cornerRadius = addButtonFrame.height / 2
        view.addSubview(addButton)
        
        addButton.adjustsImageWhenHighlighted = false
        addButton.setImage(UIImage(named: "naviIcon"), for: .normal)
        addButton.addTarget(self, action: #selector(menuButtonAction(sender:)), for: .touchUpInside)
        view.layoutIfNeeded()
    }
    
    // MARK: Actions
    @objc private func menuButtonAction(sender: UIButton) {
        selectedIndex = 2
    }
}
