//Apple ML의 간단한 역사
// • Core ML : WWDC 2017에서 발표되었으며 모든 주요 ML 플랫폼의 변환된 모델을 지원한다. 하지만 기존 모델은 너무 크거나 범용적인 경우가 많다.
// • Turi Create : WWDC 2017 이후 Apple에 인수되었다. Turi Create는 자신의 데이터로 기존 모델을 커스터마이징 할 수 있다(Python으로 작성됨).
// • IBM Watson Services : 2018년 3월에 발표되었다. IBM Watson의 visual recognition model을 커스터마이징 할 수 있다.
//  IBM Cloud maze를 사용해 Drag-and-drop 방식으로 데이터를 입력하며 코드를 짤 필요가 없다. Core ML 모델은 Watson API로 래핑된다.
// • Create ML : WWDC 2018에서 발표되었다. ML in Xcode & Swift로 현재 Turi Create의 몇 가지 toolkit과 분류, 회귀, 데이터 테이블 등 몇 가지만 있다.
//  Swift로 Xcode에서 ML model을 만드는 Kit

//여기에서 Create ML에 대한 튜토리얼을 시작한다. GUI로 고양이와 개 image classifier를 생성한 후 동일한 데이터 세트를 사용하는 Turi Create와 비교한다.
//Turi Create이 설정할 부분이 많지만, 그래서 더 유연한 모델을 만들 수 있다. Apple은 Playground가 Jupyter notebook처럼 작동하도록 업데이트 했다.
//Keras, scikit-learn 등을 사용해 Turi Create으로 ML model을 직접 만들 수도 있다.
//Create ML은 Swift를 위한 ML이고 Swift for TensorFlow는 TensorFlow를 위한 Swift라고 생각하면 된다.




//Create ML Image Classifier
//데이터를 훈련할 때는 이상적으로 같은 수의 이미지가 있는 것이 좋다(ex. 개 이미지 30개, 고양이 이미지 30개). 여기서 차이가 생기면 모델 자체에 편향이 생긴다.
//그리고 다른 분류가 섞인 이미지를 사용해선 안 된다(ex. 고양이와 개가 함께 있는 이미지).
//Create ML image classifier를 훈련시키려면, 데이터 세트가 들어 있는 폴더를 지정해 줘야 한다.
//데이터 세트는 training dataset과 testing dataset이 있으며 이는 서로 달라야 한다. 그래야 모델이 이전에 학습하지 못한 이미지에서 얼마나 잘 작동하는 지 제대로 평가할 수 있다.
//보통 training dataset : testing dataset 를 8:2 혹은 7:3 정도로 나눈다.




//Apple’s Spectacular Party Trick
import CreateMLUI //import에서 오류가 나는 경우가 있다. 그런 경우 Mac OS playground 로 생성해야 한다.

let builder = MLImageClassifierBuilder()
//모델을 학습하여 이미지를 분류하는데 사용하는 Xcode Playground UI. //Jupyter notebook과 비슷하게 사용한다 생각하면 된다. Playground에서 해당 모델 생성, 학습 후 내보낸다.
builder.showInLiveView() //LiveView로 표시
//assistant editor를 켜고 실행 시키면 해당 뷰를 확인할 수 있다.

//LiveView 로 데이터 세트를 쉽게 확인해 볼 수 있다. 대부분의 ML은 알고리즘을 개발하는 것보다 데이터 세트를 curating하는 데 훨씬 많은 시간을 소모한다.
//즉, 알고리즘의 구현, 개발보다 잘 분류된 데이터 세트를 다양하게 확보하는 것이 훨씬 중요하다.

//모델의 학습은 단순하게 해당 training data set 폴더를 LiveView에 Drag & Drop 하면 시작된다.

//Drag-and-Drop을 하면 transfer learning(기존의 만들어진 모델을 사용하여 학습을 빠르게 완료하는 기법)을 시작한다.
//Vision Framework의 VisionFeaturePrint_Screen은 다양한 범주의 이미지를 인식하기 위해 엄청난 양의 데이터 세트로 이미 훈련되어 있다.
//이미지에서 어떤 feature를 찾고, 이 feature를 결합하여 이미지를 분류하는 방법이 이미 학습된 모델이다.
//해당 training data set을 LiveView에 Drag-and-Drop 하면 해당 이미지들에 대한 2048개의 feature를 추출한다.
//여기에는 모양, 질감, 귀 모양, 눈 사이 거리, 주둥이 모양등의 매우 다양한 feature들이 포함된다. 이후 logistic regression로 이미지를 두 개의 클래스로 나눈다.
//소요 시간은 logistic regression에 매우 짧은 시간을 소모하고, 대부분의 시간을 feature를 찾는데 사용한다.

