//
//  UserFeedSection.swift
//  SoSoHappy
//
//  Created by Sue on 12/2/23.
//

import RxDataSources

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
