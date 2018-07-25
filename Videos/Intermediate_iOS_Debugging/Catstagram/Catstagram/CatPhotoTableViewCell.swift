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

import UIKit

class CatPhotoTableViewCell: UITableViewCell {
  let userImageHeight:CGFloat = 30

  var photoModel: PhotoModel? = nil
  let photoCommentsView: CommentView

  var userAvatarImageView: AsyncImageView
  var photoImageView: AsyncImageView

  var userNameLabel: UILabel
  var photoLocationLabel: UILabel
  var photoTimeIntervalSincePostLabel: UILabel
  var photoLikesLabel: UILabel
  var photoDescriptionLabel: UILabel

  var userNameYPositionWithPhotoLocation: NSLayoutConstraint
  var userNameYPositionWithoutPhotoLocation: NSLayoutConstraint
  var photoLocationYPosition: NSLayoutConstraint

  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    photoCommentsView   = CommentView()

    userAvatarImageView = AsyncImageView()
    photoImageView      = AsyncImageView()

    userNameLabel                   = UILabel()
    photoLocationLabel              = UILabel()
    photoTimeIntervalSincePostLabel = UILabel()
    photoLikesLabel                 = UILabel()
    photoDescriptionLabel           = UILabel()

    userNameYPositionWithPhotoLocation    = NSLayoutConstraint()
    userNameYPositionWithoutPhotoLocation = NSLayoutConstraint()
    photoLocationYPosition                = NSLayoutConstraint()

    super.init(style: style, reuseIdentifier: reuseIdentifier)

    addSubview(photoCommentsView)
    addSubview(userAvatarImageView)
    addSubview(photoImageView)
    addSubview(userNameLabel)
    addSubview(photoLocationLabel)
    addSubview(photoTimeIntervalSincePostLabel)
    addSubview(photoLikesLabel)
    addSubview(photoDescriptionLabel)

    addShadows()

    userAvatarImageView.backgroundColor = .white
    photoImageView.backgroundColor = .lightGray
    photoImageView.clipsToBounds = true
    photoImageView.contentMode = .scaleAspectFill

    userAvatarImageView.layer.cornerRadius = userImageHeight/2.0
    userAvatarImageView.clipsToBounds = true

    photoCommentsView.translatesAutoresizingMaskIntoConstraints               = false
    userAvatarImageView.translatesAutoresizingMaskIntoConstraints             = false
    photoImageView.translatesAutoresizingMaskIntoConstraints                  = false
    userNameLabel.translatesAutoresizingMaskIntoConstraints                   = false
    photoLocationLabel.translatesAutoresizingMaskIntoConstraints              = false
    photoTimeIntervalSincePostLabel.translatesAutoresizingMaskIntoConstraints = false
    photoLikesLabel.translatesAutoresizingMaskIntoConstraints                 = false
    photoDescriptionLabel.translatesAutoresizingMaskIntoConstraints           = false
    photoCommentsView.translatesAutoresizingMaskIntoConstraints               = false

