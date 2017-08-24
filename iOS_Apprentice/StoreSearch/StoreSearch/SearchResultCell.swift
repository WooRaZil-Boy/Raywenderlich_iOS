//
//  SearchResultCell.swift
//  StoreSearch
//
//  Created by 근성가이 on 2016. 12. 8..
//  Copyright © 2016년 근성가이. All rights reserved.
//

import UIKit

class SearchResultCell: UITableViewCell {
    //MARK: - Properties
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var artworkImageView: UIImageView!
    
    var downloadTask: URLSessionDownloadTask?

    override func awakeFromNib() { //init?(coder)보다 awakeFromNib()이 낫다. 예를 들어 outlet의 경우 init안에서 nil이지만 awakeFromNib에서는 객체로 존재한다. //viewController의 viewDidLoad()와 비슷하다고 보면 된다.
        super.awakeFromNib()
        let selectedView = UIView(frame: CGRect.zero)
        selectedView.backgroundColor = UIColor(red: 20/255, green: 160/255, blue: 160/255, alpha: 0.5)
        selectedBackgroundView = selectedView
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func prepareForReuse() { //셀이 재사용 될 때
        super.prepareForReuse()
        downloadTask?.cancel() //이전 이미지를 아직 다운로드 중이라면 취소
        downloadTask = nil
    }
}

extension SearchResultCell {
    func configure(for searchResult: SearchResult) {
        nameLabel.text = searchResult.name
        
        if searchResult.artistName.isEmpty {
            artistNameLabel.text = NSLocalizedString("Unknown", comment: "Unknown artist name")
        } else {
            artistNameLabel.text = String(format: NSLocalizedString("ARTIST_NAME_LABEL_FORMAT", comment: "Format for artist name label"), searchResult.artistName, searchResult.kindForDisplay()) //string format을 이용한 문자열도 지역화 할 수 있다. 
        }
        
        artworkImageView.image = UIImage(named: "Placeholder")
        if let smallURL = URL(string: searchResult.artworkSmallURL) {
            downloadTask = artworkImageView.loadImage(url: smallURL)
        }
    }
}
