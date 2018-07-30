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

protocol GraphViewDelegate: class { //Ticker에 연결되는 Delegate
    func didMoveToPrice(_ graphView: GraphView, price: Double)
}

// Layout constants
private extension CGFloat {
  static let graphLineWidth: CGFloat = 1.0
  static let scale: CGFloat = 15.0
  static let lineViewHeightMultiplier: CGFloat = 0.7
  static let baseLineWidth: CGFloat = 1.0
  static let timeStampPadding: CGFloat = 10.0
}

final class GraphView: UIView {
  
  private var dataPoints: RobinhoodChartData //데이터
  
  private lazy var dateFormatter: DateFormatter = { //날짜 형식
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm a v, MMM d"
    return formatter
  }()
  
  private var lineView = UIView() //Indicator
  private let timeStampLabel = UILabel()
  private var lineViewLeading = NSLayoutConstraint() //오토 레이아웃 제약 조건
  private var timeStampLeading = NSLayoutConstraint() //오토 레이아웃 제약 조건
  
  private let panGestureRecognizer = UIPanGestureRecognizer() //Pan 제스처
  private let longPressGestureRecognizer = UILongPressGestureRecognizer() //LongPress 제스처
  
  private var height: CGFloat = 0
  private var width: CGFloat = 0
  private var step: CGFloat = 1
  
  private var xCoordinates: [CGFloat] = [] //그래프에서 x값들의 좌표
    
  weak var delegate: GraphViewDelegate? //indicator 이동 시에 delegate 호출해 feedback업데이트
  private var feedbackGenerator = UISelectionFeedbackGenerator()
  //선택의 변경을 나타내기 위해 햅틱을 작성(진동)
  
