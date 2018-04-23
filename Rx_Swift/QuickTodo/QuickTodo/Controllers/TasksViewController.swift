/*
 * Copyright (c) 2016 Razeware LLC
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
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit
import RxSwift
import RxDataSources
import Action
import NSObject_Rx

class TasksViewController: UIViewController, BindableType {
  
  @IBOutlet var tableView: UITableView!
  @IBOutlet var statisticsLabel: UILabel!
  @IBOutlet var newTaskButton: UIBarButtonItem!
  
  var viewModel: TasksViewModel!
    var dataSource: RxTableViewSectionedAnimatedDataSource<TaskSection>! //RxDataSources
    //RxCocoa와 가장 큰 차이점은 데이터 소스 객체는 구독에서 수행하는 대신 각 셀 유형을 표시한다.
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 60
    
    configureDataSource()
    //RxDataSources는 Observable을 바인딩하기 전에 데이터 소스 구성을 완료해야 한다.
    
  }
  
  func bindViewModel() {
    viewModel.sectionedItems
        .bind(to: tableView.rx.items(dataSource: dataSource)) //바인딩
        .disposed(by: self.rx.disposeBag)
        //dataSource 객체의 각 변경 유형마다 다른 애니메이션을 사용할 수 있다.
    
    
    newTaskButton.rx.action = viewModel.onCreateTask()
    //추가 버튼 바인딩
    
    tableView.rx.itemSelected //dataSource로 indexPath와 일치하는 모델을 찾는다.
        .do(onNext: { [unowned self] indexPath in
            //행을 탭하여 편집후 취소 누르면 선택된 상태로 유지되어 있다.
            //do(onNext: )로 해결할 수 있다.
            self.tableView.deselectRow(at: indexPath, animated: false)
        })
        .map { [unowned self] indexPath in
            try! self.dataSource.model(at: indexPath) as! TaskItem
        }
        .subscribe(viewModel.editAction.inputs)
        .disposed(by: self.rx.disposeBag)
  }
    
    fileprivate func configureDataSource() {
        dataSource = RxTableViewSectionedAnimatedDataSource<TaskSection>(configureCell: {
            [weak self] dataSource, tableView, indexPath, item in
            let cell = tableView.dequeueReusableCell(withIdentifier: "TaskItemCell", for: indexPath) as! TaskItemTableViewCell
            if let strongSelf = self {
                cell.configure(with: item, action: strongSelf.viewModel.onToggle(task: item))
            }
            
            return cell
        },
        titleForHeaderInSection: { dataSource, index in
            //섹션 헤더의 문자열 title 반환
            dataSource.sectionModels[index].model
        })
        //Observable을 table이나 collection에 바인딩할 때 클로저를 사용해 셀을 생성하고 구성할 수 있다.
        //RxDataSources도 같은 방식으로 작동하지만 구성은 모두 "데이터 소스"객체에서 수행된다.
        //View Model에 의해 액션이 제공된다느 ㄴ점을 제외하고는 클로저와 흡사하다.
        //View Controller는 셀과 액션을 연결시키는 역할을 제한한다. p.417
        //셀 자체가 버튼에 액션을 지정하는 것 외에는 View Model 자체에 대해 알 필요가 없다.
    }
  
}
