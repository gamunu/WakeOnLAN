//
//  ServiceTypesBrowserController.swift
//  WakeOnLAN
//
//  Created by Gamunu Balagalla on 2023-10-29.
//

import Foundation
import AppKit

@objc(ServiceTypesBrowserController)
@objcMembers
class ServiceTypesBrowserController: NSObject, NetServiceBrowserDelegate, NetServiceDelegate {
    
    var browser: NetServiceBrowser?
    var services: NSMutableArray!
    @IBOutlet var serviceTypesController: NSArrayController!
    
    /**
     This method is called after the controller's view is loaded into memory.
     It sets up the initial state of the services array, initializes a new NetServiceBrowser instance,
     assigns the current instance as its delegate, and starts the search for services of the specified type
     in the specified domain.
     */
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.services = NSMutableArray()
        self.browser = NetServiceBrowser()
        self.browser?.delegate = self
        
        self.browser?.searchForServices(ofType: "_services._dns-sd._udp.", inDomain: "")
    }
    
    deinit {
        self.browser = nil
    }
    
    // MARK: - Net Service Browser Delegate Methods
    
    /**
     Browser delegate response when a service is found. Adds the service to the service types array
     controller, and sets the browser types controller object as the service delegate.
     - Parameters:
     - browser: Sender of this delegate message.
     - service: Network service found by netServiceBrowser. The delegate can use this object to connect to and use the service.
     - moreComing: True when netServiceBrowser is waiting for additional services. False when there are no additional services.
     */
    func netServiceBrowser(_ browser: NetServiceBrowser, didFind service: NetService, moreComing: Bool) {
        serviceTypesController.addObject(service)
        // DEBUG: print("service: \(service), name: \(service.name), domain: \(service.domain), type: \(service.type)")
    }
    
    /**
     Browser delegate response when a service becomes unavailable. Removes the service from the service types array
     controller.
     - Parameters:
     - browser: Sender of this delegate message.
     - service: Network service found by netServiceBrowser. The delegate can use this object to connect to and use the service.
     - moreComing: True when netServiceBrowser is waiting for additional services. False when there are no additional services.
     */
    func netServiceBrowser(_ browser: NetServiceBrowser, didRemove service: NetService, moreComing: Bool) {
        serviceTypesController.removeObject(service)
    }
    
    // MARK: - Net Service Delegate Methods
    
    /**
     Network service delegate response when a service is resolved. Doesn't do anything, yet. Nothing
     really required for simply browsing the service types available in the `local.` domain.
     - Parameter service: The service that was resolved.
     */
    func netServiceDidResolveAddress(_ sender: NetService) {
        // No implementation needed for now
    }
    
    /**
     Network service delegate response when a service is not resolved. Simply logs the error.
     - Parameters:
     - sender: The service that was not resolved.
     - errorDict: The error dictionary.
     */
    func netService(_ sender: NetService, didNotResolve errorDict: [String : NSNumber]) {
        print("Could not resolve: \(errorDict)")
    }
}
