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

class SensorsViewController: UIViewController {

  // MARK: - Outlets
  @IBOutlet private var o3Bar: UIView!
  @IBOutlet private var o3BarHeight: NSLayoutConstraint!
  @IBOutlet private var o3Label: UILabel!

  @IBOutlet private var no2Bar: UIView!
  @IBOutlet private var no2BarHeight: NSLayoutConstraint!
  @IBOutlet private var no2Label: UILabel!

  @IBOutlet private var aqiBar: UIView!
  @IBOutlet private var aqiBarHeight: NSLayoutConstraint!
  @IBOutlet private var aqiLabel: UILabel!

  @IBOutlet private var statsLabel: UILabel!
  @IBOutlet private var strategyLabel: UILabel!
  
  // MARK: - View controller life-cycle
  private var viewModel: SensorsViewModel!
  private var strategy: String!

  static func createWith(storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil),
                         writer: DataWriterType) -> SensorsViewController {
    let vc = storyboard.instantiateViewController(withIdentifier: String(describing: SensorsViewController.self)) as! SensorsViewController
    vc.viewModel = SensorsViewModel(writer: writer)
    vc.strategy = String(describing: type(of: writer))
    return vc
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    strategyLabel.text = strategy
    viewModel.subscribeSensors()
    runStats()
  }

  // MARK: - Display stats
  func runStats() {
    viewModel.stats.connect { [weak self] averages, stats in
      DispatchQueue.main.async {
        self?.updateUI(averages: averages, stats: stats)
      }
    }
  }

  func updateUI(averages: ReadingStats.RealmStats, stats: ReadingStats.AuxStats) {
    o3BarHeight.constant = normalizeBarHeight(averages[Sensor.Symbol.o3.rawValue]!)
    no2BarHeight.constant = normalizeBarHeight(averages[Sensor.Symbol.no2.rawValue]!)
    aqiBarHeight.constant = normalizeBarHeight(averages[Sensor.Symbol.aqi.rawValue]!)

    o3Label.setText(String(format: "%.2f", averages[Sensor.Symbol.o3.rawValue]!))
    no2Label.setText(String(format: "%.2f", averages[Sensor.Symbol.no2.rawValue]!))
    aqiLabel.setText(String(format: "%.2f", averages[Sensor.Symbol.aqi.rawValue]!))
    statsLabel.text = stats

    UIView.animate(withDuration: 1.0,
                   delay: 0,
                   options: [.curveLinear],
                   animations: { self.view.layoutIfNeeded() },
                   completion: nil)
  }

  func normalizeBarHeight(_ height: Double) -> CGFloat {
    return max(0, CGFloat(height - 45.0) * 50.0)
  }

  // MARK: - Actions

  @IBAction private func stopWritingData(_ sender: UIBarButtonItem) {
    sender.isEnabled = false
    viewModel.unsubscribeSensors()
  }
}

// MARK: - UILabel Helper
extension UILabel {
  func setText(_ text: String, animated: Bool = true) {
    guard animated else {
      self.text = text
      return
    }

    UIView.transition(with: self,
                      duration: 0.33,
                      options: [.transitionCrossDissolve],
                      animations: { self.text = text },
                      completion: nil)
  }
}
