//
//  Helper.swift
//  AnWebService
//
//  Created by Surendra, Annapureddy(AWF) on 5/25/18.
//  Copyright © 2018 Surendra, Annapureddy(AWF). All rights reserved.
//

import Foundation
import Alamofire

// MARK: - NETWORK FAILURE ERROR CODES

struct NETWORK_ERROR_CODE {
    static let dataFailedToSave = 1
    static let invalidJSON = 4
    static let serverDown = 500
    static let connectionTimedOut = -1001
    static let vpnNotConnected = -1003
    static let lostConnection = -1005
    static let noInternetConnection = -1009
    static let canNotParseServerResponse = -1017
    static let invalidServerResponse = -1011
    static let invalidToken = 0
    static let cannotGainAccess = 401
    static let expiredToken = -10
    static let authIssue1 = -4
    static let authIssue2 = -5
}

// MARK: - NETWORK ERROR MESSAGE BASED ON ERROR CODE
struct NETWORK_ERROR_MESSAGE {
    
    static func errorMessage(with code: Int) -> String {
        switch code {
        case NETWORK_ERROR_CODE.dataFailedToSave:
            return "The data has failed to save, please make sure there is enough space on the device"
        case NETWORK_ERROR_CODE.invalidJSON:
            return "The data failed to download, please check your connection and try again. Error code: \(code)"
        case NETWORK_ERROR_CODE.serverDown:
            return "Either network or server seems to be down.Please check your connectivity and try again."
            
        case NETWORK_ERROR_CODE.vpnNotConnected:
            return "The app can not connect to the server, please make sure you are connected to the VPN"
        case NETWORK_ERROR_CODE.noInternetConnection:
            return "The app can only download new data when connected to the internet, please connect and try again"
        case NETWORK_ERROR_CODE.connectionTimedOut:
            return "The internet connection has timed out, please try again when you have a better connection"
        case NETWORK_ERROR_CODE.canNotParseServerResponse:
            return "The server response seems to be invalid"
        case NETWORK_ERROR_CODE.invalidServerResponse:
            return "The server response seems to be invalid"
        case NETWORK_ERROR_CODE.invalidToken:
            return "Your token is invalid or expired please press refresh to login again."
        case NETWORK_ERROR_CODE.cannotGainAccess:
            return "Can not gain access to the network to get daily data, make sure you are connected to the VPN."
        case NETWORK_ERROR_CODE.expiredToken:
            return "Your SSO token has expired, please re-authenticate to access the application."
        case NETWORK_ERROR_CODE.authIssue1, NETWORK_ERROR_CODE.authIssue2:
            return "There seems to be and issue with SSO, please re-authenticate to access the application."
        default:
            return "An unknown error has occured"
        }
    }
}
// MARK: Declare the APi Details
struct ApiDetails {
    var apiName: String = ""
    var param: [String: Any] = [:]
    var method: HTTPMethod!
    var isBackgroundCall: Bool = false
    var viewController: UIViewController?
    var needSslException: Bool = false
    var delegate: WebServiceDelegate!
}
// MARK: API NAMES
struct BASE_URL {
    
    static let url = ""
    
}
// MARK: - SERVER TRUST POLICIES TO ADD EXCEPTION FOR SSL URL

let serverTrustPolicies: [String: ServerTrustPolicy] = [
    "":.disableEvaluation,
    "": .disableEvaluation,
    "10.74.12.71": .disableEvaluation,
    "": .disableEvaluation,
    "": .disableEvaluation,
    "": .disableEvaluation,
    "": .disableEvaluation,
    "" : .disableEvaluation,
    "" : .disableEvaluation,
    "": .disableEvaluation,
    "": .disableEvaluation,
    "": .disableEvaluation,
    "": .disableEvaluation,
    "": .disableEvaluation
]
// MARK: - HTTP METHODS
struct HTTPS_METHODS {
    static let get = "get"
    static let post = "post"
}

