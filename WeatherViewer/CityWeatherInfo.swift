//
//  CityWeatherInfo.swift
//  WeatherViewer
//
//  Created by Iurii Smovzhenko on 19.03.19.
//  Copyright © 2019 Iurii Smovzhenko. All rights reserved.
//

class CityWeatherInfo {
    
    var city: String = "n/a" // City name
    var valid: Bool = true; // If information from server is received and valid
    var degreeCelsium: Float? = nil // Temperature in celsium
    var condition: String? = nil // Condition explanation
    var imageUrl: String? = nil // Url for condition image on server
    var humidity: Int? = nil // Humidity
    
}
