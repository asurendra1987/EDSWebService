//
//  WebServiceManager.swift
//  AnWebService
//
//  Created by Surendra, Annapureddy(AWF) on 5/25/18.
//  Copyright © 2018 Surendra, Annapureddy(AWF). All rights reserved.
//


protocol WebServiceDelegate {
    func API_CALLBACK_RESPONSE (responseData: [String: Any], apiName: String)
    func API_CALLBACK_ERROR (errorMessage: String, apiName: String)
}

import UIKit
import Alamofire
import AASquaresLoading
class WebServiceManager: NSObject ,WebServiceDelegate{
    
    // MARK: - DECLARATIONS
    static let sharedInstance = WebServiceManager()
    private var afManager : SessionManager!
    var handlerResponseData: ((_ responseData:[String : Any]) -> ())?
    private var currentViewController: UIViewController! //To pass super view to alert and activity indicator, this view controller variable has been declared

    // MARK: MAKE API WITH PARAMS
    func Make_API_CALL_WITH(apiName: String, parameters: [String: Any], method: HTTPMethod, isBackgroundCall: Bool, viewController: UIViewController, needSSLexeption: Bool, delegate: WebServiceDelegate) {
        
        var apiDetails = ApiDetails()
        apiDetails.apiName = apiName
        apiDetails.param = parameters
        apiDetails.method = method
        apiDetails.isBackgroundCall = isBackgroundCall
        apiDetails.viewController = viewController.parent
        apiDetails.needSslException = needSSLexeption
        apiDetails.delegate = delegate
        
        
        if isBackgroundCall { //API callback need to be performed in background. No need to show error alert or activitivity indicator while calling API in background.
            
            DispatchQueue.global(qos: .background).async { //Background call
                
                //UNCOMMENT THESE LINE TO TEST API IN SIMULATOR
                self.MAKE_API_CALL_WITH(apiName: apiName, parameters: parameters, method: method, isBackgroundCall: isBackgroundCall, viewController: viewController, needSSLexeption: needSSLexeption, delegate: delegate)
                DispatchQueue.main.async { () -> Void in //Main thread call for UI updations
                }
            }
        }
        else { //API call will be made in main, So we can show activity indicator and also network failure errors.
            
            //UNCOMMENT THESE LINE TO TEST API IN SIMULATOR
            self.MAKE_API_CALL_WITH(apiName: apiName, parameters: parameters, method: method, isBackgroundCall: isBackgroundCall, viewController: viewController, needSSLexeption: needSSLexeption, delegate: delegate)
        }
        
        
    }
    // MARK: MAKE API WITH PARAMS
    private func MAKE_API_CALL_WITH (apiName: String, parameters: [String: Any], method: HTTPMethod, isBackgroundCall: Bool, viewController: UIViewController, needSSLexeption: Bool, delegate: WebServiceDelegate) {
        
        //URL SESSION CONFIGURATIONS
        var url : String =  ""
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest =  60
        configuration.httpAdditionalHeaders = [
            "Content-type": "application/json",
        ]
        //SSL CONNECTION URL EXCEPTION HANDLING
        let trustPolicyManager = ServerTrustPolicyManager(policies: serverTrustPolicies)
        //ALAMOFIRE NETWORK MANGER CONFIGURATION
        if needSSLexeption { //If URL need SSL exception, then trust policy need to be included in network manger
            afManager = Alamofire.SessionManager(configuration: configuration, serverTrustPolicyManager: trustPolicyManager)
        }
        else { //If URL doesn't need any SSL exception, Directly we can make API calls.
            afManager = Alamofire.SessionManager(configuration: configuration)
        }
        
        if !isBackgroundCall { //If it's not a background call, then we can show loading indicator.
        }
        // Added access token and refresh token in Header
        var header : [String: String] = [:]
        header = ["Content-Type":"application/json"]
        
        url = BASE_URL.url + apiName
        
        //MAKING SERVER REQUEST FOR RESPONSE
        afManager.request(url, method: method, parameters: parameters, encoding: URLEncoding.default, headers: header).validate().responseJSON {
            response in
            
            if !isBackgroundCall { //It's not background call, so activity indicator displayed. Need to be hided on completion
                
            }
            
            //RESPONSE HANDLING
            switch (response.result) { //SUCCESS RESPONSE
            case .success(let JSON):
                
                if (JSON as AnyObject).count == 0 {
                    
                    if !isBackgroundCall { //In background API call, no need to display error message
                        
                        if let errorCode = response.response?.statusCode {
                            let errorMessage = NETWORK_ERROR_MESSAGE.errorMessage(with: errorCode)
                            print(errorMessage)
                        }
                        else {
                            let errorMessage = NETWORK_ERROR_MESSAGE.errorMessage(with: NETWORK_ERROR_CODE.serverDown)
                            print(errorMessage)
                            
                        }
                    }
                }
                else {
            
                    delegate.API_CALLBACK_RESPONSE(responseData: JSON as! [String : Any], apiName: apiName)
                }
                break
            case .failure(let error): //ERROR RESPONSE
                print(error)
                
                if !isBackgroundCall { //In background API call, no need to display error message
                    
                    if let errorCode = response.response?.statusCode {
                        let errorMessage = NETWORK_ERROR_MESSAGE.errorMessage(with: errorCode)
                        print(errorMessage)
                        
                    }
                    else {
                        let errorMessage = NETWORK_ERROR_MESSAGE.errorMessage(with: NETWORK_ERROR_CODE.serverDown)
                        print(errorMessage)
                        
                    }
                }
                break
            }
        }
    }
    // MARK: This function is used the post method
    func postRequestJSON(_ endPoint: String, parameters: [String: AnyObject]?,bodayParm: [AnyObject], isBackgroundCall: Bool,bodyParamKey : String, viewController: UIViewController,delegate: WebServiceDelegate) {
        
        let url = "" + endPoint + "?"
        currentViewController = viewController
        var header : [String: String] = [:]
        header = ["Content-Type":"application/json"]
        
        
        var apiDetails = ApiDetails()
        apiDetails.delegate = delegate
        if !isBackgroundCall { //If it's not a background call, then we can show loading indicator.
           
        }
        let bodyParmData =  [bodyParamKey:bodayParm] as [String : AnyObject]
        
        let strParameters = self.convertDictToStringParameters(parameters: parameters!)
        
        if let theJSONData = try? JSONSerialization.data(
            withJSONObject: bodyParmData,
            options: []) {
            let theJSONText = String(data: theJSONData,
                                     encoding: .utf8)
            //print("JSON string = \(theJSONText!)")
            
            afManager.request(url + strParameters, method: .post, parameters: bodyParmData, encoding:theJSONText!, headers: header).validate().responseJSON {
                //afManager.request(url, method: .post, parameters: parameters, encoding:theJSONText!, headers: header).validate().responseJSON {
                response in
                
                if !isBackgroundCall { //It's not background call, so activity indicator displayed. Need to be hided on completion
                }
                
                //RESPONSE HANDLING
                switch (response.result) { //SUCCESS RESPONSE
                case .success(let JSON):
                    
                    if (JSON as AnyObject).count == 0 {
                        
                        if !isBackgroundCall { //In background API call, no need to display error message
                            
                            if let errorCode = response.response?.statusCode {
                                let errorMessage = NETWORK_ERROR_MESSAGE.errorMessage(with: errorCode)
                                print(errorMessage)

                            }
                            else {
                                let errorMessage = NETWORK_ERROR_MESSAGE.errorMessage(with: NETWORK_ERROR_CODE.serverDown)
                                print(errorMessage)

                            }
                        }
                    }
                    else {
                        delegate.API_CALLBACK_RESPONSE(responseData: JSON as! [String : Any], apiName: endPoint)
                    }
                    break
                case .failure(let error): //ERROR RESPONSE
                    print(error)
                    
                    if !isBackgroundCall { //In background API call, no need to display error message
                        
                        if let errorCode = response.response?.statusCode {
                            let errorMessage = NETWORK_ERROR_MESSAGE.errorMessage(with: errorCode)
                            print(errorMessage)

                        }
                        else {
                            let errorMessage = NETWORK_ERROR_MESSAGE.errorMessage(with: NETWORK_ERROR_CODE.serverDown)
                            print(errorMessage)

                        }
                    }
                    break
                }
                
            }
        }
        
    }
    // MARk:- Post Request methods
    func postRequestJSONWithLoadLocalQA(_ endPoint: String, parameters: [String: AnyObject]?,bodayParm: [AnyObject], isBackgroundCall: Bool, viewController: UIViewController,delegate: WebServiceDelegate) {
        let url = "" + endPoint + "?"
        currentViewController = viewController
        var header : [String: String] = [:]
        header = ["Content-Type":"application/json"]
        
        var apiDetails = ApiDetails()
        apiDetails.delegate = delegate
        if !isBackgroundCall { //If it's not a background call, then we can show loading indicator.
        
        }
        
        let jsonObject = self.convertJsonObjectWith(withDict: bodayParm)
        let strParameters = self.convertDictToStringParameters(parameters: parameters!)
        afManager.request(url + strParameters , method: .post, parameters: parameters, encoding:jsonObject, headers: header).validate().responseJSON {
            response in
            
            if !isBackgroundCall { //It's not background call, so activity indicator displayed. Need to be hided on completion
            }
            
            
            //RESPONSE HANDLING
            switch (response.result) { //SUCCESS RESPONSE
            case .success(let JSON):
                
                if (JSON as AnyObject).count == 0 {
                    
                    if !isBackgroundCall { //In background API call, no need to display error message
                        
                        if let errorCode = response.response?.statusCode {
                            let errorMessage = NETWORK_ERROR_MESSAGE.errorMessage(with: errorCode)
                            print(errorMessage)

                        }
                        else {
                            let errorMessage = NETWORK_ERROR_MESSAGE.errorMessage(with: NETWORK_ERROR_CODE.serverDown)
                            print(errorMessage)

                        }
                    }
                }
                else {
                    
                    delegate.API_CALLBACK_RESPONSE(responseData: JSON as! [String : Any], apiName: endPoint)
                }
                break
            case .failure(let error): //ERROR RESPONSE
                print(error)
                
                if !isBackgroundCall { //In background API call, no need to display error message
                    
                    if let errorCode = response.response?.statusCode {
                        let errorMessage = NETWORK_ERROR_MESSAGE.errorMessage(with: errorCode)
                        print(errorMessage)
                    }
                    else {
                        let errorMessage = NETWORK_ERROR_MESSAGE.errorMessage(with: NETWORK_ERROR_CODE.serverDown)
                        print(errorMessage)

                    }
                }
                break
            }
            
        }
    }
    //This function to call and other Module api With parms.
    func EDSRequestDataAPIWith(withFromData fromDate: String, toDate: String, entity: String, region: String, categoryValue:String, pageCount: Int, countryName: String, inViewController: UIViewController,responseData:@escaping (_ responseData: [String: Any]?)->()) {
        
        self.handlerResponseData = responseData
        
        let param = ["" : ""] // here we can params
        
        self.requestHandlerAPIWith(withAPIName:"", param: param as [String : AnyObject], aViewController: inViewController,method: HTTPS_METHODS.get)
    }
    
