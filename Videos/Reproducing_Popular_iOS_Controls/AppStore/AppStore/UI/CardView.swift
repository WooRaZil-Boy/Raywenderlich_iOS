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

class CardView: UIView {
  
  var appView: AppView?
  var cardModel: CardViewModel
  var collectionAppViews: [AppView] = []
  
  let shadowView = UIView()
  let containerView = UIView()
  var backgroundImageView = UIImageView()
  private var tableView = UITableView()
  private let titleLabel = UILabel()
  private let subtitleLabel = UILabel()
  private let featuredTitleLabel = UILabel()
  private let descriptionLabel = UILabel()
  
  var leftConstraint:NSLayoutConstraint = NSLayoutConstraint()
  var rightConstraint:NSLayoutConstraint = NSLayoutConstraint()
  var topConstraint:NSLayoutConstraint = NSLayoutConstraint()
  var bottomConstraint:NSLayoutConstraint = NSLayoutConstraint()
  
  init(cardModel: CardViewModel, appView: AppView?) {
    self.cardModel = cardModel
    self.appView = appView
    
    super.init(frame: .zero)
    
    self.appView?.backgroundType = cardModel.backgroundType
    leftConstraint = NSLayoutConstraint(item: containerView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 0)
    rightConstraint = NSLayoutConstraint(item: containerView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: 0)
    topConstraint = NSLayoutConstraint(item: containerView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0)
    bottomConstraint = NSLayoutConstraint(item: containerView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0)
    
    setUpViews()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func addShadow() {
    
    shadowView.layer.cornerRadius = 20
    shadowView.layer.shadowColor = UIColor.black.cgColor
    shadowView.layer.shadowOpacity = 0.2
    shadowView.layer.shadowRadius = 10
    shadowView.layer.shadowOffset = CGSize(width: -1, height: 2)
  }
  
  func removeShadow() {
    
    shadowView.layer.shadowColor = UIColor.clear.cgColor
    shadowView.layer.shadowOpacity = 0
    shadowView.layer.shadowRadius = 0
    shadowView.layer.shadowOffset = CGSize(width: 0, height: 0)
  }
  
  func updateLayout(for viewMode: CardViewMode) {
    switch viewMode {
    case .card:
      leftConstraint.constant = 20
      rightConstraint.constant = -20
      topConstraint.constant = 15
      bottomConstraint.constant = -15
      addShadow()
    case .full:
      leftConstraint.constant = 0
      rightConstraint.constant = 0
      topConstraint.constant = 0
      bottomConstraint.constant = 0
      removeShadow()
    }
  }
  
  func convertContainerViewToCardView() {
    
    updateLayout(for: .card)
    
    containerView.layer.cornerRadius = 20
    containerView.layer.masksToBounds = true
  }
  
  func convertContainerViewToFullScreen() {
    
    updateLayout(for: .full)
    
    containerView.layer.cornerRadius = 0
    containerView.layer.masksToBounds = true
  }
  
  func setUpViews() {
    backgroundColor = .clear
    addSubview(shadowView)
    shadowView.backgroundColor = .white
    addSubview(containerView)
    containerView.backgroundColor = .white
    containerView.translatesAutoresizingMaskIntoConstraints = false
    
    if cardModel.viewMode == .card {
      convertContainerViewToCardView()
    } else {
      convertContainerViewToFullScreen()
    }
    
    shadowView.pin(toView: containerView, attributes: [.left, .right, .top, .bottom])
    
    addConstraints([leftConstraint, rightConstraint, topConstraint, bottomConstraint])
    
    switch cardModel.viewType {
    case .appOfTheDay:
      addBackgroundImage(withApp: true)
      addFeaturedTitle()
      
    case .appArticle:
      addBackgroundImage(withApp: false)
      addTopTitleLabels()
      addDescriptionLabel()
      
    case .appCollection:
      addTopTitleLabels()
      addAppCollection()
    }
  }
  
  private func addDescriptionLabel() {
    
    configureDescriptionLabel()
    containerView.addSubview(descriptionLabel)
    
    descriptionLabel.pinToSuperview(forAtrributes: [.leading], constant: 20.0)
    descriptionLabel.pinToSuperview(forAtrributes: [.trailing], constant: -40.0)
    descriptionLabel.pinToSuperview(forAtrributes: [.bottom], constant: -15.0)
  }
  
  private func configureDescriptionLabel() {
    guard let description = cardModel.description else { return }
    
    descriptionLabel.configureAppSubHeaderLabel(withText: description)
    descriptionLabel.textColor = cardModel.backgroundType.subtitleTextColor
  }
  
  private func addBackgroundImage(withApp hasApp: Bool) {
    
    configureBackgroundImage()
    
    backgroundImageView.contentMode = .center
    
    containerView.addSubview(backgroundImageView)
    backgroundImageView.pinEdgesToSuperview()
    
    guard let appView = appView, hasApp else { return }
    containerView.addSubview(appView)
    
    appView.pinToSuperview(forAtrributes: [.leading, .top], multiplier: 1.0, constant: 25.0)
    appView.pinToSuperview(forAtrributes: [.trailing, .bottom], multiplier: 1.0, constant: -25.0)
  }
  
  private func configureBackgroundImage() {
    guard let backgroundImage = cardModel.backgroundImage else { return }
    backgroundImageView.image = backgroundImage
  }
  
  private func addFeaturedTitle() {
    
    featuredTitleLabel.layer.shadowOffset = CGSize(width: -1, height: 1)
    featuredTitleLabel.layer.shadowOpacity = 0.1
    featuredTitleLabel.layer.shadowRadius = 5
    
    containerView.addSubview(featuredTitleLabel)
    
    featuredTitleLabel.pinToSuperview(forAtrributes: [.leading, .centerY], constant: 20.0)
    featuredTitleLabel.pinToSuperview(forAtrributes: [.width], multiplier: 0.6)
    
    configureFeaturedTitle()
  }
  
  private func configureFeaturedTitle() {
    featuredTitleLabel.configureHeroLabel(withText: "APP\nOF THE\nDAY")
    featuredTitleLabel.textColor = .heroTextColor
  }
  
  private func addAppCollection() {
    
    tableView.delegate = self
    tableView.dataSource = self
    tableView.separatorStyle = .singleLine
    tableView.separatorInset = UIEdgeInsets(top: 0, left: 65, bottom: 0, right: 0)
    tableView.isScrollEnabled = false
    tableView.registerCell(GenericTableViewCell<AppView>.self)
    
    containerView.addSubview(tableView)
    
    tableView.pinToSuperview(forAtrributes: [.leading], constant: 20.0)
    tableView.pin(attribute: .top, toView: titleLabel, toAttribute: .bottom, constant: 15.0)
    tableView.pinToSuperview(forAtrributes: [.trailing, .bottom], constant: -20.0)
    
    tableView.reloadData()
  }
  
  private func addTopTitleLabels() {
    
    configureTopTitleLabels()
    
    containerView.addSubview(subtitleLabel)
    containerView.addSubview(titleLabel)
    
    subtitleLabel.pinToSuperview(forAtrributes: [.leading, .top], constant: 20.0)
    subtitleLabel.pinToSuperview(forAtrributes: [.trailing], constant: -20.0)
    
    titleLabel.pinToSuperview(forAtrributes: [.leading], constant: 20.0)
    titleLabel.pinToSuperview(forAtrributes: [.trailing], constant: -20.0)
    titleLabel.pin(attribute: .top, toView: subtitleLabel, toAttribute: .bottom, constant: 5.0)
  }
  
  private func configureTopTitleLabels() {
    guard let subtitle = cardModel.subtitle,
      let title = cardModel.title else { return }
    
    subtitleLabel.configureSubHeaderLabel(withText: subtitle.uppercased())
    subtitleLabel.textColor = cardModel.backgroundType.subtitleTextColor
    
    titleLabel.configureHeaderLabel(withText: title)
    titleLabel.textColor = cardModel.backgroundType.titleTextColor
  }
  
  private func setUpCallOutConstraints() {
    guard let app = appView else { return }
    
    app.pinToSuperview(forAtrributes: [.leading, .top], constant: 20.0)
    app.pinToSuperview(forAtrributes: [.trailing], constant: -20.0)
    app.pinToSuperview(forAtrributes: [.bottom])
  }
  
  func configure(with viewModel: CardViewModel) {
    
    self.cardModel = viewModel
    
    if let appViewModel = viewModel.app {
      self.appView?.configure(with: appViewModel)
    } else {
      self.appView = nil
    }
    
    switch cardModel.viewType {
    case .appOfTheDay:
      hide(views: [self.titleLabel, self.subtitleLabel, self.descriptionLabel, self.tableView])
      addBackgroundImage(withApp: true)
      addFeaturedTitle()
      
    case .appArticle:
      hide(views: [self.featuredTitleLabel, self.tableView])
      addBackgroundImage(withApp: false)
      addTopTitleLabels()
      addDescriptionLabel()
      
    case .appCollection:
      hide(views: [self.featuredTitleLabel, self.descriptionLabel, self.backgroundImageView])
      addTopTitleLabels()
      addAppCollection()
      tableView.reloadData()
    }
  }
  
  func hide(views: [UIView]) {
    views.forEach{ $0.removeFromSuperview() }
  }
  
  func show(views: [UIView]) {
    views.forEach{ $0.isHidden = false }
  }
}

extension CardView: UITableViewDelegate, UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    guard let appCollectionData = cardModel.appCollection else { return 0 }
    return appCollectionData.count >= 4 ? 4 : appCollectionData.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let appCell = tableView.dequeueReusableCell(forIndexPath: indexPath) as GenericTableViewCell<AppView>
    
    guard let collectionViewModel = cardModel.appCollection?[indexPath.row] else { return appCell }
    
    guard let appCellView = appCell.cellView else {
      let appView = AppView(collectionViewModel)
      appCell.cellView = appView
      return appCell
    }
    
    appCellView.configure(with: collectionViewModel)
    
    return appCell
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 70
  }
  
  //MARK: This is how we get rid of the last tableViewCell separator
  func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    return UIView()
  }
}


