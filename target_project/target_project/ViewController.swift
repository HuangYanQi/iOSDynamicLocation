//
//  ViewController.swift
//  target_project
//
//  Created by 黄彦棋 on 2019/4/18.
//  Copyright © 2019 seer. All rights reserved.
//

import UIKit
import AMapFoundationKit
import MAMapKit
class ViewController: UIViewController {

    @IBOutlet weak var mapContainer: UIView!
    
    @IBOutlet weak var segment: UISegmentedControl!
    
    let userLocation:BMKUserLocation = BMKUserLocation.init()
    let locationManager:BMKLocationManager = BMKLocationManager.init()
    
    lazy var bdMapView:BMKMapView = {
        return BMKMapView.init(frame: mapContainer.bounds)
    }()
    
    lazy var gdMapView:MAMapView = {
        return MAMapView.init(frame: mapContainer.bounds)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bdMapView.userTrackingMode = BMKUserTrackingModeFollow
        bdMapView.showsUserLocation = true
        bdMapView.zoomLevel = 16.4
        locationManager.delegate = self
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.startUpdatingLocation()
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.coordinateType = BMKLocationCoordinateType.GCJ02
        
        gdMapView.userTrackingMode  = MAUserTrackingMode.follow
        gdMapView.showsUserLocation = true
        gdMapView.zoomLevel = 15
        
        mapContainer.addSubview(bdMapView)
        mapContainer.addSubview(gdMapView)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let _ = bdMapView.superview {
            bdMapView.viewWillAppear()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let _ = bdMapView.superview{
            bdMapView.viewWillDisappear()
            locationManager.stopUpdatingLocation()
        }
    }
    
    var segmentIndex:Int{
        get{
            return segment.selectedSegmentIndex
        }
    }
    
    @IBAction func switchMap(_ sender: Any) {
        if segmentIndex == 1 {
            mapContainer.bringSubviewToFront(bdMapView)
        }else{
            mapContainer.bringSubviewToFront(gdMapView)
        }
    }
    
    @IBAction func reduce(_ sender: Any) {
        if segmentIndex == 0 {
            if gdMapView.zoomLevel - 0.5 > gdMapView.minZoomLevel{
                gdMapView.setZoomLevel(gdMapView.zoomLevel - 0.5, animated: true)
            }else{
                gdMapView.setZoomLevel(gdMapView.minZoomLevel, animated: true)
            }
        }else{
            if bdMapView.zoomLevel - 0.5 > bdMapView.minZoomLevel{
                bdMapView.zoomLevel = bdMapView.zoomLevel - 0.5
            }else{
                bdMapView.zoomLevel = bdMapView.minZoomLevel
            }
        }
    }
    
    @IBAction func gotoGPSLocation(_ sender: Any) {
        if segmentIndex == 0 {
            gdMapView.setUserTrackingMode(.follow, animated: true)
            gdMapView.setZoomLevel(17, animated: true)
        }else{
            bdMapView.zoomLevel = 18.4
            gdMapView.userTrackingMode = MAUserTrackingMode.follow
        }
    }
}

extension ViewController:BMKLocationManagerDelegate{
    func bmkLocationManager(_ manager: BMKLocationManager, didUpdate heading: CLHeading?) {
        guard heading != nil else{
            return
        }
        
        userLocation.heading = heading!
        bdMapView.updateLocationData(userLocation)
    }
    
    func bmkLocationManager(_ manager: BMKLocationManager, didUpdate location: BMKLocation?, orError error: Error?) {
        guard location != nil else{
            return
        }
        
        userLocation.location = location!.location!
        bdMapView.updateLocationData(userLocation)
    }
}


