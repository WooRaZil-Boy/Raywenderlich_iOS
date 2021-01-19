//
//  ReadMeApp.swift
//  ReadMe
//
//  Created by youngho on 2021/01/18.
//

import SwiftUI

@main
struct ReadMeApp: App { //ContentView의 ancestor
  var body: some Scene {
    WindowGroup {
      ContentView()
        .environmentObject(Library())
        //@EnvironmentObject를 지정해 준다.
    }
  }
}
