//
//  FindOtherFeedRequest.swift
//  SoSoHappy
//
//  Created by 박희경 on 2023/09/30.
//

import Foundation

struct FindOtherFeedRequest: Codable, Requestable {
    let nickName: String
    let date: Double?
    let page: Int
    let size: Int
    
    var params: [String: Any] {
        var parameters: [String: Any] = [
            "nickname": nickName,
            "page": page,
            "size": size
        ]
        
        if let date = date {
            parameters["date"] = date
        }
        
        return parameters
    }
    
}
