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

final class ContactListTableViewController: UITableViewController {
  // MARK: - Properties
  private let cellIdentififer = "ContactCell"
    @IBOutlet var contactPreviewView: ContactPreviewView! //추가
    
  private var contacts: [Contact] = [
    Contact(name: "John Doe", photo: "rw-logo"),
    Contact(name: "Jane Doe", photo: "rw-logo"),
    Contact(name: "Joseph Doe", photo: "rw-logo")]
  
  // MARK: - Life Cycles
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.rowHeight = 44
    
    configureGestures()
  }
  
  // MARK: - UITableViewDataSource
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return contacts.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentififer, for: indexPath)
      as? ContactTableViewCell else { fatalError("Dequeued unregistered cell.") }
    
    let contact = contacts[indexPath.row]
    cell.nameLabel.text = contact.name
    
    return cell
  }
    
  // MARK: - Setup Contact Preview
  override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
    let contact = contacts[indexPath.row]
    //indexPath.row로 해당 요소를 가져온다.
    contactPreviewView.nameLabel.text = contact.name
    contactPreviewView.photoImageView.image = UIImage(named: contact.photo)
    view.addSubview(contactPreviewView) //기본 view에 contactPreviewView를 추가한다.
    contactPreviewView.translatesAutoresizingMaskIntoConstraints = false
    //view의 autoresizing mask가 Auto Layout constraints으로 변환되는지 여부를 결정한다.
    //보통 코드로 제약조건을 조정해야할 때 호출한다.
    NSLayoutConstraint.activate([
      contactPreviewView.widthAnchor.constraint(equalToConstant: 150),
      contactPreviewView.heightAnchor.constraint(equalToConstant: 150),
      contactPreviewView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      contactPreviewView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
    ])
    //크기와 제약조건을 설정한다. //layout anchors
    contactPreviewView.transform = CGAffineTransform(scaleX: 1.25, y: 1.25)
    //1.25배 크게 설정
    contactPreviewView.alpha = 0 //투명
    UIView.animate(withDuration: 0.3) { [weak self] in
      guard let self = self else { return }
      
      self.contactPreviewView.alpha = 1
      self.contactPreviewView.transform = CGAffineTransform.identity
    } //애니메이션을 추가해 원래 크기로 축소하고 불투명하게 fade in 한다.
  }
  
  @objc private func hideContactPreview() { //modal을 감춘다.
    UIView.animate(withDuration: 0.3, animations: { [weak self] in
      guard let self = self else { return }
      
      self.contactPreviewView.transform = CGAffineTransform(scaleX: 1.25, y: 1.25)
      self.contactPreviewView.alpha = 0
      //애니메이션을 추가해 fade out 한다.
    }) { (success) in //애니메이션 종료 시
      self.contactPreviewView.removeFromSuperview() //view 제거
    }
  }
  
  private func configureGestures() {
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideContactPreview)) //트리거
    contactPreviewView.addGestureRecognizer(tapGesture)
    view.addGestureRecognizer(tapGesture)
    //제스처를 추가한다. contactPreviewView 나 view를 터치했을 때 작동한다.
  }
}
