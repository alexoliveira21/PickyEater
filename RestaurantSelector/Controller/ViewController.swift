//
//  ViewController.swift
//  RestaurantSelector
//
//  Created by Alexandre Oliveira on 10/2/18.
//  Copyright © 2018 Alexandre Oliveira. All rights reserved.
//

import UIKit
//import BrightFutures
import YelpAPI
import Alamofire
import SwiftyJSON
import CoreLocation
import ProgressHUD
import MapKit


class ViewController: UIViewController, CLLocationManagerDelegate, UITextFieldDelegate {
    let locationManager = CLLocationManager()
    var currentLocation = CLLocation()
    var latitude = CLLocationDegrees()
    var longitude = CLLocationDegrees()
    let geocoder = CLGeocoder()
    var randomNumber = 0;
    let restaurantData = RestaurantData()
    var term : String = "lunch"
    var priceValue = 2
    let YELP_URL = "https://api.yelp.com/v3/businesses/search?"
    let yelpAPI_KEY = "JHaUQ4YOE_IiA1s0eu4vkfzd2SXfpE8n7ObVL5Cm3pPbRdw4iQjArwulkYt2A0b7Lr2hY4fYB9-vu5vU6Qgk4amUQy51E_R87whSCHPqrg3WMivnRBarpGS0LpazW3Yx"
    var gotData = false

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var getDirections: UIButton!
    @IBOutlet weak var moreInfo: UIButton!
    @IBOutlet weak var randomize: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        searchBarText.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        ProgressHUD.show()
        getDirections.layer.cornerRadius = 10
        moreInfo.layer.cornerRadius = 10
        randomize.layer.cornerRadius = 5
        mapView.isHidden = true
    
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBOutlet weak var searchBarText: UITextField!
    
    
    @IBOutlet weak var restaurantLabel: UILabel!
    
    @IBAction func searchBar(_ sender: Any) {
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        term = textField.text!
        textField.resignFirstResponder()
        print(term)
        getYelpData()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.view.endEditing(true)
        return false
    }
    
    @IBAction func randomizeRestaurant(_ sender: UIButton) {
        randomNumber = Int.random(in: 0...restaurantData.yelpJSON["businesses"].count-1)
        print(randomNumber)
        updateRestaurantData()
    }
    
    @IBAction func priceSelector(_ sender: UISegmentedControl) {
        switch(sender.selectedSegmentIndex){
        case 0:
            priceValue = 1
            getYelpData()
        case 1:
            priceValue = 2
            getYelpData()
        case 2:
            priceValue = 3
            getYelpData()
        case 4:
            priceValue = 4
            getYelpData()
        default:
            priceValue = 2
            getYelpData()
        }
    }
    @IBAction func termSelector(_ sender: UISegmentedControl) {
        
        switch  (sender.selectedSegmentIndex) {
        case 0:
            term = "breakfast"
            ProgressHUD.show()
            getYelpData()
        case 1:
            term = "lunch"
            ProgressHUD.show()
            getYelpData()
        case 2:
            term = "dinner"
            ProgressHUD.show()
            getYelpData()
        case 3:
            term = "fast-food"
            ProgressHUD.show()
            getYelpData()
        default:
            term = "lunch"
            ProgressHUD.show()
            getYelpData()
        }
    }
    @IBAction func getDirections(_ sender: Any) {
        openMaps()
    }
    
    
    func getYelpData(){
        
        let yelpAuthorization = ["Authorization" : "Bearer \(yelpAPI_KEY)"]
       // let yelpParameters = ["term" : term, "latitude" : Double(latitude), "longitude" : Double(longitude), "sort-by" : "review_count", "limit" : 50] as [String : Any]
        let yelpParameters = ["term" : term, "location" : "\(latitude),\(longitude)", "sort-by" : "rating", "limit" : 30, "price" : priceValue] as [String : Any]
        Alamofire.request(YELP_URL, method: .get, parameters: yelpParameters, encoding: URLEncoding.default, headers: yelpAuthorization).responseJSON {
            response in
            if response.result.isSuccess {
                let yelpJSON = JSON(response.result.value!)
                print(yelpJSON)
                self.restaurantData.yelpJSON = yelpJSON
                self.gotData = true
                print(yelpJSON["businesses"].count)
                self.randomNumber = Int.random(in: 0...(yelpJSON["businesses"].count-1))
                print(self.randomNumber)
                self.updateRestaurantData()
            }
                
            else {
                print("Error: \(response.result.error)")
                self.gotData = false
            }
        }
    }
    
    func updateRestaurantData() {
        if gotData == true {
            ProgressHUD.dismiss()
            restaurantData.chosenRestaurant = restaurantData.yelpJSON["businesses"][randomNumber]["name"].string!
            restaurantData.chosenPlaceLatitude = restaurantData.yelpJSON["businesses"][randomNumber]["coordinates"]["latitude"].double!
            restaurantData.chosenPlaceLongitude = restaurantData.yelpJSON["businesses"][randomNumber]["coordinates"]["longitude"].double!
            
            mapView.removeAnnotation(restaurantData.placeMark)
            let coordinates = CLLocationCoordinate2DMake(restaurantData.chosenPlaceLatitude, restaurantData.chosenPlaceLongitude)
            restaurantData.coordinates = coordinates
            let placeMark = MKPointAnnotation()
            placeMark.coordinate = coordinates
            placeMark.title = restaurantData.chosenRestaurant
            restaurantData.placeMark = placeMark
            
            let center = CLLocationCoordinate2D(latitude: restaurantData.chosenPlaceLatitude, longitude: restaurantData.chosenPlaceLongitude)
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            mapView.setRegion(region, animated: true)
            
            updateUI()
        }
        else if gotData == false {
            print("Error getting data.")
            restaurantLabel.text = "Error"
        }
        
    }
    
    func updateUI(){
        
        mapView.layer.cornerRadius = 10
        mapView.isHidden = false
        mapView.addAnnotation(restaurantData.placeMark)
        restaurantLabel.text = restaurantData.chosenRestaurant
        
    }
    
    func openMaps(){
        let mapPlacemark = MKPlacemark(coordinate: restaurantData.coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: mapPlacemark)
        mapItem.name = restaurantData.chosenRestaurant
        mapItem.openInMaps(launchOptions: nil)
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations[locations.count-1]
        
        if location.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            
            print("Longitude: \(location.coordinate.longitude) \nLatitude: \(location.coordinate.latitude)")
            
            latitude = location.coordinate.latitude
            longitude = location.coordinate.longitude
            
            print(location.coordinate)
            getYelpData()
            
                }
        
            }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Error: \(error)")
    }
    }


