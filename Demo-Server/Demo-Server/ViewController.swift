//
//  ViewController.swift
//  Demo-Server
//
//  Created by 黄彦棋 on 2019/3/17.
//  Copyright © 2019 seer. All rights reserved.
//

import UIKit
import AMapFoundationKit
import MAMapKit

class ViewController: UIViewController {
    @IBOutlet weak var mapContainer: UIView!
    @IBOutlet weak var btnTurn: UIButton!
    var server:GCDWebServer!
    
    let userLocation:BMKUserLocation = BMKUserLocation.init()
    let locationManager:BMKLocationManager = BMKLocationManager.init()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        server = GCDWebServer.init()
        server.addHandler(forMethod: "GET", path: "/locations", request: GCDWebServerRequest.self) {[unowned self] (request:GCDWebServerRequest) -> GCDWebServerResponse? in

            let idx = self.segmentIndex
            let coodiate:CLLocationCoordinate2D = self.routePoints[idx].last?.coordinate ?? CLLocationCoordinate2D.init(latitude: 0.0, longitude: 0.0)
            print("idx:\(self.segmentIndex)")
            let coodiateGps:ECLocationTransform = self.segmentIndex == 0 ? ECLocationTransform.init(latitude: coodiate.latitude, andLongitude: coodiate.longitude)!.fromGDToGPS() : ECLocationTransform.init(latitude: coodiate.latitude, andLongitude: coodiate.longitude)!.fromBDToGPS()
            print("Seer : GCDServer response lat\(coodiateGps.latitude) : lon:\(coodiateGps.longitude)")
            var date = Date.init()
            date.addTimeInterval(TimeInterval(TimeZone.current.secondsFromGMT(for: date)))
            let formatter = DateFormatter.init()
            formatter.dateFormat = "yyy-MM-dd HH:mm:ss"

            return GCDWebServerDataResponse.init(jsonObject: [
                "isValid":coodiate.longitude != 0 || coodiate.latitude != 0,
                "lat":String.init(describing: coodiateGps.latitude),
                "lon":String.init(describing: coodiateGps.longitude),
                "index":self.routePoints[idx].count,
                "type":idx == 0 ? "高德地图":"百度地图",
                "coordinate-system":"gps",
                "date":formatter.string(from: date)
                ])
        }
        server.start(withPort: 8080, bonjourName: nil)
        
        
        btnTurn.setBackgroundImage(UIImage.init(named: "start.png"), for: .normal)
        btnTurn.setBackgroundImage(UIImage.init(named: "stop.png"),  for: .selected)
        
        bdMapView.delegate = self
        bdMapView.userTrackingMode = BMKUserTrackingModeFollow
        bdMapView.showsUserLocation = true
        bdMapView.zoomLevel = 16.4
        locationManager.delegate = self
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.startUpdatingLocation()
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.coordinateType = BMKLocationCoordinateType.BMK09LL
        
        gdMapView.userTrackingMode = MAUserTrackingMode.follow
        gdMapView.delegate = self
        gdMapView.zoomLevel = 15
        
