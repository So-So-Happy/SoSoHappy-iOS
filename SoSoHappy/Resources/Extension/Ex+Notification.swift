//
//  Ex+Notification.swift
//  SoSoHappy
//
//  Created by Sue on 12/15/23.
//

import Foundation

// Notification Name 설정
extension Notification.Name {
    static let DidReceiveLikeNotification = Notification.Name("DidReceiveLikeNotification")
    static let DidReceiveShowLikedPostNotification = Notification.Name("DidReceiveShowLikedPostNotification")
    static let logoutNotification = Notification.Name("logoutNotification")
}
