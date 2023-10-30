//
//  ServiceBrowserController.swift
//  WakeOnLAN
//
//  Created by Gamunu Balagalla on 2023-10-30.
//

import Foundation
import AppKit

@objc(ServiceBrowserController)
@objcMembers
class ServiceBrowserController: NSObject, NetServiceBrowserDelegate, NetServiceDelegate {
    
    var browser: NetServiceBrowser?
    var connectedService: NetService?
    var services: [NetService] = []
    var foundServices: [NetService] = []
    var resolvedService: ResolvedService?
    var serviceCount: Int = 0
    
    @IBOutlet var servicesController: NSArrayController!
    @IBOutlet var serviceTypes: NSArrayController!
    @IBOutlet var networkNodes: NSArrayController!
    @IBOutlet var scanProgressIndicator: NSProgressIndicator!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        services = []
        foundServices = []
        browser = NetServiceBrowser()
        browser?.delegate = self
    }
    
    deinit {
        browser?.stop()
        browser = nil
    }
    
    /**
     Performs the scan action for the Bonjour service browser. Retrieves the
     type of service to scan for from the service types browser. Note, starts
     the progress indicator for the scan.
     */
    @IBAction func scan(_ sender: Any) {
        // DEBUG: print("Scanning for Bonjour services...")
        defer {
            // To allow for multiple scans with the same or different type of service,
            // clear the arrays populated by the services.
            scanProgressIndicator?.stopAnimation(self)
            if let arrangedObjects = servicesController?.arrangedObjects as? [Any] {
                servicesController?.remove(contentsOf: arrangedObjects)
            }
        }
        
        // Set the service count to zero, and start animating the progress
        // indicator. Note, the service count is only used to support the
        // progress indicator. See comments in the other methods for description
        // of the closed loop functionality.
        serviceCount = 0
        scanProgressIndicator.startAnimation(self)
        
        // Retrieve the selected service type. The type identifier required
        // for scanning needs to be built for two members of the service
        // object.
        guard let selected = serviceTypes?.selectedObjects as? [NetService],
              let serviceName = selected.first?.name.appending("."),
              let serviceProtocol = selected.first?.type.prefix(5) else { return }
        
        let serviceType = serviceName + serviceProtocol
        
        // DEBUG: print("Type to scan for: \(serviceType)")
        
        // To allow for multiple scans with the same or different type of service,
        // stop the browser
        browser?.stop()
        
        // Start the browser to search for the selected service type.
        browser?.searchForServices(ofType: String(serviceType), inDomain: "")
    }
    
    // MARK: - NSNetServiceBrowser Delegate Methods
    
    /**
     Browser delegate response when a service is found. Adds the service to the found services array.
     Sets the browser controller object as the service delegate, and attempts to resolve the service.
     */
    func netServiceBrowser(_ browser: NetServiceBrowser, didFind service: NetService, moreComing: Bool) {
        foundServices.append(service)
        service.delegate = self
        service.resolve(withTimeout: 2)
        serviceCount += 1
    }
    
    /**
     Browser delegate response when a service becomes unavailable. Removes the service from the found services array.
     */
    func netServiceBrowser(_ browser: NetServiceBrowser, didRemove service: NetService, moreComing: Bool) {
        foundServices.removeAll { $0 == service }
    }
    
    // MARK: - NSNetService Delegate Methods
    
    /**
     Network service delegate response when a service is resolved. Creates a resolved service object.
     Adds the resolved service to the service browser array controller, and monitors the service
     to get its device info. Note, stops the progress indicator for the scan.
     */
    func netServiceDidResolveAddress(_ sender: NetService) {
        connectedService = sender
        
        let rService = ResolvedService(service: sender)
        servicesController.addObject(rService)
        
        let aService = NetService(domain: "local.", type: "_device-info._tcp", name: sender.name)
        aService.delegate = self
        aService.startMonitoring()
        
        serviceCount -= 1
        if serviceCount <= 0 {
            scanProgressIndicator.stopAnimation(self)
        }
    }
    
    /**
     Network service delegate response when a service is not resolved. Decrements
     the service count, and then simply logs the error.
     */
    func netService(_ sender: NetService, didNotResolve errorDict: [String : NSNumber]) {
        serviceCount -= 1
        NSLog("Could not resolve: %@ %@", sender.name, errorDict)
    }
    
    /**
     Network service delegate response when a service updates its text record. Get the model identifier
     from the text record, and set the appropriate object record in the array controller.
     */
    func netService(_ sender: NetService, didUpdateTXTRecord data: Data) {
        guard let modelData = NetService.dictionary(fromTXTRecord: data)["model"],
              let model = String(data: modelData, encoding: .utf8) else { return }
        
        sender.stopMonitoring()
        
        guard let rServices = servicesController.arrangedObjects as? [ResolvedService] else { return }
        
        let predicate = NSPredicate(format: "(host = %@)", sender.name)
        guard let resolved = (rServices.filter { predicate.evaluate(with: $0) }).last else { return }
        
        resolved.icon = model
    }
}
