//
//  TableViewController.swift
//  Testing
//
//  Created by Merz on 10/7/16.
//  Copyright © 2016 Merz. All rights reserved.
//



import Foundation
import UIKit
import OneSignal
import EventKitUI

class TableViewController: UITableViewController {
    //@IBOutlet var tableView: UITableView!
    //let myarray = ["item1", "item2", "item3"]
    let images = ["homesteadhigh"]
    var pageToOpen = 0
    var settings: Array<String> = Array()
    var settingsNS = UserDefaults.standard
    let settingsDictionary: NSDictionary = [
        "All Notifications" : "all_notifications",
        "Delays/Cancellations" : "status_notifications",
        "News Articles" : "news_notifications"
    ]
    
    deinit {
        //make sure to remove the observer when this view controller is dismissed/deallocated
        NotificationCenter.default.removeObserver(self, name: nil, object: nil)
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            delegate.orientationLock = UIInterfaceOrientationMask.all
        }
    }
    
    func reloadView() {
        print("reloading")
        //self.view.setNeedsDisplay()//seems to reload only if there is a change. This seems good
        self.viewDidLoad()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(reloadView), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            delegate.orientationLock = UIInterfaceOrientationMask.portrait
        }
        self.tableView.isScrollEnabled = false
        settings.append("All Notifications")
        settings.append("Delays/Cancellations")
        settings.append("News Articles")
        //settings.append("Other")
        // Do any additional setup after loading the view, typically from a nib.
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "customcell")
        self.tableView.allowsSelection = false
        navigationItem.title = "Settings"
        self.navigationController?.isNavigationBarHidden = false
        //navigationController?.navigationBar.barTintColor = UIColor.black
        navigationController?.navigationBar.backgroundColor = UIColor.white
        let accessChecker = EKEventStore()
        /*if accessChecker.requestAccess(to: EKEntityType.event){
            completion()
        } else {
            
        }*/
        //var errorHolder = NSError()
        //var grantHolder = NSNull()
        //var errorHolder = NSNull()

        /*let footerView = UIView(frame: CGRect())
        let subscribeButton = UIButton()
        subscribeButton.backgroundRect(forBounds: CGRect(x: 0, y: 0, width: 1000, height: 1000))
        //subscribeButton.addTarget(self, action: "subscribeToCalander", for: .touchUpInside)
        footerView.addSubview(subscribeButton)
        footerView.backgroundColor = UIColor(colorLiteralRed: 100, green: 100, blue: 1, alpha: 100)*/
        let customView = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 380))
        //let bottomOfTable = UIView(frame: CGRect(x:0, y:0, width: self.view.frame.width, height: 1))
        //bottomOfTable.backgroundColor = UIColor.lightGray
        //customView.addSubview(bottomOfTable)
        //customView.backgroundColor = UIColor.blue
        
        /* This section is a calendar subscription button. It however suffered death by prompts. Due to privacy it is nigh on impossible to check if the user is actually subscribed and adjust behavior accordingly
         */
        let button = UIButton(frame: CGRect(x: self.view.frame.width/4, y: 60, width: self.view.frame.width/2, height: 50))
        button.layer.cornerRadius = 10
        button.backgroundColor = UIColor.init(white: 0.85, alpha: 0.5)
        button.setTitleColor(UIColor.init(white: 0.15, alpha: 1), for: UIControlState.normal)
        button.setTitle("Subscribe", for: .normal)
        button.addTarget(self, action: #selector(subscribeToCalander), for: .touchUpInside)
        let calTitle = UITextView(frame: CGRect(x: 0.0, y: 0, width: self.view.frame.width, height: 50))
        calTitle.text = "Calendar"
        calTitle.font = .systemFont(ofSize: 36)
        calTitle.textAlignment = .center
        calTitle.isScrollEnabled = false
        calTitle.isEditable = false
        customView.addSubview(calTitle)
        
        customView.addSubview(button)
        let textView = UITextView(frame: CGRect(x: 0.0, y: 60, width: self.view.frame.width, height: 170))
        textView.text = "Instructions to remove the calendar:\n   1) Go to the settings app\n   2) Select \"Calendar\"\n   3) Select \"Accounts\"\n   4) Select \"Subscribed Caladendars\"\n   (the subtitle should include sacs)\n   5) Scroll down and select \"Delete\""
        textView.font = .systemFont(ofSize: 18)
        textView.isEditable = false
        customView.addSubview(textView)
        
        //check access to calendar
        if let result = try? accessChecker.requestAccess(to: EKEntityType.event, completion: {
            (success: Bool, error: Error?) in
            
            print("Got permission = \(success); error = \(error)")
            if(success == false){
                button.setTitle("No Calendar Access", for: .normal)
            } else {
                print("YES access")
            }
            
        }){
            print("unecessary success?; or I always print?")
        }
        if (checkICS() == true) {
            button.removeFromSuperview()
        } else {
            textView.removeFromSuperview()
        }

        self.tableView.tableFooterView = customView
        //first launch code; currently to enable all settings
        let launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
        if launchedBefore  {
            
        } else {
            for x in 0...(settings.count-1)
            {
                print(x)
                /*OneSignal.sendTag(settings[x], value: "true")
                settingsNS.set(true, forKey: settings[x])*/
                print((settingsDictionary.allValues[x] as AnyObject))
                OneSignal.sendTag((settingsDictionary.allValues[x] as AnyObject) as! String, value: "true")
                settingsNS.set(true, forKey: (settingsDictionary.allValues[x] as AnyObject) as! String)
            }
            print("First launch, enabling notifications.")
            UserDefaults.standard.set(true, forKey: "launchedBefore")
        }
        //UIApplication.shared.openURL(NSURL(string: "webcal://www.sacs.k12.in.us/site/handlers/icalfeed.ashx?MIID=1")! as URL)
    }
    

    
    func checkICS() -> Bool { //returns true if existing
        let eventStrore = EKEventStore()
        var alreadySubcribed = false
        var spin = true
        eventStrore.requestAccess(to: EKEntityType.event) { (granted, error) -> Void in
            
            let allCalendars = eventStrore.calendars(for: EKEntityType.event)
            for currentCal : EKCalendar in allCalendars {
                if (currentCal.type == EKCalendarType.subscription && currentCal.title == "www.sacs.k12.in.us/site/handlers/icalfeed.ashx?MIID=1") {
                    alreadySubcribed = true
                }
            }
            spin = false
        }
        while (spin == true) {
            sleep(1)
        }
        print("alreadysubscribed: \(alreadySubcribed)")
        return alreadySubcribed
    }
    
    @IBAction func subscribeToCalander(sender: AnyObject) {
        //var err = NSError()
        //UIApplication.shared.openURL(URL(string: "webcal://www.sacs.k12.in.us/site/handlers/icalfeed.ashx?MIID=1")!)
        let eventStore = EKEventStore()
        /*if let result = try? eventStore.requestAccess(to: EKEntityType.event) {
            print(result)
            // doSomething succeeded, and result is unwrapped.
        } else {
            // Ouch, doSomething() threw an error.
        }*/
        var spin = true
        eventStore.requestAccess(to: EKEntityType.event) { (granted, error) -> Void in
            let calendarList = eventStore.calendars(for: EKEntityType.event)
            var sacsIndex = 0
            for x in 0..<calendarList.count {
                print(calendarList[x].title)
                if (calendarList[x].title == "www.sacs.k12.in.us/site/handlers/icalfeed.ashx?MIID=1") {
                    sacsIndex = x
                }
            }
            //if (self.checkICS() == false){
                UIApplication.shared.openURL(URL(string: "webcal://www.sacs.k12.in.us/site/handlers/icalfeed.ashx?MIID=1")!)//webcal://www.sacs.k12.in.us/site/handlers/icalfeed.ashx?MIID=1
            //} else {
                /*if let result = try? eventStore.removeCalendar(calendarList[sacsIndex], commit: true) {
                    //eventStore.reset()
                    print(result)
                    print("removal success")
                } else {
                    print("removal faliure")
                }*/
                //calendarList[0]
            //}
            spin = false
        }
        while (spin == true) {
            sleep(1)
        }
        self.tableView.tableFooterView?.subviews[1].removeFromSuperview()
        let textView = UITextView(frame: CGRect(x: 0.0, y: 60, width: self.view.frame.width, height: 170))
        textView.text = "Instructions to remove the calendar:\n   1) Go to the settings app\n   2) Select \"Calendar\"\n   3) Select \"Accounts\"\n   4) Select \"Subscribed Calendars\"\n   (the subtitle should include sacs)\n   5) Scroll down and select \"Delete\""
        textView.font = .systemFont(ofSize: 18)
        textView.isEditable = false
        self.tableView.tableFooterView?.addSubview(textView)
        /*try {
            eventStore.removeCalendar(EKCalendar(, commit: true)
        }*/
    }

    /*override var prefersStatusBarHidden: Bool {
        return true
    }*/
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
        navigationItem.title = "Notifications"
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView:UITableView, numberOfRowsInSection section: Int) -> Int {
        return settings.count;
    }
    
    var switches: Array<UISwitch> = Array()
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //pageToOpen = pageToOpen + 1
        //print("times \(pageToOpen)")
        let cell = tableView.dequeueReusableCell(withIdentifier: "customcell", for: indexPath) as UITableViewCell
        cell.textLabel?.text = settings[indexPath.item]
        var switchDemo: UISwitch!
        switchDemo = UISwitch()
        switchDemo.isOn = settingsNS.bool(forKey: ((settingsDictionary.allValues[indexPath.item] as AnyObject) as! String))
        //finds mid y cordinant of cell; subtracts cell height*number of cells to make sure it is in the right cell, every cell it adds an extra cell's worth of height to .midY; subtracts 1/2 switch height to center switch
        switchDemo.frame.origin.y = cell.frame.midY-cell.frame.height*CGFloat(indexPath.item)-switchDemo.frame.height/2
        switchDemo.frame.origin.x = UIScreen.main.bounds.width-70
        switchDemo.addTarget(self, action:#selector(buttonClicked), for: UIControlEvents.valueChanged)
        switches.append(switchDemo)
        cell.addSubview(switchDemo)
        return cell
        /*if indexPath.item<images.count {
         let image : UIImage = UIImage(named: images[indexPath.item])!
         cell.imageView?.image = image
         }*/
         /*let cell = UITableViewCell()
         let label = UILabel(frame: CGRect(x:0, y:0, width:200, height:50))
         label.text = "test"
         cell.addSubview(label)
         return cell*/
        //let cell = tableView.dequeueReusableCellWithIdentifier("customcell", forIndexPath: indexPath)
        /*let cell = tableView.dequeueReusableCellWithIdentifier("customcell", forIndexPath: indexPath) as UITableViewCell
        let label = UILabel(frame: CGRect(x:0, y:0, width:200, height:50))
        label.text = "test"
        cell.addSubview(label)
        return cell*/
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //let rowIndexPath = tableView.indexPathForSelectedRow!
        /*let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let userVC = mainStoryboard.instantiateViewControllerWithIdentifier("WebViewControlID") //as! UserViewController
        presentViewController(userVC, animated: true, completion: nil) // this seems to not call prepareForSegue, is it something different?
        */

        
        
        /*var nameString:String
        var segueString:String
        nameString = self.myarray[rowIndexPath.row].lowercased()
        segueString = nameString + "View"
        print(segueString)
        //self.performSegueWithIdentifier(segueString, sender: self)
        let pages=[51,54,56]
        pageToOpen = pages[rowIndexPath.row]
        self.performSegue(withIdentifier: "toWebView", sender: self)*/
    }
    
    @IBAction func buttonClicked(sender: UISwitch){
        //let switchIndex = 0
        let switchIndex = switches.index(of: sender)!
        //let setting = settings[switchIndex]
        let setting = (settingsDictionary.allValues[switchIndex] as AnyObject) as! String
        if (switchIndex  == 0){//all notifications is changed; disable other switches and turn off their notifications
            for individualSetting in settings{
                if (switches[0].isOn == true){
                    //OneSignal.sendTag(individualSetting, value: "true")
                    //settingsNS.set(true, forKey: individualSetting)
                    switches[settings.index(of: individualSetting)!].isEnabled = true
                }
                else{
                    //OneSignal.sendTag(individualSetting, value: "false")
                    //settingsNS.set(false, forKey: individualSetting)
                    switches[settings.index(of: individualSetting)!].isEnabled = false
                }
            }
            switches[0].isEnabled = true
        }
        if (switches[switchIndex].isOn == true){
            OneSignal.sendTag(setting, value: "true")
            settingsNS.set(true, forKey: setting)
        }
        else{
            OneSignal.sendTag(setting, value: "false")
            settingsNS.set(false, forKey: setting)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        //segue may not be as broad as I first imagined, consider creating one from this to webview so this method is called
        
        
        //doesn't currently enter this; perhaps it isn't using segue to transition?
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            delegate.orientationLock = UIInterfaceOrientationMask.all
        }
        let destinationViewController = segue.destination as! WebView
        //destinationViewController.test = pageToOpen //note test does not exist anymore, this was a test
    }
}
