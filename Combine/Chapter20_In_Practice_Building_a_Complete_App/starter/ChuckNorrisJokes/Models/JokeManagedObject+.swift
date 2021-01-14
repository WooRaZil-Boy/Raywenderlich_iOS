//
//  JokeManagedObject+.swift
//  ChuckNorrisJokes
//
//  Created by youngho on 2021/01/12.
//  Copyright © 2021 Scott Gardner. All rights reserved.
//

import Foundation
import SwiftUI
import CoreData
import ChuckNorrisJokesModel
//Core Data, SwiftUI, model module을 가져온다.

extension JokeManagedObject {
  //자동 생성된 JokeManagedObject 클래스를 확장한다.
  static func save(joke: Joke, inViewContext viewContext: NSManagedObjectContext) {
    //전달된 view context를 사용하여 전달된 joke을 저장하는 static method를 추가한다.
    //Core Data에 익숙하지 않다면, view context를 Core Data의 scratchpad라고 생각할 수 있다.
    //이것은 main queue와 연결되어 있다.
    guard joke.id != "error" else { return }
    //문제가 발생했을 때 나타내는 error joke의 ID는 "error"이다.
    //이때는 joke을 저장할 이유가 없으므로, 진행하기 전에 error joke인지 확인한다.
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(
      entityName: String(describing: JokeManagedObject.self)
    )
    //JokeManagedObject entity 이름에 대한 fetch request을 생성한다.
    fetchRequest.predicate = NSPredicate(format: "id = %@", joke.id)
    //전달된 joke과 동일한 ID의 jokes으로 fetch하도록, fetch request의 predicate를 filter한다.
    
    if let results = try? viewContext.fetch(fetchRequest),
       let existing = results.first as? JokeManagedObject {
      //viewContext를 사용하여 fetch request을 실행한다.
      existing.value = joke.value
      existing.categories = joke.categories as NSArray
      //성공하면 joke가 이미 존재하는 것이므로, 전달된 joke의 값으로 update한다.
    } else {
      let newJoke = self.init(context: viewContext)
      newJoke.id = joke.id
      newJoke.value = joke.value
      newJoke.categories = joke.categories as NSObject
      //그렇지 않으면 joke이 아직 존재하지 않는 경우이므로, 전달된 joke의 값으로 새 joke를 만든다.
    }
    
    do {
      try viewContext.save()
      //viewContext를 저장한다.
    } catch {
      fatalError("\(#file), \(#function), \(error.localizedDescription)")
    }
  }
}

extension Collection where Element == JokeManagedObject, Index == Int {
  func delete(at indices: IndexSet, inViewContext viewContext: NSManagedObjectContext) {
    //전달된 view context를 사용하여 전달된 indices에서 objects를 삭제하는 method를 구현한다.
    indices.forEach { index in
      viewContext.delete(self[index])
      //indices를 반복하고, viewContext에서 delete(_:)를 호출하여 self의 각 요소, 즉 JokeManagedObjects collection을 전달한다.
    }
    
    do {
      try viewContext.save()
      //context를 저장한다.
    } catch {
      fatalError("\(#file), \(#function), \(error.localizedDescription)")
    }
  }
}
