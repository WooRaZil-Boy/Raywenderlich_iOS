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
import HealthKit

protocol AddWaterViewControllerDelegate: class {
  func addWaterInfo()
  func waterSaveSuccessful(waterConsumed: Double, control: UISegmentedControl)
  func waterSaveFailed(message: String)
}

extension UIViewController {
  func presentVC(_ viewController: UIViewController) {
    transition(to: viewController)
  }
  
  func transition(to child: UIViewController, completion: ((Bool) -> Void)? = nil) {
    let duration = 0.3
    addChildViewController(child)
    
    let newView = child.view!
    newView.translatesAutoresizingMaskIntoConstraints = true
    newView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    newView.frame = view.bounds

    view.addSubview(newView)
    UIView.animate(withDuration: duration, delay: 0, options: [.transitionCrossDissolve], animations: { }, completion: { done in
      child.didMove(toParentViewController: self)
      completion?(done)
    })
  }
}

class CoordinatorViewController: UIViewController {
  
  var landingController: LandingPageViewController!
  var waterController: AddWaterViewController!
  var enterWorkoutController: EnterWorkoutTimeViewController!
  var reviewController: ReviewViewController!
  var approvalController: ApprovalViewController!
  var errorController: ErrorViewController!
  var latestWorkoutCalories: Double!
  var latestWaterConsumed: Double!
  var latestWaterUnit: HKUnit!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    createViewControllers()
    // Do any additional setup after loading the view.
  }
  
  override func viewDidAppear(_ animated: Bool) {
    let landingPage = LandingPageViewController()
    landingPage.delegate = self
    presentVC(landingPage)
  }
  
  func createViewControllers() {
    landingController = LandingPageViewController()
    landingController.delegate = self
    waterController = AddWaterViewController()
    waterController.delegate = self
    enterWorkoutController = EnterWorkoutTimeViewController()
    enterWorkoutController.delegate = self
    reviewController = ReviewViewController()
    reviewController.delegate = self
    approvalController = ApprovalViewController()
    approvalController.delegate = self
    errorController = ErrorViewController()
    errorController.delegate = self
  }
  
  private func displayAlert(for message: String) {
    
    let alert = UIAlertController(title: nil,
                                  message: message,
                                  preferredStyle: .alert)
    
    alert.addAction(UIAlertAction(title: "OK",
                                  style: .default,
                                  handler: nil))
    
    present(alert, animated: true, completion: nil)
  }
  
}

//each view controller delegate has an extension here in the controller (for organizational purposes) and adopting those protocol methods lets the Controller dictate how to navigate to the next screen, display an error, etc.
extension CoordinatorViewController: LandingPageViewControllerDelegate
{
  func beginButtonTouched() {
    presentVC(waterController)
  }
}

extension CoordinatorViewController: AddWaterViewControllerDelegate
{
  func addWaterInfo() {
    displayAlert(for: "Here, you can enter your water in either oz or mL.  Remember to stay hydrated while you exercise!")
  }
  
  func waterSaveSuccessful(waterConsumed: Double, control: UISegmentedControl) {
    latestWaterConsumed = waterConsumed
    latestWaterUnit = control.getHKUnit()
    presentVC(enterWorkoutController)
  }
  
  //You could have errors displayed in a different way for each controller (if you want), and that can all be dictated from the adopted protocol methods here
  func waterSaveFailed(message: String) {
    displayAlert(for: message)
  }
}

//3. Add this extension to implement this delegate
extension CoordinatorViewController: EnterWorkoutTimeViewControllerDelegate {
  //3a. Display an alert if the info button is tapped
  func enterWorkoutInfo() {
    displayAlert(for: "Here, you can enter how many calories you burned during your workout.  Try to close those rings!")
  }
  
  //3b. If everything is valid, pass on the values to the review controller, and present it
  func enterWorkoutSaveSuccessful(calories: Double) {
    latestWorkoutCalories = calories
    reviewController.waterValue = latestWaterConsumed
    reviewController.caloriesValue = latestWorkoutCalories
    reviewController.waterUnit = latestWaterUnit.unitString
    presentVC(reviewController)
  }
  
  //3c.  If the entry failed, display an alert with the passed in message
  func enterWorkoutSaveFailed(message: String) {
    displayAlert(for: message)
  }
}


extension CoordinatorViewController: ReviewViewControllerDelegate {
  func reviewInfo() {
    displayAlert(for: "Here, you can review your entries before you save the data to HealthKit!")
  }
  
  func reviewSubmitSuccessful() {
    guard let waterType = HKQuantityType.quantityType(forIdentifier: .dietaryWater) else {
      fatalError("Dietary Water Type is no longer available in HealthKit")
    }
    ProfileDataStore.saveSample(value: latestWaterConsumed, unit: latestWaterUnit, type: waterType, date: Date())
    ProfileDataStore.saveWorkout(energyBurned: latestWorkoutCalories)
    
    presentVC(approvalController)
  }
  
  func reviewSubmitFailed() {
    //otherwise go to error page
    presentVC(errorController)
  }

}

extension CoordinatorViewController: ApprovalViewControllerDelegate {
  func approvalInfo() {
    displayAlert(for: "Great job!  We've stored this workout in HealthKit!")
  }
  
  func approvalReturnToHome() {
    presentVC(landingController)
  }
}

extension CoordinatorViewController: ErrorViewControllerDelegate {
  func errorInfo() {
    displayAlert(for: "Oops!  Something went wrong.  Back to the review screen!")
  }
  
  func returnToReviewPage() {
    print("Return button touched")
    presentVC(landingController)
  }
}

//This extension was taken from the HealthKit Quickstart screencast (along with other HealthKit code)
extension UISegmentedControl {
  func getHKUnit() -> HKUnit
  {
    switch selectedSegmentIndex {
    case 0:
      return HKUnit.fluidOunceUS()
    default:
      return HKUnit.literUnit(with: .milli)
    }
  }
}

//각 ViewController에서 구현할 메서드들을 모두 이곳에서 관리한다.
//CoordinatorViewController는 각 ViewController를 변수로 가지고 있으면서 필요한 부분에 연결 시켜 준다.
//seg를 사용하지 않고 present로 필요한 ViewController를 연결시켜 주면 된다.
