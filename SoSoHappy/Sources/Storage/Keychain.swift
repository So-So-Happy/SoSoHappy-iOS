//
//  TokenUtils.swift
//  SoSoHappy
//
//  Created by 박희경 on 2023/09/07.
//


import Security
import Alamofire


final class KeychainService: NSObject {
    public class func saveData(serviceIdentifier: String, forKey: String, data: String) {
        self.save(service: serviceIdentifier, forKey: forKey, data: data)
    }
     
    public class func loadData(serviceIdentifier: String, forKey: String) -> String? {
        let data = self.load(service: serviceIdentifier, forKey: forKey)
         
        return data
    }
    
    public class func deleteTokenData(identifier: String, account: String) {
        if let token = KeychainService.loadData(serviceIdentifier: identifier, forKey: account) {
            self.delete(service: identifier, forKey: account, data: token)
        }
    }
}

private extension KeychainService {
    class func save(service: String, forKey: String, data: String) {
        let dataFromString: Data = data.data(using: String.Encoding.utf8)!
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword as String,
                                    kSecAttrService as String: service,
                                    kSecAttrAccount as String: forKey,
                                    kSecValueData as String: dataFromString]
        
        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }
     
    class func load(service: String, forKey: String) -> String? {
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword as String,
                                    kSecAttrService as String: service,
                                    kSecAttrAccount as String: forKey,
                                    kSecReturnData as String: kCFBooleanTrue!,
                                    kSecMatchLimit as String: kSecMatchLimitOne as String]
         
        var retrievedData: NSData?
        var dataTypeRef: AnyObject?
        var contentsOfKeychain: String?
         
        let status: OSStatus = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
         
        if status == errSecSuccess {
            retrievedData = dataTypeRef as? NSData
            contentsOfKeychain = String(data: retrievedData! as Data, encoding: String.Encoding.utf8)
        } else {
            contentsOfKeychain = nil
        }
         
        return contentsOfKeychain
    }
    
    class func delete(service: String, forKey: String, data: String) {
        let dataFromString: Data = data.data(using: String.Encoding.utf8)!
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword as String,
                                    kSecAttrService as String: service,
                                    kSecAttrAccount as String: forKey,
                                    kSecValueData as String: dataFromString]
        
        SecItemDelete(query as CFDictionary)
    }
}

extension KeychainService {
    
    class func getAccessToken() -> String {

        let accessToken = KeychainService.loadData(
            serviceIdentifier: "sosohappy.tokens",
            forKey: "accessToken"
        ) ?? ""
        
        return accessToken
    }
    
    class func getRefreshToken() -> String {
        let refreshToken = KeychainService.loadData(
            serviceIdentifier: "sosohappy.tokens",
            forKey: "refreshToken"
        ) ?? ""
        
        return refreshToken
    }
    
    class func getUserEmail() -> String {
        let provider = KeychainService.loadData(
            serviceIdentifier: "sosohappy.userInfo",
            forKey: "provider"
        ) ?? ""
        
        let userEmail = KeychainService.loadData(
            serviceIdentifier: "sosohappy.userInfo\(provider)",
            forKey: "userEmail"
        ) ?? ""
        
        return userEmail
    }
    
    class func getNickName() -> String {

        let provider = KeychainService.loadData(
            serviceIdentifier: "sosohappy.userInfo",
            forKey: "provider"
        ) ?? ""
        
        let nickName = KeychainService.loadData(
            serviceIdentifier: "sosohappy.userInfo\(provider)",
            forKey: "userNickName"
        ) ?? ""
        
        return nickName
    }
    
}
