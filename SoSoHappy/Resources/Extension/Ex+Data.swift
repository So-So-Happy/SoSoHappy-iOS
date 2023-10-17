//
//  Ex+Data.swift
//  SoSoHappy
//
//  Created by 박민주 on 10/17/23.
//

import Foundation
import CommonCrypto

extension Data {
    public func sha512() -> String {
        return hexStringFromData(input: digest(input: self as NSData))
    }
    
    private func digest(input : NSData) -> NSData {
        let digestLength = Int(CC_SHA512_DIGEST_LENGTH)
        var hash = [UInt8](repeating: 0, count: digestLength)
        CC_SHA512(input.bytes, CC_LONG(input.length), &hash)
        return NSData(bytes: hash, length: digestLength)
    }
    
    // sha-256을 호출. 반환이 'byte[]'이기 때문에 String 변환이 필요
    private  func hexStringFromData(input: NSData) -> String {
        var bytes = [UInt8](repeating: 0, count: input.length)
        input.getBytes(&bytes, length: input.length)
        
        var hexString = ""
        for byte in bytes {
            hexString += String(format:"%02x", UInt8(byte))
        }
        
        return hexString
    }
}
