//
//  BaseTargetType.swift
//  SoSoHappy
//
//  Created by 박희경 on 2023/09/07.
//

import Foundation
import Moya

protocol BaseTargetType: TargetType {
    func getPath() -> String
    func getMethod() -> Moya.Method
    func getTask() -> Moya.Task
    func getHeader() -> [String: String]?
}

extension BaseTargetType {
    var baseURL: URL {
        // plist 에서 baseURL 뽑아오기
        return URL(string: Bundle.main.baseURL)!
    }
    
    var sampleData: Data { Data() }
    var authorizationType: JWTAuthorizationType? { return .accessToken }
}

extension BaseTargetType {
    
    func getHeader() -> [String: String]? {
        return ["Content-Type": "application/json"]
    }
    
}
