//
//  SelfIntroductionCache.swift
//  SoSoHappy
//
//  Created by Sue on 11/2/23.
//

import Foundation

// MARK: 닉네임(key) 자시고개 글(value) 캐시
final class SelfIntroductionCache {
    typealias CacheType = Cache<String, String>
    
    static let shared = SelfIntroductionCache()
    var cache: CacheType = CacheType()
    
    private init() { }
}
