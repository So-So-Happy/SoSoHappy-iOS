//
//  ImageCacheManager.swift
//  SoSoHappy
//
//  Created by Sue on 10/25/23.
//

import UIKit
import Then

class ImageCacheManager {
    static let shared = ImageCacheManager()
    private init() { }
    
    var imageCache = NSCache<NSString, UIImage>().then {
        $0.countLimit =  200 // Hold the most recent images
        $0.totalCostLimit =  1024 * 1024 * 200 // Total amount of data that we can put in the cache
    }
    
    func add(key: String, value: UIImage) {
        print("ImageCacheManager Cache에 추가 ")
        imageCache.setObject(value, forKey: key as NSString)
    }
    
    func get(key: String) -> UIImage? {
        print("ImageCacheManager Cache에서 가져옴")
        return imageCache.object(forKey: key as NSString)
    }
}

/*
 nickname (key) - [lastModified, img]
 img -> byte string으로 주시니깐 ..
 */
