Apple은 새로운 iOS 버전의 앱에 기계 학습(Machine learning)을 쉽게 추가할 수 있도록 하고 있다. 현재 Apple의 iOS tooling에는 간단한 API로 고급 기계 학습(advanced machine learning) 기능을 제공하는 자연 언어(Natural Language), 음성(Speech), 비전(Vision) 등의 여러 가지 고급 프레임 워크(high-level framework)가 있다. 음성 텍스트 변환(speech to text), 텍스트 음성 변환(text to speech), 언어의 문법 구조(grammatical structure) 파악, 사진에서 얼굴 감지(detect face), 비디오에서 움직이는 물체 추적(track moving object) 등의 기능을 기본 제공(built-in) 프레임워크(framework)로 구현할 수 있다.
Core ML과 Metal을 사용해 자신만의 기계 학습 모델(machine-learning model)을 생성해, 최신(state-of- the-art) 기계 학습 기술을 앱에 추가 할 수 있다. 또한 Apple은 Create ML과 Turi Create와 같은 사용하기 쉬운 도구를 제공한다. 업계에서 주로 사용하는 표준의 기계 학습 도구(industry-standard machine-learning tool)들을 Core ML 모델로 내보내(export), iOS 앱에 쉽게 적용(integrate)할 수 있다. 




What is machine learning?
기계 학습(Machine learning)은 주목받는 흥미로운 기술이지만, 완전히 새로운 것은 아니다. 많은 회사들이 이미 수십 년 동안 일상적인 사업의 일환으로 기계 학습(machine learning)을 사용해 왔다. 본질적으로는 기계 학습(Machine learning) 회사인 Google은 Larry Page가 고전적인 기계 학습 알고리즘(classic machine-learning algorithm)으로 여겨지는 페이지 링크(PageRank)를 발명한 1998년에 설립되었다.
하지만 기계 학습(machine learning)의 시작은 현대 컴퓨터의 초기 시대까지 거슬러 올라간다. 1959년 Arthur Samuel은 기계 학습(machine learning)을 명시적으로 프로그래밍하지 않아도 컴퓨터가 학습할 수 있는 능력을 연구하는 분야로 정의했다.
사실, 가장 기본적인 기계 학습(machine learning) 알고리즘(algorithm)인 선형 회귀(linear regression, 또는 "최소 제곱 방법(method of least squares)"으로 불리기도 한다)는 유명한 수학자 Carl Friedrich Gauss이 200년 전에 발명한 것이다. 이는 컴퓨터가 등장하기 약 1세기 반 정도 전, 전기가 보편화되기도 전이다. 이 간단한 알고리즘(algorithm)은 오늘날에도 여전히 사용되고 있으며, 로지스틱 회귀(logistic regression)와 신경망(neural network)과 같은 보다 복잡한 구현의 기초가 된다.
2012년 ImageNet 대규모 시각 인식 대회(Large Scale Visual Recognition Challenge)에서 압도적인 격차로 우승해 큰 주목을 받은 융합 신경망(CNN, convolutional neural network) 딥 러닝(deep learning)도 1940년대 초반에 인간의 뇌처럼 작동하는 컴퓨터를 연구한 McCulloch와 Pitts의 인공 신경망(artificialneural network)을 기반으로 한다. 
기계 학습(machine learning)은 이처럼 오래도록 연구되어 왔다. 최근에 큰 화제가 되고 있는 이유는 인터넷과 스마트폰 덕분에 많은 데이터가 쌓이게 되었고, 기계 학습(machine learning)은 이처럼 데이터가 많을 수록 잘 작동하기 때문이다. 또한 컴퓨팅 성능은 발전하였지만, 가격은 훨씬 저렴해졌다. 시간이 걸렸지만, 기계 학습(machine learning)은 이전에는 다루기 힘들었던 복잡한 현실 문제를 해결하는 실용적인 도구로 발전했다.
이제는 손바닥 위의 휴대 기기로 기계 학습 알고리즘(machine-learning algorithm)을 직접 실행할 수 있을 정도가 되었다.

Learning without explicit programming
개발자(programmer)는 주어진 상황에서 컴퓨터가 정확히 무엇을 해야하는지 알려주는 코드(code)를 작성한다. 이 코드의 대부분은 규칙으로 구성된다.    
//if this is true,
//then do something,
//else do another thing    
이는 소프트웨어가 항상 작성된 방식이다. 개발자들은 서로 다른 언어를 사용하지만, 모두 컴퓨터가 수행할 수있는 긴 명령 목록을 작성하고 있다. 이는 많은 소프트웨어에서 매우 잘 작동하기 때문에 인기있는 접근 방법이다. 
위의 if-then-else 구문은 반복적인(repetitive) 작업을 자동화하는데 효과적이다. 비록 시간이 많이 걸리긴 하지만, 컴퓨터에 많은 지식을 이런 규칙의 형태로 입력하여, 규칙이나 지식을 논리적으로 추론하거나 경험 법칙(heuristics)을 적용하여 전략이나 규칙을 찾는 식으로 사람들이 의식적으로하는 일을 모방하도록 프로그래밍할 수 있다.
그러나 적절한 규칙을 세우기가 어렵거나 경험 법칙(heuristics)이 너무 조잡한 흥미로운 문제의 해결에 기계 학습(machine learning)이 도움이 될 수 있다. 얼굴, 표현과 감정, 물체의 모양, 문장(sentence)의 감각 또는 스타일 등을 인식하는 것과 같이 대부분의 사람들이 별다른 의식 없이 하는 일을 컴퓨터가 수행하도록 명시적으로 프로그래밍하는 것은 매우 어렵다. 이러한 작업을 처리하기 위해 실제 인간의 두뇌가 수행하는 작업을 알고리즘(algorithm)을 작성하는 것은 매우 어렵다.
사진에서 얼굴을 인식하는 경우, 픽셀(pixel)의 RGB 값으로 머리카락, 피부, 눈 색깔을 묘사하는 것을 확인할 수 있지만 이는 그다지 신뢰할 수 없다. 게다가 사람의 외모는 머리 스타일, 메이크업, 안경 등의 요소로 사진마다 크게 달라질 수 있다. 또한 사람들은 종종 카메라를 똑바로 쳐다 보지 않기 때문에 다양한 카메라 각도도 고려해야 한다. 이런 식으로 수천까지는 아니라도 수백 가지의 규칙이 추가되더라도, 여전히 가능한 모든 상황을 다룰 수는 없을 것이다.
닮은 형제나 친척들을 구별하거나 개와 고양이를 구별하는 방법을 명확하게 설명하기는 어렵다. 이를 설명하는 모든 규칙에는 많은 예외가 있을 것이다.
기계 학습(machine learning)의 가장 획기적인 점은 컴퓨터가 이미지에서 사물을 명확하게 인식하기 힘들거나, 텍스트로 명확한 감정을 표현하기 힘든 상황에서도 알고리즘(algorithm)을 생성하는 프로그램을 작성할 수 있다는 것이다.
if-then-else 구문을 설계하고 구현하는 대신, 컴퓨터가 예제로부터 이러한 종류의 문제를 해결하는 규칙을 배우게 할 수 있다. 이것이 바로 기계 학습(machine learning)으로, 특정 문제를 해결하는 데 필요한 “규칙”을 자동으로 도출할 수 있는 학습 알고리즘(learning algorithm)을 사용한다. 이렇게 자동화된 학습은 사람이 볼 수 없는 데이터에서 패턴을 찾을 수 있기 때문에 종종 인간보다 더 나은 규칙을 고안해 낸다.




Deep learning
신경망(Neural network)은 인간 두뇌의 작동 방식을 모방하기 위해 노드(node, 뉴런(neuron)) 층(layer)으로 구성된다. 오래도록 이는 대부분 이론(theoretical)에 불과했다. 두어 층의 단순한 신경망(neural network)만이 그 시대의 컴퓨터로 제대로 계산 될 수 있으며, 수학 이론에도 문제가 있어 더 많은 층의 네트워크는 제대로 작동하지 않았다.
컴퓨터 과학자들은 2000년대 중반이 되어서야, 여러 층(layer)으로 구성된 딥 네트워크(deep network)를 훈련시키는 방법을 알아 냈다. 동시에 컴퓨터 게임 장치(computer game device) 시장이 폭발적으로 커지며, 보다 정교한 게임을 위해 더 빠르고 저렴한 GPU에 대한 수요를 증가시켰다.
GPU(Graphics Processing Units)는 그래픽 속도를 증가시키고, 많은 행렬(matrix) 작업을 매우 빠르게 처리한다. 신경망(neural network) 또한 많은 행렬 연산이 필요하다.
게이머(gamer) 덕분에 다층 신경망(deep multi-layer neural network) 훈련에 필요한 하드웨어인 GPU가 매우 빠르고 저렴해졌다. 기계 학습(machine learning)에서 가장 흥미로운 진척(progress)은 다층(large number of layer) 신경망(neural network)과 각 층(layer)의 뉴런(neuron)을 학습 알고리즘(algorithm)으로 사용하는 딥 러닝(deep learning)에 의해 이루어지고 있다.
Apple, Intel, Google과 같은 회사는 Google의 TPU(Tensor Processing Unit), iPhone XS의 A12 프로세서의 새로운 Neural Engine과 같이 딥 러닝(deep learning) 처리에 특별히 고안된 처리 장치(processing unit)를 설계하고 있다. 이는 일반 GPU에 비해 3D 렌더링(rendering) 기능이 부족하지만, 신경망(neural network)의 계산을 훨씬 더 효율적으로 실행할 수 있다.
네트워크가 깊을수록(deeper) 더 복잡한 것을 학습할 수 있다. 딥 러닝(deep learning) 덕분에 현대 기계 학습 모델(modern machine-learning model)은 이미지 속 사물 판별, 언어 인식, 언어 이해 등의 어려운 문제를 해결할 수 있다. 딥 러닝(deep learning) 연구는 여전히 진행 중이며 새로운 발견이 계속되고 있다.
NVIDIA는 컴퓨터 게임 칩 제조업체(computer game chip maker)였지만, 이제는기계 학습 칩 제조업체(machine-learning chip maker)이기도 한다. 대부분의 학습 모델 도구(training model tool)는 macOS에서도 작동하지만, Linux에서는 더 일반적으로 사용된다. 이러한 도구(tool)이 지원하는 유일한 GPU는 NVIDIA의 GPU이며, 대부분의 Mac에는 NVIDIA 칩이 없다. 최신 Mac에서 Apple 자체 도구를 사용해 GPU 가속 교육(GPU-accelerated training)이 가능하지만, 최상의 속도와 유연성(flexibility)을 원한다면 Linux 시스템이 필요하다. 다행히도 클라우드(cloud) 환경에서 이러한 머신을 대여 할 수 있다.

