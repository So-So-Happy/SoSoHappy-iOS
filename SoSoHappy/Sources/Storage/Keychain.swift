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
//        if let identifier = UserDefaults.standard.read(key: .userIdentifier) as? String,
//                   let account = UserDefaults.standard.read(key: .userAccount) as? String,
//           let token = KeychainService.loadData(serviceIdentifier: identifier, forKey: account) {
//            self.delete(service: identifier, forKey: account, data: token)
//        }
        
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
            print("No Data From Keychain")
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
    
    class func getAccessToken(serviceID: String) -> String? {
        let serviceID = serviceID
        if let accessToken = self.loadData(serviceIdentifier: serviceID, forKey: "accessToken") {
            return accessToken
        } else {
            return nil
        }
    }
    
    class func getRefreshToken(serviceID: String) -> String? {
        let serviceID = serviceID
        if let refreshToken = self.loadData(serviceIdentifier: serviceID, forKey: "refreshToken")  {
            return refreshToken
        } else {
            return nil
        }
    }
    
//    class func getEmail(serviceID: String) -> String? {
//        let serviceID = serviceID
//        if let email = self.read(serviceID, account: "email") {
//            return email
//        } else {
//            return nil
//        }
//    }
//
}
