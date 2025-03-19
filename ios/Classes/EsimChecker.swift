//
//  EsimChecker.swift
//  flutter_esim
//
//  Created by Hien Nguyen on 29/02/2024.
//

import Foundation
import CoreTelephony

@available(iOS 10.0, *)
class EsimChecker: NSObject {
    
    
    
    let internalSupportedModels = [
        
        //iPhone 16
        "iPhone17,1",
        "iPhone17,2",
        "iPhone17,3",
        "iPhone17,4",
        
        //iPhone 15
        "iPhone15,4", //15
        "iPhone15,5", //15Plus
        "iPhone16,1", //15Pro
        "iPhone16,2", //15ProMax
        
        //iPhone 14
        "iPhone14,7", //14
        "iPhone14,8", //14Plus
        "iPhone15,2", //14Pro
        "iPhone15,3", //14ProMax
        
        //iPhone 13
        "iPhone14,5", //13
        "iPhone14,4", //13Mini
        "iPhone14,2", //13Pro
        "iPhone14,3", //13ProMax
        
        //iPhone 12
        "iPhone13,2", //12
        "iPhone13,1", //12Mini
        "iPhone13,3", //12Pro
        "iPhone13,4", //12ProMax
        
        //iPhone 11
        "iPhone12,1", //11
        "iPhone12,3", //11Pro
        "iPhone12,5", //11ProMax
        
        //iPhone X
        "iPhone11,2", //XS
        "iPhone11,4", //XSMAX
        "iPhone11,6", //XSMAX
        "iPhone11,8", //XR
        
        //iPhone SE
        "iPhone12,8", //SE2 2020
        "iPhone14,6", //SE3 2022
        
        //iPad
        "iPad6,8", //iPad Pro 1st Gen (12.9 inch, WiFi+Cellular)
        "iPad6,12", //iPad 5th Gen (WiFi+Cellular)
        "iPad7,2", //iPad Pro 2nd Gen (12.9 inch, WiFi+Cellular)
        "iPad7,4", //iPad Pro 2nd Gen (10.5 inch, WiFi+Cellular)
        "iPad7,6", //iPad 6th Gen (WiFi+Cellular)
        "iPad7,12", //iPad 7th Gen (WiFi+Cellular)
        "iPad8,3", //iPad Pro 3rd Gen (11 inch, WiFi+Cellular)
        "iPad8,4", //iPad Pro 3rd Gen (11 inch, WiFi+Cellular, 1TB)
        "iPad8,7", //iPad Pro 3rd Gen (12.9 inch, WiFi+Cellular)
        "iPad8,8", //iPad Pro 3rd Gen (12.9 inch, WiFi+Cellular, 1TB)
        "iPad8,10", //iPad Pro 4th Gen (11 inch, WiFi+Cellular)
        "iPad8,12", //iPad Pro 4th Gen (12.9 inch, WiFi+Cellular)
        "iPad11,2", //iPad mini 5th Gen (WiFi+Cellular)
        "iPad11,4", //iPad Air 3rd Gen (WiFi+Cellular)
        "iPad11,7", //iPad 8th Gen (WiFi+Cellular)
        "iPad12,2", //iPad 9th Gen (WiFi+Cellular)
        "iPad13,2", //iPad Air 4th Gen (WiFi+Cellular)
        "iPad13,6", //iPad Pro 3rd Gen (11 inch, WiFi+Cellular)
        "iPad13,7", //iPad Pro 3rd Gen (11 inch, WiFi+Cellular)
        "iPad13,10", //iPad Pro 5th Gen (12.9 inch, WiFi+Cellular)
        "iPad13,11", //iPad Pro 5th Gen (12.9 inch, WiFi+Cellular)
        "iPad13,17", //iPad Air 5th Gen (WiFi+Cellular)
        "iPad13,19", //iPad 10th Gen
        "iPad14,2", //iPad mini 6th Gen (WiFi+Cellular)
        "iPad14,4", //iPad Pro 4th Gen (11 inch)
        "iPad14,6", //iPad Pro 6th Gen (12.9 inch)
        
    ]
    
    public var handler: EventCallbackHandler?;
    
    
    public var identifier: String = {
        var systemInfo = utsname()
        uname(&systemInfo)
        let mirror = Mirror(reflecting: systemInfo.machine)
        
        let identifier = mirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
    }()
    
    
    func isSupportESim(supportedModels: [String]) -> Bool {
        let newSupportedModels = internalSupportedModels + supportedModels;
        for model in newSupportedModels {
            if identifier.contains(model) {
                return true
            }
        }
        return false
    }
    
    func installEsimProfile(address: String, matchingID: String?, oid: String?, confirmationCode: String?, iccid: String?, eid: String?) {
        let ctpr = CTCellularPlanProvisioningRequest();
        ctpr.address = address;
        if((matchingID) != nil) {
            ctpr.matchingID = matchingID;
        }
        if((oid) != nil) {
            ctpr.oid = oid
        }
        if((confirmationCode) != nil) {
            ctpr.confirmationCode = confirmationCode
        }
        if((iccid) != nil) {
            ctpr.iccid = iccid
        }
        if((eid) != nil) {
            ctpr.eid = eid
        }
        
        if #available(iOS 12.0, *) {
            let ctcp =  CTCellularPlanProvisioning()
            if(!ctcp.supportsCellularPlan()){
                handler?.send("unsupport", [:])
                return;
            }
            ctcp.addPlan(with: ctpr) { (result) in
                switch result {
                case .unknown:
                    self.handler?.send("unknown", [:])
                case .fail:
                    self.handler?.send("fail", [:])
                case .success:
                    self.handler?.send("success", [:])
                case .cancel:
                    self.handler?.send("cancel", [:])
                @unknown default:
                    self.handler?.send("unknown", [:])
                }
            }
        }
    }
    
    
}