    // Mark: Simple Api call for get
    func EDSRequestGraphsDetailsDataAPIWith(withdayAfterInterval dayAfterInterval: String, dayBeforeInterval: String, entity: String, region: String,storyDate:String, inViewController: UIViewController,categoryName: String, ApiEndPoint:String,responseData:@escaping (_ responseData: [String: Any]?)->()) {
        
        self.handlerResponseData = responseData
        let parm = ["" : ""]
        self.requestHandlerAPIWith(withAPIName:ApiEndPoint, param: parm as [String : AnyObject], aViewController: inViewController,method: HTTPS_METHODS.get)
    }
    // MArk:- Simple call API / Web servise.
    private func requestHandlerAPIWith(withAPIName apiName:String, param: [String: AnyObject], aViewController: UIViewController, method: String) {
        
        if method == HTTPS_METHODS.get {
            self.Make_API_CALL_WITH(apiName: apiName, parameters: param, method: .get, isBackgroundCall: false, viewController: aViewController, needSSLexeption: true, delegate: self)
        }else if method == HTTPS_METHODS.post {
            self.Make_API_CALL_WITH(apiName: apiName, parameters: param, method: .post, isBackgroundCall: false, viewController: aViewController, needSSLexeption: true, delegate: self)
        }
        
    }
    // MARK: Delegates methods for WebService
    func API_CALLBACK_RESPONSE(responseData: [String : Any], apiName: String) {
        
    }
    
