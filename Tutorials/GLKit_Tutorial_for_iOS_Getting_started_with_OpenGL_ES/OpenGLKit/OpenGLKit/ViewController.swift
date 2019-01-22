//
//  ViewController.swift
//  OpenGLKit
//
//  Created by 근성가이 on 21/01/2019.
//  Copyright © 2019 근성가이. All rights reserved.
//

import GLKit

extension Array {
    func size() -> Int { //배열의 크기를 바이트 단위로 가져온다.
        return MemoryLayout<Element>.stride * self.count
        //배열이 차지하는 메모리를 결정하려면, element의 size가 아니라, stride가 필요하다.
        //stride는 각 element가 배열에 있을 때 차지하는 메모리 크기이기 때문이다.
    }
}




class ViewController: GLKViewController {
    private var context: EAGLContext? //OpenGL을 사용하려면, EAGLContext를 먼저 생성해야 한다.
    
    var Vertices = [
        Vertex(x:  1, y: -1, z: 0, r: 1, g: 0, b: 0, a: 1),
        Vertex(x:  1, y:  1, z: 0, r: 0, g: 1, b: 0, a: 1),
        Vertex(x: -1, y:  1, z: 0, r: 0, g: 0, b: 1, a: 1),
        Vertex(x: -1, y: -1, z: 0, r: 0, g: 0, b: 0, a: 1),
        ]
    //Vertex 구조체로 그릴 정점들의 배열 //삼각형 두 개로 되어 있지만, 겹치는 정점이 있으므로 6개가 아니다.
    
    var Indices: [GLubyte] = [ //GLubyte는 UInt8의 alias이다.
        0, 1, 2, //Vertices의 0, 1, 2 요소로 삼각형을 그린다.
        2, 3, 0 //Verticesd의 2, 3, 0 요소로 삼각형을 그린다.
    ]
    //모든 정점이 포함된 배열(Vertices)을 만들고, 별도의 배열(Indices)로 각 정점을 참조해 삼각형을 정의한다.
    //이렇게 구현하면, 정점을 가리키는 배열 인덱스는 정점자체를 갖고 있는 것보다 메모리를 적게 사용하므로 효율적이다.
    
    //Creating Vertex Data for a Simple Square
    //사각형을 그릴 때에는 vertex(정점)를 만들어야 한다. 정점은 그리려는 모양의 윤곽을 정의하는 점이다.
    //OpenGL은 삼각형 geometry 만 지원한다. 하지만, 삼각형을 두개 합쳐 사각형을 만들 수 있다.
    //OpenGL ES은 원하는 대로 정점 데이터를 정리할 수 있다.
    //Swift를 사용해, 정점의 위치와 색상 정보등을 저장하고 그릴 때 사용할 수 있다.
    //Vertex.swift 파일을 생성해 해당 정보를 저장한다.
    
    //Creating Vertex Buffer Objects and a Vertex Array Object
    private var ebo = GLuint()
    private var vbo = GLuint()
    private var vao = GLuint()
    //OpenGL에 데이터를 보내는 가장 좋은 방법은 Vertex Buffer Objects를 사용하는 것이다.
    //이는 정점 데이터의 store buffer이다. 여기에는 세 가지 유형이 있다.
    // • Vertex Buffer Object (VBO) : Vertex(정점) 별로 데이터를 저장한다.
    // • Element Buffer Object (EBO) : 삼각형을 정의하는 인덱스를 저장한다.
    // • Vertex Array Object (VAO) : VBO처럼 사용 된다. 앞으로 사용할 모든 정점 속성 호출은 이 안에 저장된다.
    //  정점 속성 포인터를 한 번 설정한 다음 객체를 그릴 때마다 해당 VAO를 바인딩하기만 하면 된다.
    //  다른 configuration으로 정점을 그릴 때 빠르게 그릴 수 있다.
    
