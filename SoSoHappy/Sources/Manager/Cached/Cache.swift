//
//  Cache.swift
//  SoSoHappy
//
//  Created by Sue on 11/1/23.
//

import Foundation

final class Cache<Key: Hashable, Value> {
    private let wrapped = NSCache<WrappedKey, Entry>()
    private let dateProvider: () -> Date
    private let entryLifeTime: TimeInterval
    private let keyTracker = KeyTracker()
    
    init(dateProvider: @escaping () -> Date = Date.init,
         entryLifeTime: TimeInterval = 10 * 60,
         maximumEntryCount: Int = 100) {
        self.dateProvider = dateProvider
        self.entryLifeTime = entryLifeTime
        wrapped.countLimit = maximumEntryCount
        wrapped.delegate = keyTracker
    }
    
    // MARK: 캐시에 저장 메서드
    func insert(_ value: Value, forKey key: Key) {
        let date = dateProvider().addingTimeInterval(entryLifeTime)
        let entry = Entry(key: key, value: value, expirationDate: date)
        print("캐시에 저장 - value \(value), key: \(key)")
        wrapped.setObject(entry, forKey: WrappedKey(key))
        keyTracker.keys.insert(key)
    }
    
    // MARK: 캐시에 저장된 object 가져오는 메서드
    func value(forKey key: Key) -> Value? {
        guard let entry = wrapped.object(forKey: WrappedKey(key)) else {
            print("캐시에 없음")
            return nil // key에 대해 저장된 항목이 없으면 nil
        }
        
        guard dateProvider() < entry.expirationDate else {
            // Discard values that have expired
            print("캐시 시간제한 넘어감")
            removeValue(forKey: key) // 유효기간이 지났으면 항목을 삭제하고
            return nil // key에 대한 value로 nil 반환
        }
        
        print("캐시에 있음 : \(entry.value) ")
        return entry.value
    }
    
    // MARK: 캐시에 해당 key에 대한 entry 제거
    func removeValue(forKey key: Key) {
        wrapped.removeObject(forKey: WrappedKey(key))
    }
}

// MARK: - Cache Subscript
extension Cache {
    subscript(key: Key) -> Value? {
        get { return value(forKey: key) }
        set {
            guard let value = newValue else {
                // If nil was assigned using our subscript,
                // then we remove any value for that key:
                removeValue(forKey: key)
                return
            }
            
            insert(value, forKey: key)
        }
    }
}


// MARK: - WrappedKey (Key)
private extension Cache {
    final class WrappedKey: NSObject {
        let key: Key
        
        init(_ key: Key) { self.key = key }
        
        override var hash: Int { return key.hashValue }
        
        override func isEqual(_ object: Any?) -> Bool {
            guard let value = object as? WrappedKey else {
                return false
            }
            
            return value.key == key
        }
    }
}

// MARK: - Entry (Object)
private extension Cache {
    final class Entry: NSObject, NSDiscardableContent {
        let key: Key // 해당 Entry에 대한 key. entry가 제거되면 key도 remove 할 수 있도록
        let value: Value
        let expirationDate: Date // 캐시 무효화 조건 - 특정 시간 간격 후에 캐시 항목을 제거해서 캐시 항목의 수명 제한 (만료날짜)
        
        init(key: Key, value: Value, expirationDate: Date) {
            self.key = key
            self.value = value
            self.expirationDate = expirationDate
        }
        
        // Keep entries around after entering background state
        // by overriding NSDiscardableContent
        func beginContentAccess() -> Bool { true }
        func endContentAccess() {}
        func discardContentIfPossible() {}
        func isContentDiscarded() -> Bool { false }
    }
}

// MARK: - Key Tracker
private extension Cache {
    final class KeyTracker: NSObject, NSCacheDelegate {
        var keys = Set<Key>()
        
        // MARK: 캐시에서 entry가 되기 직전에 호출되는 메서드
        func cache(_ cache: NSCache<AnyObject, AnyObject>, willEvictObject obj: Any) {
            guard let entry = obj as? Entry else {
                return
            }
            print("캐시에서 삭제되기 전 : \(entry.value)")
            print("캐시에서 삭제된 key : \(entry.key)")
            keys.remove(entry.key)
        }
    }
}

