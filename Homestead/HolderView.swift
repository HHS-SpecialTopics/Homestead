//
//  ViewController.swift
//  Testing
//
//  Created by Merz on 10/7/16.
//  Copyright © 2016 Merz. All rights reserved.
//

import SystemConfiguration
import UIKit

//not finshied not refered to

class HolderView: UIViewController {
    @IBOutlet var webView: UIWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground2), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        
        //watch for taps
        
        
        /*//print("Reached loading of splash screen")
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        // Get the Document directory path
        let documentDirectorPath:String = paths[0]
        // Create a new path for the new images folder
        let imagesDirectoryPath = documentDirectorPath + "/SplashScreen"
        var objcBool:ObjCBool = true
        let isExist = FileManager.default.fileExists(atPath: imagesDirectoryPath, isDirectory: &objcBool)
        // If the folder with the given path doesn't exist already, create it
        if isExist == false{
            do{
                try FileManager.default.createDirectory(atPath: imagesDirectoryPath, withIntermediateDirectories: true, attributes: nil)
            }catch{
                print("this folder already exists - or something went wrong")
            }
        }
         
         addBackgroundImage()
         //addLogo()
         
         // Show the home screen after a bit. Calls the show() function.
         //self.show()
         */


        /*if (HolderView.connectedToNetwork() == true){
            Timer.scheduledTimer(
                timeInterval: 2.5, target: self, selector: #selector(self.showNext), userInfo: nil, repeats: false
            )
        } else{
            let alert = UIAlertView(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", delegate: nil, cancelButtonTitle: "OK")
            alert.show()

        }*/
    }
    func willEnterForeground2() {
        //send to web view
        
    }
    func touchesEnded(touches: NSSet!, withEvent event: UIEvent!) {
        print("test")
    }
    /*
     * Gets rid of the status bar
     *
     override func prefersStatusBarHidden(); -&gt; Bool {
     return true
     }*/
    
    /*
     * Shows the app's main home screen.
     * Gets called by the timer in viewDidLoad()
     */
    func showNext() {
        self.performSegue(withIdentifier: "showApp", sender: self)
    }
    
    /*
     * Adds background image to the splash screen
     */
    func addBackgroundImage() {
        let screenSize: CGRect = UIScreen.main.bounds
        var bg = UIImage()
        let url = URL(string: "https://sacs-backend-chrisblutz.c9users.io/wp-content/uploads/2016/12/SplashScreen.png")
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        // Get the Document directory path
        let documentDirectorPath:String = paths[0]
        // Set the path for the images
        let localImagesDirectoryPath = documentDirectorPath + "/SplashScreen/default.png"
        if (HolderView.connectedToNetwork() == true){ //note that this only ensures there is a file, it doesn't validate the pictureness of it
            if ( try? Data(contentsOf: url!)) != nil{
                let data = try? Data(contentsOf: url!)
                if UIImage(data: data!) != nil{
                    bg = UIImage(data: data!)!
                } else{
                    
                }
                FileManager.default.createFile(atPath: localImagesDirectoryPath, contents: data, attributes: nil)
                
            } else{
                print("failed to contact website")
                if(try! UIImage(contentsOfFile: localImagesDirectoryPath) != nil){
                    bg = UIImage(contentsOfFile: localImagesDirectoryPath)!
                } else{
                    //bg = UIImage(named: "homesteadhigh.png")!;
                }
            }
        } else{
            print("failed to contact website")
            if(try! UIImage(contentsOfFile: localImagesDirectoryPath) != nil){
                bg = UIImage(contentsOfFile: localImagesDirectoryPath)!
            } else{
                bg = UIImage(named: "homesteadhigh.png")!;
            }
        }
        //print(localImagesDirectoryPath)
        let bgView = UIImageView(image: bg)
        //bgView.frame = CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height)
        //bgView.addConstraint(<#T##constraint: NSLayoutConstraint##NSLayoutConstraint#>)
        self.view.addSubview(bgView)
    }
    
    /*
     * Adds logo to splash screen
     */
    func addLogo() {
        let screenSize: CGRect = UIScreen.main.bounds
        let url = URL(fileURLWithPath: "http://www.sacs.k12.in.us//cms/lib07/IN01907860/Centricity/Domain/4/jg.jpg")//can't take jpgs?
        let data = try? Data(contentsOf: url) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
        let logo = UIImage(data: data!)
        
        //let logo     = UIImage(named: "homesteadhigh.png")
        let logoView = UIImageView(image: logo)
        
        let w = logo?.size.width
        let h = logo?.size.height
        
        logoView.frame = CGRect( x: (screenSize.width/2) - (w!/2), y: 5, width: w!, height: h! )
        self.view.addSubview(logoView)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    override var prefersStatusBarHidden: Bool {
        return true
    }
}


