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

protocol ContactListTableViewControllerDelegate: class { //프로토콜 추가
  func contactListTableViewController(_ contactListTableViewController: ContactListTableViewController, didSelectContact selectedContact: Contact)
  //적절한 메시지를 표시한다.
}

class ContactListTableViewController: UITableViewController {
  weak var delegate: ContactListTableViewControllerDelegate?
  
  var contacts = [
    Contact(
      name: "Hillary Oliver",
      photo: "rw-logo",
      lastTime: Date(timeIntervalSinceNow: -3.2)),
    Contact(
      name: "Evan Derek",
      photo: "rw-logo",
      lastTime: Date(timeIntervalSinceNow: -10.4))
  ]
  
  private let cellIdentififer = "ContactCell"
  private let segueIdentifier = "ShowMessages"
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  // MARK: - Table View Delegate
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) { //수정
    guard let messagesViewController = delegate as? MessagesViewController,
      let messagesNavigationController = messagesViewController.navigationController else { //참조를 가져온다.
        return
    }
    
    let selectedContact = contacts[indexPath.row]
    messagesViewController.contactListTableViewController(self, didSelectContact: selectedContact)
    //선택한 contact를 가져와서 delegate 메서드를 호출한다.
    splitViewController?.showDetailViewController(messagesNavigationController, sender: nil)
    //DetailViewController를 표시한다.
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if(segue.identifier == segueIdentifier) {
      guard let messagesVC = segue.destination as? MessagesViewController else {
        return
      }
      guard let indexPath = tableView.indexPathForSelectedRow else {
        return
      }
      
      messagesVC.contact = contacts[indexPath.row]
    }
  }
  
  // MARK: - Table View Data Source
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return contacts.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(
      withIdentifier: cellIdentififer,
      for: indexPath) as! ContactTableViewCell
    
    let contact = contacts[indexPath.row]
    cell.nameLabel.text = contact.name
    cell.lastMessageLabel.text = contact.lastMessage
    
    return cell
  }
}
