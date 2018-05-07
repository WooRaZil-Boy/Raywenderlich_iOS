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

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?
}

//Realm Platform은 Realm Database를 사용하는 응용 프로그램을 위한 다중 플랫폼 데이터 동기화 솔루션을
//제공하는 서버 소프트웨어이다. 앱에서 Realm 데이터베이스를 사용하는 경우 몇 줄의 코드로 서버에 연결하여
//앱을 실행하는 모든 기기에서 실시간 데이터를 전송할 수 있다. p.255
//유사한 솔루션에 비해 Realm Platform의 장점은 다음과 같다.
//• 자동 데이터 동기화 : Realm은 서버 연결을 유지 관리하고, 필요에 따라 모든 데이터 변경 사항을 동기화한다.
//• 실시간 양방향 동기화 : Realm은 로컬 변경 사항을 클라우드로 전송하는 것 이상의 역할을 한다.
//  또한, 모든 장치 및 플랫폼에서 모든 변경 사항을 동기화한다.
//• 데이터 변환 없음 : JSON, Codable 혹은 다른 데이터 변환을 사용하지 않아도 된다. Realm API에서 가져올 때
//  동기화된 데이터를 서버에서 원활하게 가져올 수 있다.
//• 충돌 없음 : End-to-End 데이터 인프라로 Realm이 동기화 충돌을 피하도록 신경쓴다/
//• 다중 플랫폼 실시간 동기화 : iPhone, Android, tvOS, macOS등 응용 프로그램을 동일한 서버 인스턴스에 연결할 수 있으며
//  사용자는이 플랫폼에서 모든 장치에 대한 데이터를 즉시 가져올 수 있다.
//• 자체 호스팅 또는 PaaS : 이미 호스팅 된 Realm Cloud에 연결하여 시작하거나, 자체 인프라에서 Realm Platform을
//  자체 호스팅하고, 사내 데이터에 대한 모든 액세스 권한을 가질 수 있다.

//https://cloud.realm.io
//인스턴스에서 사용하지 않는 인증 방법은 비활성화 시키는 것이 좋다.
//Realm Studio와, Realm Flatform을 같이 사용한다.

//• Admin users : 서버의 모든 파일에 액세스하고 수정할 수 있다.
//• Regular users: : 개인 사용자 폴더에서 파일을 생성, 액세스 및 수정할 수 있다.
//  또한 다른 사용자가 공유 파일을 공동 작업하도록 초대 할 수 있다.
//  이 사용자는 nobody 사용자가 소유 한 파일에 액세스 할 수도 있다.
//여기서는 Regular로 생성한 chatuser 사용자로 인스턴스에 연결하고 공유 DB의 데이터를 동기화한다.




//Accessing synced data
//서버에서 동기화된 Realm을 여는 두 가지 방법이 있다.
//• 서버에서 전체 DB를 동기화한다. : 단순히 서버에서 Realm을 복제하고 클라이언트와 동기화하는 것.
//  일반적으로 비효율적이기에 자주 사용하지는 않는다.
//• 해당 데이터가 응용 프로그램에 필요할 때만 Realm DB의 일부를 실시간으로 동기화한다. : 부분 동기화
//  주로 사용하게 되는 방법이다.

//Local notification subscription
//Realm notification을 사용해서 UI를 업데이트 할 수 있다. p.261

//Remote sync subscription
//서버 동기화는 Local notification과 매우 유사하게 작동한다. p.262
//SyncSubscription<Object>로 구독이 활성화되어 있는 동안 레코드에 대한 모든 변경 사항이 서버에서 동기화된다.
//구독을 취소하면, 즉시 로컬에 캐시된 데이터가 삭제된다.
//로컬에서 서버의 Realm에 쿼리하여 일치하는 모든 객체를 가져와 로컬 Realm에 저장한다. 서버나 Realm Cloud에 연결된
//다른 클라이언트에서 새 사용자를 추가한 경우, 변경 사항이 로컬 DB에 반영되어 변경 사항 알림이 전송된다.

//앱의 전체적인 로직은 p.263
//Chat - ChatRoom - ChatItem의 구조이다. 
