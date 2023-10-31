//
//  NetworkNode+CoreDataProperties.swift
//  WakeOnLAN
//
//  Created by Gamunu Balagalla on 2023-10-31.
//
//

import Foundation
import CoreData


extension NetworkNode {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NetworkNode> {
        return NSFetchRequest<NetworkNode>(entityName: "NetworkNode")
    }

    @NSManaged public var domain: String?
    @NSManaged public var host: String?
    @NSManaged public var icon: String?
    @NSManaged public var ipAddr: String?
    @NSManaged public var macAddr: String?
    @NSManaged public var status: Bool
    @NSManaged public var owner: Owner?
    @NSManaged public var services: NSSet?

}

// MARK: Generated accessors for services
extension NetworkNode {

    @objc(addServicesObject:)
    @NSManaged public func addToServices(_ value: Service)

    @objc(removeServicesObject:)
    @NSManaged public func removeFromServices(_ value: Service)

    @objc(addServices:)
    @NSManaged public func addToServices(_ values: NSSet)

    @objc(removeServices:)
    @NSManaged public func removeFromServices(_ values: NSSet)

}

extension NetworkNode : Identifiable {

}
