/// Copyright (c) 2018 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import Foundation
import UIKit

#if EXAMS_V2_0
  typealias MigrationCompleted = (() -> Void)?

  class Navigator {
    weak var controller: UINavigationController?

    init(controller: UINavigationController) {
      self.controller = controller
    }

    func navigateToMainScene() {
      guard let controller = controller, let storyboard = controller.storyboard else { return }

      if let migrationTask = MigrationTask.first(in: RealmProvider.exams.realm) {
        //보류중인 MigrationTask가 있는지 확인하고, 있다면
        switch migrationTask.name { //이름을 확인해서
        case MigrationTask.TaskType.askForExamResults.rawValue:
          //askForExamResults가 있는 경우
          navigateToMigrationExamStatus(controller)
          //exam result를 마이그레이션할 사용자 정의 UI 표시
          return
        default: break
        }
        return
      }
      //이런 접근법은 몇 가지 특징을 가지고 있다.
      //• 사용자가 맞춤 마이그레이션 중에 앱을 종료하면 다음에 exam을 시작할 때 계속해서 마이그레이션 UI가 표시된다.
      //• 대기중인 단일 마이그레이션 작업이 두 개 이상 있는 경우 사용자가 메인 UI에 도달하기 전에 UI가 순차적으로 표시된다.
      //• MigrationTask.first(in :)는 우선 순위별로 작업을 정렬할 수 있도록 다음 작업을 가져오는 논리를
      //  완전히 래핑하거나 마이그레이션 진행 방법에 대한 다른 결정을 수행한다.
      
      // proceed to main app UI
      let mainVC = ExamsViewController.createWith(storyboard: storyboard)
      controller.setViewControllers([mainVC], animated: true)
    }
  }

extension Navigator {
  func navigateToMigrationExamStatus(_ ctr: UINavigationController) {
    //MigrateExamStatusViewController를 인스턴스화하고,
    //파라미터의 navigationController를 사용하여 화면에 표시한다.
    let migrateExamsVC = MigrateExamStatusViewController.createWith { [weak self] in
      //사용자가 해당 화면에서 완료를 누르면 호출되는 콜백 클로저
      self?.navigateToMainScene()
    }
    ctr.setViewControllers([migrateExamsVC], animated: true)
  }
}

#endif

//이전 버전에서 까지 Navigator의 역할은 기본 앱의 UI를 표시하는 것이었다.