  init(data: RobinhoodChartData) {
    self.dataPoints = data
    super.init(frame: .zero)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func draw(_ rect: CGRect) {
    //해당 뷰가 load될 때 그려진다.
    
    height = rect.size.height
    width = rect.size.width
    
    step = width/CGFloat(dataPoints.data.count) //x축의 간격
    //n번째의 x = n-1 번째 x + step
    
    drawGraph()
    drawMiddleLine()
    
    configureLineIndicatorView()
    configureTimeStampLabel()
    
    addGestureRecognizer(panGestureRecognizer) //Pan 제스처 추가
    panGestureRecognizer.addTarget(self, action: #selector(userDidPan(_:)))
    //Pan 제스처 타겟 메서드
    
    addGestureRecognizer(longPressGestureRecognizer) //LongPress 제스처 추가
    longPressGestureRecognizer.addTarget(self, action: #selector(userDidLongPress(_:)))
    //LongPress 제스처 타겟 메서드
  }
  
  private func drawGraph() {
    // draw graph
    
    let graphPath = UIBezierPath() //UIBezierPath 생성
    graphPath.move(to: CGPoint(x: 0, y: height)) //해당 좌표로 이동한다.
    
    for i in stride(from: 0, to: width, by: step) {
      //위의 stride 구문은 for(i = 0; i<width; 1+step)와 같다.
      xCoordinates.append(i)
    }
    
    for (index, dataPoint) in dataPoints.data.enumerated() {
      let midPoint = dataPoints.openingPrice
      let graphMiddle = height/2
      
      let y: CGFloat = graphMiddle + CGFloat(midPoint - dataPoint.price) * .scale
      //opening price가 그래프의 중간 지점을 지나가야 한다.
      //y = graph middle + (opening price - data point price) //좌측 상단이 (0, 0)인 것을 생각
      
      let newPoint = CGPoint(x: xCoordinates[index], y: y)
      //위의 for문에서 추가한 각 step 위치가 x 좌표가 된다.
      graphPath.addLine(to: newPoint) //해당 좌표까지의 선을 추가한다.
    }
    
    UIColor.upAccentColor.setFill() //배경 색 지정
    UIColor.upAccentColor.setStroke() //라인 색 지정
    graphPath.lineWidth = .graphLineWidth //라인 너비 지정
    graphPath.stroke() //라인 그리기
  }
  
  private func drawMiddleLine() {
    // draw middle line
    
    let middleLine = UIBezierPath() //UIBezierPath 생성
    
    let startingPoint = CGPoint(x: 0, y: height/2)
    let endingPoint = CGPoint(x: width, y: height/2)
    //middle line은 starting point와 end point만 있으면 된다.
    
    middleLine.move(to: startingPoint) //해당 좌표로 이동한다.
    middleLine.addLine(to: endingPoint) //해당 좌표까지의 선을 추가한다.
    middleLine.setLineDash([0, step], count: 2, phase: 0) //선 스타일
    //첫 선분의 위치, 둘째 선분 까지의 길이(공백), 패턴의 개수, 시작할 offset 위치
    
    middleLine.lineWidth = .baseLineWidth
    middleLine.lineCapStyle = .round //endpoint 스타일 : 끝이 둥근 선
    middleLine.stroke() //선을 그린다.
    
  }
  
  private func configureLineIndicatorView() {
    lineView.backgroundColor = UIColor.gray
    lineView.translatesAutoresizingMaskIntoConstraints = false
    addSubview(lineView)
    
    lineViewLeading = NSLayoutConstraint(item: lineView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 0.0)
    
    addConstraints([
      lineViewLeading,
      NSLayoutConstraint(item: lineView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: lineView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 1.0),
      NSLayoutConstraint(item: lineView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: height * .lineViewHeightMultiplier),
      ]) //Indicator 레이아웃 제약 조건
  }
  
  private func configureTimeStampLabel() {
    timeStampLabel.configureTitleLabel(withText: "09:00 AM ET, MAY 25")
    timeStampLabel.textColor = .lightTitleTextColor
    addSubview(timeStampLabel)
    timeStampLabel.translatesAutoresizingMaskIntoConstraints = false
    
    timeStampLeading = NSLayoutConstraint(item: timeStampLabel, attribute: .leading, relatedBy: .equal, toItem: lineView, attribute: .leading, multiplier: 1.0, constant: .timeStampPadding)
    //timeStampLeading은 lineView(그래프의 indicator)의 leading에서 timeStampPadding(10)
    
    addConstraints([
      NSLayoutConstraint(item: timeStampLabel, attribute: .bottom, relatedBy: .equal, toItem: lineView, attribute: .top, multiplier: 1.0, constant: 0.0),
      timeStampLeading
      ]) //레이아웃 제약조건 timeStampLabel의 bottom
  }
  
  @objc func userDidLongPress(_ lpgr: UILongPressGestureRecognizer) { //LongPressGesture
    let touchLocation = lpgr.location(in: self) //LongPress 터치 된 위치를 가져온다.
    let x = convertTouchLocationToPointX(touchLocation: touchLocation)
    //현재 터치한 곳에서 가장 가까운 x의 좌표를 가져온다.
    
    guard let xIndex = xCoordinates.index(of: x) else { return } //x가 존재하는 지 확인
    
    let dataPoint = dataPoints.data[xIndex] //해당 좌표의 데이터를 가져온다.
    
    //Update line indicator
    updateIndicator(with: x, date: dataPoint.date, price: dataPoint.price) //Indicator 업데이트
  }
  
  @objc func userDidPan(_ pgr: UIPanGestureRecognizer) { //PanGesture
    let touchLocation = pgr.location(in: self) //pan 터치 된 위치를 가져온다.
    let velocity = pgr.velocity(in: self)
    
    switch pgr.state {
    case .changed, .began, .ended:
      
      let x = convertTouchLocationToPointX(touchLocation: touchLocation)
      //현재 터치한 곳에서 가장 가까운 x의 좌표를 가져온다.
      
      guard let xIndex = xCoordinates.index(of: x) else { return } //x가 존재하는 지 확인
      let dataPoint = dataPoints.data[xIndex] //해당 좌표의 데이터를 가져온다.
      
      //Update line indicator
      updateIndicator(with: x, date: dataPoint.date, price: dataPoint.price) //Indicator 업데이트
      
    default: break
    }
  }
  
    private func updateIndicator(with offset: CGFloat, date: Date, price: Double) {
    //Indicator의 Label의 텍스트와 오토 레이아웃 제약 조건을 업데이트 해 준다.
    
    timeStampLabel.text = dateFormatter.string(from: date).uppercased() //대문자로
    
    if offset != lineViewLeading.constant { //indicator 이동의 변화가 있었다면
      feedbackGenerator.prepare()
      feedbackGenerator.selectionChanged() //트리거
      delegate?.didMoveToPrice(self, price: price)
      //indicator를 업데이트 하기 전에 price를 업데이트 먼저 시켜준다.
    }
    
    lineViewLeading.constant = offset //레이아웃의 왼쪽 leading을 x좌표로 업데이트 해서 맞춰준다.
    
    //indicator의 label이 항상 indicator의 오른쪽에 위치해서 오른쪽 끝으로 indicator가 이동하면 label이 잘린다.
    //label이 indicator의 위치에 비례하여 위치하도록 바꿔준다(가운데에서 정 가운데 위치).
    let tsMin = timeStampLabel.frame.width / 2 + .timeStampPadding
    //timeStampLabel의 min 위치값(가장 좌측 indicator 선택 시 x값)
    let tsMax = width - timeStampLabel.frame.width / 2 - .timeStampPadding
    //timeStampLabel의 max 위치값(가장 우측 indicator 선택 시 x값)
    let tsWidth = timeStampLabel.frame.width
    
    let isCenter = offset > tsMin && offset < tsMax
    //indicator의 x 좌표가 min보다 크고, max보다 작다면 true
    //timeStampLabel이 indicator의 위치에 따라 움직인다.
    let isLeftEdge = offset + tsMin < tsMax
    //현재 x값 + 최소 x값 < 최대 x값이라면 왼쪽 사이드
    
    if isCenter { //timeStampLabel이 탭 위치에 따라 움직인다.
      timeStampLeading.constant = -tsWidth / 2
    } else if isLeftEdge { //timeStampLabel이 왼쪽에 고정
      timeStampLeading.constant = -tsWidth / 2 + (tsWidth / 2 - offset) + .timeStampPadding
    } else { //timeStampLabel이 오른쪽에 고정
      timeStampLeading.constant = -tsWidth + (width - offset) - .timeStampPadding
    }
    
    //오토 레이아웃 제약 조건을 업데이트 시켜준다.
    //timeStampLeading은 lineView(그래프의 indicator)의 leading을 기준으로 움직인다.
    //isLeftEdge과 isRightEdge 에서 timeStampLeading.constant는 매번 바뀌지만 고정되어 보인다.
    //isCenter 에서 timeStampLeading.constant는 고정되어 있기 때문에 움직여 보인다.
  }
  
  // Check if touchLocation.x is in the bounds of the width of the view, and converts it to a graph value
  private func convertTouchLocationToPointX(touchLocation: CGPoint) -> CGFloat {
    //현재 터치한 곳에서 가장 가까운 x의 좌표를 찾는다. 0보다 작을 경우에는 0
    let maxX: CGFloat = width
    let minX: CGFloat = 0
    
    var x = min(max(touchLocation.x, maxX), minX) //최소 값. 0을 넘어선 음수 값에서도 0이 된다.
    
    xCoordinates.forEach { (xCoordinate) in
      let difference = abs(xCoordinate - touchLocation.x)
      //각 x좌표에서 터치된 위치의 x 좌표를 빼준 값의 절대값.
      //각 x좌표와 터치된 x의 차이를 구한다.
      if difference <= step { //그 차이가 x축 간격보다 작거나 같다면
        x = CGFloat(xCoordinate) //그 축 좌표를 x 변수에 할당
        return
      }
    }
    
    return x
  }
}