Artificial intelligence
기계 학습(machine learning)과 관련하여 많이 사용되는 용어인 인공 지능(Artificial intelligence, AI)은 1950년 대에 대수학(algebra)의 단어 문제(word problem)를 해결하는 checker 프로그램에서 시작된 연구 분야이다.
인공 지능의 목표는 기계를 사용하여 인간 지능(human intelligence)의 특정 측면을 시뮬레이션(simulate)하는 것이다. AI의 유명한 예로 Turing Test가 있다. 사람이 기계와 사람의 반응을 구별 할 수 없다면, 그 기계는 지능(intelligent)이 있다고 판별한다.
AI는 컴퓨터 과학(computer science), 수학(mathematics), 심리학(psychology), 언어학(linguistics), 경제학(economics), 철학(philosophy) 등 다양한 배경의 연구자들이 모여있는 광범위한 분야이다. 통계(statistics), 확률(probability), 최적화(optimization), 논리 프로그래밍(logic programming), 지식 표현(knowledge representation) 등 다양한 접근 방식과 도구를 사용하며, 컴퓨터 비전(computer vision), 로봇 공학(robotics)과 같은 많은 하위 영역이 있다.
학습(Learning)은 분명 우리가 지능과 연관시키는 것이지만, 모든 기계 학습 시스템(machine-learning system)이 지능적(intelligent)이라 할 수는 없다. 두 분야 사이에 분명히 겹치는 부분이 있지만 기계 학습(machine learning)은 AI가 사용하는 도구(tool) 중 하나 일뿐이다. 모든 AI가 기계 학습(machine learning)인 것은 아니며 모든 기계 학습(machine learning)이 AI인 것도 아니다.
기계 학습(machine learning)은 통계학(statistics), 데이터 과학(data science)과 공통점이 많다. 데이터 과학자(data scientist)는 업무 처리에 기계 학습(machine learning)을 사용할 수 있으며, 많은 기계 학습 알고리즘(machine learning algorithm)은 원래 통계에서 나온다. 모든 것이 리믹스(remix)이다.

What can you do with machine learning?
기계 학습(machine learning)으로 할 수 있는 일 중 일부는 다음과 같다.
- 특정 상점에서 고객의 소비 금액 예측
- 보조 주행 및 자율 주행이 적용된 자동차
- 개인화된 소셜 미디어 : 타겟 광고, 추천, 얼굴 인식
- 스팸 및 악성 프로그램 탐지
- 예상 매출
- 제조 장비의 잠재적인 문제 예측
- 배송 경로 최적화
- 온라인 사기 탐지
이 모두가 기술 사용의 훌륭한 사례이지만, 모바일 개발자와는 큰 관련이 없다. 하지만 사용자와 어느 곳이든 함께 이동하면서 움직임과 주변을 감지 하면서 연락처, 사진, 통신 등의 고유한 데이터를 사용할 수 있으므로 모바일에서도 기계 학습(machine learning)을 활용할 수 있는 분야가 얼마든지 있다. 기계 학습(machine learning)으로 앱을 더 똑똑하게 만들 수 있다.
모바일 환경에서 기계 학습에(machine learning on mobile) 사용하는 주요한 데이터 유형은 카메라(cameras), 텍스트(text), 음성(speech), 활동 데이터(activity data) 등 4가지이다.
카메라(Camera) : 카메라로 찍은 사진과 비디오를 분석(analyze) 또는 증강(augment), 라이브 카메라 피드를 사용하여 사진 및 비디오의 물체, 얼굴, 랜드 마크 감지, 이미지에서 필기(handwriting) 및 인쇄 된 텍스트 인식, 사진 검색, 움직임과 포즈 추적(track), 제스처 인식, 사진과 비디오의 감정적 신호 이해, 이미지 개선, 결함(imperfection) 제거, 시각적 컨텐츠를 자동 태그 및 분류, 특수 효과 및 필터 추가, 명시적 콘텐츠 탐지, 내부 공간의 3D 모델 구현, 증강현실(augmented reality) 구현.
텍스트(Text) : 텍스트 분류, 분석하여 의미또는 문장 구조 이해, 번역, 맞춤법 교정, 텍스트 요약(summarize), 주제 및 감정 탐지, 대화식(conversational) UI, 챗봇(chatbot)
음성(Speech) : 음성을 텍스트로 받아쓰기(dictation), 번역, 시리(Siri) 유형의 명령어 음성을 텍스트로 변환, 비디오 자동 자막 구현
활동(Activity) : 자이로스코프(gyroscope), 가속도계(accelerometer), 자기계(magnetometer), 고도계(altimeter), GPS로 감지된 사용자의 활동을 분류
iOS SDK는 프레임워크(Frameworks), 도구(Tools), API 등으로 이러한 모든 영역의 데이터를 다룰 수 있다.
일반적으로 프로그래밍 문제를 해결하기위한 규칙을 작성할 때, 기계 학습(machine learning)이 좋은 해결책이 될 수 있다. 앱에서 휴리스틱(heuristic, 경험에 입각한 추측 또는 법칙)을 사용할 때마다 단순한 추측이 아닌 주어진 상황에 맞는 결과를 얻기 위해 학습 된 모델로 대체하는 것을 고려해 보는 것이 좋다.




ML in a nutshell
기계 학습(machine learning)의 핵심 개념 중 하나는 모델(model)이다. 모델은 특정 작업을 수행하기 위해 컴퓨터가 학습(learned) 한 알고리즘(algorithm)과 해당 알고리즘을 실행하는 데 필요한 데이터(data)이다. 따라서 모델은 알고리즘(algorithm)과 데이터(data)의 조합이다.
해결하려는 문제의 범위(domain)을 모델링하기 때문에 "모델(model)"이라고 한다. 예를 들어, 문제가 사진에서 친구의 얼굴을 인식하는 것(recognizing)이라면, 문제의 영역은 인간의 디지털 사진이며, 모델에는 이러한 사진을 이해하는 데 필요한 모든 것이 포함된다.
모델(model)을 만들려면 먼저 신경망(neural network)과 같은 알고리즘(algorithm)을 선택한 다음, 해결하려는 문제의 많은 예시를 보여줘서 모델을 훈련(train the model)시킨다. 얼굴 인식 모델(face-recognition model)의 경우 훈련 예제는 친구의 사진뿐 아니라 이름과 같이 모델이 해당 사진에서 배우기를 원하는 것이 될 것이다.
성공적인 훈련(training) 이후 모델은 기계 학습(machine learning) 알고리즘(algorithm)이 학습 예제에서 추출한 문제에 대한 "지식(knowledge)"을 포함하게 된다.
훈련 된 모델(trained model)이 있으면, 아직 답을 모르는 질문을 할 수 있다. 이렇게 훈련된 모델을 사용하여 예측하거나 결론을 도출하는 것을 추론(inference)이라고 한다. 모델이 이전에 본 적없는 새로운 사진을 보게 되면, 사진에서 친구의 얼굴을 감지하고 올바른 이름를 태깅한다.
모델(model)이 학습되지 않은 데이터를 정확히 예측한다면, 일반화(generalize)가 잘 되었다고 한다. 기계 학습(machine learning)의 핵심 과제는 새로운 데이터를 잘 예측(prediction)하도록 모델(model)을 훈련하는 것이다.
기계 학습(machine learning)의 "학습(learning)"은 실제로 훈련 단계(training phase)에서만 적용된다. 모델(model)을 학습 한 후에는 더 이상 새로운 내용을 배우지 않는다. 따라서 앱에서 기계 학습(machine learning) 모델을 사용할 때는 "기존에 무언가를 학습한 고정된 모델"을 사용하고, 학습(learning)을 구현하지 않는다. 물론 새 데이터를 수집 한 후, 재교육한 새로운 모델을 사용하도록 앱을 업데이트 할 수도 있다.
Core ML 3의 새로운 기능은 장치 개인화 모델(on-device personalization of model)이다. 이를 사용해, 사용자는 자신의 데이터를 모델(model)에 통합(incorporate)할 수 있다. 많은 일반 지식을 포함하고 있는 완전히 훈련된(fully trained) 모델에서 시작하여, 각 사용자의 특정 요구에 맞춰 모델을 미세 조정할 수 있다. 이러한 유형의 교육(training)은 사용자의 기기에서 바로 수행되며, 서버가 필요하지 않다.

