/// Copyright (c) 2020 Razeware LLC
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
/// This project and source code may use libraries or frameworks that are
/// released under various Open-Source licenses. Use of those libraries and
/// frameworks are governed by their own individual licenses.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import Foundation

struct KeychainWrapperError: Error {
  var message: String?
  var type: KeychainErrorType

  enum KeychainErrorType {
    case badData
    case servicesError
    case itemNotFound
    case unableToConvertToString
  }

  init(status: OSStatus, type: KeychainErrorType) {
    self.type = type
    if let errorMessage = SecCopyErrorMessageString(status, nil) {
      self.message = String(errorMessage)
    } else {
      self.message = "Status Code: \(status)"
    }
  }

  init(type: KeychainErrorType) {
    self.type = type
  }

  init(message: String, type: KeychainErrorType) {
    self.message = message
    self.type = type
  }
}

class KeychainWrapper {
  func storeGenericPasswordFor(
    account: String,
    service: String,
    password: String
  ) throws {
    if password.isEmpty {
      try deleteGenericPasswordFor(
        account: account,
        service: service)
      return
    }

    guard let passwordData = password.data(using: .utf8) else {
      print("Error converting value to data.")
      throw KeychainWrapperError(type: .badData)
    }
    
    let query: [String: Any] = [
      //query는 속성에 따라 String을 Any 객체에 매핑하는 dictionary이다. 이 패턴은 Swift에서 C기반 API를 호출할 때 일반적이다.
      //각 속성에 대해 kSec으로 시작하는 정의된 global constant를 제공한다. 각 경우 constant를 String(실제로는 CFString)으로 캐스팅하고, 해당 속성에 대한 value을 사용한다.
      kSecClass as String: kSecClassGenericPassword,
      //첫 번째 key는 미리 정의된 constant인 kSecClassGenericPassword를 사용하여, 이 item에 대한 클래스를 generic password로 정의한다.
      kSecAttrAccount as String: account,
      //generic password item의 경우, username 필드인 account을 제공한다. 이는 method에 parameter로 전달했다.
      kSecAttrService as String: service,
      //다음으로 password에 대한 service를 설정한다. 이것은 password의 목적을 반영해야 하는 임의의 String이다(ex. "user login").
      //이것 역시 method에 parameter로 전달했다.
      kSecValueData as String: passwordData
      //마지막으로 method에 전달된 String에서 변환된 passwordData를 사용하여, item에 대한 data를 설정한다.
    ]
    
    
    let status = SecItemAdd(query as CFDictionary, nil)
    //SecItemAdd(_:_:)는 Keychain Services에 keychain 정보를 추가하도록 요청한다.
    //query를 예상 CFDictionary type으로 캐스팅한다. C API는 종종 return value를 사용하여 함수의 결과를 표시한다. 여기서 value는 OSStatus type이다.
    switch status {
    //status code의 다양한 value에 대한 switch를 작성한다.
    //하나의 value만 확인하는 switch를 사용하는 것이 이상해 보일 수 있지만, 미래에 어떤 일이 일어날 지는 누구도 알 수 없다.
    case errSecSuccess:
      //errSecSuccess는 password가 이제 keychain에 있음을 의미한다. 여기서 더 추가할 작업은 없다.
      break
    case errSecDuplicateItem: //추가
      try updateGenericPasswordFor(
        account: account,
        service: service,
        password: password)
    default:
      //status에 다른 value가 포함되어 있으면, function는 실패한 것이다.
      //KeychainWrapperError에는 SecCopyErrorMessageString(_:_:)을 사용하여, human-readable한 exception 메시지를 만드는 initializer가 포함되어 있다.
      throw KeychainWrapperError(status: status, type: .servicesError)
    }
  }
  
