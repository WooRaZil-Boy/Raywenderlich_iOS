/*
 * Copyright (c) 2016-2017 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import Foundation
import Accounts
import Unbox

import RealmSwift
import RxSwift
import RxRealm
import RxCocoa

class ListPeopleViewModel {

  private let bag = DisposeBag()

  let list: ListIdentifier
  let apiType: TwitterAPIProtocol.Type

  // MARK: - Input
  let account: Driver<TwitterAccount.AccountStatus>

  // MARK: - Output
  let people = Variable<[User]?>(nil)

  // MARK: - Init
  init(account: Driver<TwitterAccount.AccountStatus>,
       list: ListIdentifier,
       apiType: TwitterAPIProtocol.Type = TwitterAPI.self) {

    self.account = account
    self.list = list
    self.apiType = apiType

    bindOutput()
  }

  func bindOutput() {
    //observe the current account status
    let currentAccount = account
      .filter { account in
        switch account {
        case .authorized: return true
        default: return false
        }
      }
      .map { account -> AccessToken in
        switch account {
        case .authorized(let acaccount):
          return acaccount
        default: fatalError()
        }
      }
      .distinctUntilChanged()

    //fetch list members
    currentAccount.asObservable()
      .flatMapLatest(apiType.members(of: list))
      .map { users in
        return (try? unbox(dictionaries: users, allowInvalidElements: true) as [User]) ?? []
      }
      .bind(to: people)
      .disposed(by: bag)
  }
}

//MVVM은 Model-View-ViewModel의 약자로 MVC와는 조금 다르다.
//MVC는 간단히 구현 가능한 패턴이지만, 앱이 커질수록 단일 컨트롤러에 많은 코드가 추가되게 되서 관리가 어려워 지게 된다. p.379
//MVVM은 MVC의 이 문제를 해결한다(하지만, MVVM이 무조건 MVC보다 나은 패턴이라 말할 수는 없다). p.380
//MVVM은 View Model이 아키텍처에서 센터 역할을 한다. 비즈니스 로직을 관리하고, model과 view 사이에서 통신한다.
//MVVM은 다음과 같은 규칙을 따른다.
//• Model은 다른 클래스들이 데이터 변경에 대한 알림을 보낼 수는 있지만, 다른 클래스와 직접 통신하지 않는다.
//• View Model은 Model과 통신하고, 데이터를 View Controller에 표시한다.
//• View Controller는 View Life Cycle을 처리할 때, View Model과 View와만 통신하고 데이터를 UI요소에 바인딩한다.
//• View는 View Controller에 이벤트를 알린다(MVC 처럼).
//MVVㅡ의 View Model은 MVC에서 Controller가 하는 일을 똑같이 수행하기도 하고 아니기도 한다.
//MVVM은 View Controller를 View와 함께 그룹화하여, View Controller에서 View를 제어하지 않는 코드(MVC의 문제점)를
//떼어 낸다. 즉, MVVC에서 View Controller는 View를 제어하는 코드만 가진다.
//MVVM의 또 다른 장점은 테스트하기 좋는 점이다. View Controller와 View 모두에 대해 명확히 테스트 할 수 있다.
//View Model은 presentation layer와 완전히 분리되어 있고, 플랫폼 간(iOS, macOS, tvOS..)에 재사용할 수도 있다.

//하지만, 모든 것이 View Model에서 관리된다고 생각하면 안 된다. View Model이 Data와 Screen 사이의
//가장 중요한 요소이지만, 네트워크, 캐시 등의 따로 떼어낼 수 있는 부분은 다른 클래스로 분리해야 한다.
//한 가지 좋은 방법은, View Model이 init 혹은 Life cycle동안 필요한 모든 객체를 DI 하는 것이다.
//즉, stateful API class 혹은 persistence layer object같이 긴 수명의 객체를 View Model에서
//다른 View Model로 전달한다. p.381
//각 파일의 크기가 작아진다는 장점 외에도 다음과 같은 장점이 있다.
//• View Controller만이 유일하게 View를 제어할 수 있다. MVVM은 Rx와 매우 잘 어울린다.
//  Observable에 UI요소를 바인딩하는 것이 이의 핵심 요소이다.
//• View Model은 명확한 input -> output 패턴이고 미리 정의된 입력을 제공하기에 예상 출력을 테스트하기 쉽다. p.382
//• 목업 View Model을 생성할 수 있어 View Controller를 시각적으로 테스트하기 쉬워진다. p.382

//이 앱은 다중 플랫폼 프로젝트이다. 트위터 기반 앱으로 미리 정의된 사용자 목록을 사용해 트윗을 표시한다.
//Model 및  View Model의 모든 코드가 특정 플랫폼의 UI 프레임 워크에 의존하지 않기 때문에 재사용 가능하다.
//여기서, Common Classes, Data Entities 등의 폴더에 있는 파일들은 iOS, Mac에서 공동으로 사용가능하다.
//전체적인 아키텍처는 p.384. 하늘색이 View, 파란색이 View Controller, 주황색이 View Model, 빨간색이 Model
//밑에서 부터 네트워킹 - View Model - View Controller 순으로 구현.
