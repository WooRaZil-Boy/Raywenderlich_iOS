/**
 * Copyright (c) 2017 Razeware LLC
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

import UIKit
import MapKit
import CoreLocation
import InfoServiceStatic

class MapViewController: UIViewController {
  
  @IBOutlet weak var mapView: MKMapView!
  var overlayColors: [MKPolyline: UIColor] = [:]
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    mapView.delegate = self

    // this sets the view centered around Alexandria. Ignore any warnings in the console. This region is approximate and depends on the map size
    let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 38.802487320156274, longitude: -77.056133355780659),
                                    span: MKCoordinateSpan(latitudeDelta: 0.17845926350371855, longitudeDelta: 0.14360136507224297))
    mapView.setRegion(region, animated: false)
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    loadAnnotations()
  }

  func loadAnnotations() {
    let model = AppDelegate.sharedModel
    guard model.lines.count > 0 else {
      //check that the lines are loaded, otherwise poll
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
        self?.loadAnnotations()
      }
      return
    }

    model.lines.forEach { line in
      model.geography(forId: line.lineId) { [weak self] geometry in
        guard let strongSelf = self,
          let geometryInfo = geometry else {
            return
        }
        let coordinates = geometryInfo.geometry.coordinates.map { coordinate -> CLLocationCoordinate2D in
          let latitude = coordinate[1]
          let longitude = coordinate[0]
          return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }

        let overlay = MKPolyline(coordinates: coordinates, count: coordinates.count)
        strongSelf.overlayColors[overlay] = line.associatedColor
        strongSelf.mapView.add(overlay)
      }
    }
  }
}

// MARK: - MKMapViewDelegate
extension MapViewController: MKMapViewDelegate {

  func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
    guard let line = overlay as? MKPolyline else {
      return MKOverlayRenderer()
    }

    let lineView = MKPolylineRenderer(overlay: line)
    lineView.strokeColor = overlayColors[line] ?? .black
    lineView.lineWidth = 3.0
    return lineView
  }
}
