//
//  DataModel.swift
//  Checklists
//
//  Created by 근성가이 on 2018. 2. 5..
//  Copyright © 2018년 근성가이. All rights reserved.
//

import Foundation

class DataModel { //데이터 모델만을 따로 관리할 객체를 따로 만드는 것이 좋다.
    var lists = [Checklist]() //Array<Checklist>() 같은 표현이다.
    var indexOfSelectedChecklist: Int { //computed property
        get { //indexOfSelectedChecklist 값을 읽을 때 반환
            
            return UserDefaults.standard.integer(forKey: "ChecklistIndex")
        }
        
        set { //indexOfSelectedChecklist 값을 설정할 때 실행 된다.
            UserDefaults.standard.set(newValue, forKey: "ChecklistIndex")
            UserDefaults.standard.synchronize() //동기화
            //위의 동기화를 하지 않는 경우, UserDefaults에는 value가 저장되었지만, plist에 저장 되지 않은 경우(충돌로 인한 강제 종료) 앱을 시작하자 마자 충돌이 난다.
        }
    } //이렇게 computed property으로 구현하면 다른 객체에서 접근할 때 캡슐화가 된다.
    //코드가 더 명료해지고, 중복이 줄어든다.
    //나중에 데이터베이스에 UserDefaults 데이터를 저장하려 한다면, DataModel에서 변경을 할 수 있다.
    
    //여기서는 UserDefaults로 단순한 Integer 값만 저장하지만, 복원을 하는 API가 따로 있다.
    //https://www.raywenderlich.com/117471/state-restoration-tutorial
    
    init() { //DataModel 객체가 생성되자 마자 Checklists.plist를 로드한다.
        //DataModel은 super class가 없으므로 따로 super.init()를 할 필요 없다.
        loadChecklists()
        registerDefaults()
        handleFirstTime()
    }
    
    func registerDefaults() { //처음 앱을 실행하거나 지웠다가 다시 설치한 경우에는 UserDefaults의 값이 없어서 Error가 난다.
        //그 경우를 방지하기 위해 UserDefaults에 기본 값을 설정해 준다.
        let dictionary: [String: Any] = ["ChecklistIndex": -1, "FirstTime": true] //FirstTime으로 앱을 처음 시작한 경우, 리스트가 아닌 편집 화면으로 시작하도록
        //Any로 여러가지 변수형을 한 번에 담을 수 있다.
        UserDefaults.standard.register(defaults: dictionary) //기본값으로 설정. 값이 있는 경우에는 덮어쓰지 않는다.
    }
    
    func handleFirstTime() {
        let userDefaults = UserDefaults.standard
        let firstTime = userDefaults.bool(forKey: "FirstTime") //FirstTime의 값을 가져온다.
        
        if firstTime { //처음으로 앱을 실행시
            let checklist = Checklist(name: "List") //List 이름의 checklist 생성
            lists.append(checklist)
            indexOfSelectedChecklist = 0 //첫 번째 checklist를 선택해서 편집화면으로 가도록
            
            userDefaults.set(false, forKey: "FirstTime") //FirstTime의 값을 false로 설정
            userDefaults.synchronize()
        }
    }
}

//MARK: - Documents
extension DataModel {
    func documentsDirectory() -> URL { //sandbox 경로 가져온다. //저장할 경로
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        //sandbox 내의 Documents 폴더
        
        return paths[0]
    } //모든 iOS 앱은 Document 안에 sandbox라는 내부 저장 공간을 가지고 있다. //시뮬레이터의 경우 finder를 쓰는 것이 더 편하다.
    
    func dataFilePath() -> URL {
        return documentsDirectory().appendingPathComponent("Checklists.plist")
    }
    
    func saveChecklists() { //loadChecklistItems와 비교
        let encoder = PropertyListEncoder() //리스트 변환 인코더 생성 //인코딩 되려면 객체가 Encodable를 구현해야 한다.
        
        do { //오류 처리위한 블록
            let data = try encoder.encode(lists) //인코더로 items를 저장 가능한 binarydata로 바꾼다.
            
            try data.write(to: dataFilePath(), options: Data.WritingOptions.atomic) //지정된 경로에 데이터 쓰기
        } catch { //try 구문에서 에러가 발생하면, catch로 넘어온다.
            print("Error encoding item array!")
        }
    }
    
    func loadChecklists() { //saveChecklistItems와 비교
        let path = dataFilePath() //파일이 저장된 경로를 불러온다.
        
        if let data = try? Data(contentsOf: path) { //불러온 Checklists.plist를 Data 객체로 변환
            //try? 로 되어 있으므로 실패하면 nil을 반환하고 앱이 종료되지 않는다(앱이 처음 시작할 경우).
            let decoder = PropertyListDecoder() //디코더 생성
            
            do {
                lists = try decoder.decode([Checklist].self, from: data) //디코더로 binarydata를 Array로 바꾼다.
            } catch { //try 구문에서 에러가 발생하면, catch로 넘어온다.
                print("Error decoding item array!")
            }
        }
    }
    
    //.plist는 앱의 추가정보 제공. xml 형식으로 저장된다. (데이터 저장을 위해서 사용할 수도 있다.)
    //Swift4 부터 Codable 이라는 새 프로토콜이 있다. 이전의 NSCoder와 비슷.
}

//Sandbox 구성
//Documents :: 앱이 데이터를 저장할 폴더
//Library :: 캐시와 기본 설정 파일
//SystemData :: 운영체제에서 앱과 관련된 시스템 정보 저장
//tmp :: 임시 파일. Documents 지저분해 지는 것을 방지. 운영체제가 수시로 삭제한다.