Supervised learning
오늘날 가장 일반적인 유형의 기계 학습(machine learning)은 인간이 학습 과정을 안내해주는 지도 학습(감독 학습, supervised learning)이다. 이 학습은 컴퓨터가 무엇을 배우고 어떻게 배울 것인지를 알려준다.
지도 학습(supervised learning)은 친구의 사진과 같은 예제(example)를 제공하여 모델을 학습시키며, 모델(model)이 차이점을 구분할 수 있도록 예제가 나타내는 내용도 알려준다. 이러한 레이블(label)은 모델에게 해당 사진의 실제 내용(또는 사람)을 알려준다. 지도 학습에는 항상 레이블(label)이 지정된 데이터가 필요하다.
때때로 예제 대신 "샘플(sample)"이라고 하기도 하는데 이는 같은 의미이다.
지도 학습(supervised learning)의 두 가지 하위 영역은 분류(classification)와 회귀(regression)이다.
회귀(Regression)는 온도(temperature), 전력 수요(power demand), 주식 시장 가격(stock market price)의 변화와 같은 지속적인 반응을 예측한다. 회귀 모델(regression model)의 출력(output)은 하나 이상의 부동 소수(floating-point number)이다. 사진에서 얼굴의 존재와 위치를 감지하려면, 얼굴이 포함된 이미지에서 직사각형을 나타내는 네 개의 숫자를 출력하는 회귀 모델을 사용한다.
분류(Classification)는 이메일이 스팸인지 또는 좋은(good) 개인지 판별해, 개별적인 범주(category)를 예측한다.
분류 모델(classification model)의 결과는 "좋은 개(good dog)", "나쁜 개(bad dog)", "스팸(spam)", "스팸 아님(no spam)" 혹은 친구의 이름이다. 이는 모델(model)이 인식하는 클래스(class)이다. 모바일 앱에서 사용하는 분류(classification)의 일반적인 적용은 이미지의 사물을 인식하거나 텍스트가 긍정적 또는 부정적 감정을 나타내는지 여부를 판단하는 것 등이다.
인간이 학습 과정에 참여하지 않는 비지도 학습(unsupervised learning)이라는 기계 학습(machine learning) 유형도 있다. 대표적인 예는 레이블(label)이 지정되지 않은 많은 데이터가 제공되는 클러스터링(clustering)이며, 이 알고리즘(algorithm)은 데이터에서 패턴을 찾는 것이다. 일반적으로 어떤 종류의 패턴이 있는지 미리 알지 못하므로, ML 시스템에게 지침을 줄 수 있는 방법이 없다. 이를 응용하는 애플리케이션은 유사 이미지 찾기(finding similar images), 유전자 서열 분석(gene sequence analysis), 시장 조사(market research) 등이 있다.
세 번째 유형은 대리인(agent)이 특정 환경에서 행동하는 방법을 배워 좋은 행동에 대해서는 보상을 받고(rewarded), 잘못된 행동에 대해서는 처벌을 받는(punished) 강화 학습(reinforcement learning)이다. 이 유형의 학습(learning)은 로봇 프로그래밍과 같은 작업에 사용된다.

You need data... a lot of it
모델(model)을 훈련시키기 위해서는 먼저 예제와 레이블(label)로 구성된 훈련 데이터(training data)를 수집해야 한다. 친구의 얼굴을 인식하는 모델을 만들기 위해서는 친구의 얼굴이 다른 사람과 비교하여 어떻게 생겼는지, 이름은 무엇인지 등을 학습할 수 있는 많은 예제(사진)가 필요하다.
레이블(label)은 모델(model)이 예제에서 배우고자하는 것이다. 여기에서는 사진의 어느 부분이 얼굴인지와 해당 친구의 이름이다. 
예제가 많을수록 모델(model)은 어떤 세부 사항이 중요하고, 중요하지 않은지 더 잘 학습할 수 있다. 지도 학습(supervised learning)의 한 가지 단점은 시간이 많이 걸리고, 예제의 레이블(label)을 작성하는 데 비용이 많이 든다는 것이다. 1,000 장의 사진이 있다면, 기본적으로 1,000개의 레이블(label)을 만들어야 한다. 사진에 두 명 이상의 사람이 있는 경우에는 더 많은 레이블(label)을 만들어야 한다.
예제를 모델(model)이 받는 질문으로 생각할 수 있다. 레이블(label)은 이러한 질문에 대한 답변이다. 레이블(label)은 학습(training)에만 사용하고 추론(inference)에는 사용하지 않는다. 결국 추론은 아직 답이 없는 질문을 하는 것을 의미한다.

It’s all about the features
교육 예제는 학습하려 하는 특징(feature)으로 구성된다. 이것은 약간 모호한 개념이지만, "특징(feature)"은 일반적으로 기계 학습(machine learning) 모델(model)에서 흥미로운 것으로 여겨지는 데이터의 부분이다.
많은 종류의 기계 학습(machine learning) 작업에서, 명백한 일련의 특징들(set of features)로 훈련 데이터(training data)를 구성할 수 있다. 주택 가격을 예측하는 모델(model)의 경우, 특징(feature)은 방의 개수(number of rooms), 바닥 면적(floor area), 주소(street name) 등이 될 수 있다. 레이블(label)은 데이터 세트에서 각 주택의 판매 가격이다. 이러한 종류의 교육 데이터(training dat)는 CSV 또는 JSON 테이블(table) 형태로 제공되는 경우가 많으며, 특징(feature)은 해당 테이블(table)의 열(column)이 된다.
피처 엔지니어링(Feature engineering)은 어떤 특징(feature)이 문제 해결에 중요하고 유용한지 결정하는 기술이며, 기계 학습(machine learning) 전문가(practitioner) 또는 데이터 과학자(data scientist)의 일상적인 업무에서 중요한 부분이다.
친구 얼굴 탐지기(face detector)와 같이 이미지를 작업하는 기계 학습 모델(machine-learning model)의 경우, 모델(model)에 대한 입력(input)은 주어진 사진의 픽셀(pixel) 값(value)이다. 개별 픽셀의 RGB 값은 실제로 많은 정보를 제공하지 않기 때문에 이를 데이터의 "특징(feature)"으로 간주하는 것은 그리 유용하지 않다.
대신에 눈 색깔(eye color), 피부색(skin color), 머리 모양(hair style), 턱 모양(shape of the chin), 귀 모양(shape of the ears), 안경 착용(wear glasses) 여부, 흉터(scar) 등 얼굴에 대한 모든 정보를 수집하여 테이블(table)에 넣고, 기계 학습(machine learning) 모델(model)을 훈련(train)시키면 "파란 눈, 갈색 피부, 뾰족한 귀를 가진 사람"과 같은 예측(prediction)을 할 수 있을 것이다. 하지만 문제는 입력(input)이 사진인 경우, 컴퓨터가 인식하는 것은 RGB 값(value)의 배열(array)이기 때문에 사람의 눈 색깔이나 머리 모양이 무엇인지 알 수 있는 방법이 없어 이러한 모델(model)은 무용지물이 된다.
따라서 어떻게든 이미지에서 이러한 특징들(features)을 추출(extract)해야 한다. 이 작업에 기계 학습(machine learning)을 사용할 수도 있다. 신경망(neural network)은 픽셀(pixel) 데이터를 분석하여 정답을 얻는데 유용한 특징(feature)이 무엇인지 스스로 알아낼 수 있다. 학습 중에, 제공 한 교육(training) 이미지와 레이블(label)로 이를 배울 수 있다. 그런 다음 이러한 특징들(features)을 사용하여 최종 예측(prediction)을 한다.
훈련 사진(training photos)에서 모델(model)은 눈 색깔(eye color) 및 머리 모양(hair style)과 같은 "명백한(obvious)" 특징(feature)을 발견할 수도 있지만, 일반적으로 모델(model)이 감지하는 특징(feature)은 더 미묘하고 해석하기 어렵다. 이미지 분류기(image classifier)에서 사용하는 일반적인 특징(feature)에는 가장자리(edge), 색상 부분(color blob), 추상적인 모양(abstract shape), 이미지 간의 관계(relationship) 등이 있다. 실제로 모델(model)이 좋은 예측(prediction)을 한다면 모델(model)이 어떤 특징(feature)을 선택했는지는 중요하지 않다.
딥 러닝(deep learning)이 인기를 끄는 이유 중 하나는 이미지에서 유용한 특징들(features)을 스스로 찾도록 모델을 가르치는 것이 과거 인간이 구현한 어떤 if-then-else 규칙들보다 훨씬 더 효과적이기 때문이다. 또한, 딥 러닝(deep learning)은 사용중인 교육 데이터의 구조의 힌트에서 특징을 추출해 내므로, 모든 것을 완벽하게 파악할 필요가 없다.
특징(features)은 학습 데이터(training data)에 직접적으로 제공될 수도 있고, RGB 픽셀(pixel) 값(value)과 같은 입력(input)에서 자체적으로 추출해 만들어야 할 수도 있다.

