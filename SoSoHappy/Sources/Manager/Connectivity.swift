//
//  Connectivity.swift
//  SoSoHappy
//
//  Created by Sue on 2023/12/19.
//

import Alamofire
import Foundation

class Connectivity {
    class func isConnectedToInternet() -> Bool {
        return NetworkReachabilityManager()!.isReachable
    }
}
