//
//  WakeOnLAN_AppDelegate.swift
//  WakeOnLAN
//
//  Created by Gamunu Balagalla on 2023-10-30.
//

import Foundation
import AppKit
import CoreData

@NSApplicationMain
@objc(WakeOnLAN_AppDelegate)
@objcMembers
class WakeOnLAN_AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var networkNodes: NSArrayController!
    @IBOutlet weak var serviceBrowser: NSArrayController!
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "WakeOnLAN_DataModel")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    var managedObjectContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    // MARK: - Application and Window action
    
    /// Called after the application has completed launching.
    /// Registers two custom value transformers to be used within the application.
    /// - Parameter aNotification: The notification object containing information about the launch process.
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let statusValueTransformerName = NSValueTransformerName(rawValue: "StatusValueTransformer")
        ValueTransformer.setValueTransformer(StatusValueTransformer(), forName: statusValueTransformerName)
        
        let nodeImageValueTransformerName = NSValueTransformerName(rawValue: "NodeImageValueTransformer")
        ValueTransformer.setValueTransformer(NodeImageValueTransformer(), forName: nodeImageValueTransformerName)
    }
    
    /// This method is called when the app is clicked on the Dock and there are no visible windows.
    /// - Parameters:
    ///   - sender: The application object that is being reopened.
    ///   - flag: A Boolean value that indicates whether the application has any visible windows.
    /// - Returns: A Boolean value indicating whether the application should handle reopening.
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag {
            window.makeKeyAndOrderFront(nil)
        }
        return true
    }
    
    /// Returns the `NSUndoManager` for the application, associated with the application's managed object context.
    /// - Returns: The undo manager object.
    /// - SeeAlso: `NSUndoManager`
    func windowWillReturnUndoManager(window: NSWindow) -> UndoManager? {
        return persistentContainer.viewContext.undoManager
    }
    
    /// Handles the saving of changes in the application's managed object context before the application terminates.
    /// - Parameter sender: The object that sent the terminate action.
    /// - Returns: The terminate reply object.
    /// - SeeAlso: `NSApplication.TerminateReply`
    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        let context = persistentContainer.viewContext
        
        if !context.commitEditing() {
            NSLog("\(NSStringFromClass(type(of: self))) unable to commit editing to terminate")
            return .terminateCancel
        }
        
        if !context.hasChanges {
            return .terminateNow
        }
        
        do {
            try context.save()
        } catch {
            let nserror = error as NSError
            
            let result = sender.presentError(nserror)
            if (result) {
                return .terminateCancel
            }
            
            let question = NSLocalizedString("Could not save changes while quitting. Quit anyway?", comment: "Quit without saving warning: question")
            let info = NSLocalizedString("Quitting now will lose any changes you have made since the last successful save", comment: "Quit without saving warning: info")
            let quitButton = NSLocalizedString("Quit anyway", comment: "Quit without saving warning: quit button")
            let cancelButton = NSLocalizedString("Cancel", comment: "Quit without saving warning: cancel button")
            
            let alert = NSAlert()
            alert.messageText = question
            alert.informativeText = info
            alert.addButton(withTitle: quitButton)
            alert.addButton(withTitle: cancelButton)
            
            let answer = alert.runModal()
            if answer == .alertSecondButtonReturn {
                return .terminateCancel
            }
        }
        
        // If we got here, it is time to quit.
        return .terminateNow
    }
    
    // MARK: - Custom Actions
    
    /// Performs the save action for the application by attempting to save the managed object context. Any encountered errors are presented to the user.
    /// - Parameter sender: The object that sent the action.
    /// - SeeAlso: `IBAction`
    @IBAction func saveAction(_ sender: Any) {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                NSApplication.shared.presentError(error)
            }
        }
    }
    
    /// Performs the wake action for the application, which is to send the Wake on LAN
    /// Magic Packet using the selected network node's MAC address. Any encountered
    /// errors are presented to the user.
    ///
    /// - Parameter sender: The object that sent the action.
    /// - Returns: The IBAction object.
    @IBAction func wakeAction(_ sender: Any) {
        // Assuming `networkNodes` is an IBOutlet connected to an NSArrayController
        guard let selected = networkNodes.selectedObjects as? [NSManagedObject],
              let macAddr = selected.first?.value(forKey: "macAddr") as? String else {
            print("No selected network node or MAC address found")
            return
        }
        print("MAC Address: \(macAddr)")
        
        // Convert String to CString for the send_wol function
        let cStr = strdup(macAddr)
        defer { free(cStr) }  // Ensure memory is freed after use
        
        print("MAC Address: \(String(cString: cStr!))")
        
        // Call the send_wol function with the C string
        let result = send_wol(cStr!)
        
        // Check the result if necessary
        if result != 0 {
            print("Failed to send wake on LAN magic packet, error code: \(result)")
        }
        
        // Test code for changing the status indicator in the table view.
        // TBD: Move to a thread that monitors status of the network nodes.
        // networkNodes.setValue(NSNumber(value: (sender as? NSControl)?.intValue ?? 0), forKeyPath: "selection.status")
    }
    
    /// Adds the selected service host from the Service Browser to the persistent store as a managed object.
    /// Inserts a new managed object for the NetworkNode entity, and sets its values from the selected
    /// resolved service in the Service Browser. Stores the service type, as well, and creates the
    /// relationship between service and node.
    ///
    /// - Parameter sender: The object that sent the action.
    /// - Returns: The IBAction object.
    @IBAction func addSelectedServiceHost(_ sender: Any) {
        // Assume serviceBrowser and networkNodes are properly set up elsewhere in your code
        guard let selectedResolvedServices = serviceBrowser.selectedObjects as? [ResolvedService],
              let selectedService = selectedResolvedServices.first else {
            // Handle error or exit if there are no selected services
            return
        }
        
        let context = persistentContainer.viewContext
        
        // Check if NetworkNode already exists
        let fetchRequest: NSFetchRequest<NetworkNode> = NetworkNode.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "%K = %@", "host", selectedService.host)
        
        do {
            let existingNodes = try context.fetch(fetchRequest)
            let networkNode: NetworkNode
            if let existingNode = existingNodes.first {
                networkNode = existingNode
            } else {
                // If it doesn't exist, create a new NetworkNode
                networkNode = NetworkNode(context: context)
                networkNode.host = selectedService.host
                networkNode.domain = selectedService.domain
                networkNode.ipAddr = selectedService.ipAddr
                networkNode.macAddr = selectedService.macAddr
                networkNode.icon = selectedService.icon
            }
            
            // Check if Service already exists
            let serviceFetchRequest: NSFetchRequest<Service> = Service.fetchRequest()
            serviceFetchRequest.predicate = NSPredicate(format: "%K = %@", "identifier", selectedService.type)
            
            let existingServices = try context.fetch(serviceFetchRequest)
            let service: Service
            if let existingService = existingServices.first {
                service = existingService
            } else {
                // If it doesn't exist, create a new Service
                service = Service(context: context)
                service.identifier = selectedService.type
                service.name = selectedService.name
            }
            
            // Set up the relationship between NetworkNode and Service
            service.addToNetworkNodes(networkNode)
            networkNode.addToServices(service)
            
            // Save the context
            try context.save()
            
        } catch {
            // Handle or log error
            print("Error: \(error)")
        }
    }
}
