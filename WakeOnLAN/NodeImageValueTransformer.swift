//
//  NodeImageValueTransformer.swift
//  WakeOnLAN
//
//  Created by Gamunu Balagalla on 2023-10-29.
//

import Foundation
import AppKit

@objc(NodeImageValueTransformer)
class NodeImageValueTransformer: ValueTransformer {
    
    override class func transformedValueClass() -> AnyClass {
        return NSString.self
    }
    
    override class func allowsReverseTransformation() -> Bool {
        return true
    }
    
    override func transformedValue(_ value: Any?) -> Any? {
        guard let valueString = value as? String else { return nil }
        return getComputerIcon(forModelCode: valueString)
    }
    
    
    func getComputerIcon(forModelCode modelCode: String?) -> NSImage? {
        let workspace = NSWorkspace.shared
        var iconImage: NSImage?
        
        if let modelCode = modelCode, !modelCode.isEmpty {
            let fileType = modelCode
            iconImage = workspace.icon(forFileType: fileType)
        }
        
        if iconImage == nil || iconImage!.isValid == false {
            iconImage = getDefaultMacComputerIcon()
        }
        
        return iconImage
    }
    
    func getDefaultMacComputerIcon() -> NSImage? {
        let workspace = NSWorkspace.shared
        guard let fileType = NSFileTypeForHFSTypeCode(OSType(kComputerIcon)) else { return nil }
        return workspace.icon(forFileType: fileType)
    }
}
