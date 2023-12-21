//
//  KingFisherImageCache.swift
//  SoSoHappy
//
//  Created by 박희경 on 2023/12/22.
//

import UIKit
import Kingfisher

// MARK: 닉네임(key) 자시고개 글(value) 캐시
class KingFisherImageCachingManager {
    
    static let shared = KingFisherImageCachingManager()
    
    func checkCurrentCacheSize() {
      //현재 캐시 크기 확인
      ImageCache.default.calculateDiskStorageSize { result in
        switch result {
        case .success(let size):
          print("disk cache size = \(Double(size) / 1024 / 1024)")
        case .failure(let error):
          print(error)
        }
      }
    }
    
    func removeCache() {
      //모든 캐시 삭제
      ImageCache.default.clearMemoryCache()
      ImageCache.default.clearDiskCache { print("done clearDiskCache") }
      
      //만료된 캐시만 삭제
      ImageCache.default.cleanExpiredMemoryCache()
      ImageCache.default.cleanExpiredDiskCache { print("done cleanExpiredDiskCache") }
    }
    
}
