//
//  Service+CoreDataProperties.swift
//  WakeOnLAN
//
//  Created by Gamunu Balagalla on 2023-10-31.
//
//

import Foundation
import CoreData


extension Service {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Service> {
        return NSFetchRequest<Service>(entityName: "Service")
    }

    @NSManaged public var identifier: String?
    @NSManaged public var name: String?
    @NSManaged public var networkNodes: NSSet?

}

// MARK: Generated accessors for networkNodes
extension Service {

    @objc(addNetworkNodesObject:)
    @NSManaged public func addToNetworkNodes(_ value: NetworkNode)

    @objc(removeNetworkNodesObject:)
    @NSManaged public func removeFromNetworkNodes(_ value: NetworkNode)

    @objc(addNetworkNodes:)
    @NSManaged public func addToNetworkNodes(_ values: NSSet)

    @objc(removeNetworkNodes:)
    @NSManaged public func removeFromNetworkNodes(_ values: NSSet)

}

extension Service : Identifiable {

}
