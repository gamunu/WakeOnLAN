//
//  NetworkNodeStatusController.swift
//  WakeOnLAN
//
//  Created by Gamunu Balagalla on 2023-10-29.
//

import Foundation
import AppKit

@objc(NetworkNodeStatusController)
class NetworkNodeStatusController: NSObject, NetServiceBrowserDelegate {
    var managedObjectContext: NSManagedObjectContext?
    @IBOutlet var networkNodes: NSArrayController?
    
    /**
     Initialize state information being loaded from the Interface Builder archive (nib file).
     */
    override func awakeFromNib() {
        super.awakeFromNib()
        
        guard let managedObjectContext = networkNodes?.managedObjectContext else { return }
        
        // Create a fetch request to retrieve the "Service" entity objects for this context
        // if they exist.
        guard let entityDescription = NSEntityDescription.entity(forEntityName: "Service", in: managedObjectContext) else { return }
        let request = NSFetchRequest<NSManagedObject>(entityName: "Service")
        request.entity = entityDescription
        
        
        // Create the predicate for the fetch request that retrieves all of
        // the Service objects.
        let predicate = NSPredicate(format:"identifier > %@", "")
        // DEBUG: print("predicate: \(predicate)")
        request.predicate = predicate
        
        // Attempt to fetch the Service managed objects.
        do {
            let array = try managedObjectContext.fetch(request)
            // DEBUG: print("array: \(array)")
            
            // Iterate through the array of Service types.
            for serviceObject in array {
                // DEBUG: print("Service name: \(serviceObject.value(forKey: "identifier") ?? "")")
                
                // Create and initialize a service browser for each service type.
                let serviceBrowser = NetServiceBrowser()
                serviceBrowser.delegate = self
                
                // Start the browser for the service type.
                if let serviceType = serviceObject.value(forKey: "identifier") as? String {
                    serviceBrowser.searchForServices(ofType: serviceType, inDomain: "")
                }
            }
        } catch {
            print("Error fetching data: \(error)")
        }
    }
    
    
    /**
     Retrieves a managed object for the specified service if it exists. This is a
     convenience method for finding the managed object that has experienced a
     change in status or availability
     
     - Parameter service: The `NSNetService` that has changed its status.
     - Returns: The `NSManagedObject` if it was found, `nil` if not.
     */
    func managedObjectForService(_ service: NetService) -> NSManagedObject? {
        // Initialize the return value to nil. If the managed object
        // is not found, and it falls through, this is returned.
        var managedObject: NSManagedObject? = nil
        
        // Create a fetch request to retrieve the "NetworkNode" entity object for this service
        // if it exists.
        let entityDescription = NSEntityDescription.entity(forEntityName: "NetworkNode", in: managedObjectContext!)
        let request = NSFetchRequest<NSManagedObject>(entityName: "NetworkNode")
        request.entity = entityDescription
        
        // Create the predicate for the fetch request that retrieves the managed object
        // that corresponds to the found Service.
        let predicate = NSPredicate(format: "host = %@", service.name)
        request.predicate = predicate
        
        // Attempt to fetch the NetworkNode managed object.
        do {
            let array = try managedObjectContext!.fetch(request)
            // The fetch request returned a single object. This is the managed object associated
            // with the service. Set the return value, a pointer to this object.
            if array.count == 1 {
                managedObject = array[0]
            }
        } catch {
            print("Fetch request failed: \(error)")
        }
        
        // Finally, return the found object, or nil, if it was not found.
        return managedObject
    }
    
    // MARK: - Net Service Browser Delegate Methods
    
    /**
     Browser delegate response when a service is found. Sets the managed object associated
     with the service to true.
     
     - Parameters:
     - aBrowser: Sender of this delegate message.
     - aService: Network service found by netServiceBrowser. The delegate can use this object to connect to and use the service.
     - moreComing: True when netServiceBrowser is waiting for additional services. False when there are no additional services.
     */
    func netServiceBrowser(_ browser: NetServiceBrowser, didFind service: NetService, moreComing: Bool) {
        // DEBUG: print("Found Service: \(service.name)")
        
        if let managedObject = managedObjectForService(service) {
            managedObject.setValue(true, forKey: "status")
        }
    }
    
    /**
     Browser delegate response when a service is removed. Sets the managed object associated
     with the service to false.
     
     - Parameters:
     - browser: Sender of this delegate message.
     - service: Network service found by netServiceBrowser. The delegate can use this object to connect to and use the service.
     - moreComing: True when netServiceBrowser is waiting for additional services. False when there are no additional services.
     */
    func netServiceBrowser(_ browser: NetServiceBrowser, didRemove service: NetService, moreComing: Bool) {
        // DEBUG: print("Remove Service: \(service.name)")
        
        if let managedObject = managedObjectForService(service) {
            managedObject.setValue(false, forKey: "status")
        }
    }
    
    /**
     Network service delegate response when a service is resolved. Shouldn't do anything.
     No attempt is made to resolve the browsed services. Calling of this method is an error,
     and the attempt is simply logged.
     
     - Parameter service: The service that was resolved.
     */
    func netServiceDidResolveAddress(_ service: NetService) {
        print("Service: \(service.name), resolved.")
    }
    
    /**
     Network service delegate response when a service is not resolved. Shouldn't do anything.
     No attempt is made to resolve the browsed services. Calling of this method is an error,
     and the attempt is simply logged.
     
     - Parameters:
     - service: The service that was not resolved.
     - errorDict: The error dictionary.
     */
    func netService(_ service: NetService, didNotResolve errorDict: [String: NSNumber]) {
        print("Could not resolve: \(service.name), error: \(errorDict)")
    }
}
