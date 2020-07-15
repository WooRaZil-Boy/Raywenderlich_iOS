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

class TiltShiftTableViewController: UITableViewController {
  private let context = CIContext()

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 10
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "normal", for: indexPath) as! PhotoCell
    
    
    
    
    
    
//    cell.display(image: nil)
//
//    let name = "\(indexPath.row).png" //Asset 카탈로그의 이미지를 가져온다.
//    let inputImage = UIImage(named: name)!
//
//    print("Tilt shifting image \(name)")
//
//    guard let filter = TiltShiftFilter(image: inputImage, radius: 3),
//      let output = filter.outputImage else { //이미지를 처리해서 가져온다.
//        print("Failed to generate tilt shift image")
//        cell.display(image: nil) //오류가 있다면 빈 이미지
//        return cell
//    }
//
//    print("Generating UIImage for \(name)")
//    let fromRect = CGRect(origin: .zero, size: inputImage.size)
//
//    guard let cgImage = context.createCGImage(output, from: fromRect) else {
//      //CGImage로 변환한다.
//      print("No image generated")
//      cell.display(image: nil) //오류가 있다면 빈 이미지
//      return cell
//    }
//
//    cell.display(image: UIImage(cgImage: cgImage))
//
//    print("Displaying \(name)")
//
//    return cell
    
    
    
    
    let image = UIImage(named: "\(indexPath.row).png")!
    
    print("Filtering")
    let op = TiltShiftOperation(image: image)
    op.start() //직접 실행한다. //일반적으로는 직접 호출해서는 안된다.
    //기본적으로 현대 스레드에서 동기 호출로 실행된다.
    
    cell.display(image: op.outputImage)
    print("Done")
    
    return cell
  }
}
