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


class ProfileDataStore: UIViewController {
  //Saves a workout for the number of calories burned into the HealthKit store
  class func saveWorkout(energyBurned: Double) {
    //1. Setup the Calorie Quantity for total energy burned
    let calorieQuantity = HKQuantity(unit: HKUnit.kilocalorie(),
                                     doubleValue: energyBurned)
    
    //2. Build the workout using data from your Prancercise workout
    let workout = HKWorkout(activityType: .other,
                            start: Date(),
                            end: Date(),
                            duration: 30*60,
                            totalEnergyBurned: calorieQuantity,
                            totalDistance: nil,
                            device: HKDevice.local(),
                            metadata: nil)
    
    //3. Save your workout to HealthKit
    let healthStore = HKHealthStore()
    
    healthStore.save(workout) { (success, error) in
      guard let error = error else {
        print("Successfully saved workout!")
        return
      }
      print("Error saving workout \(error.localizedDescription)")
    }
  }
  
  //Saves a sample (in this example, water consumed) to the store.
  class func saveSample(value:Double, unit:HKUnit, type: HKQuantityType, date:Date) {
    let quantity = HKQuantity(unit: unit, doubleValue: value)
    let sample = HKQuantitySample(type: type,
                                  quantity: quantity,
                                  start: date,
                                  end: date)
    
    HKHealthStore().save(sample) { (success, error) in
      guard let error = error else {
        print("Successfully saved \(type)")
        return
      }
      print("Error saving \(type) \(error.localizedDescription)")
    }
  }

}
