//
//  MapViewController.swift
//  liChat
//
//  Created by Simon on 2/7/19.
//  Copyright © 2019 Simon. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    var location:CLLocation!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Map"
        setupUI()
        createRightButton()

        // Do any additional setup after loading the view.
    }

    //MARK: Setup UI
    func setupUI(){
        var region = MKCoordinateRegion()
        region.center.longitude = location.coordinate.longitude
        region.center.latitude = location.coordinate.latitude
        
        region.span.latitudeDelta = 0.01
        region.span.longitudeDelta = 0.01
        
        mapView.setRegion(region, animated: false)
        mapView.showsUserLocation = true
        let annotaion = MKPointAnnotation()
        annotaion.coordinate = location.coordinate
        mapView.addAnnotation(annotaion)
        
    }
    
    
    //MARK: OpenInMaps
    func createRightButton(){
        self.navigationItem.rightBarButtonItems = [UIBarButtonItem(title:"Open in Maps", style:.plain, target: self, action: #selector(self.openInMap)) ]
    }
    
    @objc func openInMap(){
        let regionDestination:CLLocationDistance = 10000
        let coordinates = location.coordinate
        let regionSpan = MKCoordinateRegion(center: coordinates, span: MKCoordinateSpan(latitudeDelta: regionDestination, longitudeDelta: regionDestination))
        
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
        ]
        let placeMark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placeMark)
        mapItem.name = "User's location"
        mapItem.openInMaps(launchOptions: options)
        
    }
    
   

}
