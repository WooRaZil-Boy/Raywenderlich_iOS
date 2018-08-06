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
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit

class LocationsTableViewCell: UITableViewCell {
  @IBOutlet weak var locationIcon: UIImageView!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var subtitleLabel: UILabel!
}

private struct LocationData {
  let title: String
  let subtitle: String
  let imgString: String
  
  static var `default`: [LocationData] {
    return [
      LocationData(title: "Mozirje", subtitle: "Mozirje", imgString: "locationIcon"),
      LocationData(title: "641 St Peters Ave", subtitle: "641 St Peters Ave, Brooklyn", imgString: "locationIcon"),
      LocationData(title: "Nassau St", subtitle: "122 Nassau St, New York", imgString: "searchIcon"),
      LocationData(title: "1115 Apple Ave", subtitle: "San Francisco", imgString: "searchIcon"),
      LocationData(title: "Facebook NY Office", subtitle: "San Francisco", imgString: "searchIcon"),
      LocationData(title: "Mary Turner", subtitle: "Directions from My Location", imgString: "directionIcon"),
      LocationData(title: "Hannah Logan's Location", subtitle: "Directions from My Location", imgString: "directionIcon"),
      LocationData(title: "Mom's Location", subtitle: "Directions from My Location", imgString: "directionIcon"),
      LocationData(title: "Target Location", subtitle: "Directions from My Location", imgString: "directionIcon")
    ]
  }
}

class LocationsViewController: UIViewController {
  
  @IBOutlet weak var handleView: UIView!
  @IBOutlet weak var containerView: UIView!
  @IBOutlet weak var tableView: UITableView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setUpViews()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  private func setUpViews() {
    handleView.layer.cornerRadius = 2.5
    containerView.round(corners: [.topLeft, .topRight], radius: 8)
    tableView.isUserInteractionEnabled = false
  }
}

extension LocationsViewController: UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return LocationData.default.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: "MapsCell", for: indexPath) as? LocationsTableViewCell else { return UITableViewCell() }
    
    let data = LocationData.default[indexPath.row]
    cell.titleLabel.text = data.title
    cell.subtitleLabel.text = data.subtitle
    cell.locationIcon.image = UIImage(named: data.imgString)!
    return cell
  }
}

extension LocationsViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 80
  }
}

extension LocationsViewController: UISearchBarDelegate {
  func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
    guard let draggablePresentation = presentationController as? DraggablePresentationController else { return }
    draggablePresentation.animateToOpen()
    searchBar.resignFirstResponder() // Remove keyboard so that it doesn't get in the way
  }
}

