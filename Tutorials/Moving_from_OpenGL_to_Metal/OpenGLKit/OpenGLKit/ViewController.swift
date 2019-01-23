//
//  ViewController.swift
//  OpenGLKit
//
//  Created by 근성가이 on 21/01/2019.
//  Copyright © 2019 근성가이. All rights reserved.
//

import GLKit
import MetalKit

extension Array {
    func size() -> Int { //배열의 크기를 바이트 단위로 가져온다.
        return MemoryLayout<Element>.stride * self.count
        //배열이 차지하는 메모리를 결정하려면, element의 size가 아니라, stride가 필요하다.
        //stride는 각 element가 배열에 있을 때 차지하는 메모리 크기이기 때문이다.
    }
}




class ViewController: UIViewController {
    //Integrating Metal
    //Metal은 GLKit의 GLKViewController와 같은 ViewController가 따로 없다.
    //대신, UIViewController에서 MTKView를 사용해야 한다. MTKView은 MetalKit 프레임워크의 일부이다.
    @IBOutlet weak var metalView: MTKView!
    private var metalDevice: MTLDevice! //Metal에서는 MTLDevice로 GPU에 액세스한다.
    private var metalCommandQueue: MTLCommandQueue!
    //MTLCommandQueue은 인코딩 된 프레임을 전달하는 queue이다.
    
    private var vertexBuffer: MTLBuffer!
    private var indicesBuffer: MTLBuffer!
    //Drawing Primitives
    //무언가를 그리려면 객체를 나타내는 데이터를 GPU에 전달해야 한다.
    //OpenGL에서 사용한 Vertex 구조체를 Metal에서 사용하려면 약간 수정해야 한다.
    
    //Data Buffers
    //Vertex 데이터를 GPU에 전달하려면, vertices buffer와 indices buffer가 필요하다.
    //이는 OpenGL의 element buffer object(EBO) 와 vertex buffer object(VBO)와 비슷하다.
    
    var Vertices = [
        Vertex(x:  1, y: -1, z: 0, r: 1, g: 0, b: 0, a: 1),
        Vertex(x:  1, y:  1, z: 0, r: 0, g: 1, b: 0, a: 1),
        Vertex(x: -1, y:  1, z: 0, r: 0, g: 0, b: 1, a: 1),
        Vertex(x: -1, y: -1, z: 0, r: 0, g: 0, b: 0, a: 1),
        ]
    //Vertex 구조체로 그릴 정점들의 배열 //삼각형 두 개로 되어 있지만, 겹치는 정점이 있으므로 6개가 아니다.
    
    var Indices: [UInt32] = [
        //GLKit에서는 GLubyte(UInt8의 alias)를 썼지만, Metal에서는 UInt8를 그대로 사용한다.
        0, 1, 2, //Vertices의 0, 1, 2 요소로 삼각형을 그린다.
        2, 3, 0 //Verticesd의 2, 3, 0 요소로 삼각형을 그린다.
    ]
    //모든 정점이 포함된 배열(Vertices)을 만들고, 별도의 배열(Indices)로 각 정점을 참조해 삼각형을 정의한다.
    //이렇게 구현하면, 정점을 가리키는 배열 인덱스는 정점자체를 갖고 있는 것보다 메모리를 적게 사용하므로 효율적이다.
    
    private var rotation: Float = 0.0
    
    private var pipelineState: MTLRenderPipelineState!
    //MTLRenderPipelineState은 shader 데이터가 포함된다.
    
    private var sceneMatrices = SceneMatrices() //Vertex에서 정의한 행렬을 사용한다.
    private var uniformBuffer: MTLBuffer!
    