    //Introducing GLKBaseEffect
    private var effect = GLKBaseEffect()
    //OpenGL은 파이프라인을 사용해, 개발자가 각 픽셀의 렌더링 방식을 완벽하게 제어할 수 있다.
    //이를 사용해, 유연성을 얻으면서 뛰어난 효과를 렌더링할 수 있지만, 개발자가 더 많은 작업을 해야 한다.
    //Shader는 GLSL (OpenGL Shading Language)로 작성되었으며 사용하기 전에 컴파일해야 한다.
    //GLKit의 GLKBaseEffect를 사용하면, 쉽게 shader 효과를 낼 수 있다.
    private var rotation: Float = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupGL() //메인 스레드에서 OpenGL context를 사용한다.
        //메인 스레드는 시스템에서 UIKit과의 상호작용에 사용되며, viewDidLoad()를 호출하는 스레드이다.
    }
    
    deinit { //뷰 컨트롤러가 메모리에서 해제될때, OpenGL에서 사용하는 리소스들을 반환한다.
        tearDownGL()
    }
    
    private func setupGL() {
        context = EAGLContext(api: .openGLES3)
        //EAGLContext는 iOS가 OpenGL로 그리는 모든 정보를 관리한다.
        //Core Graphics를 사용할 때, Core Graphics context가 필요한 것과 유사하다.
        //context를 생성할 때 사용하는 API 버전을 지정해 준다(여기서는 OpenGL ES 3.0).
        EAGLContext.setCurrent(context)
        //현재 스레드에서 사용할 context를 지정해 준다.
        //OpenGL context는 여러 스레드에서 공유되지 않으므로, context를 지정할 때 사용된 스레드에서만 상호작용한다.
        
        if let view = self.view as? GLKView, let context = context {
            view.context = context //GLKView의 context를 설정한다.
            delegate = self //delegate 설정
            //state 및 logic이 업데이트 될 때마다, glkViewControllerUpdate(_ controller:)가 호출된다.
        }
        
        //Setting Up the Buffers
        let vertexAttribColor = GLuint(GLKVertexAttrib.color.rawValue)
        //버퍼를 생성할 때 데이터 구조에서 색상 및 위치를 읽는 방법에 대한 정보를 지정해 줘야 한다.
        //GLuint(UInt8) 유형의 색상 정점 속성을 지정해 준다.
        //GLKVertexAttrib enum의 color 속성을 에서 raw value를 가져와 GLuint로 변환한다.
        let vertexAttribPosition = GLuint(GLKVertexAttrib.position.rawValue)
        //마찬가지로, 위치에 대한 정보를 지정해 준다.
        let vertexSize = MemoryLayout<Vertex>.stride
        //stride는 유형 항목의 크기(바이트)이다.
        let colorOffset = MemoryLayout<GLfloat>.stride * 3
        //색상의 offset은 stride에 3을 곱해야 한다(x, y, z).
        let colorOffsetPointer = UnsafeRawPointer(bitPattern: colorOffset)
        //offset을 필요한 유형(UnsafeRawPointer)으로 변환한다.
        
        //Creating VAO Buffers
        glGenVertexArraysOES(1, &vao) //OpenGL에게 새로운 VAO를 생성하도록 요청한다.
        //매개 변수는 (생성할 vao 수, 생성된 개체의ID를 저장하는 GLuint 포인터)
        glBindVertexArrayOES(vao)
        //생성한 vao를 바인딩한다. OpenGL은 그리기 전에 바인드를 해제하거나 바인드 할 때까지 VAO를 사용한다.
    
        //VAO를 사용하면, 코드가 늘어나지만 필요한 geometry를 그릴때 마다 일일히 코드를 짜주는 것 보단 나은 선택이다.
        
        //Creating VBO Buffers
        glGenBuffers(1, &vbo)
        //VAO와 마찬가지로, glGenBuffers에 생성할 VBO 수와, ID를 저장할 포인터 변수를 전달해 준다.
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vbo)
        //glBindBuffer에 바인딩한다. (버퍼 유형, 식별자)
        //GL_ARRAY_BUFFER는 Vertex 버퍼를 바인딩할 때 사용한다. 이를 GLenum로 캐스팅한다.
        glBufferData(GLenum(GL_ARRAY_BUFFER), //데이터를 전달할 버퍼
                     Vertices.size(), //데이터의 크기
                     Vertices, //데이터
                     GLenum(GL_STATIC_DRAW)) //CPU가 데이터를 관리하는 방법. 최적화를 한다.
                    //데이터를 그래픽 카드에서 사용하고 거의 변경하지 않기 때문에 GL_STATIC_DRAW으로 지정한다.
        //glBufferData를 호출해 모든 정적의 정보를 OpenGL에 전달한다.
        
        //Swift에서 OpenGL을 사용할 때 특정 변수와 매개 변수를 OpenGL 전용 유형으로 변환해야 한다.
        //하지만 이는 기본 유형의 type aliases 이므로 크게 신경쓸 것은 없다.
        
        //위의 코드까지 정점과 색상, 위치 데이터를 모두 GPU에 전달했다.
        //하지만, OpenGL에서 화면을 그릴 때 데이터를 해석하는 방법을 설정해 줘야 한다.
        
        glEnableVertexAttribArray(vertexAttribPosition) //OpenGL에게 해석할 데이터가 무엇인지 알려준다.
        //glEnableVertexAttribArray로 각 위치의 정점을 알려준다. geometry의 위치가 된다.
        glVertexAttribPointer(vertexAttribPosition, //설정할 속성의 이름
                              3, //각 정점이 몇 개의 값을 가지고 있는 지 지정 //position은 x, y, z 이므로 3
                              GLenum(GL_FLOAT), //값의 유형
                              GLboolean(UInt8(GL_FALSE)), //데이터 정규화 여부. 보통 false
                              GLsizei(vertexSize), //stride 크기 //데이터 구조의 크기라 생각하면 된다.
                              nil) //position 데이터의 offset //배열의 처음에 있다.
        
        glEnableVertexAttribArray(vertexAttribColor)
        glVertexAttribPointer(vertexAttribColor, //설정할 속성의 이름
                              4, //각 정점이 몇 개의 값을 가지고 있는 지 지정 //color는 rgba 이므로 4
                              GLenum(GL_FLOAT), //값의 유형
                              GLboolean(UInt8(GL_FALSE)), //데이터 정규화 여부. 보통 false
                              GLsizei(vertexSize), //stride 크기 //데이터 구조의 크기라 생각하면 된다.
                              colorOffsetPointer) //position 데이터의 offset //배열의 처음에 있다.
        
        //VBO와 데이터가 준비되면, EBO를 사용해 index를 OpenGL에 알린다. 이후, OpenGL은 그릴 순서를 정한다.
        
        //Creating EBO Buffers
        glGenBuffers(1, &ebo) //버퍼 생성 //개수, 포인터
        glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), ebo) //버퍼에 바인딩
        glBufferData(GLenum(GL_ELEMENT_ARRAY_BUFFER),
                     Indices.size(),
                     Indices,
                     GLenum(GL_STATIC_DRAW)) //데이터 전달
        //VBO에서 사용한 것과 동일하다.
        
        glBindVertexArrayOES(0) //VAO를 바인드 해제한다.
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), 0) //버퍼 해제
        glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), 0) //버퍼 해제
        //꼭 필요하진 않지만, 사용 이후, 바인딩을 해제하는 것이 좋은 습관이다.
    }
    
    //Tidying Up
    private func tearDownGL() {
        EAGLContext.setCurrent(context) //현재 작업 컨텍스트
        
        glDeleteBuffers(1, &vao)
        glDeleteBuffers(1, &vbo)
        glDeleteBuffers(1, &ebo)
        //VAO, VBO, EBO 삭제
        
        EAGLContext.setCurrent(nil)
        //context를 비워준다.
        
        context = nil
    }
    
    override func glkView(_ view: GLKView, drawIn rect: CGRect) {
        //GLKViewDelegate의 메서드로, 매 프레임마다 화면에 내용을 그려준다.
        glClearColor(0.85, 0.85, 0.85, 1.0) //화면을 지울때 사용하는 RGB 값 설정
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT)) //실제로 화면을 지우는 메서드
        //화면을 지울 때, 다른 render/color 버퍼가 있을 수 있다.
        //GL_COLOR_BUFFER_BIT를 사용해, 버퍼를 지정해 준다.
        
        
        //Introducing GLKBaseEffect
        effect.prepareToDraw() //GLSL이나 OpenGL 코드를 작성하지 않고 shader를 바인딩하고 컴파일 할 수 있다.
        
        glBindVertexArrayOES(vao) //glBindVertexArrayOES로 VAO를 바인딩한다.
        //그리기위한 설정도 glBindVertexArrayOES 로 한다.
        glDrawElements(GLenum(GL_TRIANGLES), //OpenGL에게 그릴 내용을 알려준다. GL_TRIANGLES은 삼각형
            GLsizei(Indices.count), //그리려는 정점의 수를 알려준다.
            GLenum(GL_UNSIGNED_BYTE), //index에 포함된 값의 유형을 지정해 준다.
            nil) //버퍼의 offset
        //glDrawElements로 그린다.
        glBindVertexArrayOES(0)
    }
}

