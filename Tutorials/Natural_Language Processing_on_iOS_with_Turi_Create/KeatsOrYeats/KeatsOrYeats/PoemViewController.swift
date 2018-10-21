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
import CoreML

class PoemViewController: UIViewController {

  // MARK: - IBOutlets
  @IBOutlet weak var poemTextView: UITextView!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var resultTable: UITableView!

  // MARK: - Properties
  var probabilities: [(String, Double)]?

  private lazy var formatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .percent
    return formatter
  }()

  // MARK: - View Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    poemTextView.layer.borderWidth = 1.0
    poemTextView.layer.borderColor = UIColor.darkGray.cgColor
    poemTextView.layer.cornerRadius = 4
    poemTextView.delegate = self
  }
}

// MARK: - Internal
private extension PoemViewController {

  //Using the model
  func analyze(text: String) {
    let counts = wordCounts(text: text) //BOW 생성(input)이 된다
    let model = Poets() //Model 인스턴스 생성

    do {
      let prediction = try model.prediction(text: counts) //예측
      updateWithPrediction(poet: prediction.author, probabilities: prediction.authorProbability)
    } catch {
      print(error)
    }
  }
  
  func updateWithPrediction(poet: String, probabilities: [String: Double]) {
    titleLabel.text = "Written by: \(poet)"
    titleLabel.textColor = .darkText
    
    self.probabilities = probabilities.sorted { a, b in
      a.value > b.value
    }
    resultTable.reloadData()
  }
  
  func updateWithError(error: Error) {
    titleLabel.text = error.localizedDescription
    titleLabel.textColor = .red
    probabilities = nil
    resultTable.reloadData()
  }
}

// MARK: - UITextViewDelegate
extension PoemViewController: UITextViewDelegate {
  
  func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
    guard text == "\n" else {
      return true
    }

    textView.resignFirstResponder()
    return false
  }
  
  func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
    return true
  }
  
  func textViewDidEndEditing(_ textView: UITextView) {
    analyze(text: textView.text)
  }
}

// MARK: - UITableViewDataSource
extension PoemViewController: UITableViewDataSource {

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return probabilities?.count ?? 0
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ResultTableViewCell
    if let poet = probabilities?[indexPath.row] {
      let percent = formatter.string(for: poet.1)!
      cell.configureCell("\(poet.0): \(percent)", progress: Float(poet.1))
    }
    return cell
  }
}

//NLP(Natural Language Processing)는 구조화되지 않은 텍스트를 가져와서 특성을 식별한다. 이를 위해 Apple은 다음과 같은 기술을 사용해 텍스트를 이해한다.
// • Language identification
// • Lemmatization (identification of the root form of a word)
// • Named entity recognition (proper names of people, places and organizations)
// • Parts of speech identification
// • Tokenization
//이 앱에서는 tokenization과 custom machine learning model를 사용해, 주어진 시의 작가를 식별한다.




//Getting Started
//NLP는 Apple에서 데이터 탐색, 키보드 자동 입력 제안, Siri 제안 등에 널리 사용된다.
//검색 기능이 있는 앱에서는 NLP를 사용하여 관련 정보를 찾고, input text를 indexing 가능한 형식으로 변환한다.
//이 앱에서 Core ML 모델을 만들기 위해, Apple의 오픈 소스 Python 프로젝트인 Turi Create를 사용한다.
//Turi Create는 기계 학습 모델을 손쉽게 생성한다.

//Download Every Known Poem
//때로는 단순하고 무식한 접근 방법이 유용할 때 있다. 저자 식별 정확도를 높이기 위한 가장 확실한 해결책은 모든 시인들의 시 사본을 데이터로 확보하는 것이다.
//하지만 이런 방법은 데이터를 정제하는 데 힘이 들고, DB에 없는 시를 식별하기 어렵다.
//현실적이고 효율적인 해결책은 ML로 텍스트 모델을 작성한 후, DB에 없는 새로운 시라도 카테고리로 분류해 내는 것이다.




//Intro to Machine Learning: Text-Style
//기계 학습에도 다양한 알고리즘이 있다. 주로 입력된 text를 변환해, 의사 결정을 하거나 확률을 구한다.
//https://www.youtube.com/watch?v=R9OHn5ZF4Uo
//https://www.youtube.com/watch?v=wvWpdrfoEv0
//https://www.youtube.com/watch?v=aircAruvnKk
//가장 간단한 모델은 일련의 점에 선을 긋는 linear regressiond이다. y = mx + b에서 가중치(m)과 편향(b)를 계산하는 것이다.
//epoch을 진행하면서 오류를 최소화하는 값을 찾는다. 데이터 x가 제시되면, 모델은 가중치와 편향을 적용해 예측 y를 구한다.

//Bag of Words
//기계학습은 input의 features를 검사하고 분석한다. context의 features은 계산에 중요하게 작용한다.
//여기서는 corpus.json이 model을 훈련시키기 위한 input file이다.
//하나의 case(input)은 title, author, text 로 되어 있다. 이 중 text가 유의미한 feature이며, author는 구하려고 하는 answer(label)이 된다.
//텍스트 처리의 기본 단위는 bag of words(BOW)로, text를 word 단위로 나눠 BOW에서의 출현 빈도를 측정한다.
//BOW는 해당 단어를 text에서 반복 되는 수로 매핑한 것으로 이해하면 된다.
//이 앱에서는 한 저자가 자신이 쓴 여러 시에서 비슷한 단어를 자주 쓰는 경향이 있다는 가정하에 시가 BOW로 변환된다.
//이렇게 BOW의 각 단어는 모델을 최적화하기 위한 차원이 된다. 여기서는 518개의 시와 24,399개의 word(BOW 요소)가 사용되었다.

