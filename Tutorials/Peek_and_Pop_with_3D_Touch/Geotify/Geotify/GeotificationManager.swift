/// Copyright (c) 2018 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// /Users/andypereira/Desktop/Geotify/Geotify-Finished/Geotify/Base.lproj/Main.storyboardFITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import Foundation
import CoreLocation

struct PreferencesKeys {
  static let savedItems = "savedItems"
}

class GeotificationManager: NSObject {
  static let shared = GeotificationManager.init()
  
  var geotifications: [Geotification] = []
  private let locationManager = CLLocationManager()
  
  private override init() {
    super.init()
    locationManager.delegate = self
    guard let savedData = UserDefaults.standard.data(forKey: PreferencesKeys.savedItems) else {
      return
    }
    let decoder = JSONDecoder()
    if let savedGeotifications = try? decoder.decode(Array.self, from: savedData) as [Geotification] {
      geotifications = savedGeotifications
    }
  }
  
  public func add(_ geotification: Geotification) {
    geotifications.append(geotification)
    startMonitoring(geotification: geotification)
    saveAllGeotifications()
  }
  
  public func remove(_ geotification: Geotification) {
    guard let index = GeotificationManager.shared.geotifications.index(of: geotification) else { return }
    geotifications.remove(at: index)
    stopMonitoring(geotification: geotification)
    saveAllGeotifications()
  }
  
  private func saveAllGeotifications() {
    let encoder = JSONEncoder()
    do {
      let data = try encoder.encode(geotifications)
      UserDefaults.standard.set(data, forKey: PreferencesKeys.savedItems)
    } catch {
      print("error encoding geotifications")
    }
  }
  
  private func region(with geotification: Geotification) -> CLCircularRegion {
    let region = CLCircularRegion(center: geotification.coordinate, radius: geotification.radius, identifier: geotification.identifier)
    region.notifyOnEntry = (geotification.eventType == .onEntry)
    region.notifyOnExit = !region.notifyOnEntry
    return region
  }
  
  private func startMonitoring(geotification: Geotification) {
    if !CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
      print("Geofencing is not supported on this device!")
      return
    }
    
    if CLLocationManager.authorizationStatus() != .authorizedAlways {
      let message = """
      Your geotification is saved but will only be activated once you grant
      Geotify permission to access the device location.
      """
      print(message)
    }
    
    let fenceRegion = region(with: geotification)
    locationManager.startMonitoring(for: fenceRegion)
  }
  
  private func stopMonitoring(geotification: Geotification) {
    for region in locationManager.monitoredRegions {
      guard let circularRegion = region as? CLCircularRegion, circularRegion.identifier == geotification.identifier else { continue }
      locationManager.stopMonitoring(for: circularRegion)
    }
  }
}

extension GeotificationManager: CLLocationManagerDelegate {
  func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
    print("Monitoring failed for region with identifier: \(region!.identifier)")
  }
}
