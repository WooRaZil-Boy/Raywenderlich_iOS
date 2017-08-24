//
//  DataModel.swift
//  Checklists
//
//  Created by 근성가이 on 2016. 11. 2..
//  Copyright © 2016년 근성가이. All rights reserved.
//

import Foundation

class DataModel {
    //MARK: - Propertise
    var lists = [Checklist]()
    var indexOfSelectedChecklist: Int {
        get {
            return UserDefaults.standard.integer(forKey: "ChecklistIndex")
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: "ChecklistIndex")
            UserDefaults.standard.synchronize() //UserDefault 정보는 계속해서 바뀌는데, 실제 데이터베이스에 저장되는 것은 홈버튼을 눌러야 되기 때문에 중간에 강제 종료해서 데이터가 저장되지 않는 경우에는 맞지 않아서 crash 가 날 수 있다. 따라서 동기화 시켜줘야 한다. 
        }
    }
    
    init() {
        loadChecklists()
        registerDefaults()
        handleFirstTime()
    }
}

//MARK - Data
extension DataModel {
    func documentsDirectory() -> URL { //App sandBox 경로 불러오기 - 다른 어플에서는 접근할 수 없는 고유 공간
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        
        return paths[0]
    }
    
    func dataFilePath() -> URL { //file://
        return documentsDirectory().appendingPathComponent("Checklists.plist")
    }
    
    func saveChecklists() {
        let data = NSMutableData() //값의 변경이 일어나므로 MutalbleData
        let archiver = NSKeyedArchiver(forWritingWith: data) //NSCoder로 plist 생성
        archiver.encode(lists, forKey: "Checklists") //items를 키 값으로 인코딩 //ChecklistItem이 인코딩 가능하도록 구현해 주어야 한다.
        archiver.finishEncoding() //인코딩 완료
        data.write(to: dataFilePath(), atomically: true) //경로에 저장
    }
    
    func loadChecklists() {
        let path = dataFilePath() //데이터가 저장된 경로를 불러온다.
        if let data = try? Data(contentsOf: path) { //경로에서 데이터를 불러온다. //값 변경이 없으므로 Data
            let unarchiver = NSKeyedUnarchiver(forReadingWith: data)
            lists = unarchiver.decodeObject(forKey: "Checklists") as! [Checklist]
            unarchiver.finishDecoding() //디코딩 완료
            
            sortChecklists()
        }
    }
    
    class func nextChecklistItemID() -> Int {
        let userDefaults = UserDefaults.standard
        let itemID = userDefaults.integer(forKey: "ChecklistItemID")
        userDefaults.set(itemID + 1, forKey: "ChecklistItemID")
        userDefaults.synchronize() //UserDefaults의 변경사항을 바로 저장하도록
        
        return itemID
    }
    
    func registerDefaults() {
        let dictionary: [String: Any] = ["ChecklistIndex": -1, "FirstTime": true, "ChecklistItemID": 0]
        UserDefaults.standard.register(defaults: dictionary) //키가 없을 시 dictionary 값을 가져온다 //UserDefaults default 설정
    }
    
    func handleFirstTime() {
        let userDefaults = UserDefaults.standard
        let firstTime = userDefaults.bool(forKey: "FirstTime")
        
        if firstTime {
            let checklist = Checklist(name: "List")
            lists.append(checklist)
            indexOfSelectedChecklist = 0
            userDefaults.set(false, forKey: "FirstTime")
            userDefaults.synchronize()
        }
    }
}

//MARK: - Sort
extension DataModel {
    func sortChecklists() {
        lists.sort(by: { checklist1, checklist2 in
            return checklist1.name.localizedStandardCompare(checklist2.name) == .orderedAscending }) //대소문자 구분없이 locale 따라 정렬
    }
}
