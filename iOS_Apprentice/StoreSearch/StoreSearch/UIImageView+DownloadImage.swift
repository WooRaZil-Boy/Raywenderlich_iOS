//
//  UIImageView+DownloadImage.swift
//  StoreSearch
//
//  Created by 근성가이 on 2018. 3. 1..
//  Copyright © 2018년 근성가이. All rights reserved.
//

import UIKit

extension UIImageView {
    func loadImage(url: URL) -> URLSessionDownloadTask {
        let session = URLSession.shared //URLSession :: 캐싱, 쿠키 등 웹 관련 기본 설정에 사용
        let downloadTask = session.downloadTask(with: url) { [weak self] url, response, error in
            //dataTask와 비슷하지만, 다운로드한 파일을 메모리에 보관하지 않고 디스크 임시 위치에 저장한다.
            //핸들러에 dataTask에선 data를 return한 것과 달리 downloadTask는 다운로드한 파일에 접근할 수 있는 local url return
            if error == nil, let url = url, let data = try? Data(contentsOf: url), let image = UIImage(data: data) { //url에서 data 로드, data에서 image 생성
                //여러개의 if 문으로 중첩 시킬 수 있지만, 하나의 if문 에 모든 내용을 포함해 줄 수 있다.
                DispatchQueue.main.async { //UI를 변경하기 때문에 메인 스레드에서 진행해야 한다.
                    if let weakSelf = self { //이미지를 서버에서 다운로드를 완료 했을 때, 해당 이미지뷰가 존재하지 않을 수 있다.
                        //다운로드에 시간이 걸리기 때문에, 도중에 다른 이벤트를 실행하면서 imageView의 메모리가 해제될 수 있다.
                        //클로저는 값을 캡쳐하므로, 이런 경우에도 self(여기서는 imageView)에 접근할 수 있다.
                        //하지만 그런 경우, strong reference가 생겨 메모리가 낭비되므로 캡쳐 목록에 weak self를 추가해 줘야 한다.
                        //캡쳐목록[]에 weak self를 추가하면 weak reference로 self를 캡쳐하므로 메모리 누수를 막을 수 있다.
                        weakSelf.image = image
                    }
                }
            }
        }
        
        downloadTask.resume() //downloadTask 시작
        
        return downloadTask //필요한 경우 취소할 수 있게 downloadTask를 반환해 준다.
    }
}

//이 앱은 검색 결과, 똑같은 이미지가 많다. 이런 경우, 다운로드를 여러 번 하지 않도록 캐싱해주는 것이 필요하다.
//URLSession은 이미 캐싱이 구현되어 있어 다른 설정을 하지 않아도 알아서 캐싱한다.
//캐싱된 데이터는 오래 지속되지 않으며, 메모리가 부족한 경우, iOS에서 강제로 삭제하는 경우도 있다.
//URLCache, URLSessionConfiguration를 설정해 디스크에 캐시하거나 더 많은 옵션을 설정해 줄 수 있다.