    private var lastUpdateDate = Date()
    //OpenGL로 구현할 때에는, GLViewController에서 lastUpdateDate로 마지막 렌더링이 완료된 때를 알수 있었지만,
    //Metal을 사용할 때는 직접 구현해 줘야 한다.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupMetal()
        //메인 스레드는 시스템에서 UIKit과의 상호작용에 사용되며, viewDidLoad()를 호출하는 스레드이다.
    }
    
    private func setupMetal() {
        metalDevice = MTLCreateSystemDefaultDevice() //Metal을 사용할 defaultDevice 생성
        metalCommandQueue = metalDevice.makeCommandQueue() //명령 queue 생성
        metalView.device = metalDevice //MetalView의 device를 설정해 준다.
        metalView.delegate = self
        //OpenGL로 설정한 것보다 코드가 상당히 줄어든다.
        
        let vertexBufferSize = Vertices.size()
        vertexBuffer = metalDevice.makeBuffer(bytes: &Vertices, length: vertexBufferSize, options: .storageModeShared) //버퍼 생성
        
        let indicesBufferSize = Indices.size()
        indicesBuffer = metalDevice.makeBuffer(bytes: &Indices, length: indicesBufferSize, options: .storageModeShared) //버퍼 생성
        //Data Buffers
        //Vertex 데이터를 GPU에 전달하려면, vertices buffer와 indices buffer가 필요하다.
        //이는 OpenGL의 element buffer object(EBO) 와 vertex buffer object(VBO)와 비슷하다.
        
        //Hooking up the Shaders to the Pipeline
        let defaultLibrary = metalDevice.makeDefaultLibrary()! //라이브러리 생성
        let fragmentProgram = defaultLibrary.makeFunction(name: "basic_fragment")
        let vertexProgram = defaultLibrary.makeFunction(name: "basic_vertex")
        //프로젝트 내의 모든 metal 파일에서 name으로 function을 찾아 온다.
        
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.vertexFunction = vertexProgram
        pipelineStateDescriptor.fragmentFunction = fragmentProgram
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        //픽셀 형식은 표준 BGRA (Blue Green Red Alpha)
        
        pipelineState = try! metalDevice.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
        //GPU에 최적화된 객체로 컴파일하도록 요청한다.

    }
}

extension ViewController: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        //화면 회전과 같이 drawable size가 변경될 때 호출된다.
        
        //Projection Matrix
        let aspect = fabsf(Float(size.width) / Float(size.height)) //뷰의 가로 세로 비율
        let projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0), aspect, 4.0, 10.0) //Projection Matrix 생성
        sceneMatrices.projectionMatrix = projectionMatrix //Projection Matrix를 추가해 준다.
    }
    
    func draw(in view: MTKView) { //실제로 그리기를 수행할 때 호출된다.
        //Metal에서는 그리는 각 프레임에 대해 무엇을, 어떻게 그려야하는 지 지정하는 command buffer를 만들어야 한다.
        //버퍼는 CPU에서 인코딩 되고, command queue를 사용해 GPU로 전송된다.
        guard let drawable = view.currentDrawable else {
            //현재 프레임에 사용할 유효한 Drawble이 있는 지 확인한다.
            return
        }
        
        let renderPassDescriptor = MTLRenderPassDescriptor()
        //MTLRenderPassDescriptor은 rendering pass로 생성된 픽셀의 attachments를 포함하고 있다.
        renderPassDescriptor.colorAttachments[0].texture = drawable.texture //텍스처 설정
        renderPassDescriptor.colorAttachments[0].loadAction = .clear //렌더링 시작 시 모든 픽셀 clear
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0.85, 0.85, 0.85, 1.0)
        //clear시 사용할 색상
        
        guard let commandBuffer = metalCommandQueue.makeCommandBuffer() else {
            //CommandQueue에 새 CommandBuffer를 생성한다.
            return
        }
        
        guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
            //graphics rendering command을 command buffer로 인코딩 할 수 있는 인코더를 생성한다.
            return
        }
        
        //Matrices
        var modelViewMatrix = GLKMatrix4MakeTranslation(0.0, 0.0, -6.0)
        //6단위 뒤로 이동시켜 작게 보이게 한다.
        
        //Making it Spin
        let timeSinceLastUpdate = lastUpdateDate.timeIntervalSince(Date())
        //마지막 업데이트된 이후 부터 현재시간까지의 차이
        rotation += 90 * Float(timeSinceLastUpdate) //차이나는 시간에 비례하여 회전 각도를 증가시켜 준다.
        
        modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, GLKMathDegreesToRadians(rotation), 0, 0, 1)
        //z축을 중심으로 회전을 적용한다.
        
        sceneMatrices.modelviewMatrix = modelViewMatrix
        
        let uniformBufferSize = MemoryLayout.size(ofValue: sceneMatrices)
        uniformBuffer = metalDevice.makeBuffer(bytes: &sceneMatrices, length: uniformBufferSize, options: .storageModeShared)
        //행렬 데이터를 사용해, uniformBuffer를 생성한다.
        
        renderEncoder.setVertexBuffer(uniformBuffer, offset: 0, index: 1)
        //uniformBuffer를 파이프 라인에 추가하고 식별자를 설정한다.
        
        renderEncoder.setRenderPipelineState(pipelineState) //Shader 설정
        
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        //vertexBuffer를 인코더에 설정한다.
        renderEncoder.drawIndexedPrimitives(type: .triangle, indexCount: Indices.count, indexType: .uint32, indexBuffer: indicesBuffer, indexBufferOffset: 0)
        //indicesBuffer를 사용해 삼각형을 그린다.
        
        //Frame drawing goes here
        renderEncoder.endEncoding() //인코딩 완료
        
        
        commandBuffer.addCompletedHandler { _ in //draw가 완료 될 때 호출
            self.lastUpdateDate = Date() //lastUpdateDate를 업데이트 해 준다.
        }
        commandBuffer.present(drawable) //drawable 등록
        commandBuffer.commit() //command queue에서 실행하기 위해 버퍼를 커밋한다.
        
        //command buffer 와 command encoder를 생성한 후, command encoder에서 drawing을 하고,
        //command queue를 사용해 command buffer를 GPU에 커밋한다.
        //이 단계는 프레임을 그릴 때마다 반복된다.
    }
}


