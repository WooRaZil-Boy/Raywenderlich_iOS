//
//  UIViewController+rx.swift
//  Combinestagram
//
//  Created by 근성가이 on 2018. 3. 30..
//  Copyright © 2018년 Underplot ltd. All rights reserved.
//

import UIKit
import RxSwift

extension UIViewController {
    func alert(title: String, text: String?) -> Completable { //alert Rx
        return Completable.create { [weak self] completable in
            let alertVC = UIAlertController(title: title, message: text, preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "Close", style: .default, handler: {_ in
                completable(.completed) //Completable emit
            }))
            self?.present(alertVC, animated: true, completion: nil)
            return Disposables.create { //메모리 해제되면서 dismiss
                self?.dismiss(animated: true, completion: nil)
            }
        }
    }
}
