//
//  ViewController.swift
//  BeaconSpot
//
//  Created by Abdul Qadar on 10/3/15.
//  Copyright (c) Argonteq . All rights reserved.
//

import UIKit
import QuartzCore
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var btnSwitchSpotting: UIButton!
    
    @IBOutlet weak var lblBeaconReport: UILabel!
    
    @IBOutlet weak var lblBeaconDetails: UILabel!
    

    var beaconRegion: CLBeaconRegion!
    
    var locationManager: CLLocationManager!
    
    var isSearchingForBeacons = false
    
    var lastFoundBeacon: CLBeacon! = CLBeacon()
    
    var lastProximity: CLProximity! = CLProximity.unknown
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        lblBeaconDetails.isHidden = true
        btnSwitchSpotting.layer.cornerRadius = 30.0
        
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        
        let uuid = UUID(uuidString: "388A0B9C-600F-41D7-ACF1-5CA80A2B82FA")
        beaconRegion = CLBeaconRegion(proximityUUID: uuid!, identifier: "argonteq.BeaconPop")
        
        beaconRegion.notifyOnEntry = true
        beaconRegion.notifyOnExit = true
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    
    // MARK: IBAction method implementation
    
    @IBAction func switchSpotting(sender: AnyObject) {
        if !isSearchingForBeacons {
            locationManager.requestAlwaysAuthorization()
            locationManager.startMonitoring(for: beaconRegion)
            locationManager.startUpdatingLocation()
            
            btnSwitchSpotting.setTitle("Stop Spotting", for: .normal)
            lblBeaconReport.text = "Spotting beacons..."
        }else {
            locationManager.stopMonitoring(for: beaconRegion)
            locationManager.stopRangingBeacons(in: beaconRegion)
            locationManager.stopUpdatingLocation()
            
            btnSwitchSpotting.setTitle("Start Spotting", for: .normal)
            lblBeaconReport.text = "Not running"
            lblBeaconDetails.isHidden = true
        }
        
        isSearchingForBeacons = !isSearchingForBeacons
    }
    
    

    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        locationManager.requestState(for: region)

    }

    func locationManager(manager: CLLocationManager!, didDetermineState state: CLRegionState, forRegion region: CLRegion!) {
        if state == CLRegionState.inside {
            locationManager.startRangingBeacons(in: beaconRegion)
        }
        else {
            locationManager.stopRangingBeacons(in: beaconRegion)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        if state == CLRegionState.inside {
            locationManager.startRangingBeacons(in: beaconRegion)
        }else {
            locationManager.stopRangingBeacons(in: beaconRegion)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        lblBeaconReport.text = "Beacon in range"
        lblBeaconDetails.isHidden = false
    }
    
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        lblBeaconReport.text = "No beacons in range"
        lblBeaconDetails.isHidden = true
    }
    
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [AnyObject]!, in region: CLBeaconRegion) {
        var shouldHideBeaconDetails = true
        
        if let foundBeacons = beacons {
            if beacons.count > 0 {
                if let closestBeacon = foundBeacons[0] as? CLBeacon {
                    if closestBeacon != lastFoundBeacon || lastProximity != closestBeacon.proximity  {
                        lastFoundBeacon = closestBeacon
                        lastProximity = closestBeacon.proximity
                        
                        var proximityMessage: String!
                        switch lastFoundBeacon.proximity {
                        case CLProximity.immediate:
                            proximityMessage = "Very close"
                            
                        case CLProximity.near:
                            proximityMessage = "Near"
                            
                        case CLProximity.far:
                            proximityMessage = "Far"
                            
                        default:
                            proximityMessage = "Where's the beacon?"
                        }
                        
                        shouldHideBeaconDetails = false
                        
                        lblBeaconDetails.text = "Beacon Details:\nMajor = " + String(closestBeacon.major.intValue) + "\nMinor = " + String(closestBeacon.minor.intValue) + "\nDistance: " + proximityMessage
                    }
                }
            }
        }
        
        lblBeaconDetails.isHidden = shouldHideBeaconDetails
    }
    

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print(error)
    }
    
    func locationManager(_ manager: CLLocationManager, rangingBeaconsDidFailFor region: CLBeaconRegion, withError error: Error) {
        print(error)
    }


}