  func getGenericPasswordFor(
    account: String,
    service: String
  ) throws -> String {
    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrAccount as String: account,
      kSecAttrService as String: service,
      //keychain에 password를 추가할 때에는 kSecClass, kSecAttrAccount, kSecAttrService를 제공했다.
      //이제 이러한 값들을 사용하여, keychain에서 item을 찾을 수 있다.
      kSecMatchLimit as String: kSecMatchLimitOne,
      //kSecMatchLimit을 사용하여, Keychain Services에 search 결과가 단일 item임을 알려준다.
      kSecReturnAttributes as String: true,
      kSecReturnData as String: true
      //dictionary의 마지막 두 parameters는 Keychain Services에 발견된 value에 대한 모든 data와 attributes을 return하도록 지시한다.
    ]
    
    var item: CFTypeRef?
    let status = SecItemCopyMatching(query as CFDictionary, &item)
    guard status != errSecItemNotFound else {
      throw KeychainWrapperError(type: .itemNotFound)
    }
    guard status == errSecSuccess else {
      throw KeychainWrapperError(status: status, type: .servicesError)
    }
    
    guard
      let existingItem = item as? [String: Any],
      //반환된 CFTypeRef를 dictionary로 캐스팅한다.
      let valueData = existingItem[kSecValueData as String] as? Data,
      //dictionary에서 kSecValueData 값을 추출하여 Data로 캐스팅한다.
      let value = String(data: valueData, encoding: .utf8)
      //Data를 다시 String로 변환한다.
      //password를 저장 때 수행한 작업을 반대로 한다.
      else {
        //이러한 단계 중 하나라도 nil을 반환하면, data를 읽을 수 없다는 의미이므로 error를 발생시킨다.
        throw KeychainWrapperError(type: .unableToConvertToString)
    }

    return value
    //캐스팅 및 변환이 성공하면, 저장된 password가 포함된 String을 반환한다.
  }
  
  func updateGenericPasswordFor(
    account: String,
    service: String,
    password: String
  ) throws {
    guard let passwordData = password.data(using: .utf8) else {
      print("Error converting value to data.")
      return
    }
    
    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrAccount as String: account,
      kSecAttrService as String: service
    ]
    //search query는 update할 데이터를 지정한다.
    //이전에 만든 search query와 마찬가지로 attributes을 제공하지만, match limit 및 return attributes과 같은 search parameters를 사용하지 않았다.
    //따라서 이 function는 일치하는 모든 entries을 update한다.

    let attributes: [String: Any] = [
      kSecValueData as String: passwordData
    ]
    //두 번째 dictionary에는 update할 data가 포함되어 있다.
    //class에 유효한 일부 또는 모든 attributes을 지정할 수 있지만, 변경하려는 속성만 포함한다.
    //여기에서는 새 password만 지정한다.
    //그러나 service나 account에 대한 새 value을 저장하려는 경우, 해당 attributes을 설정할 수도 있다.

    let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
    guard status != errSecItemNotFound else {
      throw KeychainWrapperError(
        message: "Matching Item Not Found",
        type: .itemNotFound)
    }
    guard status == errSecSuccess else {
      throw KeychainWrapperError(status: status, type: .servicesError)
    }
    //SecItemUpdate(_:_:)는 위의 두 dictionaries의 내용을 사용하여 update를 수행한다.
    //가장 일반적인 error는 The specified attribute does not exist 이다.
    //이 error는 Keychain Services가 search query와 일치하는 항목을 찾지 못했음을 나타낸다.
  }
  
  func deleteGenericPasswordFor(
    account: String,
    service: String
  ) throws {
    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrAccount as String: account,
      kSecAttrService as String: service
    ]
    //query가 add 및 update와 비슷해 보이지만, 여기에서는 새 value을 제공하지 않는다.
    //Note: query가 delete할 item만 식별하는지 확인한다.
    //여러 items이 해당 query와 일치하는 경우, Keychain Services는 모든 항목을 deletes한다.

    let status = SecItemDelete(query as CFDictionary)
    guard status == errSecSuccess || status == errSecItemNotFound else {
      throw KeychainWrapperError(status: status, type: .servicesError)
    }
    //query를 사용하여 SecItemDelete(_:)를 호출하여 items을 delete한다.
    //이 작업은 실행 취소할 수 없다.
  }
}




