//
//  SelfIntroductionCache.swift
//  SoSoHappy
//
//  Created by Sue on 11/2/23.
//

import Foundation

final class SelfIntroductionCache {
    typealias CacheType = Cache<String, String> // 닉네임, 자기소개 글
    
    static let shared = SelfIntroductionCache()
    var cache: CacheType = CacheType()
    
    private init() { }
}
