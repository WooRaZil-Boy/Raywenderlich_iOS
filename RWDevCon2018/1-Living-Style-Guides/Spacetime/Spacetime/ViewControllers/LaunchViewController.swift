//
//  LaunchViewController.swift
//  Spacetime
//
//  Created by Ellen Shapiro on 10/25/17.
//  Copyright © 2017 RayWenderlich.com. All rights reserved.
//

import MapKit
import SafariServices
import UIKit

class LaunchViewController: UIViewController {
  
  @IBOutlet private var launchDateLabel: UILabel!
  @IBOutlet private var launchSuccessLabel: UILabel!
  @IBOutlet private var launchBoosterReuseLabel: UILabel!
  @IBOutlet private var launchSiteMap: MKMapView!
  @IBOutlet private var launchDetailsLabel: UILabel!
  
  @IBOutlet private var landingTypeLabel: UILabel!
  @IBOutlet private var landingLocationLabel: UILabel!
  @IBOutlet private var landingSuccessLabel: UILabel!
  
  @IBOutlet private var articleButton: UIButton!
  @IBOutlet private var videoButton: UIButton!
  @IBOutlet private var pressKitButton: UIButton!
  
  @IBOutlet private var patchImageView: UIImageView!
  @IBOutlet private var imageLoadingView: UIActivityIndicatorView!
  
  private let annotationIdentifier = "LaunchLocation"
  
  var launch: SpaceXLaunch? {
    didSet {
      if let launch = self.launch {
        self.configureForLaunch(launch)
      }
    }
  }
  
  // SingleImageLoading conformance
  var imageLoadTask: URLSessionTask?
  
  //MARK: - View Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.launchSiteMap.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: self.annotationIdentifier)
    
    if let launch = self.launch {
      self.configureForLaunch(launch)
    }
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    self.imageLoadTask?.cancel()
  }
  
  //MARK: - Configuration from model
  
  private func configureForLaunch(_ launch: SpaceXLaunch) {
    guard self.launchDetailsLabel != nil else {
      // This is not ready to be configured.
      return
    }
    
    self.title = UserVisibleString.launchTitleString(for: launch.flightNumber, and: launch.rocket.name)
    self.launchDetailsLabel.text = launch.details
    
    self.pressKitButton.isHidden = (launch.links.pressKit == nil)
    self.articleButton.isHidden = (launch.links.article == nil)
    self.videoButton.isHidden = (launch.links.video == nil)
    
    let launchSucceeded = launch.launchSucceeded
    self.launchSuccessLabel.spc_configureForSuccess(launchSucceeded)
    self.launchSuccessLabel.text = UserVisibleString.launchStatusString(for: launchSucceeded)
    self.launchDateLabel.text = UserVisibleString.longLaunchDateString(for: launch.launchDate)
    
    self.launchBoosterReuseLabel.text = UserVisibleString.boosterRecycledString(for: launch.reusedLaunchVehicle)
    
    let landingSucceeded = launch.landingSucceeded
    self.landingSuccessLabel.spc_configureForSuccess(landingSucceeded)
    self.landingSuccessLabel.text = UserVisibleString.landingStatusString(for: landingSucceeded)
    
    if let landingTypeName = launch.landingType?.displayName {
      self.landingTypeLabel.isHidden = false
      self.landingTypeLabel.text = UserVisibleString.landingTargetString(for: landingTypeName)
    } else {
      self.landingTypeLabel.isHidden = true
    }
    
    if let landingLocationName = launch.landingVehicle?.displayName {
      self.landingLocationLabel.isHidden = false
      self.landingLocationLabel.text = landingLocationName
    } else {
      self.landingLocationLabel.isHidden = true
    }
    
    self.setupMap(for: launch.launchSite.site.coordinate,
                  title: launch.launchSite.site.displayName)
    
    self.loadImage(for: launch.links.missionPatchImage)
  }
  
  func setupMap(for coordinate: CLLocationCoordinate2D,
                title: String) {
    let distance: Double = 1000
    let region = MKCoordinateRegionMakeWithDistance(coordinate,
                                                    distance,
                                                    distance)
    let regionToSet = self.launchSiteMap.regionThatFits(region)
    self.launchSiteMap.setRegion(regionToSet, animated: false)
    
    let annotation = MKPointAnnotation()
    annotation.coordinate = coordinate
    annotation.title = title    
    self.launchSiteMap.addAnnotation(annotation)
  }
  
  //MARK: - Link handling
  
  private func loadWebpage(from urlString: String?) {
    guard
      let string = urlString,
      let url = URL(string: string) else {
        return
    }
    
    let safariVC = SFSafariViewController(url: url)
    self.navigationController?.pushViewController(safariVC, animated: true)
  }
  
  //MARK: - Actions
  
  @IBAction private func pressKitButtonTapped() {
    self.loadWebpage(from: launch?.links.pressKit)
  }
  
  @IBAction private func videoButtonTapped() {
    self.loadWebpage(from: launch?.links.video)
  }
  
  @IBAction private func articleButtonTapped() {
    self.loadWebpage(from: launch?.links.article)
  }
}

//MARK: - Single Image Loading

extension LaunchViewController: SingleImageLoading {
  
  var targetImageView: UIImageView! {
    return self.patchImageView
  }
  
  var loadingView: UIActivityIndicatorView! {
    return self.imageLoadingView
  }
  
}

extension LaunchViewController: MKMapViewDelegate {
  
  func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    guard annotation is MKPointAnnotation else {
      // This is some other kind of annotation we don't want to mess with
      return nil
    }
    
    guard let view = mapView.dequeueReusableAnnotationView(withIdentifier: self.annotationIdentifier, for: annotation) as? MKMarkerAnnotationView else {
      assertionFailure("Could not dequeue annotation")
      return nil
    }
    
    view.animatesWhenAdded = true
    
    // Forces the title to always show
    view.titleVisibility = .visible
    return view
  }
}
