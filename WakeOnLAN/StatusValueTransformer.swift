//
//  StatusValueTransformer.swift
//  WakeOnLAN
//
//  Created by Gamunu Balagalla on 2023-10-29.
//

import Foundation
import AppKit

@objc(StatusValueTransformer)
class StatusValueTransformer: ValueTransformer {
    
    override class func transformedValueClass() -> AnyClass {
        return NSString.self
    }
    
    override class func allowsReverseTransformation() -> Bool {
        return true
    }
    
    override func transformedValue(_ value: Any?) -> Any? {
        let boolValue = (value as? Bool) ?? (value != nil)
        return boolValue ? NSImage(named: "green.png") : NSImage(named: "red.png")
    }
}
