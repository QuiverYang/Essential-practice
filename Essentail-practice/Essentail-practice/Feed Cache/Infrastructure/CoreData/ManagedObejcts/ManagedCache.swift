//
//  ManagedCache.swift
//  Essentail-practice
//
//  Created by Menglin Yang on 2022/12/7.
//

import CoreData

@objc(ManagedCache)
class ManagedCache: NSManagedObject {
    @NSManaged var timestamp: Date
    @NSManaged var feed: NSOrderedSet
}
extension ManagedCache {
    
    var localFeed: [LocalFeedImage] {
        return feed
            .compactMap{ ($0 as? ManagedFeedImage)?.local }
    }
    static func find(in context: NSManagedObjectContext) throws -> ManagedCache? {
        let request = NSFetchRequest<ManagedCache>(entityName: ManagedCache.entity().name!)
        request.returnsObjectsAsFaults = false
        return try context.fetch(request).first
    }
    
    static func newQuniqueInstance(in context: NSManagedObjectContext) throws -> ManagedCache {
        try find(in: context).map(context.delete)
        return ManagedCache(context: context)
    }
}
