//
//  LocalStorage.swift
//  SoSoHappy
//
//  Created by 박희경 on 2023/09/10.
//
  
import Foundation

public enum LocalKey: String {
    case isNewUser
    case nickName
    case userIdentifier // id
    case userAccount // email
    case token
    
    init(value: String) {
        switch value {
        case "isNewUser": self = .isNewUser
        case "nickName": self = .nickName
        case "userIdentifier": self = .userIdentifier
        case "token": self = .token
        default:  self = .userAccount
        }
    }
}

extension LocalKey {
    var value: String {
        switch self {
        case .isNewUser:
            return "isNewUser"

        case .nickName:
            return "nickName"

        case .userIdentifier:
            return "userIdentifier"

        case .userAccount:
            return "userAccount"
        case .token:
            return "token"
        }
    }
}


public protocol LocalStorageService: AnyObject {
    func read(key: LocalKey) -> Any?
    func write(key: LocalKey, value: Any)
    func delete(key: LocalKey)
//    func makeKey(email: String, type: SocialType) -> String
}

extension UserDefaults: LocalStorageService {
    public func read(key: LocalKey) -> Any? {
        return Self.standard.object(forKey: key.rawValue)
    }
    
    public func write(key: LocalKey, value: Any) {
        Self.standard.setValue(value, forKey: key.rawValue)
        Self.standard.synchronize()
    }
    
    public func delete(key: LocalKey) {
        Self.standard.setValue(nil, forKey: key.rawValue)
        Self.standard.synchronize()
    }
}

extension UserDefaults {
    public func makeKey(email: String, socialType: String) -> String {
        var key = email + socialType
        return key
    }
}

//
//private func saveKakaoUserInfo() {
//        UserApi.shared.me() { (user, error) in
//            if let user = user,
//               let identifier = user.id,
//               let account = user.kakaoAccount?.email {
//                UserDefaults.standard.write(key: .userIdentifier, value: String(identifier))
//                UserDefaults.standard.write(key: .userAccount, value: account)
//            }
//        }
//    }

