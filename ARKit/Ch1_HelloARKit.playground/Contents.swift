//Augmented reality

//Marker-based tracking
//증강현실은 새로운 개념이 아니다. 지난 몇 년 간 일반적인 장치에서 tracking card와 Marker-based tracking 방식으로 구현되었다.
//tracking card는 실제 표면의 앵커 역할을 한다. 특수 알고리즘은 카메라 데이터를 분석하여 카드의 위치, 크기, 방향을 결정한다.
//추적 정보는 카메라의 이미지 위에 중첩되어 있는 3D 컨텐츠를 투사하고, 크기를 조정하여 배치하는데 사용한다. ex. Om Nom Candy Flick
//하지만 이 기술은 tracking card가 카메라 뷰를 벗어나는 순간 구현할 수 없게 된다.

//Markerless tracking
//가상의 3D 요소를 볼 수 있는 모든 것 위에 겹쳐 놓는다. ex. Microsoft HoloLens.
//공간 인식을 통해 주변 세계를 볼 뿐아니라 이해한다. 실제 공간의 움직임을 추적하고 매핑하여 3D 공간을 만든다.
//이 경우에는 시선, 제스처, 음성 등이 방법으로 가상공간과 상호작용한다.
//크고 거추장스러우며 비싼 것이 단점이다.




//Introducing ARKit
//ARKit은 Apple의 모바일 AR 개발 프레임워크이다. ARKit은 Markerless tracking을 할 수 있으며, A9 이상 프로세서가 장착된 모든 Apple 장치에서 구현 가능하다.

//What can ARKit do for you?
//ARKir이 대부분의 어려운 작업을 처리하므로 중요한 부분에 집중해 몇 줄의 코드만으로 증강현실을 쉽게 구현할 수 있다.
//ARKit으로 Tracking, Scene understanding, Light estimation, Scene interaction, Metric scaling system, Rendering integra1ons 등을 활용할 수 있다.
//ARKit에는 자체 그래픽 API가 없다. 추적 정보및 표면 탐지 기능만 제공된다. SpriteKit, SceneKit 및 Metal 등의 그래픽 프레임워크와 쉽게 통합할 수 있다.
//Unity나 Unreal 플레그인과도 결합 가능하다.




//Limitations of ARKit(ARKit의 한계)
//감지에 시간 필요, 모션 처리지연, 저 조명 상태, 질감없고 부드러운 표면에서 감지 어려움, 고스트 효과 등이 있다.




//Technology behind ARKit
//AVFoundation + CoreMotion = ARKit
//ARKit은 VIO (Visual Inertial Odometry)를 사용하여 장치 및 주변의 움직임을 추적한다.
//VIO는 카메라 센서의 AVFoundation 기반 입력을 CoreMotion을 통해 캡처 된 장치 모션 데이터와 통합한다.
