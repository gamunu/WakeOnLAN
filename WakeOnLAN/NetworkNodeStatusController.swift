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
    var serviceBrowser: NetServiceBrowser?
    @IBOutlet var networkNodes: NSArrayController?
    
    /// Initialize state information being loaded from the Interface Builder archive (nib file).
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Obtain a reference to the AppDelegate
        guard let appDelegate = NSApplication.shared.delegate as? WakeOnLAN_AppDelegate else { return }
        
        // Obtain the managedObjectContext from the AppDelegate's persistentContainer
        let managedObjectContext = appDelegate.persistentContainer.viewContext
        
        // Create a fetch request for the "Service" entity
        let fetchRequest: NSFetchRequest<Service> = Service.fetchRequest()
        
        // Create a predicate to filter the results if necessary
        let predicate = NSPredicate(format: "identifier != %@", "")
        fetchRequest.predicate = predicate
        
        // Execute the fetch request
        do {
            let serviceArray = try managedObjectContext.fetch(fetchRequest)
            
            for serviceObject in serviceArray {
                // Initialize a service browser for each service type
                serviceBrowser = NetServiceBrowser()
                serviceBrowser?.delegate = self
                
                // Start browsing for the service type
                if let serviceType = serviceObject.identifier {
                    serviceBrowser?.searchForServices(ofType: serviceType, inDomain: "")
                }
            }
            
        } catch {
            print("Error fetching data: \(error)")
        }
    }
    
    
    /**
     Retrieves a managed object for the specified service if it exists. This is a
     convenience method for finding the managed object that has experienced a
     change in status or availability.
     - Parameter service: The `NSNetService` that has changed its status.
     - Returns: The `NetworkNode` if it was found, `nil` if not.
     */
    func managedObjectForService(_ service: NetService) -> NetworkNode? {
        // Obtain a reference to the AppDelegate to access the persistent container
        guard let appDelegate = NSApplication.shared.delegate as? WakeOnLAN_AppDelegate else { return nil }
        let managedObjectContext = appDelegate.persistentContainer.viewContext

        // Create a fetch request for the "NetworkNode" entity
        let fetchRequest: NSFetchRequest<NetworkNode> = NetworkNode.fetchRequest()

        // Create the predicate for the fetch request
        fetchRequest.predicate = NSPredicate(format: "host = %@", service.name)

        // Execute the fetch request
        do {
            let results = try managedObjectContext.fetch(fetchRequest)
            return results.first
        } catch {
            print("Fetch request failed: \(error)")
            return nil
        }
    }
    
    // MARK: - Net Service Browser Delegate Methods
    
    /// Browser delegate response when a service is found. Sets the managed object associated
    /// with the service to true.
    /// - Parameters:
    ///  - aBrowser: Sender of this delegate message.
    ///  - aService:  Network service found by netServiceBrowser. The delegate can use this object to connect to and use the service.
    ///  -  moreComing: True when netServiceBrowser is waiting for additional services. False when there are no additional services.
    func netServiceBrowser(_ browser: NetServiceBrowser, didFind service: NetService, moreComing: Bool) {
        // DEBUG: print("Found Service: \(service.name)")
        
        if let managedObject = managedObjectForService(service) {
            managedObject.setValue(true, forKey: "status")
        }
    }
    
    /// Browser delegate response when a service is removed. Sets the managed object associated
    ///  with the service to false.
    /// - Parameters:
    ///   - browser: Sender of this delegate message.
    ///   - service: Network service found by netServiceBrowser. The delegate can use this object to connect to and use the service.
    ///   - moreComing: True when netServiceBrowser is waiting for additional services. False when there are no additional services.
    func netServiceBrowser(_ browser: NetServiceBrowser, didRemove service: NetService, moreComing: Bool) {
        // print("Remove Service: \(service.name)")
        
        if let managedObject = managedObjectForService(service) {
            managedObject.setValue(false, forKey: "status")
        }
    }
    
    /// Network service delegate response when a service is resolved. Shouldn't do anything.
    /// No attempt is made to resolve the browsed services. Calling of this method is an error,
    /// and the attempt is simply logged.
    /// - Parameters:
    ///   - service: The service that was resolved.
    func netServiceDidResolveAddress(_ service: NetService) {
        print("Service: \(service.name), resolved.")
    }
    
    /// Network service delegate response when a service is not resolved. Shouldn't do anything.
    /// No attempt is made to resolve the browsed services. Calling of this method is an error,
    /// and the attempt is simply logged.
    /// - Parameters:
    ///   - service: The service that was not resolved.
    ///   - errorDict: The error dictionary.
    func netService(_ service: NetService, didNotResolve errorDict: [String: NSNumber]) {
        print("Could not resolve: \(service.name), error: \(errorDict)")
    }
}
