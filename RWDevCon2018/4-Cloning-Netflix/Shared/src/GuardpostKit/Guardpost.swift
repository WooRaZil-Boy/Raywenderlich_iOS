/*
 * Copyright (c) 2017 Razeware LLC
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
import SafariServices

public enum Result<T> {
  case success(T)
  case failure(Error)
}

public enum LoginError: Error {
  case unableToCreateLoginUrl
  case errorResponseFromGuardpost(Error?)
  case unableToDecodeGuardpostResponse
  case invalidSignature
  case unableToCreateValidUser
}

public class Guardpost {
  private let baseUrl: String
  private let urlScheme: String
  private let ssoSecret: String
  private var _currentUser: SingleSignOnUser?
  private var authSession: SFAuthenticationSession?
  
  public init(baseUrl: String, urlScheme: String, ssoSecret: String) {
    self.baseUrl = baseUrl
    self.urlScheme = urlScheme
    self.ssoSecret = ssoSecret
  }
  
  public var currentUser: SingleSignOnUser? {
    if _currentUser == .none {
      _currentUser = SingleSignOnUser.restoreFromKeychain()
    }
    return _currentUser
  }
  
  public func login(reauthenticate: Bool = true, callback: @escaping (Result<SingleSignOnUser>) -> ()) {
    let guardpostLogin = "\(baseUrl)/v2/sso/login"
    let returnUrl = "\(urlScheme)sessions/create"
    let ssoRequest = SingleSignOnRequest(endpoint: guardpostLogin, secret: ssoSecret, callbackUrl: returnUrl, reauthenticate: reauthenticate)
    
    guard let loginUrl = ssoRequest.url else {
      let result = Result<SingleSignOnUser>.failure(LoginError.unableToCreateLoginUrl)
      return asyncResponse(callback: callback, result: result)
    }
    
    authSession = SFAuthenticationSession(url: loginUrl, callbackURLScheme: urlScheme) { (url, error) in
      var result: Result<SingleSignOnUser>
      
      guard let url = url else {
        result = .failure(LoginError.errorResponseFromGuardpost(error))
        return self.asyncResponse(callback: callback, result: result)
      }
      
      guard let response = SingleSignOnResponse(request: ssoRequest, responseUrl: url) else {
        result = .failure(LoginError.unableToDecodeGuardpostResponse)
        return self.asyncResponse(callback: callback, result: result)
      }
      
      if !response.isValid {
        result = .failure(LoginError.invalidSignature)
        return self.asyncResponse(callback: callback, result: result)
      }
      
      guard let user = response.user else {
        result = .failure(LoginError.unableToCreateValidUser)
        return self.asyncResponse(callback: callback, result: result)
      }
      
      user.persistToKeychain()
      self._currentUser = user
      
      result = Result.success(user)
      return self.asyncResponse(callback: callback, result: result)
    }
    
    authSession?.start()
  }
  
  public func cancelLogin() {
    authSession?.cancel()
  }
  
  public func logout() {
    SingleSignOnUser.removeUserFromKeychain()
    _currentUser = .none
  }
  
  private func asyncResponse(callback: @escaping (Result<SingleSignOnUser>) -> (), result: Result<SingleSignOnUser>) {
    DispatchQueue.global(qos: .userInitiated).async {
      callback(result)
    }
  }
}

