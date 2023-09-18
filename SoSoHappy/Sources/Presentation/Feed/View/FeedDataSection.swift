//
//  FeedDataSection.swift
//  SoSoHappy
//
//  Created by Sue on 2023/09/07.
//

import Foundation
import RxDataSources

/*
 궁금한 점
 - section이 1개이면 그냥 rxswift로 구현해도 되는데 RxDataSource로 했을 때 좋은 점이 무엇인지
  - 복잡한 데이터 세트?
  - 추후에 리팩토링해보면서 필요한지 한번 다시 확인해보기
 */

struct FeedDataSection {
    var items: [Feed]
}

extension FeedDataSection: SectionModelType {
    typealias Item = Feed
    
    init(original: FeedDataSection, items: [Item]) {
        self = original
        self.items = items
    }
}
