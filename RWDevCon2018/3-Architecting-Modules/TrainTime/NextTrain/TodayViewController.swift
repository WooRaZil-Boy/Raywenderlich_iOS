/// Copyright (c) 2017 Razeware LLC
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

import UIKit
import NotificationCenter
import InfoService

class TodayViewController: UIViewController, NCWidgetProviding {
  
  @IBOutlet weak var label: UILabel!

  let model = Model()
  var nextRun: (TrainLine, LineSchedule.Run)? = nil

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    model.lines.forEach { line in
      model.schedule(forId: line.lineId, completion: { [weak self] schedule in
        guard let strongSelf = self else {
          return
        }

        schedule.schedule.forEach { run in
          strongSelf.checkRunIfItsNext(run, line: line)
        }
      })
    }
  }

  func checkRunIfItsNext(_ run: LineSchedule.Run, line: TrainLine) {
    guard run.departs > Date() else {
      return
    }

    guard let latestRun = self.nextRun else {
      self.nextRun = (line, run)
      self.updateOnMain()
      return
    }

    if run.departs < latestRun.1.departs {
      self.nextRun = (line, run)
      self.updateOnMain()
    }
  }

  func updateOnMain() {
    DispatchQueue.main.async { [weak self] in
      guard let strongSelf = self else {
        return
      }

      strongSelf.updateLabel()
    }
  }

  func updateLabel() {
    if let (line, run) = nextRun {
      let formatter = DateFormatter()
      formatter.dateStyle = .none
      formatter.timeStyle = .short
      let time = formatter.string(from: run.departs)
      let train = line.name
      self.label.text = "Next train: \(train) (\(run.train)): @ \(time)"
    } else {
      self.label.text = "No train information at this time."
    }
  }

  func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
    // Perform any setup necessary in order to update the view.
    
    // If an error is encountered, use NCUpdateResult.Failed
    // If there's no update required, use NCUpdateResult.NoData
    // If there's an update, use NCUpdateResult.NewData
    
    completionHandler(NCUpdateResult.newData)
  }
}

//extension을 만들어 다양한 기능을 추가할 수 있다(위젯 등).

//Create a "Next Up" Today Extension
//Project Editor에서 "+" 버튼을 눌러 새 target을 설정한다.
//이 후, iOS > Application Extension > Today Extension 선택
//생성시, 해당 스키마를 활성화할지 묻는데, Activate 선택. (이렇게하면 위젯을 실행하는 시뮬레이터를 쉽게 시작할 수 있다)




//Fix some issues
//일반적으로 서버에서 데이터를 가져와서 위젯을 업데이트하지만, 여기에서는 포함된 JSON 파일에서 데이터가 로드된다.
//따라서 해당 JSON 파일들의 File Inspector에서 Target Membership란에 NextTrain extension을 추가해 줘야 한다.

//Project Editor에서 NextTrain extension에서 사용하는 모듈(InfoService)를 추가해 줘야 한다.
//Deployment Info > App Extensions > Allow app extension API only에 체크해야 한다(앱 확장 설정).
//InfoService가 Helper 모듈을 사용하므로, Helper 모듈에 대해서도 똑같이 적용시켜 줘야 한다.
//그래야 extension 기능에 안전하지 않은 프레임 워크를 추가하는 것에 대한 경고가 사라진다.

//마지막으로, 해당 프레임워크들이 extension에 link가 되어야 한다.
//Project Editor에서 NextTrain 타겟 선택
//Linked Frameworks and Libraries에서 + 버튼 선택해 새 프레임워크 추가
//Helpers.framework, InfoService.framework 선택




//Take a look at launch times
//모듈화가 항상 완벽한 해결책은 아니다. 많은 프레임워크로 분리하는 것의 한 가지 단점은
//동적 프레임워크가 앱 시작 시에 라이브러리가 로드되고 처리되면서 자원을 소모한다는 것이다.
//이를 완화시키는 방법 중 하나는 정적 라이브러리를 사용하는 것이다.

//실행 단추에서, TrainTime 스키마를 선택한 후 Edit Scheme를 선택해 설정 메뉴로 들어간다.
//Run > Arguments > Environment Variables에서 + 버튼을 눌러 새 변수를 추가해 준다.
//name은 DYLD_PRINT_STATISTICS, value는 1로 추가하고 앱을 빌드하면, 콘솔 창에서 통계 자료를 볼 수 있다.
//dylid(dynamic library)를 static library로 바꾸면 로딩 시간을 줄일 수 있다.
//실행할 때마다, 캐시가 쌓이므로 전체적인 로딩 시간을 줄이들기는 한다.
