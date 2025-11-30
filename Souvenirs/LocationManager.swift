//
//  LocationManager.swift
//  Souvenirs
//
//  Created by Jean Martin on 30/11/2025.
//

import Foundation
import CoreLocation

class LocationManager {
    static let shared = LocationManager()
    private let geocoder = CLGeocoder()
    
    
    private init() {}
    
    //Geocode a location name to coordinates
    func geocodeLocation(_ locationName: String) async ->CLLocationCoordinate2D? {
        return await withCheckedContinuation { continuation in
            geocoder.geocodeAddressString(locationName) { placemarks, error in
                
                if let error = error {
                    
                    print("Geocoding Error: \(error.localizedDescription)")
                    continuation.resume(returning: nil)
                    return
                    
                } //if loop end
                
                if let coordinate = placemarks?.first?.location?.coordinate {
                    continuation.resume(returning: coordinate)
                    
                } else {
                    continuation.resume(returning: nil)
                    
                } //if loop 2 end
                
            } // geocoder loop end
            
        } //return loop end
        
    } //func end
    
} //class end
