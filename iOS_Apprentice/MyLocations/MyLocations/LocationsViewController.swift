//
//  LocationsViewController.swift
//  MyLocations
//
//  Created by 근성가이 on 2018. 2. 22..
//  Copyright © 2018년 근성가이. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

class LocationsViewController: UITableViewController {
    var managedObjectContext: NSManagedObjectContext! //Appdelegate의 managedObjectContext를 DI
    var locations = [Location]()
    
    lazy var fetchedResultsController: NSFetchedResultsController<Location> = {
        //delegate로 tableView가 업데이트 되었을 경우를 알 수 있지만, CoreData를 사용하면 수동으로 설정할 필요없다.
        //NSFetchedResultsController를 구현하고 delegate를 통해 CoreData에서 가져온 결과를 배열에 넣지 않고 컨트롤러에서 바로 읽을 수 있다.
        //lazy로 선언되었으므로 처음 사용될 떄 초기화 된다. //메모리를 절약할 수 있다.
        //NSFetchedResultsController<Location>로 선언해, 페치된 결과로 가져올 객체 유형을 미리 알려줘야 한다.
        let fetchRequest = NSFetchRequest<Location>() //NSFetchRequest는 데이터 저장소에서 가져올 객체를 설명 //제네릭
        //찾으려는 객체, 담으려는 객체로 NSFetchReques를 생성한다.
        
        let entity = Location.entity()
        fetchRequest.entity = entity //엔티티 추가
        
        let sort1 = NSSortDescriptor(key: "category", ascending: true) //정렬 //카테고리 순 오름차순
        let sort2 = NSSortDescriptor(key: "date", ascending: true) //정렬 //날짜 순 오름차순
        fetchRequest.sortDescriptors = [sort1, sort2] //정렬 방법 NSFetchRequest에 추가
        //카테고리별로 정렬, 이후 날짜 순 정렬
        fetchRequest.fetchBatchSize = 20 //한 번에 가져올 객체의 수 20개 씩
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext, sectionNameKeyPath: "category", cacheName: "Locations")
        //fetchedResultsController는 실제로 보여지는 객체만 가져와서 메모리를 줄일 수 있다.
        //cacheName은 NSFetchedResultsController가 검색 결과를 캐시하는 데 사용하는 고유명
        //NSFetchedResultsController가 데이터베이스와 연동할 필요없이 캐시된 데이터를 사용해 속도를 높인다.
        //sectionNameKeyPath로 카테고리별로 섹션을 생성한다.
        
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
    }()
    
    deinit { //해당 뷰 컨트롤러의 메모리가 해제될 때 deinit가 호출된다.
        fetchedResultsController.delegate = nil //fetchedResultsController로 페치한 경우에는, 데이터가 변경될 때마다 delegate가 호출된다.
        //따라서 NSFetchedResultsController가 더 이상 필요하지 않을 때는 알림 표시를 막기 위해 delegate를 nil로 설정하는 것이 좋다.
    } //실제로 LocationsViewController는 탭바의 최상위 뷰 컨트롤러이므로 메모리가 해제되지는 않는다.
    //Defensive programming으로 deinit를 사용
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = editButtonItem //에디트 버튼 추가
        //스토리보드에서 구현하려면 따로 메서드 구현해야 한다.
        
//        NSFetchedResultsController<Location>.deleteCache(withName: "Locations") //캐시 삭제
        //CoreData 버그 때문에 p.672 참고. //캐시를 삭제해 버리기 때문에 좋은 해결책은 아니다.
        performFetch()
    }
    
    // MARK:- Private methods
    func performFetch() {
        do { //모든 Location 객체를 가져와서 날짜순 정렬
            try fetchedResultsController.performFetch() //데이터 저장소에서 오브젝트의 참조를 가져오는 것을 fetching이라 한다.
        } catch {
            fatalCoreDataError(error)
        }
    }
}

