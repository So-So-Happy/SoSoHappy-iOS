//
//  TestAPI.swift
//  SoSoHappy
//
//  Created by 박희경 on 2023/10/08.
//


import Moya

enum TestAPI {
    case list
}

extension TestAPI: TargetType {
    var baseURL: URL {
        return URL(string: "https://sosohappy.net")!
    }
    
    var headers: [String: String]? {
        var header = ["Content-Type": "application/json"]
        return header
    }
    
    var path: String {
        switch self {
        case .list: return "/feed-service/test-actuator"
        }
    }

    var method: Method {
        switch self {
        case .list: return .get
        }
    }

    var task: Task {
        switch self {
        case .list: return .requestPlain
        }
    }
}