The training loop
지도 학습(supervised learning)을 위한 훈련 과정(training process)은 다음과 같다.
모델(model)은 신경망(neural network)과 같이 선택된 특정 알고리즘(algorithm)이다. 예제로 구성된 교육 데이터(training data)와 이러한 예제에 대한 정답 레이블(label)을 제공하면, 모델(model)은 각 교육 예제(training examples)를 예측(prediction)한다.
처음에는 모델(model)이 아직 아무것도 배우지 않았기 때문에 예측(prediction)은 완전히 틀릴 것이다. 그러나 정답을 알고 있으므로, 예측  출력(outputpredicted output)을 예상 출력(expected output, 레이블(label), 정답)과 비교하여 모델이 얼마나 "잘못(wrong)"되었는지 계산할 수 있다. 이 “잘못(wrongness)”의 측정 값을 손실(loss) 또는 오류(error)라고 한다.
역 전파(back-propagation)는 훈련 과정(training process)에서 다음에 더 나은 예측(prediction)을 할 수 있도록, 손실 값(loss value)을 사용하여 모델(model)의 매개 변수(parameter)를 약간 조정(tweak)한다.
모델(model)에 모든 훈련 예제를 한 번만 보여주는 것만으로는 충분하지 않다. 이 과정을 수백 번 반복해야 한다. 반복할 때마다 손실(loss)이 조금씩 줄어드는데, 이는 예측(prediction)과 실제(true) 값 사이의 오차(error)가 작아져 모델(model)이 이전보다 개선되었음을 의미한다.
이 과정을 충분히 반복하고, 선택한 모델(model)이 작업을 학습하기에 충분하다면, 점차 모델(model)의 예측(prediction) 결과가 나아질 것이다.
일반적으로 모델(model)이 어느 정도 허용 가능한 최소한의 정확도(accuracy)나 최대 반복(iteration) 횟수에 도달할 때까지 계속 훈련한다 심층 신경망(deep neural network)의 경우 수백만 개의 이미지를 사용해, 수백 번의 반복을 거치는 일이 드물지 않다.
물론 실제 훈련 과정에서 조금 더 복잡한 상황이 발생할 수 있다. 예를 들어, 너무 오래 훈련하면 모델(model)의 성능이 오히려 더 나빠질 수 있다. 하지만 일반적으로는 훈련(training) 예제를 입력해, 예측(prediction) 하고, 오차에 따라 모델(model)의 매개 변수(parameters)를 수정해, 충분할 때까지 반복(repeat)한다.
기계 학습(machine learning) 모델(model)을 훈련시키는 것은 무 차별적(brute-force)이고 오랜 시간이 걸리는(time-consuming) 과정(process)이다. 알고리즘(algorithm)은 시행 착오(trial and error)에서 문제를 해결할 방법을 알아 내야한다. 대규모의 처리 능력(processing power)이 필요하며, 선택한 알고리즘(algorithm)의 복잡도(complexity)와 교육 데이터(training data)의 양에 따라 고성능 프로세서(processors)가 장착된 컴퓨터에서도 모델(model) 학습에 몇 주(weeks)가 걸릴 수 있다. 학습 작업의 규모가 클 경우, 일반적인 노트북(laptop)이나 데스크탑(desktop) 컴퓨터보다 훨씬 빠른 Amazon, Google, Microsoft의 서버(server)나 서버 클러스터(cluster)를 임대해 시간을 절약할 수 있다. 

What does the model actually learn?
모델이 정확히 무엇을 학습하는지(learn)는 선택한 알고리즘(algorithm)에 따라 달라진다. 예를 들어, 의사 결정 트리(decision tree)는 인간이 만든 것과 같은 if-then-else 규칙을 학습합니다. 그러나 대부분의 다른 기계 학습(machine learning) 알고리즘(algorithm)은 규칙을 직접(directly) 학습하는 것이 아니라, 모델(model)의 학습된 매개 변수(learned parameters) 또는 "매개 변수(parameters)"라고 하는 일련의 숫자(set of numbers)를 학습한다.
이 숫자는 알고리즘(algorithm)이 학습한 것을 나타내지만, 반드시 인간이 보기에 의미가 있는 것은 아니다. 단순히 if-then-else로 해석 할 수 없으며 그보다 더 복잡할 수 있다.
이러한 모델(model)이 완벽한 결과(outcome)를 생성하더라도, 모델(model)의 안에서 어떤 일이 일어나고 있는지 항상 명확한 것은 아니다. 커다란 신경망(neural network)은 매개 변수(parameters)가 5천만 개 이상인 것도 흔하며, 이를 전부 파악한다는 것은 결코 쉬운 일이 아니다.
모델(model)은 훈련 예제(training examples)를 암기(memorize)하는 것이 아니라는 것을 인식(realize)해야 한다. 단순히 예제를 암기하는 것은 매개 변수(parameters)를 학습하는 것이 아니다. 훈련 과정(training process)에서 모델 매개변수(model parameters)는 훈련 데이터를 그대로 보유(retain)하는 게 아니라, 어떤 종류의 의미(meaning)를 포착해야 한다. 이는 좋은 예시, 좋은 레이블(label), 문제에 적합한 손실 함수(loss function) 등을 선택하여 수행된다.
그럼에도 불구하고, 기계 학습(machine learning)의 주요 과제(challenge) 중 하나는 모델(model)이 특정 교육 예제를 기억하기 시작할 때 발생하는 과적합(overfitting)이다. 특히 수백만 개의 매개 변수(parameters)가 있는 모델(model)의 경우, 과적합을 피하기 어렵다.
친구 탐지기(friends detector)의 경우 모델(model)의 학습된 매개 변수(learned parameters)는 사람의 얼굴 모양, 사진에서 얼굴을 찾는 방법, 어떤 사람의 얼굴인지 등을 부호화(encode)한다. 그러나 모델(model)이 과적합(overfitting)되지 않도록, 훈련 이미지의 특정 픽셀(pixel) 값 블록(blocks)을 기억하지 않도록 해야 한다.
신경망(neural network)의 경우, 모델(model)은 특징(feature)을 탐지하는(detector) 역할을 하며, 관심 대상(얼굴, face)과 아닌 것(다른 모든 것, anything else)을 구분하는 법을 배운다.

Transfer learning: Just add data
데이터는 기계 학습(machine learning)의 전부다. 예측 유형(sort)을 정밀하게(accurately) 표현하는 데이터로 모델(model)을 훈련시켜야한다.
좋은 기계 학습 모델(machine-learning model)을 만드는 데 필요한 작업량은 데이터와 모델(model)의 종류에 따라 달라진다. 무료로 배포되어 있는 훈련된 모델의 경우에는 단순히 Core ML로 변환하여 iOS 앱에 추가하면 된다.
그러나 기존 모델(model)의 출력(output)이 원하는 출력(output)과 다를 수도 있다. 예를 들어, 다음 장에 사용할 사진 속의 간식(snack)이 건강에 이로운지 또는 해로운지 분류하는 프로젝트에서 사용할 수 있는 무료 모델(model)이 없기에 해당 모델을 직접 만들었다.
이런 경우, 전이 학습(transfer learning)이 도움이 될 수 있다. 실제로 기계 학습(machine learning)으로 어떤 문제를 해결하려 할 때, 전이 학습(transfer learning)은 99%의 확률로 가장 좋은 방법이다. 전이 학습(transfer learning)을 사용하면, 다른 사람들이 이미 학습해 놓은 결과를 쉽게 사용할 수 있다.
딥 러닝 모델(deep-learning model)을 훈련할 때, 해당 이미지 분류(classifying)에 유용한 이미지의 특징(features)을 식별(identify)하는 방법을 학습한다. Core ML에는 수천 가지 특징(features)을 감지하고, 1,000 개의 서로 다른 종류(class)의 객체(object)를 이해하는 즉시 사용 가능한(ready-to-use) 많은 모델(model)이 포함되어 있다. 이러한 대규모 모델(model)을 처음부터 교육(Training)하려면 매우 큰 데이터 세트(dataset)과 엄청난 양의 계산(computation)이 필요하며 비용이 많이들 수 있다.
무료로 제공되는 이러한 모델(model)의 대부분은 인간, 동물, 일반적인 사물(object)의 다양한 사진들을 학습(trained)한다. 대부분의 학습 시간은 사진을 가장 잘 표현하는 특징(features) 감지 방법을 배우는 데 소비된다. 모델이 이미 학습 한 특징(가장자리(edges), 모서리(corners), 색상(color) 패치, 형태(shapes) 사이의 관계)이 예제와 유사한 경우, 범주(class)를 분류(classifying)하는데 유용할 수 있다. 
따라서 동일한 특징(features)을 배우기 위해 자신의 모델(model)을 처음부터 훈련시킨다면 낭비가 될 것이다. 대신에, 기존의 사전 훈련(pre-trained) 모델(model)을 가져와 자체 데이터 세트(dataset)에 맞게 수정(customize)할 수 있습니다. 기존 모델(existing model)의 지식(knowledge)을 자신의 모델(your own model)로 전송(transfer)하기 때문에, 이를 전이 학습(transfer learning)이라고 한다.
실제로 기존의 사전 훈련 모델(pre-trained model)을 사용해, 자체 학습 데이터(own training data)에서 특징(features)을 추출(extract)한 다음 추출된 특징에서 예측(predictions)하는 방법을 학습하도록 모델(model)의 최종 분류 계층(final classification layer)만 교육한다.
전이 학습(transfer learning)은 전체 모델(model)을 처음부터 교육하는 것보다 훨씬 빠를 뿐 아니라, 데이터 세트(dataset)도 훨씬 작을 수 있다는 장점이 있다. 수백만 장 대신, 수천 또는 수백 장의 이미지만 있으면 된다.
Apple은 전이 학습(transfer learning)을 수행하는 두 가지 도구(tool)로 Create ML과 Turi Create를 제공한다. 이는 이미지 분류(image classification) 또는 감정 분석(sentiment analysis)과 같이 가장 많이 사용되는 기계 학습 작업(machine-learning tasks)에 대한 전이 학습(transfer learning) 도구를 찾을 수있는 유용한 기술이다. 때로는 데이터를 단순히 끌어다 놓는 것(drag-and-dropping)만큼이나 쉽게 사용할 수 있다. 몇 줄의 코드만 작성하여 데이터를 읽고 구조화(structure) 할 수 있다.




