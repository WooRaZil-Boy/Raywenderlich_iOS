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
import RealmSwift

class SetupViewController: UIViewController {
  var setPassword = false

  // MARK: - View controller life-cycle

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    if setPassword {
        encryptRealm() //암호화된 Realm 생성
    } else {
        detectConfiguration() //default Realm이거나, 이미 암호화된 Realm 존재
    }
  }

  // Modify default configuration with unencrypted file path
  private func detectConfiguration() {
    if TodoRealm.encrypted.fileExists { //암호화된 Realm 파일이 있는 지 확인한 후,
        askForPassword() //있다면 암호를 입력받아 해당 Realm을 가져온다.
    } else { //없다면 기본 Realm을 가져온다.
        Realm.Configuration.defaultConfiguration = Realm.Configuration(fileURL: TodoRealm.plain.url)
        //기본 구성 Realm 파일을 설정
        showToDoList() //todo 목록 화면으로 이동
    }
  }

  // MARK: - Open encrypted Realm

  private func askForPassword() { //암호 확인
    userInputAlert("Enter a password to open the encrypted todo file", isSecure: true) { [weak self] password in
      self?.openRealm(with: password)
    }
  }

  // Modify default configuration with encrypted file path and a key
  private func openRealm(with password: String) {
    //Add password to the default configuration
    Realm.Configuration.defaultConfiguration = Realm.Configuration(fileURL: TodoRealm.encrypted.url, encryptionKey: password.sha512)
    //암호화 Configuration을 default로 설정. 이후, Configuration 없이 생성되는 Realm 인스턴스는 모두 암호화 구성을 사용.
    
    do {
        _ = try Realm() //위에서 default를 encrypted Realm으로 설정하였기에, 암호화된 Realm이 생성된다.
        showToDoList()
    } catch let error as NSError {
        print(error.localizedDescription)
        askForPassword() //암호 재 입력
    }
  }

  // MARK: - Encrypt existing realm

  // here we show how to copy a Realm over to a new configuration and delete an existing Realm file
  private func encryptRealm() {
    userInputAlert("Create a password to encrypt your to do list", isSecure: false) { [weak self] password in
      // copy to a new location, encrypt, and delete old data
        //alert에서 password를 입력하면
        autoreleasepool { //Realm 파일 복사가 끝나면, 모든 객체와 참조가 한 번에 해제된다.
            let plainConfig = Realm.Configuration(fileURL: TodoRealm.plain.url)
            //plain Realm의 Configuration 으로
            let realm = try! Realm(configuration: plainConfig)
            //새로운 Realm 생성
            
            try! realm.writeCopy(toFile: TodoRealm.encrypted.url, encryptionKey: password.sha512)
            //지정된 키로 암호화된 복사본을 만든다. 생성된 Realm을 encrypted Realm의 URL 위치로 암호화해 복사한다.
            //String+sha512.swift의 코드로 문자열을 SHA512 형식으로 암호화할 수 있다.
            //암호화된 바이트는 키로 사용할 수 있다.
        }
        
        do {
            //Delete old file
            //암호화하여 복사하였으므로, 이전의 plain Realm은 삭제해도 무방하다.
            let files = FileManager.default.enumerator(at: try Path.documents(), includingPropertiesForKeys: [])!
            //Documents 폴더의 파일을 열거해 가져온다.
            
            for file in files.allObjects {
                guard let url = file as? URL, url.lastPathComponent.hasPrefix("mytodo.") else { continue } //mytodo. 파일을 모두 찾아야 하므로 return이 아닌 continue
                //Realm 생성시, 메타 파일과 다른 폴더가 함께 생생되므로 이러한 데이터들 모두 삭제해야 한다.
                //mytodo.realm을 삭제하려면, mytodo로 시작하는 모든 파일을 삭제해야 한다. p.152
                
                try FileManager.default.removeItem(at: url) //해당 파일 삭제
            }
        } catch let err {
            fatalError("Failed deleting unencrypted Realm: \(err)")
        }
        
        self?.detectConfiguration() //작업 완료 후 todo Controller로 다시 보낸다.
    }
  }

  // MARK: - Navigation

  private func showToDoList() {
    let list = storyboard!.instantiateViewController(withIdentifier: "ToDoNavigationController")
    UIView.transition(with: view.window!, duration: 0.33, options: .transitionFlipFromLeft, animations: {
      self.view.window!.rootViewController = list
    }, completion: nil)
  }
}


