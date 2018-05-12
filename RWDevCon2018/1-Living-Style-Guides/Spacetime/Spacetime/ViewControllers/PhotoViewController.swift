//
//  PhotoViewController.swift
//  Spacetime
//
//  Created by Ellen Shapiro on 3/20/18.
//  Copyright © 2018 RayWenderlich.com. All rights reserved.
//

import UIKit
import SpacetimeUI //프레임워크 불러오기

class PhotoViewController: UIViewController {
  
  var currentRover: NASAMarsRover!
  
  var imageLoadTask: URLSessionTask?

  @IBOutlet var photoImageView: UIImageView!
  @IBOutlet var loadingView: UIActivityIndicatorView!
  @IBOutlet var descriptionLabel: UILabel!
  @IBOutlet var dateLabel: UILabel!
  @IBOutlet var cameraStackView: UIStackView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.title = self.currentRover.name
    
    for (index, camera) in currentRover.cameras.enumerated() {
//      let button = UIButton()
//      button.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
//      button.setTitleColor(.blue, for: .normal)
        let button = BorderedButton()
      
      button.setTitle(camera.fullName, for: .normal)
      button.tag = index
      cameraStackView.addArrangedSubview(button)
      button.addTarget(self,
                       action: #selector(tapped(_:)),
                       for: .touchUpInside)
      
      // All rovers have a navigation camera
      if camera.name == "NAVCAM" {
        self.loadMostRecentPhoto(using: camera)
      }
    }
  }
  
  private func loadMostRecentPhoto(using camera: NASARoverCamera) {
    self.descriptionLabel.text = UserVisibleString.loading
    self.photoImageView.image = nil
    self.dateLabel.text = nil
    self.loadingView.startAnimating()
    NASAAPIController.fetchMostRecentPhoto(for: self.currentRover,
                                           takenWith: camera,
                                           errorCompletion: {
                                            [weak self]
                                            error in
                                            self?.loadingView.stopAnimating()
                                            self?.descriptionLabel.text = error.localizedDescription
                                           },
                                           successCompletion: {
                                            [weak self]
                                            photo in
                                            self?.setup(for: photo)
                                           })
  }

  private func setup(for photo: NASARoverPhoto) {
    self.loadImage(for: photo.imageURLString)
    self.selectButton(for: photo.camera)
    self.descriptionLabel.text = UserVisibleString.mostRecentPhoto(for: photo.camera.fullName)
    self.dateLabel.text = UserVisibleString.takenOn(earthDate: photo.earthDate, sol: photo.martianSol)
    UIView.animate(withDuration: 0.2) {
      self.view.layoutIfNeeded()
    }
  }
  
  func selectButton(for camera: NASARoverCamera) {
    guard
      let index = self.currentRover.cameras.index(where: { $0.fullName == camera.fullName }),
      let button = self.cameraStackView.arrangedSubviews[index] as? UIButton else {
        return
    }
    
    button.isSelected = true
  }
  
  @objc func tapped(_ sender: UIButton) {
    for view in cameraStackView.arrangedSubviews as! [UIButton] {
      view.isSelected = (view.tag == sender.tag)
    }
    
    self.imageLoadTask?.cancel()

    let camera = self.currentRover.cameras[sender.tag]
    self.loadMostRecentPhoto(using: camera)
  }
}

extension PhotoViewController: SingleImageLoading {
  
  var targetImageView: UIImageView! {
    return self.photoImageView
  }
}