Can mobile devices really do machine learning?
훈련된 모델(model)의 크기는 수백 MB일 수 있고 추론(inference)은 ​​일반적으로 수십억 번의 계산을 수행하므로, 빠른 프로세서와 대용량의 메모리가 있는 서버에서 진행하는 경우가 많다. 예를 들어, Siri는 음성 명령(voice commands)을 처리하기 위해 인터넷 연결이 필요하다. 음성은 의미를 분석(analyzes)하는 Apple 서버로 전송되고, 관련 응답(response)을 되돌려 받는다.
이 책의 목적은 모바일 환경에서 최첨단(state-of-the-art) 기계 학습(machine learning)을 수행하는 것이므로, 가능한 한 장치(device)에서 많은 작업을 처리하고, 서버 사용을 최소화한다. Metal과 Accelerate와 같은 핵심 기술(core technologies)을 사용하면 iOS 기기(device)에서의 추론(inference)도 매우 효과적으로 구현할 수 있다.
장치에서(on-device) 추론(inference)의 이점은 다음과 같다.
1. 응답(response) 시간이 빠르다 : HTTP 요청(request)을 서버에 보내고 응답(response)을 받는것보다 속도가 빠르므로, 실시간 추론(inference)을 수행해 보다 나은 사용자 환경(user experience)을 제공할 수 있다.
2. 사용자 개인 정보 보호에 도움이 된다 : 사용자 데이터는 처리를 위해 백엔드(backend) 서버로 전송되지 않으며, 장치(device)에 남아 있다.
3. 서버 유지 비용이 들지 않으므로 저렴하다 : 대신 사용자의 배터리를 사용한다. 물론 모델(model)을 최대한 효율적으로 구현하는 것이 중요하다. 
반면, 기기에서 학습(on-device training)은 몇 가지 커다란 한계가 있기 때문에 좋은 선택이 아니다. 기계 학습 모델(machine-learning model)을 훈련(training)시키는 데는 많은 처리 능력이 필요한데, 소규모 모델(model)을 제외하고는 현시점에서 대부분의 모바일 장치(mobile devices) 성능이 이를 따라가지 못한다. 입력대로 학습하는 예측 키보드(predictive keyboard)와 같이 사용자가 제공하는 새로운 데이터로 이전에 훈련된 모델(trained model)을 업데이트하는 것("온라인 교육(online training)"이라고도 함)은 모델이 충분히 작다면 가능하다.
Core ML 3는 기기(device)에서 제한된 종류의 훈련(training)을 할 수 있지만, 이는 모델(model)을 처음부터 교육하기위한 것이 아니라 사용자의 데이터로 모델(model)을 미세 조정(fine-tune)하기 위한 것이다. 이 책에서는 오프라인으로(offline) 훈련된 모델을 사용하여 예측(predictions)하는 것에 중점을 두고 있으며, Mac 또는 클라우드(cloud) 서비스에서 해당 모델을 훈련하는 방법을 설명한다.

Why not in the cloud?
수 많은 소규모 기업을 비롯해 Amazon, Google, Microsoft까지 기계 학습(machine learning)을 위한 클라우드 기반 서비스(cloud-based services)를 제공하고 있다. 이들 중 일부는 단지 원시 컴퓨팅 기반(raw computing power, 서버 임대)을 제공한다. 또한 일부는 기계 학습(machine learning)의 세부 사항을 전혀 신경 쓸 필요없는 완전한 API를 제공하기도 한다. 이런 서비스는 데이터를 API로 보내면 몇 초 후에 결과를 반환(return)해 준다.
이러한 클라우드 서비스(cloud services)를 사용하면 많은 이점(benefits)이 있다.
1. 기계 학습(machine learning)에 대해 아무것도 알 필요가 없다. 책의 나머지 부분을 읽을 필요도 없어진다.
2. 이런 서비스를 사용하는 것은 HTTP 요청(request)을 보내는 것만큼이나 쉽다.
3. 직접 서버를 운영하고 관리할 필요가 없다.
그러나 다음과 같은 단점(downsides) 또한 존재한다.
1. 서비스가 자신의 데이터에 맞춤화되지 않을 수 있다.
2. 앱에서 실시간으로(real-time) 기계 학습(machine learning)을 수행해야하는 경우(예 : 비디오) HTTP 요청(request) 전송이 너무 느려진다.
3. 서비스는 편리하지만 비용이 든다. 이용료를 지불해야 하며, 서비스를 한 번 선택하면 앱을 다른 서비스로 이전하기 어렵다.
이 책에서는 클라우드 서비스(cloud services) 사용에 중점을 두지 않는다. 실시간(real-time) 예측(predictions)이 필요하지 않은 경우 많은 앱에서 유용한 해결책이 될 수 있지만, 모바일 개발자로서 엣지 컴퓨팅(edge computing)이라고도 하는, 장치에서(on the device) 기계 학습(machine learning)을 구현하는 것이 더 흥미로울 것이다.




Frameworks, tools and APIs
기계 학습(machine learning)을 사용하면, 뒷단에서(backside) 매우 복잡한 작업을 해야 할 것처럼 보인다. 하지만 모든 프로그래밍 기술과 마찬가지로 기계 학습(machine learning)도 추상화(abstraction)되어 있기 때문에 반드시 그렇지만은 않다. 복잡도(difficulty)와 시간(effort)은 구현해야 하는 수준(level)에 따라 달라진다.

Apple’s task-specific frameworks
최고 수준의 추상화(abstraction)는 작업 수준(task level)에서 이루어 진다. 이는 파악하기가 가장 쉬운 것으로, 앱에서 수행하려는 것과 직접적으로 연결(map)된다. Apple과 기타 주요 기업은 이미지(image) 또는 텍스트(text) 분류(classification)를 위한 작업 중심 툴킷(toolkits)을 제공(provide)한다.
Apple은 웹 페이지는 다음과 같이 말하고 있다 : 기계 학습 전문가가 될 필요는 없다(You don’t have to be a machine learning expert)!
Apple은 특정 기계 학습(machine learning) 작업 수행을 위한 몇 가지 Swift 프레임 워크(frameworks)를 제공한다:
- Vision : 이미지에서 얼굴(face), 얼굴의 주요 부위(landmarks), 사각형(rectangles), 바코드(bar codes), 텍스트(text) 등 감지(detect). 영상(video)에서 객체(object) 추적(track). 고양이 / 개 및 기타 여러 유형(type)의 사물(objects)를 분류(classify) 등의 작업을 할 수 있다. 또한 Vision은 입력(input) 이미지 형식을 올바르게 변환하여 Core ML 이미지 모델(model)을 보다 쉽게 ​​사용할 수 있도록 한다.
- Natural Language : 텍스트를 분석하여 언어(language), 이야기의 일부, 특정 사람, 장소, 조직 등을 식별(identify)한다.
- SoundAnalysis : 오디오 파형(waveforms)을 분석(analyze)하고 분류(classify)한다.
- Speech : 음성을 텍스트로 변환, Apple 서버 또는 기기(on-device)의 음성 인식기(speech recognizer)를 사용하여 답변을 검색한다. Apple 서버를 이용할 경우, 오디오의 길이와 일일 요청(request) 건수에 제한이 있다.
- SiriKit : 메시지(messaging), 노트(lists and notes), 운동(workouts), 결제(payments), 사진(photos) 등의 extension을 구현하여 Siri 또는 Maps의 앱 서비스 요청(request)을 처리한다.
- GameplayKit : 질문(questions)과 가능한 답변(possible answers ) 및 결과 행동(consequent actions)이 포함된 의사 결정 트리(decision tree)를 평가한다.
위 목록 중 하나를 사용할 수 있다면, 적절한 API를 호출해 어려움 작업을 프레임 워크(framework)에게 위임할 수 있다.