extension ViewController: GLKViewControllerDelegate {
    func glkViewControllerUpdate(_ controller: GLKViewController) {
        //state 및 logic이 업데이트 될 때마다, 호출된다.
        
        //Setting Up the Geometry
        //projection matrix로 2차원 평면에 3차원 형상을 렌더링하는 방법을 GPU에게 알려줄 수 있다.
        //그려지는 픽셀은 각 선에서 가장 앞에 있는 3차원 물체가 부딪치는 것에 의해 결정된다.
        //GLKit에는 projection matrix를 설정하는 편리한 함수가 있다. y축, 가로 세로 비율 등을 정해 줄 수 있다.
        //field of view는 카메라 렌즈와 같다. 값이 작은 field of view (e.g., 10)는 망원렌즈처럼 이미지를 확대한다.
        //값이 큰 field of view (e.g., 100)는 광각렌즈처럼 사물을 멀리서 보는 것처럼 처리한다. 일반적인 값은 65 - 75 이다.
        //aspect ratio은 렌더링할 가로 세로 비율이다. x축을 따라 시야를 결정하기 위해 y축의 시야와 결합하여 사용한다.
        //near plane과 far plane은 scene에서 볼 수 있는 경계값이다.
        //어떤 사물이 near plane보다 가까이 있거나, far plane보다 멀리 있으면 렌더링 되지 않는다.
        let aspect = fabsf(Float(view.bounds.size.width) / Float(view.bounds.size.height))
        //가로 세로 비율을 계산한다.
        let projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0), aspect, 4.0, 10.0)
        //projection matrix를 생성하기 위해 GLKit math library의 함수를 사용한다.
        //near plane를 4단위 거리로, far plane를 10단위 거리로 설정한다.
        effect.transform.projectionMatrix = projectionMatrix
        //projection matrix를 effect의 transform property에 설정한다.
        
        //이후 modelViewMatrix도 설정해 줘야 한다.
        var modelViewMatrix = GLKMatrix4MakeTranslation(0.0, 0.0, -6.0)
        //modelViewMatrix는 효과가 레더링하는 모든 geometry에 적용되는 transform이다.
        //객체를 뒤로 이동 시킨다. GLKMatrix4MakeTranslation로 -6 단위로 변환한다.
        
        rotation += 90 * Float(timeSinceLastUpdate) //큐브를 회전할 방향
        modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, GLKMathDegreesToRadians(rotation), 0, 0, 1)
        //GLKMatrix4Rotate로 modelViewMatrix를 하나씩 증가시키면 회전한다.
        //GLKMathDegreesToRadians로 라디안으로 변환한다.
        
        effect.transform.modelviewMatrix = modelViewMatrix
        //modelviewMatrix에 설정해 준다.
    }
}

