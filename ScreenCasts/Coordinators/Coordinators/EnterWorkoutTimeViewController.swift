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

//1. Add this protocol
protocol EnterWorkoutTimeViewControllerDelegate: class {
  func enterWorkoutInfo()
  func enterWorkoutSaveSuccessful(calories: Double)
  func enterWorkoutSaveFailed(message: String)
}
//프로토콜을 선언하고, 해당 ViewController에서 사용할 메서드들을 정의해 준다.


class EnterWorkoutTimeViewController: UIViewController {
  
  //2. Declare the delegate
  weak var delegate: EnterWorkoutTimeViewControllerDelegate? //ViewController에 delegate 변수를 생성한다.
  
  @IBOutlet weak var workoutCaloriesInputField: UITextField!
  
  @IBAction func saveButtonTouched(_ sender: Any) {
    guard let workoutCaloriesConsumed = workoutCaloriesInputField.text else {
      
      //2a. Let the delegate popup the alert with the given message
      delegate?.enterWorkoutSaveFailed(message: WorkoutInputDataError.missingWorkoutCalories.localizedDescription)
      return
    }
    
    guard let workoutCaloriesValue = Double(workoutCaloriesConsumed) else {
      //2b. Let the delegate popup the alert with the given message
      delegate?.enterWorkoutSaveFailed(message: WorkoutInputDataError.invalidValue.localizedDescription)
      return
    }
    
    //2c. Let the delegate know the workout was successful
    delegate?.enterWorkoutSaveSuccessful(calories: workoutCaloriesValue)
  }
  
  @IBAction func enterWorkoutInfoButtonTapped(_ sender: Any) {
    //2d. Tell the delegate that the enter workout button has been tapped
    delegate?.enterWorkoutInfo()
  }
  
  private enum WorkoutInputDataError: Error {
    
    case missingWorkoutCalories
    case invalidValue
    
    var localizedDescription: String {
      switch self {
      case .missingWorkoutCalories:
        return "Unable to save workout calories - no value entered."
      case .invalidValue:
        return "Unable to save workout calories - invalid value entered."
      }
    }
  }
}