Core ML ready-to-use models
Core ML은 모바일에서 기계 학습(machine learning)을 수행하기 위한 Apple의 프레임 워크이다. 사용하기 쉽고 Vision, Natural Language, SoundAnalysis 등의 프레임 워크(frameworks)와도 잘 통합된다. Core ML에는 한계(limitations)가 있지만, 기계 학습(machine learning)을 시작하기 좋다.
Core ML은 단순한 프레임 워크(frameworks)가 아닌, 기계 학습(machine learning) 모델(model) 공유를 위한 파일 형식이기도 하다. Apple은 developer.apple.com/machine-learning/models에서 미리 준비된(ready-to-use pre-trained) 다양한 이미지 및 텍스트 모델(model)을 Core ML 형식으로 제공한다.
또한, 인터넷의 “모델 동물원(model zoos)”에서 사전 훈련 된 다른 Core ML 모델(model)을 찾을 수도 있다. : github.com/likedan/Awesome-CoreML-Models
iOS 앱에 모델(model)을 추가할 때는 크기(size)가 중요하다. 대규모 모델(model)은 배터리를 많이 소모하며, 소규모 모델(model)보다 느리다. Core ML 파일의 크기는 모델(model)이 학습한 매개 변수(learned parameters)의 수에 비례한다. 예를 들어, 2,560 만 개의 매개 변수(parameters)가 있는 ResNet50 모델(model)은 103MB 이다. 6 백만 개의 매개 변수(parameters)가 있는 MobileNetV2는 "단지" 25MB 이다. 하지만, 매개 변수가 더 많은 모델(model)이 반드시 더 정확(accurate)한 것은 아니다. ResNet50은 MobileNetV2보다 훨씬 크지만 두 모델의 분류(classification) 정확도(accuracy)는 비슷하다.
이러한 모델(model)은 웹에서 찾을 수있는 다른 무료 모델(free models)과 마찬가지로 매우 일반적인 데이터 세트(generic datasets)에 대해 교육(trained)된다. 장치(gizmos) 제조 과정에서 결함을 감지(detect)하는 앱을 만들때, 다른 사람이 훈련해 놓은 무료 모델(model)을 사용할 수 있다면 매우 운이 좋은 경우이다. 좋은 모델(model)을 만드는 데에는 많은 비용이 들고 대다수의 기업들이 무료 공개하지 않기 때문에, 자신만의 모델(model)을 만드는 방법을 알아야 한다.

Convert existing models with coremltools
원하는 것을 정확하게 수행하지만 Core ML 형식이 아닌 기존 모델(model)을 쉽게 변환 할 수도 있다.

기계 학습(Machine learning) 모델(model) 교육을 위한 인기 있는 오픈 소스(open-source) 패키지(packages)의 예는 다음과 같다.

Apache MXNet
- Caffe (and the relatively unrelated Caffe2)
- Keras
- PyTorch
- scikit-learn
- TensorFlow
이러한 패키지(packages)로 학습된 모델이 있는 경우(XGBoost, LIBSVM, IBM Watson등 다른 패키지(packages)를 사용한 모델(model)도 가능), coremltools을 사용해 Core ML 형식으로 변환하여 iOS 앱에서 실행할 수 있다.
coremltools는 Python 패키지(package)로, 이를 사용하려면 Python 스크립트(script)를 작성해야 한다. Python은 기계 학습 프로젝트(machine-learning projects)에서 가장 광범위하게 사용하는 프로그래밍 언어로, 대부분의 교육 패키지(training packages)도 Python으로 작성되었다.
TensorFlow와 MXNet과 같은 일부 모델(model) 형식(formats)은 coremltools에서 직접 변환을 지원하지 않지만, 해당 패키지 자체적인 Core ML 변환기(converters)가 있다. IBM의 Watson은 Swift 프로젝트를 제공하지만, Core ML 모델(model)을 자체 API로 래핑(wraps)한다.
현재는 다양한 훈련 도구(training tools)들이 서로 호환되지 않는(incompatible) 형식(formats)을 가지고 있기 때문에 표준 형식(standard format)을 만들려고 노력하고 있다. Apple의 Core ML도 이 중 하나이지만, ONNX가 좀 더 대중적으로 사용되고 있으며, 당연히 ONNX에서 Core ML 로의 변환도 가능하다.
Core ML에는 여러 가지 제한(limitations)이 있으며, 다른 기계 학습 패키지(machine-learning packages)만큼 성능이 뛰어나지 않음을 유의해야 한다. Core ML은 특정 연산(operations)이나 신경망 계층(neural network layer)을 지원하지 않을 수 있으므로, 이러한 도구(tool)로 학습된(trained) 모델(model)이 실제 Core ML로 변환 할 수 있다(converted)는 보장은 없다. 이 경우에는 변환하기 전의 원본(original) 모델(model)을 조정(tweak)해야 할 수도 있다.

Transfer learning with Create ML and Turi Create
사전 훈련된(pre-trained) 기본 모델(model)을 Create ML 및 Turi Create로 가져와 자신의 데이터로 전이 학습(transfer learning)할 수 있다. 기본 모델(model)은 매우 큰 데이터 세트(datasets)로 학습되었지만, 전이 학습(transfer learning)은 훨씬 더 작은 데이터 세트(datasets)와 적은 교육 시간으로 데이터에 대한 정확한 모델을 생성 할 수 있다.
훈련에 수만 장이 아닌 수십, 수백 장의 이미지만 있으면 되고, 시간 또한 며칠이 아닌 몇 분이면 충분하다. 즉, 자신의 Mac에서 편안하게 모델을 훈련(train)할 수 있다.
실제로 Create ML과 Turi Create (버전 5 기준)는 Mac의 GPU를 사용하여 훈련 속도를 높일 수 있다.
Apple은 2016년 8월 스타트업이었던 Turi를 인수 한 후, 2017년 12월에 Turi Create를 오픈 소스 소프트웨어(open- source software)로 출시했다. Turi Create는 Apple 최초의 전이 학습(transfer learning) 도구(tool)이지만, Python 환경에서 작업해야 한다.
WWDC 2018에서 Apple은 Turi Create의 Swift 기반(Swift-based)의 서브셋(subset)인 Create ML을 발표하여, Swift와 Xcode를 이용한 영상 및 텍스트 분류(classification) 전이 학습(transfer learning)을 제공하였다. Xcode 11부터 Create ML은 별도의 앱이다.
Turi Create와 Create ML의 기준은 모델(model)이 아니라 작업이다(task-specific). 즉, 사용하려는 모델(model) 유형을 선택하는 것이 아니라 해결하려는 문제(problem) 유형을 지정해야 한다. 해결하려는 문제 유형과 일치하는 작업을 선택하면, Turi Create가 데이터를 분석하여 작업(task)에 적합한 모델(model)을 선택한다.
Turi Create의 작업 중심(task-focused) 툴킷(toolkits) 종류는 다음과 같다.
- 이미지 분류(Image classification) : 이미지에 의미있는 레이블(label)을 지정한다.
- 드로잉 분류(Drawing classification) : Apple Pencil의 드로잉(line drawings)을 위한 특별한 이미지 분류기(image classifier)이다.
- 이미지 유사성(Image similarity) : 특정 이미지와 유사한 이미지를 찾는다. 예를 들어, Biometric Mirror 프로젝트가 있다.
- 추천 시스템(Recommender system) : 사용자의 과거 선택(interactions)을 기반으로, 영화, 책, 휴일 등에 대한 맞춤 추천을 제공한다.
- 객체 탐지(Object detection) : 이미지에서 객체(objects)를 찾아 분류(classify)한다.
- 스타일 전송(Style transfer) : 스타일 이미지의 요소(stylistic elements)를 새 이미지에 적용한다.
- 활동 분류(Activity classification) : 장치(device)의 모션 센서(motion sensor) 데이터를 사용하여 걷기(walking), 뛰기(running), 흔들기(waving) 등의 사용자 활동을 분류(classify)한다.
- 텍스트 분류(Text classification) : 소셜 미디어, 영화 리뷰, 콜센터 대화 등의 텍스트에서 긍정적(positive) 또는 부정적(negative) 감정을 분석(Analyze)한다.
- 소리 분류(Sound classification) : 어떤 소리가 언제 나는지 탐지한다.
Create ML은 이러한 툴킷(toolkits) 중, 이미지, 텍스트, 활동, 소리 분류, 객체 감지를 지원한다. Apple은 향후 업데이트에서 더 많은 툴킷(toolkits)을 추가 할 것이다.

Turi Create’s statistical models
지금까지 작업별(task-specific) 해결책에 대해 설명했다. 이제 한 단계 더 깊은(deeper) 모델 수준(model level)에서의 추상화(abstraction)를 살펴 본다. 작업(task) 선택 후, API가 최적의 모델(model)을 선택하는 대신 직접 모델(model)을 선택한다. 이렇게 하면, 모델(model)을 더 자세하게 제어할 수 있지만, 구현해야 할 코드도 많아진다.
Turi Create에는 다음과 같은 범용 모델(general-purpose models)이 포함되어 있다:
- 분류(Classification) : 부스트 트리 분류(Boosted trees classifier), 의사 결정 트리 분류(decision tree classifier), 로지스틱 회귀(logistic regression), 최근접 이웃 분류(nearest neighbor classifier), 랜덤 포레스트 분류(random forest classifier), 서포트 벡터 머신(Support Vector Machines, SVM)
- 클러스터링(Clustering) : K-평균(K-Means), 디비스캔 군집화(DBSCAN (밀도(density) 기반))
- 그래프 분석(Graph analytics) : 페이지 링크(PageRank), 최단 경로(shortest path), 그래프 컬러링(graph coloring) 등
- 최근접 이웃(Nearest neighbors)
- 회귀(Regression) : 부스트 트리 회귀(Boosted trees regression), 의사 결정 트리 회귀(decision tree regression), 선형 회귀(linear regression), 랜덤 포레스트 회귀(random forest regression)
- 토픽 모델(Topic models) : 텍스트 분석용(for text analysis)
이 모델을 배울 필요는 없다. 작업 중심 툴킷(task-focused toolkit)을 사용하는 경우, Turi Create는 데이터 분석을 기반으로 적합한 통계 모델(statistical models)을 선택한다. Turi Create가 만족할만한 모델(model)을 생성하지 못하는 경우, 직접 모델(model)을 선택해 사용할 수 있다.
Turi Create에 대한 자세한 내용은 github.com/apple/turicreate/tree/master/userguide/에서 확인할 수 있다.

