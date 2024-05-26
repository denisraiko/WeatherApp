//
//  LocationManager.swift
//  WeatherApp
//
//  Created by Denis Raiko on 11.05.24.
//

import Foundation
import CoreLocation

class LocationManager: NSObject, CLLocationManagerDelegate {
    static let shared = LocationManager()
    
    private let locationManager = CLLocationManager()
    private var completion: ((CLLocationCoordinate2D) -> Void)?
    
    private override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }
    
    func getCurrentLocation(completion: @escaping (CLLocationCoordinate2D) -> Void) {
        let defaultCoordinate = CLLocationCoordinate2D(latitude: 37.785834, longitude: -122.406417) // дефолтные координаты
        completion(defaultCoordinate)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        let coordinate = location.coordinate
        completion?(coordinate)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager failed with error: \(error.localizedDescription)")
    }
}

