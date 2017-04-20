//
//  MuseumEncore.swift
//  iMuseumEncore
//
//  Created by Himaja Motheram on 4/14/17.
//  Copyright © 2017 Sriram Motheram. All rights reserved.
//



import UIKit
import MapKit

class MuseumEncore: NSObject {
    
    
    var name          :String!
    var street  :String!
    var city          :String!
    var state    :String!
    var  coord: CLLocationCoordinate2D!
    //var latitude         :Double!
    //var longitude        :Double!
    
    
    convenience init(name: String, street: String, city: String, state: String, coord2d: CLLocationCoordinate2D){
        
        self.init( )
        self.name = name
        self.street = street
        self.city = city
        self.state = state
        self.coord = coord2d
        //self.latitude = coord2d.latitude
        //self.longitude = coord2d.longitude
        
    }
    
    func get_latitude( ) -> Double{
    
      return coord.latitude
    }
    
}