Build your own model in Keras
Apple의 프레임 워크(frameworks)와 작업 중심 툴킷(task-focused toolkits)로 대부분의 앱에 사용되는 기계 학습 모델을 구현할 수 있지만, Create ML 과 Turi Create로 적합한 모델(model)을 만들 수 없다면, 자신만의 모델(build your own model)을 처음부터(from scratch) 만들어야 한다.
이를 위해 다양한 유형의 신경망 계층(neural network layers), 활성 함수(activation functions), 배치 크기(batch sizes), 학습률(learning rates), 기타 하이퍼 매개변수(hyperparameters) 등을 학습해야 한다. 차후에 이 모든 새로운 용어들과 Keras를 사용해 딥 러닝 네트워크(deep-learning networks)를 구성하고 훈련하는 방법을 배운다.
Keras는 가장 인기 있는 딥 러닝(deep-learning) 도구(tool)인 Google TensorFlow의 래퍼(wrapper) 이다. TensorFlow는 학습 곡선(learning curve)이 다소 가파른 저 수준(low-level) 툴킷(toolkit)으로, 행렬(matrix)과 같은 수학을 이해해야 하므로 여기서는 직접 사용하지 않는다. Keras는 사용하기가 훨씬 쉽다. 더 높은 수준의 추상(abstraction) 단계에서 작업하며, 수학을 전혀 몰라도 된다.
Swift for TensorFlow도 있다. 이는 Swift를 창안한 Chris Lattner가 이끄는 Google Brain의 프로젝트(project)로, TensorFlow 사용자에게 Python보다 나은 프로그래밍 언어를 제공하기 위한 것이다. 이는 TensorFlow 사용자가 Swift로 구현을 더 쉽게 하기 위한 프로젝트이지, Swift 사용자가 TensorFlow를 더 쉽게 배우기 위한 프로젝트가 아니다. Swift for TensorFlow의 대상자는 모바일(mobile) 환경에서 기계 학습(machine learning)을 구현하는 개발자가 아닌 기계 학습 연구자들(researchers)이다.

Gettin’ jiggy with the algorithms
기계 학습(machine learning) 온라인 강좌 또는 교재를 살펴 봤다면, 경사 하강법(gradient descent), 역 전파(back-propagation), 옵티마이저(optimizers)와 같은 효율적인 알고리즘(algorithms)에 대한 복잡한 수식을 본 적 있을 것이다. iOS 앱 개발자로서, 그 어떤 것도 배울 필요가 없다.
고급 도구(high-level tools)와 프레임 워크(frameworks)를 이해하고 효과적으로 사용할 수 있으면 된다. 연구자들(researchers)이 더 나은 알고리즘(algorithm)을 개발하면, 특별한 작업을 수행할 필요 없이 Keras와 사전 훈련 모델(pre-trained models)과 같은 도구(tools)를 사용해 신속하게 구현할 수 있다. 일반적으로 기계 학습(machine learning)을 사용하기 위해, 처음부터 학습 알고리즘(learning algorithms)을 구현할 필요가 없다.
그러나 Core ML은 새로운 iOS 버전을 출시(releases)해야만 업데이트되므로, 업계의 경향을 따라가기 버거울 수 있다. 기계 학습(machine learning)의 최신 경향을 따라가고자 하는 개발자는 새로운 알고리즘을 구현할 수 있어야 한다. Apple이 Core ML을 업데이트(update)하기를 기다리는 것은 좋은 선택이 아닌 경우도 있기 때문이다. 다행히 Core ML을 사용하면 모델(model)을 유연하게(flexibility) 변경(customize)할 수 있다.
Core ML보다 저 수준(low-level)이면서 iOS에서 사용할 수 있는 몇 가지 기계 학습(machine learning) 프레임 워크(frameworks)는 다음과 같다. Core ML이 충분하지 않은 경우에만 사용하는 것이 좋다.
- Metal Performance Shaders : Metal은 iOS 장치(device)에서 GPU를 프로그래밍(programming)하기 위한 공식(official) 프레임 워크(framework) 및 언어(language)이다. 상당히 저 수준(low-level)이며, 최고의 제어력(control)과 유연성(flexibility)을 제공한다.
- Accelerate : 이 평가 절하(underappreciated)된 프레임 워크(framework)는 모든 iOS 장치(device)에 제공되며, 고도로 최적화된(optimized) CPU 코드를 작성할 수 있다. Metal이 GPU를 최대한 활용하듯이, Accelerate도 CPU에서 동일하게 작동한다. 신경망 라이브러리(neural-networking library)의 BNNS (Basic Neural Networking Subroutines)는 선형 대수(linear algebra) 및 기타 수학에 최적화된 코드를 가지고 있다. 자체적인 기계 학습(machine learning) 알고리즘(algorithms)을 처음부터 구현하는 경우 Accelerate을 사용할 수 있다.

Third-party frameworks
Apple의 자체 API 외에도 다양한 iOS 머신 러닝 프레임 워크(machine learning frameworks)가 있다. 
- Google ML Kit : Vision 프레임 워크(framework)와 비슷한 Google의 프레임 워크(framework)이다. ML Kit를 사용하면 이미지 라벨링(labeling), 텍스트 인식(text recognition), 얼굴 인식(face detection) 등의 작업을 앱에 쉽게 추가 할 수 있다. ML Kit는 클라우드(cloud)뿐 아니라 장치에서도 실행할 수 있으며, iOS와 Android를 모두 지원한다.
- TensorFlow-Lite : Google의 인기 있는 기계 학습 프레임 워크(machine-learning framework) TensorFlow의 모바일 기기(devices) 버전이다. TF-Lite의 주요 장점은 "lite" 형식(format)으로 먼저 변환(convert)해야 하지만, TensorFlow 모델(model)을 불러올(load) 수 있다는 것이다. 최근에 iOS의 GPU 가속(acceleration)에 대한 지원이 추가되었지만, 이 글을 쓰는 시점에서 TF-Lite는 아직 Neural Engine을 사용할 수 없다. 또한, API가 C ++로 되어있어 Swift에서 사용하기가 어렵다.




ML all the things?
기계 학습(Machine learning), 특히 딥 러닝(deep learning)을 사용하면 이미지 분류(image classification), 음성 인식(speech recognition)등의 작업을 매우 성공적으로 처리할 수 있지만, 모든 문제를 해결할 수는 없다. 일부 문제(problems)에는 효과적이지만 다른 문제에서는 전혀 쓸모가 없을 수 있다. 딥 러닝 모델(deep-learning model)은 인간의 상식(common sense)과 다르게, 실제 보이는 것에 대해 타당한 이치(reason)를 부여 하지 않는다.
딥 러닝(Deep learning)은 객체(object)가 분리된 부분으로 구성 될 수 있다는 것, 객체가 갑자기 나타나거나 사라지지 않는다는 것, 둥근 객체가 탁자에서 굴러 떨어질 수 있다는 것, 아이들이 야구 방망이를 입에 넣지 않는다는 것 등을 알지 못하거나 신경 쓰지 않는다.
현재의 기계 학습 모델(machine-learning models)은 기껏해야 매우 훌륭한 패턴 검출기(pattern detector)일 뿐이다. 그 이상의 지나친 기대를 하는 것은 옳지 않다. 진정한 지능을 가진 기계(machine intelligence)라 하기에는 아직 많이 부족하다.
기계 학습 모델(machine-learning model)은 제공한 예제(examples)로부터만 배울 수 있지만, 제공되지 예제 또한 중요하다. 인간의 이미지에 대해서만 훈련된 친구 탐지기(friends detector)모델에서 개의 이미지로 추론(inference)하려 한다면, 아마도 가장 개와 닮은 친구의 얼굴을 "탐지(detect)"할 것이다. 모델(model)이 개와 사람의 얼굴이 다르다는 것을 배울 기회가 없었기 때문에 이런 현상이 발생한다.
기계 학습 모델(Machine-learning models)이 기대하는 것을 학습하지 못하는 경우도 있다. 예를 들어 고양이와 강아지 사진을 구별하는 분류기(classifier)를 훈련했을 때, 훈련에 사용한 모든 고양이 사진은 맑은 날에 촬영하고, 모든 개 사진은 흐린 날에 촬영했다면, 동물 대신 날씨를 "예측(predicts)"하는 모델(model)을 훈련 시킨 것일 수도 있다.
컨텍스트(context)가 부족하기 때문에 딥 러닝 모델(deep-learning models)이 잘못 학습할 수 있다. 인간은 딥 러닝 모델(deep-learning model)이 추출하는 모서리(edges), 모양(shapes) 등의 몇가지 특징(features)을 이해할 수 있지만, 모델(model)에게 특별한 의미가 있는 대부분의 특징들(features)은 우리에게 픽셀(pixel)의 추상적 패턴(abstract patterns)처럼 보일 뿐이다. 모델(model)이 어떻게 예측(predictions)하는지 이해하기는 어렵지만, 잘못된 모델(model)을 만드는 것은 쉬운 일이다.
모델(model)을 생성한 것과 동일한 학습(training) 방법을 사용하여 이미지에 소량의 노이즈(noise)를 추가하면, 모델(model)을 속이는 예를 만들 수 있다. 인간에게는 그 이미지가 여전히 동일하게 보이지만, 모델(model)은 완전히 다른 것으로 분류한다. 예를 들어, 판다를 긴팔 원숭이(gibbon)로 분류하거나(classified), 녹색 신호등(green traffic light)으로 오인할 수도 있다.
이러한 오인에 대한 모델(models)의 학습 방법에 많은 연구가 현재 진행되고 있다.
여기서 알아야 할 것은 머신 러닝(machine learning)의 한계를 이해하고 다루는 것이 처음부터 모델(model)을 구축하는 것만큼이나 중요하다는 것이다. 그렇지 않으면, 불쾌한 놀라움에 빠질 수 있다.




