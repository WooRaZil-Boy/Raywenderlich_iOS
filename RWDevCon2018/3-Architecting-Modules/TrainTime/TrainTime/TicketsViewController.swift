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
import UserService
import InfoService

class TicketsViewController: UIViewController {

  @IBOutlet weak var loginPrompt: UIView!
  @IBOutlet weak var balanceLabel: UILabel!
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    loginPrompt.isHidden = AppDelegate.sharedUserModel.wallet != nil
    updateBalance()
  }

  private func updateBalance() {
    let priceFormatter = NumberFormatter()
    priceFormatter.numberStyle = .currency
    let balance = AppDelegate.sharedUserModel.wallet?.balance ?? 0
    let priceString = priceFormatter.string(for: balance)!
    balanceLabel.text = "Remaining Balance: \(priceString)"
  }

  @IBAction func buyTicket(_ sender: Any) {
    selectTicket()
  }

  private func selectTicket() {
    let chooser = UIAlertController(title: "Select Train Line", message: nil, preferredStyle: .actionSheet)
    let priceFormatter = NumberFormatter()
    priceFormatter.numberStyle = .currency
    AppDelegate.sharedModel.lines.forEach { line in
      let priceString = priceFormatter.string(for: line.fare)!
      let title = "\(line.name) \(priceString)"
      let action = UIAlertAction(title: title, style: .default, handler: { [weak self] _ in
        guard let strongSelf = self else {
          return
        }

        strongSelf.purchaseTicket(for: line)
      })
      chooser.addAction(action)
    }
    present(chooser, animated: true)
  }

  private func purchaseTicket(for line: TrainLine) {
    AppDelegate.sharedUserModel.buyTicket(lineId: line.lineId, fare: line.fare) { success, error in
      DispatchQueue.main.async { [unowned self] in
        if success {
          let ticketViewController = self.childViewControllers[0] as! PurchasedTicketTableViewController
          ticketViewController.tableView.reloadData()
        } else {
          let alert = UIAlertController(title: "Error Buying Ticket", message: error?.localizedDescription ?? "", preferredStyle: .alert)
          alert.addAction(UIAlertAction(title: "Dismiss", style: .default))
          self.present(alert, animated: true)
        }
        self.updateBalance()
      }
    }
  }

  @IBAction func activateTicket() {
    
  }
}
