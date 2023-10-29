//
//  ResolvedService.swift
//  WakeOnLAN
//
//  Created by Gamunu Balagalla on 2023-10-30.
//

import Foundation
import AppKit

@objc(ResolvedService)
@objcMembers
class ResolvedService: NSObject {
    var host: String
    var domain: String
    var ipAddr: String
    var macAddr: String
    var owner: String
    var icon: String
    var name: String
    var type: String
    var status: Bool
    
    @objc(initWithNSNetService:)
    init(service: NetService) {
        self.host = service.name
        self.domain = service.domain
        self.type = service.type
        self.status = true
        self.owner = ""
        self.icon = ""
        self.name = ""
        self.ipAddr = ""
        self.macAddr = ""
        
        super.init()
        
        guard let addressData = service.addresses?.first else {
            print("Service addresses entries empty.")
            return
        }
        
        var address = sockaddr_in()
        (addressData as NSData).getBytes(&address, length: MemoryLayout<sockaddr_in>.size)
        guard let ipString = String(cString: inet_ntoa(address.sin_addr), encoding: .utf8) else {
            return
        }
        self.ipAddr = ipString
        
        let port = Int(address.sin_port)
        print("Port: \(port)")  // If you need to use port
        
        self.resolveIP(ipString)
    }
    
    func resolveIP(_ ipString: String) {
        ipString.withCString { cString in
            var mutableCString = UnsafeMutablePointer(mutating: cString)
            let pingError = pingIP(mutableCString)
            if pingError != 0 {
                print("pingIP() failed, error code \(pingError)")
            }

            Thread.sleep(forTimeInterval: 0.2)

            var macAddrStr = [CChar](repeating: 0, count: 64)
            let macError = macForIP(mutableCString, &macAddrStr)
            if macError != 0 {
                print("macForIP() failed, error code \(macError)")
            }

            guard let macTempStr = String(cString: macAddrStr, encoding: .utf8) else {
                return
            }
            self.macAddr = macTempStr
        }
    }

}
