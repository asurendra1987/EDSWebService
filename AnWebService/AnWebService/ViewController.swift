//
//  ViewController.swift
//  AnWebService
//
//  Created by Surendra, Annapureddy(AWF) on 5/25/18.
//  Copyright © 2018 Surendra, Annapureddy(AWF). All rights reserved.
//

import UIKit
import Alamofire
class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        sampleGetApiCall()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK : S
    func sampleGetApiCall()
    {
        let urlStr = "https://rss.itunes.apple.com/api/v1/us/apple-music/hot-tracks/all/10/explicit.json"
        Alamofire.request(urlStr, method: .get, encoding: JSONEncoding.default)
            .responseJSON { response in
                print(response.result.value as Any)
        }
    }

}



