//
//  TabBarController.swift
//  SoSoHappy
//
//  Created by 박희경 on 2023/08/28.
//

import UIKit

public final class TabBarController: UITabBarController {
    
    public init() {
        super.init(nibName: nil, bundle: nil)
        object_setClass(self.tabBar, TabBar.self)
        applyShadow()
    }
    
    class TabBar: UITabBar {
        
        override func sizeThatFits(_ size: CGSize) -> CGSize {
            return CGSize(width: UIScreen.main.bounds.width, height: 96)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    private func applyShadow() {
        tabBar.layer.shadowColor = UIColor.black.cgColor
        tabBar.layer.shadowOpacity = 0.3
        tabBar.layer.shadowOffset = CGSize(width: 0, height: 0)
        tabBar.layer.shadowRadius = 0.33
    }
    
}