The ethics of machine learning
기계 학습(Machine learning)은 인공 지능(artificial intelligence)의 범위를 일상 생활로 확장시키는(extending) 강력한 도구이다. 훈련된 모델(trained models)을 사용하면 재미있고, 시간이 절약되며, 수익을 얻을 수 있지만, AI 오용(misuse)은 해로울 수 있다.
인간의 두뇌는 위험에 대해 빠른 결정을 하도록 진화했고, 지름길(shortcuts)을 이용하는 것을 행복해 한다. 누구를 고용하고 해고할지, 대학 입학, 대출 심사, 어떤 치료법을 사용해야 할지, 누구를 투옥할 것인지, 얼마나 오래 살 것인지 등에 대한 삶을 변화시키는 결정을 내려야 할 때 요식적인 척도로 집착하면 문제가 발생할 수 있다. 그리고 기계 학습 모델(machine-learning model) 예측(predictions)은 때로는 편향된(biased) 데이터를 기반하는 지름길을 제공하며, 일반적으로 모델(model)이 어떻게 예측 했는지에 대한 설명은 하지 않는다.
go.unimelb.edu.au/vi56에서 사람의 사진을 보고 성격 특성(traits)을 예측하는, Ben Grubb 기자(journalist)의 Biometric Mirror 프로젝트(project) 결과는 다음과 같다.
그의 기사는 제목에서 다음과 같이 말하고 있다 - bit.ly/2KWRkpF : 이 알고리즘(algorithm)은 공격적(aggressive)이고 무책임(irresponsible)하며 매력적이지 않다(unattractive). 그러면 이 알고리즘(algorithm)을 믿어야 할지 알 수 없다. 
이 알고리즘(algorithm)은 2,222 개의 얼굴 사진 데이터 세트(dataset)에서 입력 사진과 가장 일치하는 것을 찾는 간단한 이미지 유사성 모델(image-similarity model)이다. 33,430명의 참가자들(crowd-sourced people)이 공격성(aggression), 정서적 안정성(stability), 매력(attractiveness), 기이함(weirdness) 등을 포함한 다양한 성격 특성(traits)을 예측(predict)하기 위해 데이터 세트의 사진을 평가했다. 이 모델(model)은 가장 일치하는 사진을 사용하여 성격 특성(traits)을 예측한다.
해당 기자는 자신의 다양한 사진으로 실험했고, 모델(model)은 실제보다 그가 더 젊고(younger) 매력적(attractive)이라 예측했다.
이는 재미있지만(amusing), 위험(harmful)할 수 있다.
이 모델(model)이 정서적 안정성(emotional stability)과 같은 특성(traits) 중 하나를 선택하는 대화형 어플리케이션(interactive application)의 일부로, 보험사, 고용주, 법 집행 공무원과 같은 사람들이 사용한다고 가정하면, 걱정이 될 수 밖에 없을 것이다.
bit.ly/2LMialy에서 이 프로젝트의 주요 연구원들(lead researchers)은 “[Biometric Mirror]는 AI와 알고리즘의 편향적인(bias) 결과를 극명하게 보여 주며, 정부와 기업의 의사결정(decisions)에 AI에 점점 더 의존하는 경향에 대해 성찰하도록 한다.” 고 말한다.
그리고 프로젝트(project) 페이지에는 다음과 같이 쓰여 있다.
알고리즘은 정확하지만(correct), 반환된(returns) 정보는 정확하지 않다. 그리고 이것이 정확히(precisely) 공유하고자하는 목표이다: 인공 지능(artificial intelligence) 시스템은 내부 논리가 부정확하거나(incorrect), 불완전하거나(incomplete), 극도로 민감하거나(sensitive), 차별적(discriminatory) 일 수 있으므로 AI에 의존하는 것에 주의해야 한다.
이 프로젝트(project)는 AI 사용에 있어 두 가지 윤리적(ethical) 질문을 제기한다.
- 알고리즘의 편향(Algorithmic bias)
- 설명 가능하거나 이해할 수 있는 AI(Explainable or understandable AI)

Biased data, biased model
훈련되지 않은 데이터를 정확하게 예측(predictions)할 수 있다면, 기계 학습 모델(machine-learning model)이 좋은 것으로 간주한다. 즉, 훈련 데이터 세트(training dataset)에서는 잘 작동한다(generalizes). 그러나 교육 데이터(training data)가 일부 그룹에 대해 편향된(biased) 경우 문제가 발생할 수 있다: 그 데이터는 인종 차별적(racist)이거나 성 차별적(sexist)일 수 있다.
편견(bias)의 이유는 역사적(historical) 일 수 있다. 대출 연체 위험이나 대학진학 이후 성취도를 예측하는(predicts) 모델(model)을 훈련 시키려면, 대출을 연체했거나 대학에서 성취도가 좋지 못한 사람들의 과거 데이터를 사용해야 한다. 그리고 이 자료는 역사적으로(historically) 백인 남성들이 오랫동안 대부분의 대출과 대학 입학 허가를 받았기 때문에 이들에게 유리할 것이다.
데이터에는 여성과 인종 소수자(racial minorities)들의 표본이 적기 때문에, 모델(model)은 전체적으로 90%의 정확도(accurate)를 보일지라도, 여성과 인종 소수자들에 대한 정확도는 50%가 될 수도 있다.
또한 이 자료는 애초에 의사 결정자들(decisions)이 편향되었을 수 있다: 대출 공무원이 백인 남성의 대출 연체에 더 관대했거나, 대학 교수가 특정 인구 통계(demographics)에 대해 편향(biased)을 가지고 있었을 수도 있다.
훈련 데이터(training data)나 매개 변수(parameters)를 명시적으로 조정하여(adjusting) 모델(model)이 편향(bias)을 해소하도록 시도할 수 있다. 일부 모델 아키텍처(model architectures)는 민감한 특징(features)을 식별하고, 예측에 미치는 영향을 줄이거나 제거하도록 조정할 수 있다.

Explainable/interpretable/transparent AI
알고리즘 편향(algorithmic bias) 문제는 ML 모델(model)의 예측(predictions)에 어떤 특징(features)을 사용 했고, 그것이 정확(accurate)하고 공정(fair)한지 검토하는 것이 중요하다는 것을 의미한다.
앞부분의 도표(diagram)에서 교육(training)은 블랙 박스(black box)로 그려졌다. 상자 안에서 무슨 일이 일어나는지 알게되더라도, 많은 딥 러닝 모델(deep learning models)은 너무 복잡하여, 제작자조차도 개별적인 예측(individual predictions)을 설명 할 수 없다.
알고리즘 편향(algorithmic biases)과 이를 극복하기 위한 한 가지 접근방식은, 모델(model) 설계자(designer)가 이를 극복하기 위해 더 많은 투명성(transparency)을 요구(require)하는 것이다.
Google Brain에는 신경망(neural network)이 학습한 내용을 해석(interpret)하는 데 사용할 수있는 오픈 소스 도구(open source tool)인 github.com/google/svcca가 있다.




Key points
- 기계 학습(Machine learning)은 실제로 배우기 어렵지 않다.
- 온라인에서 사용할 수 있는 대량의 데이터와 컴퓨팅 성능(computing power)이 기계 학습(machine learning)을 실행 가능한 기술로 만들었다.
- 기계 학습(machine learning)의 핵심은 모델(model)이다. 이를 생성(creating)하고, 훈련(training)시킨 후 사용해 결과를 예측(inferring)한다.
- 모델을 훈련시키는 것(Training models)은 부정확(inexact)하고, 인내심(patience)을 요구하는 작업이다. 그러나 Create ML, Turi Create와 같은 사용하기 쉬운(easy-to-use) 전이 학습(transfer learning) 도구를 사용하여 특정 사례에 대한 경험을 향상 시킬 수 있다.
- 모바일 장치(Mobile devices)는 결과를 유추(inferring)하는데 꽤 능숙하다. Core ML 3를 사용하면, 제한된 형태의 기기내 교육(on-device training)으로 모델을 개인화(personalized)할 수 있다.
- 기계 학습(Machine Learning)과 인공 지능(Artificial Intelligence)을 혼동해선 안 된다. 기계 학습(machine learning)은 앱에 큰 도움이 될 수 있지만, 그 한계를 아는 것 또한 중요하다.
