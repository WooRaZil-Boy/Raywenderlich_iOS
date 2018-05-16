/**
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
 * Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
 * distribute, sublicense, create a derivative work, and/or sell copies of the
 * Software in any work that is designed, intended, or marketed for pedagogical or
 * instructional purposes related to programming, coding, application development,
 * or information technology.  Permission for such use, copying, modification,
 * merger, publication, distribution, sublicensing, creation of derivative works,
 * or sale is expressly withheld.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit
import InfoServiceStatic

class ScheduleViewController: UITableViewController {

  @IBOutlet weak var lineChooser: UIButton!

  var lineId: Int = 1300
  var lineInfo: TrainLine?
  var schedule: LineSchedule?
  private lazy var dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "h:mma"
    return dateFormatter
  }()

  override func viewDidLoad() {
    super.viewDidLoad()
    
    updateViewForLine()
  }

  func updateViewForLine() {
    lineInfo = AppDelegate.sharedModel.line(forId: lineId)
    let title = (lineInfo?.name ?? "") + "⌄"
    lineChooser.setTitle(title, for: .normal)

    AppDelegate.sharedModel.schedule(forId: lineId) { [weak self] schedule in
      guard let strongSelf = self else {
        return
      }

      strongSelf.schedule = schedule
      DispatchQueue.main.async { [weak self] in
        guard let strongSelf = self else {
          return
        }

        strongSelf.tableView.reloadData()
      }
    }
  }

  @IBAction func selectTrainLine(_ sender: Any) {
    let chooser = UIAlertController(title: "Select Train Line", message: nil, preferredStyle: .actionSheet)
    AppDelegate.sharedModel.lines.forEach { line in
      let action = UIAlertAction(title: line.name, style: .default, handler: { [weak self] _ in
        guard let strongSelf = self else {
          return
        }

        strongSelf.lineId = line.lineId
        strongSelf.updateViewForLine()
      })
      chooser.addAction(action)
    }
    show(chooser, sender: nil)
  }
}

// MARK: - UITableViewDataSource
extension ScheduleViewController {

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return schedule?.schedule.count ?? 0
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ScheduleCell

    if let run = schedule?.schedule[indexPath.row] {
      let departs = dateFormatter.string(from: run.departs)
      let arrives = dateFormatter.string(from: run.arrives)

      var duration = run.arrives.timeIntervalSince(run.departs) / 60
      if duration < 0 { // for those overnight trains
        duration = 60 * 24 + duration
      }
      let durationFormatter = NumberFormatter()
      durationFormatter.numberStyle = .none
      let durationString = durationFormatter.string(for: duration)!

      let timeRemaining = run.departs.timeIntervalSinceNow
      let timeToNextTrain: String
      if timeRemaining < 0 {
        timeToNextTrain = ""
        cell.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
      } else {
        let durationFormatter = DateComponentsFormatter()
        durationFormatter.allowedUnits = [.hour, .minute, .second]
        durationFormatter.unitsStyle = .positional
        timeToNextTrain = durationFormatter.string(from: timeRemaining) ?? ""
        cell.backgroundColor = .white
      }

      cell.timeLabel.text = "\(departs) - \(arrives)"
      cell.durationLabel.text = "\(durationString) mins"
      cell.colorView.backgroundColor = lineInfo?.associatedColor ?? .black
      cell.trainNumberLabel.text = "train \(run.train)"
      cell.timeRemainingLabel.text = timeToNextTrain
    }

    return cell
  }
}

// MARK: - Helpers

class ScheduleCell: UITableViewCell {
  
  @IBOutlet weak var colorView: UIView!
  @IBOutlet weak var timeLabel: UILabel!
  @IBOutlet weak var durationLabel: UILabel!
  @IBOutlet weak var trainNumberLabel: UILabel!
  @IBOutlet weak var timeRemainingLabel: UILabel!
}
