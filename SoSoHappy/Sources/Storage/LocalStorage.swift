//
//  LocalStorage.swift
//  SoSoHappy
//
//  Created by 박희경 on 2023/09/10.
//
  
import Foundation

public enum LocalKey: String {
    case isNewUser
    case nickname
    case userIdentifier // id
    case userAccount // email
    case hasCompletedWelcomePage
}

public protocol LocalStorageService: AnyObject {
    func read(key: LocalKey) -> Any?
    func write(key: LocalKey, value: Any)
    func delete(key: LocalKey)
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
