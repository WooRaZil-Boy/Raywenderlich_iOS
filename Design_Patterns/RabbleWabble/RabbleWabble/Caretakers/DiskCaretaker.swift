//
//  DiskCaretaker.swift
//  RabbleWabble
//
//  Created by 근성가이 on 2019/10/29.
//  Copyright © 2019 근성가이. All rights reserved.
//

import Foundation

public final class DiskCaretaker {
    public static let decoder = JSONDecoder()
    public static let encoder = JSONEncoder()
    
    public static func save<T: Codable>(_ object: T, to fileName: String) throws {
        //Codable을 구현한 객체를 인자로 받는 제네릭 메서드
        do {
            let url = createDocumentURL(withFileName: fileName)
            //document URL을 생성
            let data = try encoder.encode(object) //인코딩
            
            try data.write(to: url, options: .atomic) //데이터 쓰기
            //temp 파일을 생성한 후 경로로 이동시킨다.
            //이 방법은 사용하는 리소스는 적고, 데이터가 손상되지 않는다.
        } catch (let error) { //오류 발생 시
            print("Save failed: Object: `\(object)`, " + "Error: `\(error)`")
            
            throw error //오류를 던진다.
        }
    }
    
    public static func retrieve<T: Codable>(_ type: T.Type, from fileName: String) throws -> T {
        //유형과 fileName이 지정된 객체를 검색
        let url = createDocumentURL(withFileName: fileName)
        return try retrieve(T.self, from: url)
    }
    
    public static func retrieve<T: Codable>(_ type: T.Type, from url: URL) throws -> T {
        //유형과 url이 지정된 객체를 검색
        do {
            let data = try Data(contentsOf: url) //data 객체 생성
            
            return try decoder.decode(T.self, from: data) //디코딩
        } catch (let error) { //오류 발생 시
            print("Retrieve failed: URL: `\(url)`, Error: `\(error)`")
            
            throw error //오류를 던진다.
        }
    }
    
    public static func createDocumentURL(withFileName fileName: String) -> URL {
        //주어진 fileName으로 document URL을 생성한다.
        let fileManager = FileManager.default
        let url = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        //Documents 디렉토리
        
        return url.appendingPathComponent(fileName).appendingPathExtension("json")
        //fileName 추가
    }
}

//DiskCaretaker는 장치의 Documents 디렉토리에서 Codable 객체를 저장하고 검색하는 방법을 제공한다.
//JSONEncoder를 사용하여 객체를 JSON 데이터로 인코딩하고
//JSONDecoder를 사용하여 JSON 데이터에서 객체로 디코딩한다.
