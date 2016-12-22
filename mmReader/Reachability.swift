//
//  Reachability.swift
//  mmReader
//
//  Created by 박종호 on 2016. 12. 21..
//  Copyright © 2016년 박종호. All rights reserved.
//
// this class is from stack overflow. just copy & paste.
//

import SystemConfiguration

internal class Reachability {
    class func connectedToNetwork() -> Bool {
    
        // check divice's wifi and cellular status.
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
    
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return false
        }
    
        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
    
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
    
        return (isReachable && !needsConnection)
    }
}
