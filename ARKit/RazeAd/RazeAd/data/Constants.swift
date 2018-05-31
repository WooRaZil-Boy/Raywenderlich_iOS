/**
 * Copyright (c) 2018 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
 * distribute, sublicense, create a derivative work, and/or sell copies of the
 * Software in any work that is designed, intended, or marketed for pedagogical or
 * instructional purposes related to programming, coding, application development,
 * or information technology.  Permission for such use, copying, modification,
 * merger, publication, distribution, sublicensing, creation of derivative works,
 * or sale is expressly withheld.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import CoreLocation

enum Constants {
  // The radius of the circle around the target you want to monitor, in meters
  static let geofencingRadius: Double = 300.0

  static let razeadBeacons: [CLBeaconRegion] = [
    // Change with your own beacon
    CLBeaconRegion(proximityUUID: UUID(uuidString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D")!, major: 21010, minor: 2255, identifier: "razead-mobile-kiosk")
  ]

  // REMINDER: Change this to a location near you!!, otherwise geofencing won't work, and beacon monitoring will never be enabled
  static let razewareMobileKioskLocation = Location(name: "Pisa", location: CLLocationCoordinate2D(latitude: 43.7153187, longitude: 10.4019739))
  //static let razewareMobileKioskLocation = Location(name: "Luszowice", location: CLLocationCoordinate2D(latitude: 50.1713779, longitude: 19.4051352))
  static let razewareMobileKioskIdentifier = "The Razeware Mobile Kiosk"

  struct Location {
    let name: String
    let location: CLLocationCoordinate2D
  }
}

