//
//  ViewController.swift
//  BubbleTeaFinder
//
//  Created by 근성가이 on 2017. 1. 1..
//  Copyright © 2017년 근성가이. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    // MARK: - Properties
    private let filterViewControllerSegueIdentifier = "toFilterViewController"
    fileprivate let venueCellIdentifier = "VenueCell"
    
    var coreDataStack: CoreDataStack!
    var fetchRequest: NSFetchRequest<Venue>!
    var asyncFetchRequest: NSAsynchronousFetchRequest<Venue>! //비동기 Fetch //실제로는 NSPersistentStoreRequest의 하위클래스
    var venues: [Venue] = []
    
    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    
//        guard let model = coreDataStack.managedContext.persistentStoreCoordinator?.managedObjectModel, let fetchRequest = model.fetchRequestTemplate(forName: "FetchRequest") as? NSFetchRequest<Venue> else { //coreDataStack.managedContext가 유일한 public //data model editor에서 추가한 fetchRequest
//            return
//        }
//        
//        self.fetchRequest = fetchRequest //이렇게 하면 immutable이라서 검색 시에 오류가 난다.
        
        let batchUpdate = NSBatchUpdateRequest(entityName: "Venue") //NSBatchUpdateRequest 한 번에 하나씩 업데이트 하는 것이 아닌 여러 개 한 번에 업데이트 할 때. //메모리에 로드하지 않고 업데이트 //메일 서비스에서 모두 읽음 등 //NSBatchDeleteRequest를 이용해서 메모리에 로드하지 않고 대량 삭제를 구현할 수도 있다. //유효성을 확인할 수 없다. //managedContext에 결과가 반영되지 않는다.
        batchUpdate.propertiesToUpdate = [#keyPath(Venue.favorite): true] //업데이트 하려는 속성과 값
        
        batchUpdate.affectedStores = coreDataStack.managedContext.persistentStoreCoordinator?.persistentStores
        batchUpdate.resultType = .updatedObjectsCountResultType //업데이트 개수 리턴
        
        do {
            let batchResult = try coreDataStack.managedContext.execute(batchUpdate) as! NSBatchUpdateResult
            print("Records updated \(batchResult.result!)")
        } catch let error as NSError {
            print("Could not update \(error), \(error.userInfo)")
        }
        
        fetchRequest = Venue.fetchRequest() //동기화 fetch를 위해 새로 바꿀 필요는 없다. wrapper 한다고 생각.
        
        asyncFetchRequest = NSAsynchronousFetchRequest<Venue>(fetchRequest: fetchRequest) { [unowned self] (result: NSAsynchronousFetchResult) in
            guard let venues = result.finalResult else { //완료 정보
                return
            }
            
            self.venues = venues
            self.tableView.reloadData()
        }
        
        do {
            try coreDataStack.managedContext.execute(asyncFetchRequest) //fetch가 아닌 execute를 해야 한다. 비동기
            // Retuns immediately, cancel here if you want
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == filterViewControllerSegueIdentifier, let navController = segue.destination as? UINavigationController, let filterVC = navController.topViewController as? FilterViewController else {
            return
        }
        
        filterVC.coreDataStack = coreDataStack
        filterVC.delegate = self
    }
}

// MARK: - IBActions
extension ViewController {
    @IBAction func unwindToVenueListViewController(_ segue: UIStoryboardSegue) {
        
    }
}

// MARK: - Helper methods
extension ViewController {
    func fetchAndReload() {
        do {
            venues = try coreDataStack.managedContext.fetch(fetchRequest)
            tableView.reloadData()
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
}

// MARK: - UITableViewDataSource
extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return venues.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: venueCellIdentifier, for: indexPath)
        let venue = venues[indexPath.row]
        cell.textLabel?.text = venue.name
        cell.detailTextLabel?.text = venue.priceInfo?.priceCategory
        
        return cell
    }
}

// MARK: - FilterViewControllerDelegate
extension ViewController: FilterViewControllerDelegate {
    func filterViewController(filter: FilterViewController, didSelectPredicate predicate: NSPredicate?, sortDescriptor: NSSortDescriptor?) {
        fetchRequest.predicate = nil
        fetchRequest.sortDescriptors = nil
        fetchRequest.predicate = predicate
        
        if let sr = sortDescriptor {
            fetchRequest.sortDescriptors = [sr]
        }
    
        fetchAndReload()
    }
}


