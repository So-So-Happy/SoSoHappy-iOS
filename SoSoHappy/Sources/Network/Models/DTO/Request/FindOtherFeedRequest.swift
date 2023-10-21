//
//  FindOtherFeedRequest.swift
//  SoSoHappy
//
//  Created by 박희경 on 2023/09/30.
//

import Foundation

struct FindOtherFeedRequest: Codable, Requestable {
    let nickname: String
    let date: Int64?
    let page: Int
    let size: Int

    var params: [String: Any] {
        var parameters: [String: Any] = [
            "nickname": nickname,
            "page": page,
            "size": size
        ]

        if let date = date {
            parameters["date"] = date
        }

        return parameters
    }

} 