//iOS12 부터 GLKit의 많은 부분이 deprecated 되었기 때문에 OpenGL 대신 Metal을 사용할 것이 추천된다.

//OpenGL은 그래픽 프로그래밍에서 가장 많이 사용되는 API이다. iOS에서는 GLKit 프레임워크를 사용해 추상화해 놓았다.
//GLKit는 네 가지 영역으로 나눌 수 있다.
// • Views and View Controllers : 기본적인 OpenGL ES 프로젝트를 설정하는 보일러 플레이트 코드 추상화.
// • Effects : 음영 동작. 조명, 음영, 반사, 스카이 박스 등의 효과를 설정해 줄 수 있다.
// • Math : 벡터 및 행렬과 같은 일반적인 수학 루틴
// • Texture Loading : 텍스처로 이미지를 로드




//Introducing GLKView and GLKViewController
//GLKit을 import 하고, UIViewController를 GLKitViewController로 변경해 준다(iOS 12에서 deprecated).
//스토리 보드를 열고, UIViewController를 삭제한 후, Object Library에서 GLKit View Controller를 추가해 준다.
//Identity inspector에서 클래스를 ViewController로 연결해 주고, Is Initial View Controller를 체크한다.
//Preferred FPS 를 60으로 변경해 준다.

//GLKViewController는 GLKView를 포함하고 있다. 이것의 설정을 변경해 값을 적용해 줄 수 있다.
//OpenGL 컨텍스트는 화면에 표시될 색상을 저장하는 버퍼가 존재한다. Color Format 속성에서 이를 설정할 수 있다.
//기본값은 GLKViewDrawableColorFormatRGBA8888 인데, 8비트가 각 색상 컴포넌트의 버퍼로 사용됨을 의미한다(픽셀 당 총 4바이트).
//GLKView는 GLKViewDelegate를 통해 OpenGL 콘텐츠를 그린다.

















