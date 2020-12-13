/// Copyright (c) 2019 Razeware LLC
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

class ContactListTableViewController: UITableViewController {
  private var contacts: [Contact] = []
  private let cellIdentififer = "ContactCell"
  @IBOutlet var contactPreviewView: ContactPreviewView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    loadData()
    configureGestures()
  }
  
  private func loadData() {
    contacts.append(Contact(name: "Cruz Jacqueline Espinal Nieves", photo: "rw-logo", lastMessage:
      """
      Hey, need to talk to you about this awesome project.
      Before you go to New Yorik, we have to meet.
      You won't regret it. Also, I have some some books that Hillary sent to you.
      """, lastTime: Date(timeIntervalSinceNow: -2)))
    contacts.append(Contact(
      name: "Hillary Oliver", photo: "rw-logo",
      lastMessage: "Remember to buy the milk",
      lastTime: Date(timeIntervalSinceNow: -3.2)))
    contacts.append(Contact(
      name: "Noah Librado", photo: "rw-logo",
      lastMessage: "Ok",
      lastTime: Date(timeIntervalSinceNow: -3.9)))
    contacts.append(Contact(
      name: "Yinet Nella", photo: "rw-logo",
      lastMessage: "Ok",
      lastTime: Date(timeIntervalSinceNow: -6.1)))
    contacts.append(Contact(
      name: "Cruz Alberto", photo: "rw-logo",
      lastMessage: "See you soon",
      lastTime: Date(timeIntervalSinceNow: -10.4)))
    contacts.append(Contact(
      name: "Evan Derek", photo: "rw-logo",
      lastMessage: "I'll call you later",
      lastTime: Date(timeIntervalSinceNow: -10.4)))
    contacts.append(Contact(
      name: "Carlos Henry", photo: "rw-logo",
      lastMessage: "I'll call you later",
      lastTime: Date(timeIntervalSinceNow: -10.4)))
  }
  
  // MARK: - Table view data source
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return contacts.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentififer, for: indexPath) as! ContactTableViewCell
    
    let contact = contacts[indexPath.row]
    cell.nameLabel.text = contact.name
    cell.lastMessageLabel.text = contact.lastMessage //추가
    
    return cell
  }
  
  // MARK: - Setup Contact Preview
  override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
    let contact = contacts[indexPath.row]
    
    contactPreviewView.nameLabel.text = contact.name
    contactPreviewView.photoImageView.image = UIImage(named: contact.photo)
    
    view.addSubview(contactPreviewView)
    
    contactPreviewView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      contactPreviewView.widthAnchor.constraint(equalToConstant: 150),
      contactPreviewView.heightAnchor.constraint(equalToConstant: 150),
      contactPreviewView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      contactPreviewView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
    ])
    
    contactPreviewView.transform = CGAffineTransform(scaleX: 1.25, y: 1.25)
    contactPreviewView.alpha = 0
    
    UIView.animate(withDuration: 0.3) { [weak self] in
      guard let self = self else {return}
      self.contactPreviewView.alpha = 1
      self.contactPreviewView.transform = CGAffineTransform.identity
    }
  }
  
  private func configureGestures() {
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideContactPreview))
    
    contactPreviewView.addGestureRecognizer(tapGesture)
    view.addGestureRecognizer(tapGesture)
  }
  
  @objc private func hideContactPreview() {
    UIView.animate(withDuration: 0.3, animations: {[weak self] in
      guard let self = self else {return}
      self.contactPreviewView.transform = CGAffineTransform(scaleX: 1.25, y: 1.25)
      self.contactPreviewView.alpha = 0
    }) { (success) in
      self.contactPreviewView.removeFromSuperview()
    }
  }
}

//content-hugging and compression-resistance priorities(CHCR priorities)은
//고정된 제약조건이 View를 본질적 크기보다 작거나 더 크게 만들려고 할 때 뷰가 어떻게 동작하는지 정의한다.
//content-hugging priority는 한 뷰가 본질적인 콘텐츠 크기보다 커저야 하는 resistance를 나타낸다.
//반대로, compression-resistance priority는 어떤 관점이 본질적인 내용 크기 이상으로 축소되어야 하는 resistance를 나타낸다. //p.163
//수평과 수직에 대해 모두 설정할 수 있다. 즉, 모두 4가지 우선순위가 있다.
//https://rhino-developer.tistory.com/entry/iOS-%EC%98%A4%ED%86%A0%EB%A0%88%EC%9D%B4%EC%95%84%EC%9B%83-%EC%A0%9C%EC%95%BD%EC%A1%B0%EA%B1%B4-%EA%B5%AC%EC%A1%B0-Anatomy-of-a-Constraint

//Intrinsic Size and Priorities
//어떤 view 본연의 크기는 대개 내용과 여백에 의해 결정된다.
//ex. UITextField는 기본적인 height를 가지고 있다.
//이 높이는 글꼴 크키, 텍스트와 테두리 사이의 여백으로 결정되며 이는 모두 UITextField의 본질적인 내용 크기의 일부분이다.
//자동으로 크기가 조정되는 view의 다른 예로는 images, labels, buttons이 있으며 view의 크기는 해당 내용에 기반한다.
//view에 내재된 크기가 있는 경우, 자동 레이아웃 시스템은 사용자를 대신하여 제약 조건을 생성하여 크기를 내재된 크기와 동일하게 만든다.
//기본 크기가 적합할 때, 이 방법은 매우유용하다. 이러한 뷰에 대한 너비와 높이 제약 조건을 수동으로 설정할 필요가 없기 때문에 시간을 절약할 수도 있다.
//하지만, 사용하려는 뷰의 크기와 본질적인 크기가 동일하지 않다면, content-hugging and compression-resistance priorities를 사용할 수 있다.
//가능한 본질적인 내용 크기를 사용하되, 우선순위를 설정하여 사용한다.

//Practical use case
//Contacts.storyboard에서 Contacts List Scene의 Table View를 선택한다.
//Size inspector에서 Row Height를 80으로 하고, Automatic 옵션을 해제한다.
//ContactCell 또한 Row Height를 80으로 하고, Automatic 옵션을 해제한다.
//새 label을 추가하고 제약조건과 옵션을 추가한다.
//하지만, 모든 제약조건을 갖추고 있지만 빨간 경고가 출력된다.
//Content Priority Ambiguity이 있기 때문이다. 두 label의 우선순위가 같기 때문에 자동 레이아웃은 어느 label을 늘려야 할지 모른다.
//방금 생성한 label의 우선순위를 조정해서 이를 해결할 수 있다.
//기본적으로 UI의 모든 요소에는 251의 우선 순위 값이 부여된다. vertical priority를 250으로 변경한다.
//한 label의 우선순위를 줄여, 필요한 것보다 더 많은 공간을 처리하는데 필요한 모든 것을 오토 레이아웃에 제공한다.
//이 경우에는 message label을 늘린다.
//ContactTableViewCell에 생성한 label의 outlet을 연결한다.