    func API_CALLBACK_ERROR(errorMessage: String, apiName: String) {
        
    }
    // Mark: This function make a key as url + parms
    func convertDictToStringParameters(parameters:[String: AnyObject])->String
    {
        // This Function make a dict to single string
        let dictToString = (parameters.compactMap({ (key, value) -> String in
            return "\(key)=\(value)"
        }) as Array).joined(separator: "&")
        print(dictToString)
        return dictToString
        
    }
    
    // This function convert to dict to json String
    func convertJsonObjectWith(withDict dictValue:[AnyObject])-> String {
        let jsonString =  self.stringify(json: dictValue)
        return jsonString
        
    }
    // This function convert to dict to json String
    func stringify(json: Any, prettyPrinted: Bool = false) -> String {
        var options: JSONSerialization.WritingOptions = []
        if prettyPrinted {
            options = JSONSerialization.WritingOptions.prettyPrinted
        }
        
        do {
            let data = try JSONSerialization.data(withJSONObject: json, options: options)
            if let string = String(data: data, encoding: String.Encoding.utf8) {
                return string
            }
        } catch {
            print(error)
        }
        
        return ""
    }
}
extension String: ParameterEncoding {
    public func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        var request = try urlRequest.asURLRequest()
        request.httpBody = data(using: .utf8, allowLossyConversion: false)
        return request
    }
    
}