//MARK: - Navigation
extension LocationsViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EditLocation" { //수정으로 LocationDetailsViewController 연결되는 경우
            let controller = segue.destination as! LocationDetailsViewController
            controller.managedObjectContext = managedObjectContext
            
            if let indexPath = tableView.indexPath(for: sender as! UITableViewCell) {
                //현재 뷰 컨트롤러에서 터치한 셀의 인덱스 패스를 가져온다.
                //Objective-C에는 모든 객체를 의미하는 id가 있다. 모든 객체는 id타입이 될 수 있다.
                //Swift는 타입에 엄격하지만 Objective-C 프레임워크를 쓰는 경우가 많아 이와 호환되는 자료형이 필요한데, 그것이 Any
                //Any는 범용적인 객체 자료형이고, Any?는 모든 객체 옵셔널이 될 수 있다.
                //여기서는 트리거 된 sender가 UITalbeViewCell(정확히는 LocationCell).
                //버튼에서는 UIBarButtonItem
                let location = fetchedResultsController.object(at: indexPath) //fetchedResultsController에서 indexPath에 해당하는 정보 가져오기
                controller.locationToEdit = location //location 객체 전달
            }
        }
    }
}

//MARK: - UITableViewDataSource
extension LocationsViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections!.count //fetchedResultsController의 sections로 섹션 정보를 가져온다
        //fetchedResultsController가 category로 섹션을 생성했으므로 sections!로 옵셔널을 해제해도 된다.
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        //fetchedResultsController의 sections로 섹션 정보를 가져온다
        
        return sectionInfo.numberOfObjects //섹션의 행의 수
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionInfo = fetchedResultsController.sections![section]
        //fetchedResultsController의 sections로 섹션 정보를 가져온다
        
        return sectionInfo.name
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath) as! LocationCell //LocationCell로 캐스팅
        let location = fetchedResultsController.object(at: indexPath) //fetchedResultsController에서 indexPath에 해당하는 정보 가져오기
        cell.configure(for: location) //이 메서드에서도 셀을 업데이트 해도 되지만, 셀 자체에서 해결하는 것이 더 적절하다.
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) { //이 메서드를 구현하면 스와이프 삭제가 가능해 진다.
        if editingStyle == .delete {
            let location = fetchedResultsController.object(at: indexPath)
            //fetchedResultsController에서 indexPath에 해당하는 정보 가져오기
            managedObjectContext.delete(location)
            
            do {
                try managedObjectContext.save() //저장
            } catch {
                fatalCoreDataError(error)
            }
        }
    }
}

//MARK: - UITableViewDelegate
extension LocationsViewController {
    
}

//MARK: - NSFetchedResultsControllerDelegate
extension LocationsViewController: NSFetchedResultsControllerDelegate {
    //NSFetchedResultsController에 변경이 있는 경우, NSFetchedResultsControllerDelegate로 전달된다.
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) { //NSFetchedResultsController 변경 시작
        print("*** controllerWillChangeContent")
        tableView.beginUpdates() //시작
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) { //행 변경
        switch type {
        case .insert:
            print("*** NSFetchedResultsChangeInsert (object)")
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            print("*** NSFetchedResultsChangeDelete (object)")
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            print("*** NSFetchedResultsChangeUpdate (object)")
            if let cell = tableView.cellForRow(at: indexPath!) as? LocationCell {
                let location = controller.object(at: indexPath!) as! Location //컨트롤러의 객체정보 가져와서
                cell.configure(for: location) //셀 업데이트
            }
        case .move:
            print("*** NSFetchedResultsChangeMove (object)")
            tableView.deleteRows(at: [indexPath!], with: .fade)
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) { //섹션 변경
        switch type {
        case .insert:
            print("*** NSFetchedResultsChangeInsert (section)")
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            print("*** NSFetchedResultsChangeDelete (section)")
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        case .update:
            print("*** NSFetchedResultsChangeUpdate (section)")
        case .move:
            print("*** NSFetchedResultsChangeMove (section)")
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) { //NSFetchedResultsController 변경 종료
        print("*** controllerDidChangeContent")
        tableView.endUpdates() //종료
    }
}
