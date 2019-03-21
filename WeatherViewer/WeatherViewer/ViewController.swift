//
//  ViewController.swift
//  WeatherViewer
//
//  Created by Iurii Smovzhenko on 17.03.19.
//  Copyright © 2019 Iurii Smovzhenko. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController
{
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var lblCityName: UILabel!
    @IBOutlet weak var lblCondition: UILabel!
    @IBOutlet weak var lblTemp: UILabel!
    @IBOutlet weak var imgViewPict: UIImageView!
    @IBOutlet weak var lblHumidity: UILabel!
    
    let weatherApiRequest: String = "http://api.apixu.com/v1/current.json?key=3d36a07892be4ee0bac202200191703&q="
    let locationManager = CLLocationManager()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Set search bar delegate
        searchBar.delegate = self
        
        // Set locaton manager
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func requestCurrentWeather(_ searchString : String)
    {
        let cityWeatherInfo: CityWeatherInfo = CityWeatherInfo() // Object of CityWeatherInfo
        var searchValue = searchString;
        searchValue = removeSpecialCharsFromString(text: searchValue) // Remove all restricted symbols
        searchValue = searchValue.replacingOccurrences(of: " ", with: "%20") // Replace space " " with %20
        
        let urlRequest = URLRequest(url: URL(string: weatherApiRequest.appending(searchValue))!) // Request to server
        
        let task = URLSession.shared.dataTask(with: urlRequest) {
            (data, response, error) in
            // Parsing JSON after response
            if error == nil {
                do {
                    let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! [String : AnyObject]
                    if let current = json["current"] as? [String : AnyObject] {
                        
                        if let temp = current["temp_c"] as? Float {
                            cityWeatherInfo.degreeCelsium = temp
                        }
                        
                        if let condition = current["condition"] as? [String : AnyObject] {
                            cityWeatherInfo.condition = condition["text"] as? String
                            let icon = condition["icon"] as! String
                            cityWeatherInfo.imageUrl = "http:\(icon)"
                        }
                        cityWeatherInfo.humidity = current["humidity"] as? Int
                        
                    }
                    
                    if let location = json["location"] as? [String : AnyObject] {
                        cityWeatherInfo.city = location["name"] as! String
                    }
                    
                    if let _ = json["error"] {
                        cityWeatherInfo.valid = false
                    }
                    
                    DispatchQueue.main.async {
                        self.showCityWeatherData(object: cityWeatherInfo)
                    }
                } catch let jsonError {
                    print(jsonError.localizedDescription)
                }
            }
        }
        task.resume()
    }
    
    @IBAction func onBtnCurrentLocationPressed(_ sender: Any)
    {
        locationManager.startUpdatingLocation()
    }
    
    func showCityWeatherData(object: CityWeatherInfo)
    {
        if object.valid {
            
            showInterface(value: true)
            self.lblTemp.text = (object.degreeCelsium?.description)! + "℃"
            self.lblCityName.text = object.city
            self.lblCondition.text = object.condition
            self.imgViewPict.downloadImage(from: object.imageUrl!)
            self.lblHumidity.text = ("Humidity: ") + (object.humidity?.description)!

        } else {
            
            showInterface(value: false)
            self.lblCityName.text = "No data"
        }
    }
    
    func showInterface(value: Bool)
    {
        if value{
            self.lblTemp.isHidden = false
            self.lblCondition.isHidden = false
            self.imgViewPict.isHidden = false
            self.lblHumidity.isHidden = false
        } else {
            self.lblTemp.isHidden = true
            self.lblCondition.isHidden = true
            self.imgViewPict.isHidden = true
            self.lblHumidity.isHidden = true
        }
    }
    
    func removeSpecialCharsFromString(text: String) -> String {
        let okayChars : Set<Character> =
            Set("abcdefghijklmnopqrstuvwxyz ABCDEFGHIJKLKMNOPQRSTUVWXYZ1234567890+-*=(),.:!_".characters)
        return String(text.characters.filter {okayChars.contains($0) })
    }

}

// MARK: - UISearchBarDelegate
extension ViewController : UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    {
        requestCurrentWeather(searchBar.text!)
    }
}

// MARK: - CLLocationManagerDelegate
extension ViewController : CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        
        requestCurrentWeather("\(locValue.latitude),\(locValue.longitude)")
        locationManager.stopUpdatingLocation()
    }
}

// MARK: - UIImageView
extension UIImageView {
    func downloadImage(from url:String) {
        let urlRequest = URLRequest(url: URL(string: url)!)
        
        let task = URLSession.shared.dataTask(with: urlRequest) { (data, rensponce, error) in
            if error == nil {
                DispatchQueue.main.async {
                    self.image = UIImage(data: data!, scale: 1.0)
                }
            }
        }
        
        task.resume()
    }
}

