///// Copyright (c) 2017 Razeware LLC
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

class AddWaterViewController: UIViewController {
  
  weak var delegate: AddWaterViewControllerDelegate?
  @IBOutlet weak var waterConsumedInputField: UITextField!
  @IBOutlet weak var waterUnitSegmentedControl: UISegmentedControl!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  @IBAction func saveButtonTouched(_ sender: Any) {
    getWater()
  }
  
  @IBAction func addWaterInfoButtonTapped(_ sender: Any) {
    delegate?.addWaterInfo()
  }
  
  func getWater() {
    guard let waterConsumed = waterConsumedInputField.text else {
      delegate?.waterSaveFailed(message: WaterInputDataError.missingWaterConsumed.localizedDescription)
      return
    }
    
    guard let waterConsumedValue = Double(waterConsumed) else {
      delegate?.waterSaveFailed(message: WaterInputDataError.invalidValue.localizedDescription)
      return
    }
    
    delegate?.waterSaveSuccessful(waterConsumed: waterConsumedValue, control: waterUnitSegmentedControl)
  }
  
  private enum WaterInputDataError: Error {
    
    case missingWaterConsumed
    case invalidValue
    
    var localizedDescription: String {
      switch self {
      case .missingWaterConsumed:
        return "Unable to save water consumed - no value entered."
      case .invalidValue:
        return "Unable to save water consumed - invalid value entered."
      }
    }
  }
}

//MARK - UITextFieldDelegate
extension AddWaterViewController: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    waterConsumedInputField.resignFirstResponder()
    return true
  }
}