//The Logistic Classifier
//Turi Create는 선형 회귀 분석과는 조금 다른 방식으로 Logistic Classifier를 만든다.
//Logistic Classifier는 하나의 값을 보간하는 대신 단어의 반복 횟수 만큼 각 단어가 그 클래스에 기여하는 정도를 곱해 각 클래스에 대한 확률을 계산한다.




//Using Turi Create
//Core ML은 iOS의 기계 학습 엔진으로 scikit 및 keras와 같은 다양한 machine learning SDK를 기반으로 여러 유형의 모델을 지원한다.
//Apple의 open-source library인 Turi Create는 이러한 라이브러리를 주어진 작업에 가장 적합한 모델을 선택하도록 처리할 수 있다.
//Turi Create는 특정 모델을 선택하는 것이 아닌, 앱에서 해결하려는 문제 유형을 고렿야 한다.

//Setting Up Python
//virutalenv으로 Turi Create를 설치하는 것이 좋다.
//SSL 오류가 발생하면 --trusted-host 명령을 추가해 준다. pip install --trusted-host pypi.python.org virtualenv
//Virtualenv는 가상의 Python 환경을 만든다. 각 다른 환경으로 구축된 프로젝트 들이 충돌하지 않도록 관리해 줄 수 있다.




//Using Core ML

//Import the Model
//mlmodel 파일을 단순히 Drag and Drop해서 프로젝트로 가져올 수 있다. 모델을 선택하면 상세 정보를 볼 수 있다.
//첫 섹션인 Machine Learning Model은 모델 생성시, Turi create가 생성한 모델의 메타 데이터를 보여준다.
//여기서 가장 중요한 것은 Type이다. 이는 해당 모델이 어떤 종류의 모델인지 알려준다. 여기서는 Pipeline Classifier
//다음 섹션인 Model Class은 생성된 Swift 클래스를 앱 내부에서 사용할 수 있는 코드로 보여준다.
//세 번째 섹션인 Model Class는 모델의 input과 output을 설명한다.
//여기에서는 하나의 input(text)가 있고 이는 string(word)을 key, 반복횟수인 double을 value로 하는 dictionary이다.
//output은 두 개가 있는데, author와 authorProbability이다.
//두 번째 섹션을 클릭하면 자동 생성된 Poets.swift이 열린다. 모델에 액세스하기 위한 래퍼를 구성되어 있다.
//init로 간단히 모델을 생성하고, prediction(text:)로 예측을 할 수 있다.

//NSLinguisticTagger
//input 하기 전에 TextView에서 입력된 텍스트를 호환 가능하도록 변환해 줘야 한다.
//Turi Create가 training 시에 BOW를 생성했더라도, Core ML에는 아직 그 때 생성한 BOW를 가져올 수 있는 기능이 구현되어 있지 않아서 수동으로 만들어 줘야 한다.
//NSLinguisticTagger는 자연어 처리를 위한 Cocoa SDK로, 쉽게 text를 정제할 수 있다(영문에 대해서만 제대로 작동한다).

extension PoemViewController {
  func wordCounts(text: String) -> [String: Double] {
    var bagOfWords: [String: Double] = [:] //BOW 초기화
    let tagger = NSLinguisticTagger(tagSchemes: [.tokenType], options: 0)
    //NSLinguisticTagger는 품사 및 어휘 클래스에 태그를 지정하는 등 텍스트를 분석한다.
    //단어 추출(tokenType)할 NSLinguisticTagger를 생성한다. //모든 토큰(words, punctuation, whitespace)에 태그를 단다.
    let range = NSRange(text.startIndex..., in: text) //분석할 범위(텍스트 전체)
    let options: NSLinguisticTagger.Options = [.omitPunctuation, .omitWhitespace] //구두점 생략, 공백 생략
    //option을 지정해 준다.
    
    tagger.string = text //분석할 텍스트를 입력해 준다.
    tagger.enumerateTags(in: range, unit: .word, scheme: .tokenType, options: options) { _, tokenRange, _ in
      //입력된 text로 tag를 생성한다. //지정한 range 범위에서, word 단위로 토큰화 하고, tokenType(단어) 정보를, options로 enumeration 한다.
      let word = (text as NSString).substring(with: tokenRange) //해당 text에서 토큰(이름)의 range를 잘라서 word만 가져온다.
      bagOfWords[word, default: 0] += 1
      //dictionary(BOW)에 key의 value가 없으면 defalt인 0이 value로 입력된다. 있으면 value를 1 증가시켜 준다.
    }
    
    return bagOfWords
  }
}

//Using the model
//모델에 많이 포함된 저자의 경우 그 저자의 시로 판단할 확률이 높아진다. 이것이 기계 학습의 단점으로, 데이터의 양과 질에 결과가 크게 달라진다.

