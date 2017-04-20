//
//  ViewController.swift
//  iMuseumEncore
//
//  Created by Himaja Motheram on 4/14/17.
//  Copyright © 2017 Sriram Motheram. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController,CLLocationManagerDelegate {
   
     let hostName = "https://data.imls.gov/resource/et8i-mnha.json"
     var MuseumArray = [MuseumEncore]()
     @IBOutlet weak var mapView: MKMapView!
    
    var locationMgr = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    func setupLocationMonitoring() {
        locationMgr.delegate = self
        locationMgr.desiredAccuracy = kCLLocationAccuracyBest
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .authorizedAlways, .authorizedWhenInUse:
                turnOnLocationMonitoring()
            case .denied, .restricted:
                print("Hey turn us back on in Settings!")
            case .notDetermined:
                if locationMgr.responds(to: #selector(CLLocationManager.requestAlwaysAuthorization)) {
                    locationMgr.requestAlwaysAuthorization()
                }
            }
        } else {
            print("Hey Turn Location On in Settings!")
        }
    }
    
    func buildArray() {
        
        let loc8 = MuseumEncore(name: "Masonic Temple of Detroit", street: "500 Temple Avenue",city: "Detroit",state:"MI",
                          coord2d: CLLocationCoordinate2D(latitude: 42.3415082,longitude: -83.0596134))
        
       let loc1 = MuseumEncore(name: "Detroit Institute of Arts", street: "5200 Woodward Avenue",city: "Detroit",state:"MI",
         coord2d: CLLocationCoordinate2D(latitude: 42.358742,longitude: -83.063754))
        
     /*   let loc2 = MuseumEncore(name: "Comerica Park", street: "2100 Woodward Avenue", city: "Detroit",state:"MI",coord2d: CLLocationCoordinate2D(latitude: 42.3677736,longitude: -83.4172997))
        
        let loc9 = MuseumEncore(name: "Historic Fort Wayne", street: "6325 West Jefferson",city: "Detroit",state:"MI",
            coord2d: CLLocationCoordinate2D(latitude: 42.358742,longitude: -83.063754))
        
        let loc10 = MuseumEncore(name: "Pewabic Pottery", street: "10125 East Jefferson Avenue",city: "Detroit",state:"MI",
            coord2d: CLLocationCoordinate2D(latitude: 42.3677736,longitude: -83.4172997))*/
        
        
       //MuseumArray = [loc8,loc1]//,loc2]
     
        MuseumSearch()
        
    }

    func annotateMapLocations() {
        var pinsToRemove = [MKPointAnnotation]()
        for annotation in mapView.annotations {
            if annotation is MKPointAnnotation {
                pinsToRemove.append(annotation as! MKPointAnnotation)
            }
        }
        mapView.removeAnnotations(pinsToRemove)
        print ("************here in annotate*****************")
        
        for Museum in MuseumArray {
           
            let pa = MKPointAnnotation()
            pa.title = Museum.name
            print("\(pa.title)")
            pa.subtitle = Museum.street
            pa.coordinate = Museum.coord//CLLocationCoordinate2D(latitude: Museum.latitude, longitude: Museum.longitude)
            mapView.addAnnotation(pa)
        }
        zoomToPins()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupLocationMonitoring()
        buildArray()
        annotateMapLocations()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let lastLoc = locations.last!
        print("Last Loc: \(lastLoc.coordinate.latitude),\(lastLoc.coordinate.longitude)")
        zoomToLocation(lat: lastLoc.coordinate.latitude, lon: lastLoc.coordinate.longitude, radius: 500)
        manager.stopUpdatingLocation()
    }
    
    func turnOnLocationMonitoring() {
        locationMgr.startUpdatingLocation()
        mapView.showsUserLocation = true
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        setupLocationMonitoring()
    }
    
    
    func zoomToLocation(lat: Double, lon: Double, radius: Double) {
        if lat == 0 && lon == 0 {
            print("Invalid Data")
        } else {
            let coord = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            let viewRegion = MKCoordinateRegionMakeWithDistance(coord, radius, radius)
            let adjustedRegion = mapView.regionThatFits(viewRegion)
            mapView.setRegion(adjustedRegion, animated: true)
        }
    }
    
    func zoomToPins() {
        mapView.showAnnotations(mapView.annotations, animated: true)
    }
    
    func MuseumSearch( )
    {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        let urlString = hostName
        
        let url = URL(string: urlString)
        var request = URLRequest(url: url!)
        request.timeoutInterval = 30
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        let session = URLSession.shared
        
        let task = session.dataTask(with: request) { (data, response, error) in
            guard let recvData = data else {
                print("No Data")
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                return
            }
            if recvData.count > 0 && error == nil {
                print("Got Data:\(recvData)")
                let dataString = String.init(data: recvData, encoding: .utf8)
                print("Got Data String:\(dataString)")
                self.parseJson(data: recvData)
            } else {
                print("Got Data of Length 0")
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
        task.resume()
    }
    

        func parseJson(data: Data) {
            
            do {
                
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
        
                let resultsArray = jsonResult as! [[String:Any]]
        
                 MuseumArray.removeAll()
                
                for resultDictionary in resultsArray {
                    
                    
                    guard let Name = resultDictionary["commonname"] as? String else {
                        continue
                    }
                    guard let Street = resultDictionary["location_1_address"] as? String else {
                        continue
                    }
                    guard let City = resultDictionary["location_1_city"] as? String else {
                        continue
                    }
                    guard let State = resultDictionary["location_1_state"] as? String else {
                        continue
                    }
                   
                   // let courseTemp = json["course"] as? NSDictionary
                    guard  let coord =  resultDictionary["location_1"]as? NSDictionary else {
                        continue
                    }
                    //                    print("here")
                  //  print("\(Name) \(coord["coordinates"])")
                    let arr = coord["coordinates"]! as! NSArray
                    
                    let latitude = arr[0] as! Double
                    let longitude = arr[1] as! Double
                   //  print("\(latitude) \(longitude)")
                  
                    let Museum_New = MuseumEncore(name: Name, street: Street, city: City, state: State, coord2d:
                    CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
        
                    MuseumArray.append(Museum_New)
                    
                    print("\(Museum_New.get_latitude())")
                }
                
                
                DispatchQueue.main.async {
                   // NotificationCenter.default.post(name: .reload, object: nil)
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
             
                
            }catch {
                print("JSON Parsing Error")
            }
            
            DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
                
            }
            
    }
        


}

