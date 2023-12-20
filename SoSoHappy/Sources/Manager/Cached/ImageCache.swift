//
//  ImageCache.swift
//  SoSoHappy
//
//  Created by Sue on 11/2/23.
//

import UIKit

// MARK: 닉네임(key) 프로필 이미지(value) 캐시
final class ImageCache {
    typealias CacheType = Cache<String, UIImage>
    
    static let shared = ImageCache()
    var cache: CacheType = CacheType()
    
    private init() { }
}
