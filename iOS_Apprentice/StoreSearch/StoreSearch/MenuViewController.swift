//
//  MenuViewController.swift
//  StoreSearch
//
//  Created by 근성가이 on 2018. 3. 7..
//  Copyright © 2018년 근성가이. All rights reserved.
//

import UIKit

protocol MenuViewControllerDelegate: class {
    func menuViewControllerSendEmail(_ controller: MenuViewController) //메일 보내기 로직 처리
}

class MenuViewController: UITableViewController {
    //MARK: - Properties
    weak var delegate: MenuViewControllerDelegate?

    //MARK: - ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
}

//MARK: - UITableViewDataSource
extension MenuViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true) //선택해제
        
        if indexPath.row == 0 {
            delegate?.menuViewControllerSendEmail(self)
            //MenuViewControllerd는 pop-over 되므로, pop-over가 종료되면 해당 로직을 수행할 수 없다.
            //따라서 MenuViewController의 델레게이트(DetailViewController)에서 이메일 작성을 처리해야 한다.
        }
    }
}