    setupConstraints()
    updateConstraints()
  }

  class func height(forPhoto photoModel: PhotoModel, with width: CGFloat) -> CGFloat {
    let headerHeight:CGFloat = 50.0
    let horizontalBuffer:CGFloat = 10.0
    let verticalBuffer:CGFloat = 5.0
    let fontSize:CGFloat = 14.0

    let photoHeight = width

    let font = UIFont.systemFont(ofSize: 14)

    let descriptionAttrString = photoModel.descriptionAttributedString(withFontSize: fontSize)
    let availableWidth = width - (horizontalBuffer * 2);

    let descriptionHeight = descriptionAttrString.boundingRect(with: CGSize(width: availableWidth, height: CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, context: nil).size.height
    let commentViewHeight = CommentView.height(forCommentFeed: photoModel.commentFeed, withWidth: availableWidth)

    return headerHeight + photoHeight + font.lineHeight + descriptionHeight + commentViewHeight + (4 * verticalBuffer)
  }

  func addShadows() {
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func prepareForReuse() {
    photoCommentsView.frame                        = CGRect.zero
    photoCommentsView.update(withCommentFeedModel: nil)

    clearImages()

    userNameLabel.attributedText                   = nil
    photoLocationLabel.attributedText              = nil
    photoLocationLabel.frame                       = CGRect.zero
    photoTimeIntervalSincePostLabel.attributedText = nil
    photoLikesLabel.attributedText                 = nil
    photoDescriptionLabel.attributedText           = nil
  }

  func clearImages() {
    userAvatarImageView.layer.contents = nil
    photoImageView.layer.contents = nil

    userAvatarImageView.image                      = placeholderAvatar()
  }

  func updateCell(with photo: PhotoModel?) {
    photoModel = photo

    guard let photoModel = photoModel else { return }

    userNameLabel.attributedText = photoModel.ownerUserProfile?.usernameAttributedString(withFontSize: 14.0)
    photoTimeIntervalSincePostLabel.attributedText = photoModel.uploadDateAttributedString(withFontSize: 14.0)
    photoLikesLabel.attributedText = photoModel.likesAttributedString(withFontSize: 14.0)
    photoDescriptionLabel.attributedText = photoModel.descriptionAttributedString(withFontSize: 14.0)

    userNameLabel.sizeToFit()
    photoTimeIntervalSincePostLabel.sizeToFit()
    photoLikesLabel.sizeToFit()
    photoDescriptionLabel.sizeToFit()

    var rect = photoDescriptionLabel.frame
    let availableWidth = bounds.size.width - 20
    rect.size = photoDescriptionLabel.sizeThatFits(CGSize(width: availableWidth, height: CGFloat.greatestFiniteMagnitude))

    photoDescriptionLabel.frame = rect
    UIImage.downloadImage(for: photoModel.url) { (image) in
      if self.photoModel == photo {
        self.photoImageView.image = image
      }
    }
    downloadAndProcessUserAvatar(forPhoto: photoModel)
    loadComments(forPhoto: photoModel)
    reverseGeocode(locationForPhoto: photoModel)
  }

  func placeholderAvatar() -> UIImage {
    return UIImage(named: "placeholder")!.makeCircularImage(with: CGSize(width: userImageHeight, height: userImageHeight))
  }

  func loadComments(forPhoto photoModel: PhotoModel) {
    if photoModel.commentFeed.numberOfItemsInFeed() > 0 {
      photoCommentsView.update(withCommentFeedModel: photoModel.commentFeed)

      var frame = photoCommentsView.frame
      let availableWidth = bounds.width - 20
      frame.size = CGSize(width: availableWidth, height: CommentView.height(forCommentFeed: photoModel.commentFeed, withWidth: availableWidth))
      photoCommentsView.frame = frame

      setNeedsLayout()
    }
  }

  func downloadAndProcessUserAvatar(forPhoto photoModel: PhotoModel) {
    UIImage.downloadImage(for: photoModel.url) { (image) in
      if self.photoModel == photoModel, let image = image {
        let size = CGSize(width: self.userImageHeight, height: self.userImageHeight)
        self.userAvatarImageView.image = image.makeCircularImage(with: size)
      }
    }
  }

  func reverseGeocode(locationForPhoto photoModel: PhotoModel) {
    photoModel.location?.reverseGeocodedLocation(completion: { [unowned self, weak photoModel = photoModel] (locationModel) in
      self.photoLocationLabel.attributedText = photoModel?.locationAttributedString(withFontSize: 14.0)
      self.photoLocationLabel.sizeToFit()

      DispatchQueue.main.async {
        self.updateConstraints()
        self.setNeedsLayout()
      }
    })
  }
}

// MARK: - CatPhotoTableViewCell
extension CatPhotoTableViewCell {
  func setupConstraints() {
    addConstraintsForAvatar()
    addConstraintsForUserNameLabel()
    addConstraintsForLocationLabel()
    addConstraintsForPhotoTimeIntervalSincePostLabel()
    addConstraintsForPhotoImageView()
    addConstraintsForLikesLabel()
    addConstraintsForDescriptionLabel()
    addConstraintsForPhotoCommentsView()
  }

  func addConstraintsForAvatar() {
    let horizontalBuffer:CGFloat = 10.0

    addConstraint(NSLayoutConstraint(item: userAvatarImageView, attribute: .left, relatedBy: .equal, toItem: userAvatarImageView.superview, attribute: .left, multiplier: 1.0, constant: horizontalBuffer))
    addConstraint(NSLayoutConstraint(item: userAvatarImageView, attribute: .top, relatedBy: .equal, toItem: userAvatarImageView.superview, attribute: .top, multiplier: 1.0, constant: horizontalBuffer))
    addConstraint(NSLayoutConstraint(item: userAvatarImageView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0.0, constant: userImageHeight))
    addConstraint(NSLayoutConstraint(item: userAvatarImageView, attribute: .height, relatedBy: .equal, toItem: userAvatarImageView, attribute: .width, multiplier: 1.0, constant: 0.0))
  }

  func addConstraintsForUserNameLabel() {
    let horizontalBuffer:CGFloat = 10.0

    addConstraint(NSLayoutConstraint(item: userNameLabel, attribute: .left, relatedBy: .equal, toItem: userAvatarImageView, attribute: .right, multiplier: 1.0, constant: horizontalBuffer))
    addConstraint(NSLayoutConstraint(item: userNameLabel, attribute: .right, relatedBy: .lessThanOrEqual, toItem: photoTimeIntervalSincePostLabel, attribute: .left, multiplier: 1.0, constant: -horizontalBuffer))

    userNameYPositionWithoutPhotoLocation = NSLayoutConstraint(item: userNameLabel, attribute: .centerY, relatedBy: .equal, toItem: userAvatarImageView, attribute: .centerY, multiplier: 1.0, constant: 0.0)
    addConstraint(userNameYPositionWithoutPhotoLocation)

    userNameYPositionWithPhotoLocation = NSLayoutConstraint(item: userNameLabel, attribute: .top, relatedBy: .equal, toItem: userAvatarImageView, attribute: .top, multiplier: 1.0, constant: -2.0)
    userNameYPositionWithPhotoLocation.isActive = false
    addConstraint(userNameYPositionWithPhotoLocation)
  }

  func addConstraintsForLocationLabel() {
    let horizontalBuffer:CGFloat = 10.0

    addConstraint(NSLayoutConstraint(item: photoLocationLabel, attribute: .left, relatedBy: .equal, toItem: userAvatarImageView, attribute: .right, multiplier: 1.0, constant: horizontalBuffer))
    addConstraint(NSLayoutConstraint(item: photoLocationLabel, attribute: .right, relatedBy: .lessThanOrEqual, toItem: photoTimeIntervalSincePostLabel, attribute: .left, multiplier: 1.0, constant: -horizontalBuffer))
    photoLocationYPosition = NSLayoutConstraint(item: photoLocationLabel, attribute: .bottom, relatedBy: .equal, toItem: userAvatarImageView, attribute: .bottom, multiplier: 1.0, constant: 2)
    photoLocationYPosition.isActive = false
    addConstraint(photoLocationYPosition)
  }

  func addConstraintsForPhotoTimeIntervalSincePostLabel() {
    let horizontalBuffer:CGFloat = 10.0

    addConstraint(NSLayoutConstraint(item: photoTimeIntervalSincePostLabel, attribute: .right, relatedBy: .equal, toItem: photoTimeIntervalSincePostLabel.superview, attribute: .right, multiplier: 1.0, constant: -horizontalBuffer))
    addConstraint(NSLayoutConstraint(item: photoTimeIntervalSincePostLabel, attribute: .centerY, relatedBy: .equal, toItem: userAvatarImageView, attribute: .centerY, multiplier: 1.0, constant: 0.0))
  }

  func addConstraintsForPhotoImageView() {
    let headerHeight:CGFloat = 50.0

    addConstraint(NSLayoutConstraint(item: photoImageView, attribute: .top, relatedBy: .equal, toItem: photoImageView.superview, attribute: .top, multiplier: 1.0, constant: headerHeight))
    addConstraint(NSLayoutConstraint(item: photoImageView, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 1.0, constant: 0.0))
    addConstraint(NSLayoutConstraint(item: photoImageView, attribute: .height, relatedBy: .equal, toItem: photoImageView, attribute: .width, multiplier: 1.0, constant: 0.0))
  }

  func addConstraintsForLikesLabel() {
    let verticalBuffer:CGFloat = 5.0
    let horizontalBuffer:CGFloat = 10.0

    addConstraint(NSLayoutConstraint(item: photoLikesLabel, attribute: .top, relatedBy: .equal, toItem: photoImageView, attribute: .bottom, multiplier: 1.0, constant: verticalBuffer))

    addConstraint(NSLayoutConstraint(item: photoLikesLabel, attribute: .left, relatedBy: .equal, toItem: photoLikesLabel.superview, attribute: .left, multiplier: 1.0, constant: horizontalBuffer))
  }

  func addConstraintsForDescriptionLabel() {
    let verticalBuffer:CGFloat = 5.0
    let horizontalBuffer:CGFloat = 10.0

    addConstraint(NSLayoutConstraint(item: photoDescriptionLabel, attribute: .top, relatedBy: .equal, toItem: photoLikesLabel, attribute: .bottom, multiplier: 1.0, constant: verticalBuffer))
    addConstraint(NSLayoutConstraint(item: photoDescriptionLabel, attribute: .left, relatedBy: .equal, toItem: photoDescriptionLabel.superview, attribute: .left, multiplier: 1.0, constant: horizontalBuffer))
    addConstraint(NSLayoutConstraint(item: photoDescriptionLabel, attribute: .width, relatedBy: .equal, toItem: photoDescriptionLabel.superview, attribute: .width, multiplier: 1.0, constant: -horizontalBuffer))
  }


  func addConstraintsForPhotoCommentsView() {
    let verticalBuffer:CGFloat = 5.0
    let horizontalBuffer:CGFloat = 10.0

    addConstraint(NSLayoutConstraint(item: photoCommentsView, attribute: .top, relatedBy: .equal, toItem: photoDescriptionLabel, attribute: .bottom, multiplier: 1.0, constant: verticalBuffer))
    addConstraint(NSLayoutConstraint(item: photoCommentsView, attribute: .left, relatedBy: .equal, toItem: photoCommentsView.superview, attribute: .left, multiplier: 1.0, constant: horizontalBuffer))
    addConstraint(NSLayoutConstraint(item: photoCommentsView, attribute: .width, relatedBy: .equal, toItem: photoCommentsView.superview, attribute: .width, multiplier: 1.0, constant: -horizontalBuffer))
  }

  override func updateConstraints() {
    super.updateConstraints()

    if let _ = photoLocationLabel.attributedText {
      userNameYPositionWithoutPhotoLocation.isActive = false
      userNameYPositionWithPhotoLocation.isActive = true
      photoLocationYPosition.isActive = true
    } else {
      userNameYPositionWithoutPhotoLocation.isActive = true
      userNameYPositionWithPhotoLocation.isActive = false
      photoLocationYPosition.isActive = false
    }
  }
}