//transfer learning은 데이터 집합의 feature가 모델을 교육하는데 이미 사용한 데이터 집합의 feature과 상당히 유사한 경우에만 성공적으로 작동한다.
//ex. ImageNet(다양한 사진으로 학습된 모델)은 손으로 그린 그림을 제대로 인식하지 못할 수 있다.




//Training & Validation Accuracy
//training이 끝나면, 디버그 console에 세부 정보가 표시된다. Validation set은 Training set에서 무작위로 추출된다.
// • Training accuracy : Drag-and-Drop한 폴더는 Category 별로 이미지가 각 폴더에 나눠져 있다. 여기서는 Cat, Dog 이라는 Label(폴더명)을 사용했다.
//  training algorithm로 answer(label)을 확인해 가중치를 조정해 나가면서 Training accuracy를 계산할 수 있다.
// • Validation accuracy : training을 시작하기 전에 무작위로 training data set의 10%를 validation data set로 분리한다.
//  feature를 추출해 내고, training dataset set에서 처럼 answer을 확인해 가중치를 계산한다.하지만 validation data의 결과를 가중치를 업데이트 하는데 사용되지 않는다.
//  Validation의 목적은 배경이나 조명 같이 중요도가 떨어지는 feature를 위주로 해 overfitting을 방지하는 것이다.
//  Validation accuracy가 Training accuracy와 크게 다른 경우에는 알고리즘 자체를 수정해야 한다. 따라서 validation image를 선택하는 것이 중요하다.
//  Turi Create을 사용하는 경우, fixed validation dataset를 따로 만들어 제공해 줄 수 있다.




//Evaluation
//모델이 훈련하지 않은 이미지를 얼마나 잘 분류하는 지를 테스트 한다. Training 이후 LiveView에 Test할 Image Data set을 Drag and Drop하면 된다.
//완료 후, Testing Accuracy가 출력되고(Console에서 더 정확한 정보를 볼 수 있다) 이미지를 확인해 볼 수 있다.
//LiveView의 filter를 누르면 잘못 분류된 이미지만 따로 확인해 볼 수 있다. 대부분 너무 밝거나 흐린 사진들인데, 이는 모델이 이미지를 299x299로 crop하면서 이런 현상이 나타난다.




//Improving Accuracy
//더 많은 모델을 학습시키면 정확도가 향상될 수 있다. Playground를 Stop한 후, Run을 다시 하면 새로운 LiveView가 생성된다.
//https://developer.apple.com/documentation/createml/improving_your_model_s_accuracy

//Improving Training Accuracy
// • image classifier의 Max iterations를 늘린다.
// • 다른 알고리즘을 사용한다.
// •. 다른 모델을 사용한다.

//Improving Training Accuracy
// • 데이터의 양을 증가 시킨다. flipping, rotating, shearing, changing the exposure 등으로 이미지 데이터를 보완해 줄 수 있다.
// • Max iterations을 줄인다. 이는 오버피팅을 방지한다.

//Improving Evaluation Accuracy
//training data의 feature과 testing data의 feature가 유사하며 실제 유저들이 사용하는 이미지들과도 유사해야 한다.




//Back to the Playground
//데이터의 양이 많아 질수록, Training accuracy와 Validation accuracy가 100%가 될 확률이 적어진다.
//같은 Testing data set으로 평가를 해 본다.

//모델을 향상시키는 유일한 방법은 많은 데이터를 사용하는 것이다. flipping, rotating, shearing, changing the exposure 등으로 이미지를 보완하거나 더 많은 이미지를 추가한다.
//또 data set을 신중하게 선택해 앱이 처리하지 못하는 이미지를 제거하는 것이 좋다.




//Increase Max Iterations?
//training accuracy가 낮다면, training을 시작하기 전에 ImageClassifier의 아래 꺽쇠를 클릭하면 옵션을 선택할 수 있다.




//Using the Image Classifier
//Training과 Validation, Testing이 완료된 이후, ImageClassifier의 아래 꺽쇠를 클릭해 모델을 저장할 수 있다.
