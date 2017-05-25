//
//  ViewController.swift
//  Testing
//
//  Created by Merz on 10/7/16.
//  Copyright © 2016 Merz. All rights reserved.
//

import UIKit
import Foundation
import SystemConfiguration


class WebView: UIViewController, UIWebViewDelegate {
    @IBOutlet var webView: UIWebView!
    deinit {
        NotificationCenter.default.removeObserver(self, name: nil, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            delegate.orientationLock = UIInterfaceOrientationMask.all
        }
        webView.delegate = self
        let url = "http://sacs.school"
        let requestURL = URL(string:url)
        let requesting = URLRequest(url: requestURL!)
        webView.loadRequest(requesting)
        self.navigationController?.isNavigationBarHidden = true
        if (WebView.connectedToNetwork() == true){
        } else{
            let alert = UIAlertView(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
        }
        
    }
    
    class func connectedToNetwork() -> Bool {
        
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
    
    func willEnterForeground() {
        webView.reload()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        print("entered webView")
        switch navigationType {
        case .linkClicked:
            print("link")
            // Open links in Safari
            guard let url = request.url else { return true }
            if(url.absoluteString.range(of: "/native/") != nil )
            {
                print("got request")
                // parse custom URL to extract parameter
                if(url.absoluteString.range(of: "settings") != nil ){
                    self.performSegue(withIdentifier: "showTable", sender: self)
                }
                return false; // return false, so webView won't actually try to load this fake request
            }
            if ((url.absoluteString.range(of: "ec2-13-58-42-230.us-east-2.compute.amazonaws.com/") != nil) || (url.absoluteString.range(of: "icalfeed.ashx") != nil)) {
                return true
            } else {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    // openURL(_:) is deprecated in iOS 10+.
                    UIApplication.shared.openURL(url)
                }
            }
            return false
        default:
            print("default")
            guard let url = request.url else { return true }
            print(url)
                        // Handle other navigation types...
            return true
        }
    }
}