//Metal은 GPU 기반 계산을 위한 범용 API로 2014년에 도입되었다.
//2018년 Apple은 iOS 12에서 , iOS, MacOS 모두에서 OpenGL 지원을 중단했다.
//여기서는 OpenGL을 사용해 앱을 Metal로 변환한다.
//Metal 앱은 iOS 시뮬레이터에서 실행되지 않는다. Apple A7 이상이 장착된 device가 필요하다.




//OpenGL ES vs. Metal
//OpenGL ES는 크로스 플랫폼 프레임워크이다. Android와 같은 다른 플랫폼에서 C++ OpenGL ES 코드를 실행할 수 있다.
//Metal의 Apple 하드웨어 전용 그래픽 API이다. 오버헤드를 낮추고 고성능을 유지하도록 최적화되어 있다.




//Understanding Conceptual Differences
//개발의 관점에서는 OpenGL과 Metal은 비슷하다.
//둘 다 GPU로 전달할 데이터가 있는 버퍼를 성정하고, Vertex와 fragment shader를 지정해 준다.
//OpenGL 프로젝트에서는 Shader를 추상화한 클래스로 GLKBaseEffect를 사용했다.
//Metal에는 이 클래스가 없으므로 shader를 직접 작성해야 한다.
//OpenGL과 Metal의 가장 큰 차이점은 Metal에서는 두 가지 유형의 객체로 작동한다는 점이다.
//Descriptor object(설명자) 와 Compiled-state object(컴파일된 상태)가 그것이다.
//Descriptor object를 만들고 컴파일한다. Compiled-state object는 최적화된 GPU 리소스이다.
//생성과 컴파일은 모두 리소스가 많이 드는 작업이므로, 가능한 수행하지 않고 Compiled-state object로 작업하는 것이다.
//이 방법은 Metal을 사용할 때, render loop에서 많은 설정 작업을 수행할 필요가 없다는 것을 의미한다.
//이는 OpenGL보다 훨씬 효율적이다. OpenGL은 아키텍처 제한으로 인해 동일한 작업을 수행할 수 없다.




//Switching From OpenGL
//OpenGL에서와 달리 Metal을 사용하면, deinit될 떄, 명시적으로 리소스를 반환해줄 필요 없다.






