        mapContainer.addSubview(bdMapView)
        mapContainer.addSubview(gdMapView)
    }
    
    lazy var bdMapView:BMKMapView = {
       return BMKMapView.init(frame: mapContainer.bounds)
    }()
    
    lazy var gdMapView:MAMapView = {
        return MAMapView.init(frame: mapContainer.bounds)
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        mapView.setUserTrackingMode(.follow, animated: false)
        if let _ = bdMapView.superview {
            bdMapView.viewWillAppear()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        server.removeAllHandlers()
        server.stop()
        
        if let _ = bdMapView.superview{
            bdMapView.viewWillDisappear()
            locationManager.stopUpdatingLocation()
        }
    }
    
    @IBAction func toGPSLocation(_ sender: Any) {
        if segmentIndex == 0 {
            gdMapView.setUserTrackingMode(.follow, animated: true)
            gdMapView.setZoomLevel(17, animated: true)
        }else{
            bdMapView.zoomLevel = 18.4
            gdMapView.userTrackingMode = MAUserTrackingMode.follow
        }
    }
    
    var isSketching:[Bool] = [false,false]
    lazy var routePoints:[[AnyObject]] = {
        return [[],[]]
    }()
    lazy var routeLines:[[AnyObject]] = {
        return [[],[]]
    }()
    
    var segmentIndex:Int{
        get{
            return segment.selectedSegmentIndex
        }
    }
    
    @IBAction func switchSketchStatus(_ sender: UIButton) {
        if isSketching[segmentIndex] {
            if segmentIndex == 0{
                gdMapView.removeAnnotations(routePoints[segmentIndex])
                gdMapView.removeOverlays(routeLines[segmentIndex])
            }else{
                bdMapView.removeAnnotations(routePoints[segmentIndex])
                bdMapView.removeOverlays(routeLines[segmentIndex])
            }
            routePoints[segmentIndex].removeAll()
            routeLines[segmentIndex].removeAll()
        }
        isSketching[segmentIndex] = !isSketching[segmentIndex]
        sender.isSelected = isSketching[segmentIndex]
    }
    
    var lastIdx = 0

    @IBOutlet weak var segment: UISegmentedControl!
    @IBAction func switchService(_ sender: UISegmentedControl) {
        if segmentIndex == 1 {
            mapContainer.bringSubviewToFront(bdMapView)
        }else{
            mapContainer.bringSubviewToFront(gdMapView)
        }
        lastIdx = segmentIndex
        btnTurn.isSelected = isSketching[segmentIndex]
    }
    
    @IBAction func reduceZoomLevel(_ sender: Any) {
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
}

extension ViewController:MAMapViewDelegate{
    func mapView(_ mapView: MAMapView!, didSingleTappedAt coordinate: CLLocationCoordinate2D) {
        print("Sing Tap at AMap Lat:\(coordinate.latitude) Lon:\(coordinate.longitude)")
        let coor = ECLocationTransform.init(clLocationCoordinate: coordinate)?.fromGDToGPS()
        print("Sing Tap at GPS  Lat:\(String(describing: coor?.latitude)) Lon:\(String(describing: coor?.longitude))")
        if isSketching[0]{
            let point:MAPointAnnotation = MAPointAnnotation.init()
            point.coordinate = coordinate
            mapView.addAnnotation(point)
            routePoints[0].append(point)
            
            if routePoints[0].count > 1{
                var coordinates:[CLLocationCoordinate2D] = [routePoints[0][routePoints[0].count - 2].coordinate,coordinate]
                let line:MAPolyline = MAPolyline(coordinates: &coordinates, count:2)
                routeLines[0].append(line)
                mapView.add(line)
            }
        }
    }
    
    func mapView(_ mapView: MAMapView!, rendererFor overlay: MAOverlay!) -> MAOverlayRenderer! {
        if overlay.isKind(of: MAPolyline.self) {
            let lineView = MAPolylineRenderer.init(overlay: overlay)
            lineView!.lineWidth = 8.0
            lineView!.strokeColor  = UIColor(red:0.87, green:0.10, blue:0.13, alpha:0.95)
            lineView!.lineJoinType = kMALineJoinRound
            lineView!.lineCapType  = kMALineCapRound
            
            return lineView
        }
        return nil
    }
}

extension ViewController:BMKMapViewDelegate{
    
    func mapView(_ mapView: BMKMapView!, onClickedMapBlank coordinate: CLLocationCoordinate2D) {
        print("Sing Tap at BMKMap Lat:\(coordinate.latitude) Lon:\(coordinate.longitude)")

        let coor = ECLocationTransform.init(clLocationCoordinate: coordinate)?.fromBDToGPS()
        print("Sing Tap at GPS  Lat:\(String(describing: coor?.latitude)) Lon:\(String(describing: coor?.longitude))")
        if isSketching[1]{
            let point:BMKPointAnnotation = BMKPointAnnotation.init()
            point.coordinate = coordinate
            mapView.addAnnotation(point)
            routePoints[1].append(point)

            if routePoints[1].count > 1{
                var coordinates:[CLLocationCoordinate2D] = [routePoints[1][routePoints[1].count - 2].coordinate,coordinate]
                let line:BMKPolyline = BMKPolyline(coordinates: &coordinates, count: 2)
                routeLines[1].append(line)
                mapView.add(line)
            }
        }
    }

    func mapView(_ mapView: BMKMapView!, viewFor overlay: BMKOverlay!) -> BMKOverlayView! {
        if overlay.isKind(of: BMKPolyline.self) {
            let lineView = BMKPolylineView.init(overlay: overlay)
            lineView!.lineWidth = 3.0
            lineView!.strokeColor  = UIColor(red:0.87, green:0.10, blue:0.13, alpha:0.95)

            return lineView
        }

        return nil
    }
}
// 高德和百度代理方法命名冲突 （还真是水火不容）
extension ViewController{
    override func responds(to aSelector: Selector!) -> Bool {
        if aSelector == #selector(MAMapViewDelegate.mapView(_:viewFor:)) {
            
        }
        
        return super.responds(to: aSelector)
    }
    
    func gdMapView(_ mapView: MAMapView!, viewFor annotation: MAAnnotation!) -> MAAnnotationView! {
        if annotation.isKind(of: MAPointAnnotation.self) && !annotation.coordinate.equalTo(coordinate: mapView.userLocation.coordinate){
            let reuseId = "PointAnnotation"
            var view:MAAnnotationView? = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
            if view == nil{
                view = MAAnnotationView.init(annotation: annotation, reuseIdentifier: reuseId)
                view!.frame = .init(x: 0, y: 0, width: 20, height: 20)
                view!.layer.cornerRadius = 10
                view!.backgroundColor = UIColor(red:0.14, green:0.55, blue:0.91, alpha:1.00)
            }
            return view

        }

        return nil
    }
    
    func bdMapView(_ mapView: BMKMapView!, viewFor annotation: BMKAnnotation!) -> BMKAnnotationView! {
        if annotation.isKind(of: MAPointAnnotation.self) && !annotation.coordinate.equalTo(coordinate: userLocation.location.coordinate){
            let reuseId = "PointAnnotation"
            var view:BMKPinAnnotationView? = (mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as! BMKPinAnnotationView)
            if view == nil{
                view = BMKPinAnnotationView.init(annotation: annotation, reuseIdentifier: reuseId)
                view!.frame = .init(x: 0, y: 0, width: 20, height: 20)
                view!.layer.cornerRadius = 10
                view!.backgroundColor = UIColor(red:0.14, green:0.55, blue:0.91, alpha:1.00)
            }
            
            return view
        }
        
        return nil
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

extension CLLocationCoordinate2D{
    func equalTo(coordinate:CLLocationCoordinate2D) -> Bool {
        return self.latitude == coordinate.latitude && self.longitude == coordinate.longitude
    }
}

