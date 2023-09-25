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
import ReactorKit
import ImageSlideshow

final class HappyListViewController : UIViewController {
    // MARK: - Properties
    var disposeBag = DisposeBag()
    
    // MARK: - UI Components
    private lazy var happyTableView = UITableView().then {
        $0.register(HappyListCell.self, forCellReuseIdentifier: HappyListCell.cellIdentifier)
        $0.backgroundColor = UIColor(named: "backgroundColor")
        $0.separatorStyle = .none
        $0.estimatedRowHeight = 30
        $0.rowHeight = UITableView.automaticDimension
    }
    
    private lazy var yearMonthLabel = UILabel().then {
        $0.text = "2023.07"
        $0.font = .systemFont(ofSize: 22)
        $0.textColor = UIColor(rgb: 0x626262)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    init(reactor: HappyListViewReactor) {
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - Layout & Attribute
private extension HappyListViewController  {
    private func setLayout() {
        self.view.backgroundColor = UIColor(rgb: 0xF5F5F5)
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

// MARK: - ReactorKit - bind func
extension HappyListViewController: View {
    // MARK: bind
    func bind(reactor: HappyListViewReactor) {
        // MARK: Action (View -> Reactor) 인풋
        self.rx.viewDidLoad
            .map { Reactor.Action.fetchRecentSortedFeeds("202307") } // 예시로 넣었음
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // MARK: State (Reactor -> State) 아웃풋
        reactor.state
            .skip(1)
            .map { $0.feeds }
            .bind(to: happyTableView.rx.items(cellIdentifier: HappyListCell.cellIdentifier, cellType: HappyListCell.self)) { (row,  feed, cell) in
                // viewcontroller에서 직접 feed로 데이터를 전달해주는게 적합한지 잘 모르겠음
                // 이것마저 Reactor에서 다루는 참고 코드가 있는지 확인하고 적용해보면 좋을 듯
                let cellReactor = HappyListCellReactor(feed: feed)
                cell.reactor = cellReactor
                
                cell.imageSlideView.tapObservable
                    .subscribe(onNext: { [weak self] in
                        guard let self = self else { return }
                        cell.imageSlideView.slideShowView.presentFullScreenController(from: self)
                    })
                    .disposed(by: cell.disposeBag)
                
            }
            .disposed(by: disposeBag)
    }
}

