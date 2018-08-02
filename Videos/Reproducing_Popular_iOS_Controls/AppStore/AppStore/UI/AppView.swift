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

import Foundation
import UIKit

class AppView: UIView {
  
  //MARK: Data
  private let appViewType: AppViewType
  var viewModel: AppViewModel
  
  var backgroundType: BackgroundType = .light {
    didSet {
      titleLabel.textColor = backgroundType.titleTextColor
      subtitleLabel.textColor = backgroundType.subtitleTextColor
      buttonSubtitleLabel.textColor = backgroundType.subtitleTextColor
    }
  }
  
  //MARK: UI
  fileprivate var iconImageView = UIImageView()
  fileprivate var titleLabel = UILabel()
  fileprivate var getButton = UIButton(type: UIButton.ButtonType.roundedRect)
  fileprivate var subtitleLabel = UILabel()
  fileprivate var buttonSubtitleLabel = UILabel()
  fileprivate var labelsView = UIView()
  fileprivate var detailsStackView = UIStackView()
  
  init?(_ viewModel: AppViewModel?) {
    guard let viewModel = viewModel else { return nil }
    self.viewModel = viewModel
    self.appViewType = viewModel.appViewType
    super.init(frame: .zero)
    setUpViews()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setUpViews() {
    
    configureViews()
    configureLabelsView()
    backgroundColor = .clear
    
    switch appViewType {
    case .horizontal:
      addDetailViews()
    case .featured:
      addFeaturedTopViews()
    case .none:
      break
    }
  }
  
  private func configureViews() {
    iconImageView.configureAppIconView(forImage: viewModel.iconImage, size: appViewType.imageSize)
    
    titleLabel.configureAppHeaderLabel(withText: viewModel.name)
    titleLabel.textColor = backgroundType.titleTextColor
    
    subtitleLabel.configureAppSubHeaderLabel(withText: viewModel.category.description.uppercasedFirstLetter)
    subtitleLabel.textColor = backgroundType.subtitleTextColor
    
    buttonSubtitleLabel.configureTinyLabel(withText: "In-App Purchases")
    buttonSubtitleLabel.textColor = backgroundType.subtitleTextColor
    
    getButton.roundedActionButton(withText: viewModel.appAccess.description)
  }
  
  private func configureLabelsView() {
    
    labelsView.addSubview(subtitleLabel)
    subtitleLabel.pinToSuperview(forAtrributes: [.leading, .width, .bottom])
    
    labelsView.addSubview(titleLabel)
    titleLabel.pinToSuperview(forAtrributes: [.leading, .width, .top])
    titleLabel.pin(attribute: .bottom, toView: subtitleLabel, toAttribute: .top, multiplier: 1.0, constant: -2)
  }
  
  fileprivate func addHorizontalLabelsAndButton() {
    addSubview(labelsView)
    addSubview(getButton)
  }
  
  fileprivate func configureHorizontalLabelsAndButton() {
    labelsView.pinToSuperview(forAtrributes: [.leading, .bottom])
    labelsView.pinToSuperview(forAtrributes: [.width], multiplier: 0.7)
    
    getButton.pinToSuperview(forAtrributes: [.trailing, .bottom])
    getButton.pin(attribute: .width, toView: nil, toAttribute: .notAnAttribute, constant: 76.0)
  }
  
  fileprivate func addPurchaseAvailableLabelIfNeeded() {
    if viewModel.hasInAppPurchase && buttonSubtitleLabel.superview == nil {
      addSubview(buttonSubtitleLabel)
      buttonSubtitleLabel.pin(toView: getButton, attributes: [.centerX])
      buttonSubtitleLabel.pin(attribute: .top, toView: getButton, toAttribute: .bottom, constant: 3.0)
    }
    
    buttonSubtitleLabel.isHidden = !viewModel.hasInAppPurchase
  }
}

//MARK: Featured Top View Layout
extension AppView {
  fileprivate func addFeaturedTopViews() {
    addSubview(iconImageView)
    addHorizontalLabelsAndButton()
    
    configureHorizontalLabelsAndButton()
    configureFeaturedTopViews()
  }
  
  fileprivate func configureFeaturedTopViews() {
    iconImageView.pinToSuperview(forAtrributes: [.top, .leading])
    iconImageView.pin(attribute: .height, toView: nil, toAttribute: .notAnAttribute, constant: appViewType.imageSize)
    iconImageView.pin(attribute: .width, toView: iconImageView, toAttribute: .height)
    configureHorizontalLabelsAndButton()
  }
  
  func configure(with viewModel: AppViewModel) {
    self.viewModel = viewModel
    
    configureViews()
    switch appViewType {
    case .horizontal:
      configureDetailViews()
    case .featured:
      configureFeaturedTopViews()
    case .none:
      break
    }
  }
}

//MARK: Small Detail View Layout
extension AppView {
  fileprivate func addDetailViews() {
    addSubview(iconImageView)
    addSubview(labelsView)
    
    addSubview(getButton)
    configureDetailViews()
  }
  
  fileprivate func configureDetailViews() {
    backgroundColor = .white
    
    iconImageView.pinToSuperview(forAtrributes: [.height], multiplier: 0.7)
    iconImageView.pin(attribute: .width, toView: iconImageView, toAttribute: .height)
    iconImageView.pinToSuperview(forAtrributes: [.leading, .centerY], constant: 0.0)
    
    labelsView.pin(attribute: .leading, toView: iconImageView, toAttribute: .trailing, multiplier: 1.0, constant: 15)
    labelsView.pin(attribute: .trailing, toView: getButton, toAttribute: .leading, multiplier: 1.0, constant: -10)
    labelsView.pinToSuperview(forAtrributes: [.centerY])
    
    getButton.pinToSuperview(forAtrributes: [.centerY])
    getButton.pinToSuperview(forAtrributes: [.trailing], constant: -1.0)
    getButton.pin(attribute: .width, toView: nil, toAttribute: .notAnAttribute, constant: 76.0)
  }
}

