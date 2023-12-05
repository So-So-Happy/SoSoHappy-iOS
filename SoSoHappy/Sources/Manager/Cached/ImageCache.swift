//
//  ImageCache.swift
//  SoSoHappy
//
//  Created by Sue on 11/2/23.
//

import UIKit

final class ImageCache {
    // typealias 별칭
    typealias CacheType = Cache<String, UIImage> // 닉네임, 프로필 이미지
    
    // singleton - keep alive for the app's existence regarding the ui rendering
    static let shared = ImageCache()
    var cache: CacheType = CacheType()
    
    private init() { }
}
