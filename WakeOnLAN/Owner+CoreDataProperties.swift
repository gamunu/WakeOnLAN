//
//  Owner+CoreDataProperties.swift
//  WakeOnLAN
//
//  Created by Gamunu Balagalla on 2023-10-31.
//
//

import Foundation
import CoreData


extension Owner {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Owner> {
        return NSFetchRequest<Owner>(entityName: "Owner")
    }

    @NSManaged public var email: String?
    @NSManaged public var firstName: String?
    @NSManaged public var lastName: String?
    @NSManaged public var nickName: String?
    @NSManaged public var networkNodes: NSSet?

}

// MARK: Generated accessors for networkNodes
extension Owner {

    @objc(addNetworkNodesObject:)
    @NSManaged public func addToNetworkNodes(_ value: NetworkNode)

    @objc(removeNetworkNodesObject:)
    @NSManaged public func removeFromNetworkNodes(_ value: NetworkNode)

    @objc(addNetworkNodes:)
    @NSManaged public func addToNetworkNodes(_ values: NSSet)

    @objc(removeNetworkNodes:)
    @NSManaged public func removeFromNetworkNodes(_ values: NSSet)

}

extension Owner : Identifiable {

}
