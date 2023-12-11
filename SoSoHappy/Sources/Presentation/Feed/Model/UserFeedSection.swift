//
//  UserFeedSection.swift
//  SoSoHappy
//
//  Created by Sue on 12/2/23.
//

import RxDataSources

//struct UserFeedSection {
//    var items: [Item]
//}
//
//extension UserFeedSection: SectionModelType {
//    typealias Item = FeedReactor
//    
//    init(original: UserFeedSection, items: [FeedReactor]) {
//        self = original
//        self.items = items
//    }
//}


struct UserFeedSection {
  typealias Model = SectionModel<Int, Item>

  enum Item {
    case feed(FeedReactor)
  }
}

extension UserFeedSection.Item: Equatable {
    static func == (lhs: UserFeedSection.Item, rhs: UserFeedSection.Item) -> Bool {
        switch (lhs, rhs) {
        case let (.feed(lhsReactor), .feed(rhsReactor)):
            return lhsReactor.currentState.userFeed == rhsReactor.currentState.userFeed
        }
    }
}


//enum UserFeedSection { // Section에 사용될 type
//    case userFeeds([UserFeedSectionItem])
//}
//
//extension UserFeedSection: SectionModelType {
//  var items: [UserFeedSectionItem] {
//    switch self {
//    case .userFeeds(let items): return items
//    }
//  }
//  
//  init(original: UserFeedSection, items: [UserFeedSectionItem]) {
//    switch original {
//    case .userFeeds: self = .userFeeds(items)
//    }
//  }
//}
//
//enum UserFeedSectionItem { // Item에 사용될 type
//    case feed(FeedReactor)
//}

