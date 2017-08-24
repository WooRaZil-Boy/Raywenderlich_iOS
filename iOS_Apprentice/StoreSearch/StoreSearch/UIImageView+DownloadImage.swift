//
//  UIImageView+DownloadImage.swift
//  StoreSearch
//
//  Created by 근성가이 on 2016. 12. 13..
//  Copyright © 2016년 근성가이. All rights reserved.
//

import UIKit

extension UIImageView {
    func loadImage(url: URL) -> URLSessionDownloadTask {
        let session = URLSession.shared
        let downloadTask = session.downloadTask(with: url, completionHandler: { [weak self] url, response, error in //URLSession과 비슷하지만 메모리(URLSession)가 아닌 임시로 디스크에 저장한다.
            if error == nil, let url = url, let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    if let strongSelf = self { //weak self이므로 존재할 때만. //셀이 재사용되므로??
                        strongSelf.image = image
                    }
                }
            }
        })
        
        downloadTask.resume()
        
        return downloadTask
    }
}
