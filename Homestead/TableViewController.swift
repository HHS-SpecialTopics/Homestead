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
        NotificationCenter.default.removeObserver(self, name: nil, object: nil)
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            delegate.orientationLock = UIInterfaceOrientationMask.all
        }
    }
    
    func reloadView() {
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
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "customcell")
        self.tableView.allowsSelection = false
        navigationItem.title = "Settings"
        self.navigationController?.isNavigationBarHidden = false
        navigationController?.navigationBar.backgroundColor = UIColor.white
        let accessChecker = EKEventStore()
        let customView = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 380))
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
            
            if(success == false){
                button.setTitle("No Calendar Access", for: .normal)
            } else {
            }
            
        }){
        }
        if (checkICS() == true) {
            button.removeFromSuperview()
        } else {
            textView.removeFromSuperview()
        }

        self.tableView.tableFooterView = customView
        //first launch rag; currently to enable all settings
        let launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
        if launchedBefore  {
            
        } else {
            for x in 0...(settings.count-1)
            {
                OneSignal.sendTag((settingsDictionary.allValues[x] as AnyObject) as! String, value: "true")
                settingsNS.set(true, forKey: (settingsDictionary.allValues[x] as AnyObject) as! String)
            }
            UserDefaults.standard.set(true, forKey: "launchedBefore")
        }
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
        return alreadySubcribed
    }
    
    @IBAction func subscribeToCalander(sender: AnyObject) {
        let eventStore = EKEventStore()
        var spin = true
        eventStore.requestAccess(to: EKEntityType.event) { (granted, error) -> Void in
            UIApplication.shared.openURL(URL(string: "webcal://www.sacs.k12.in.us/site/handlers/icalfeed.ashx?MIID=1")!)
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
    }
    
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "customcell", for: indexPath) as UITableViewCell
        cell.textLabel?.text = settings[indexPath.item]
        var switchDemo: UISwitch!
        switchDemo = UISwitch()
        switchDemo.isOn = settingsNS.bool(forKey: ((settingsDictionary.allValues[indexPath.item] as AnyObject) as! String))
        switchDemo.frame.origin.y = cell.frame.midY-cell.frame.height*CGFloat(indexPath.item)-switchDemo.frame.height/2
        switchDemo.frame.origin.x = UIScreen.main.bounds.width-70
        switchDemo.addTarget(self, action:#selector(buttonClicked), for: UIControlEvents.valueChanged)
        switches.append(switchDemo)
        cell.addSubview(switchDemo)
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    
    @IBAction func buttonClicked(sender: UISwitch){
        let switchIndex = switches.index(of: sender)!
        let setting = (settingsDictionary.allValues[switchIndex] as AnyObject) as! String
        if (switchIndex  == 0){//all notifications is changed; disable other switches and turn off their notifications
            for individualSetting in settings{
                if (switches[0].isOn == true){
                    switches[settings.index(of: individualSetting)!].isEnabled = true
                }
                else{
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
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            delegate.orientationLock = UIInterfaceOrientationMask.all
        }
    }
}
