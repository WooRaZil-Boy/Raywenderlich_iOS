//
//  MainTableViewController.swift
//  iGif
//
//  Created by Junior B. on 01.02.17.
//  Copyright © 2017 Razeware LLC. All rights reserved.
//

import UIKit
import RxSwift
import SwiftyJSON

class MainTableViewController: UITableViewController {
  
  let searchController = UISearchController(searchResultsController: nil)
  let bag = DisposeBag()
  var gifs = [JSON]()
  let search = BehaviorSubject(value: "")
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    title = "iGif"
    
    searchController.searchResultsUpdater = self
    searchController.dimsBackgroundDuringPresentation = false
    definesPresentationContext = true
    tableView.tableHeaderView = searchController.searchBar
    
    search.filter { $0.characters.count >= 3 }
      .throttle(0.3, scheduler: MainScheduler.instance)
      .distinctUntilChanged()
      .flatMapLatest { query -> Observable<[JSON]> in
        return ApiController.shared.search(text: query)
          .catchErrorJustReturn([])
      }
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { result in
        self.gifs = result
        self.tableView.reloadData()
      })
      .disposed(by:bag)
  }
  
  // MARK: - Table view data source
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return gifs.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "GifCell", for: indexPath) as! GifTableViewCell
  
    let gif = gifs[indexPath.row]
    if let url = gif["images"]["fixed_height"]["url"].string {
      cell.downloadAndDisplay(gif: url)
    }
    
    return cell
  }

}

extension MainTableViewController: UISearchResultsUpdating {
  
  public func updateSearchResults(for searchController: UISearchController) {
    search.onNext(searchController.searchBar.text ?? "")
  }
  
}

//기본 프레임 워크를 Rx를 사용하여 확장할 수 있다. NSURLSession를 확장하는 앱. RxAlamofire가 따로 있긴 하다.

//RxDataSources, RxAlamofire, RxBluetoothKit 등의 rx 래퍼들이 있으며
//http://community.rxswift.org 에서 다른 라이브러리의 래퍼들을 찾아 볼 수 있다.
