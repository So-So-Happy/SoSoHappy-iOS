//
//  HappyListViewController .swift
//  SoSoHappy
//
//  Created by 박희경 on 2023/08/11.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import ImageSlideshow

final class HappyListViewController : UIViewController {
        
    private lazy var happyTableView = UITableView().then {
        $0.register(HappyListCell.self, forCellReuseIdentifier: HappyListCell.identifier)
        $0.separatorStyle = .none
    }
    
    private lazy var yearMonthLabel = UILabel().then {
        $0.text = "2023.07"
        $0.font = .systemFont(ofSize: 22)
        $0.textColor = UIColor(rgb: 0x626262)
    }
    
    var imageSlideView = ImageSlideView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        happyTableView.delegate = self
        happyTableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
}

// MARK: - Layout & Attribute
private extension HappyListViewController  {
    func configureUI() {
        self.view.backgroundColor = UIColor(rgb: 0xF5F5F5)
        self.happyTableView.backgroundColor = UIColor(rgb: 0xF5F5F5)
        self.view.addSubview(self.happyTableView)
        self.view.addSubview(self.yearMonthLabel)
        self.yearMonthLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            $0.centerX.equalToSuperview()
        }
        self.happyTableView.snp.makeConstraints {
            $0.bottom.left.right.equalToSuperview()
            $0.top.equalTo(yearMonthLabel.snp.bottom).offset(20)
        }
    }
}

// MARK: - tableView DataSource protocol -> rx.items(datasource )
 extension HappyListViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: HappyListCell.identifier, for: indexPath) as? HappyListCell else { return UITableViewCell() }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTap(sender:)))
        cell.imageSlideView.slideShowView.addGestureRecognizer(tapGesture)
        
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
}

//MARK: - tableView Delegate
extension HappyListViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

// MARK: - Action
extension HappyListViewController {
    @objc func didTap(sender: UITapGestureRecognizer? = nil) {
        print("ViewController - didTap() called")
        let fullScreenController = imageSlideView.slideShowView.presentFullScreenController(from: self)
    }
}


#if DEBUG
import SwiftUI
struct HappyListViewControllerRepresentable: UIViewControllerRepresentable {
    
func updateUIViewController(_ uiView: UIViewController,context: Context) {
        // leave this empty
}
@available(iOS 13.0.0, *)
func makeUIViewController(context: Context) -> UIViewController {
    HappyListViewController()
    }
}
@available(iOS 13.0, *)
struct HappyListViewControllerRepresentable_PreviewProvider: PreviewProvider {
    static var previews: some View {
        Group {
            HappyListViewControllerRepresentable()
                .ignoresSafeArea()
                .previewDisplayName("Preview")
                .previewDevice(PreviewDevice(rawValue: "iPhone 11"))
        }
        
    }
} #endif



