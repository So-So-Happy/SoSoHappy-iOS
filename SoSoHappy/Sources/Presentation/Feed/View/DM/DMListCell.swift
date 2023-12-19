//
//  DMListCell.swift
//  SoSoHappy
//
//  Created by Sue on 2023/08/25.
//

import UIKit
import SnapKit

class DMListCell: UITableViewCell {
    // MARK: - Properties
    static var cellIdentifer: String {
        return String(describing: Self.self)
    }
    // MARK: - UI Components
    private lazy var backgroundCircleView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 30
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.borderWidth = 0.4
        return view
    }()
    
    private lazy var profileImageView: UIImageView = {
        let imageview = UIImageView()
        imageview.contentMode = .scaleAspectFit
        imageview.image = UIImage(named: "profile")
        imageview.layer.cornerRadius = 22
        
        return imageview
    }()
    
    private lazy var nickNameRecentMessageStackView = NickNameRecentMessageStackView()
    private lazy var recentTimeMessageCountStackView = RecentTimeMessageCountStackView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setCellAttributes()
        addSubViews()
        setConstraints()
        print("contentView.height : \(self.contentView.frame.height)")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension DMListCell {
    private func setCellAttributes() {
        backgroundColor = .clear // tableView의 backgroundColor가 보이도록 cell은 .clear
        selectionStyle = .default
    }
    private func addSubViews() {
        self.contentView.addSubview(backgroundCircleView)
        backgroundCircleView.addSubview(profileImageView)
        self.contentView.addSubview(nickNameRecentMessageStackView)
        self.contentView.addSubview(recentTimeMessageCountStackView)
    }
    
    private func setConstraints() {
        backgroundCircleView.snp.makeConstraints { make in
            make.width.height.equalTo(60)
            make.leading.top.equalToSuperview().inset(16)
            make.bottom.lessThanOrEqualToSuperview().inset(16)
        }
        
        profileImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.width.equalTo(44)
        }
        
        nickNameRecentMessageStackView.snp.makeConstraints { make in
            make.leading.equalTo(backgroundCircleView.snp.trailing).offset(8)
            make.centerY.equalToSuperview()
        }
     
        recentTimeMessageCountStackView.snp.makeConstraints { make in
            make.centerY.equalTo(profileImageView)
            make.left.equalTo(nickNameRecentMessageStackView.snp.right).offset(10)
            make.right.equalToSuperview().inset(16)
        }
    }
}

#if DEBUG
import SwiftUI
struct DMListViewControllerRepresentable: UIViewControllerRepresentable {
    
    func updateUIViewController(_ uiView: UIViewController,context: Context) {
        // leave this empty
    }
    @available(iOS 13.0.0, *)
    func makeUIViewController(context: Context) -> UIViewController{
        DMListViewController()
    }
}
@available(iOS 13.0, *)
struct DMListViewControllerRepresentable_PreviewProvider: PreviewProvider {
    static var previews: some View {
        Group {
            DMListViewControllerRepresentable()
                .ignoresSafeArea()
                .previewDisplayName(/*@START_MENU_TOKEN@*/"Preview"/*@END_MENU_TOKEN@*/)
                .previewDevice(PreviewDevice(rawValue: "iPhone 14 Pro"))
        }
        
    }
} #endif
