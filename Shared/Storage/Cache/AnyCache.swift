import UIKit

final class AnyCache<T>: CacheProtocol where T: CostableProtocol {
    typealias Value = T
    private let cache = NSCache<NSString, AnyObject>()
    
    init(limit: CacheLimit) {
        cache.totalCostLimit = limit.totalCostLimit
        cache.countLimit = limit.countLimit
    }
    
    func get(_ key: CacheKeyProtocol) -> Value? {
        return cache.object(forKey: key.key as NSString) as? Value
    }
    
    func set(_ value: Value, for key: CacheKeyProtocol) {
        cache.setObject(value as AnyObject, forKey: key.key as NSString, cost: value.cacheCost)
    }
    
    func remove(_ key: CacheKeyProtocol) {
        cache.removeObject(forKey: key.key as NSString)
    }
    
    func removeAll() {
        cache.removeAllObjects()
    }
}

