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
    
    init() { //DataModel 객체가 생성되자 마자 Checklists.plist를 로드한다.
        //DataModel은 super class가 없으므로 따로 super.init()를 할 필요 없다.
        loadChecklists()
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
