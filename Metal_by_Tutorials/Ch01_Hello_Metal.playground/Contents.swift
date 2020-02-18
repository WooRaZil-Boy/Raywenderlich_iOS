//Chapter 1: Hello, Metal!

//구체를 화면에 렌더링하는 것으로 시작한다. 그다지 흥미로워 보이진 않지만, 렌더링(rendering) 프로세스의 거의 모든 부분을 살펴볼 수 있기 때문에 훌륭한 출발점이다.
//하지만, 시작하기 전에 렌더링(rendering)과 프레임(frame)이라는 용어를 이해하는 것이 중요하다.




//What is rendering?
//옥스포드(Oxford) 백과사전은 컴퓨터 렌더링(computer rendering)을 다음과 같이 설명한다:
//  색상(color)과 음영(shading)을 사용하여, 윤곽선(outline) 이미지를 견고하고(solid), 입체적(three-dimensional)으로 처리하는 작업.
//3D 이미지를 렌더링하는 방법은 여러 가지가 있지만, 대부분 Blender 또는 Maya와 같은 모델링 앱에 내장된 모델로 시작한다.
//ex. Blender에 내장된 열차 모델 //p.28
//이 모델은 다른 모델과 마찬가지로 정점(vertext)들로 구성된다.
//정점은 정육면체(cube)의 모서리와 같이 기하학적 형태의 두 개 이상의 선, 곡선 또는 모서리가 만나는 3차원 공간의 점을 나타낸다.
//모델의 정점 수는 정육면체의 경우에서와 같은 소수에서 부터, 더 복잡한 모델에서의 수천 또는 수백만 개까지 다양할 수 있다.
//3D 렌더러(renderer)는 정점 목록을 분석하는 model loader code를 사용하여 이러한 정점을 읽어낸다.
//그런 다음, 렌더러(renderer)는 정점을 GPU로 전달하고 쉐이더(shader) 함수는 GPU에서 정점을 처리한 후 CPU로 다시 전송해 화면에 표시될 최종 이미지 또는 텍스처(texture)를 만든다.
//다음 render는, 3D 열차 모델과 몇 개의 다른 음영 기법(shading technique)을 사용해 기차가 반짝이는 구리로 만들어진 것과 같은 효과를 낸다. //p.29
//모델의 정점을 가져오는 것부터 화면에 최종 이미지를 생성하는 것 까지의 전체 프로세스를 렌더링 파이프라인(rendering pipeline)이라고 한다.
//렌더링 파이프라인은 최종 이미지를 구성하는 자원(정점(vertices), 재료(material), 조명(light))과 함께 GPU로 전송되는 명령어 목록이다.
//파이프라인에는 프로그래밍 가능한 기능과 불가능한 기능이 모두 포함되어 있다.
//정점(vertex) 기능과 조각(fragment) 기능으로 알려진, 프로그래밍 가능한 기능은 렌더된 최종 모델의 모양에 수동으로(manually) 영향 줄 수 있다.




//What is a frame?
//단순한 하나의 정지된 이미지(still image)만 렌더링하는 게임은 재미가 없을 것이다. 화면 주변의 캐릭터를 유연하게 움직이려면 GPU가 still image를 초당 약 60회 렌더링해야 한다.
//이 때, 각 still image를 프레임(frame)이라고 하며, 이미지가 나타나는 속도를 frame rate라 한다.
//게임이 버벅거리는 경우는 대개 frame rate가 감소하기 때문인데, 이는 GPU의 백그라운드 처리(background processing)가 과도하게 많은 경우이다.
//게임을 디자인할 때는 원하는 결과물과 하드웨어가 제공할 수 있는 결과물의 균형을 맞추는 것이 중요하다.
//실시간 그림자, 물 반사, 수 백만 개의 풀잎 애니메이션 등을 추가하는 것은 멋지지만,
//이 모든 것을 활용하는 것과 GPU가 1/60 초 내에 처리할 수 있는지 여부 사이에서 적절한 균형을 찾는 것은 힘들 수 있다.




//Your first Metal app
//처음 렌더링할 모델은 구(sphere)가 아닌 원(circle)처럼 보일 것이다. 이 모델에는 원근(perspective)이나 음영(shading)을 추가하지 않기 때문이다.
//그러나 정점 메쉬(vertex mesh)는 완전한 3차원 정보를 포함하고 있다. Metal의 렌더링 프로세스는 앱의 크기와 복잡도에 관계없이 거의 동일하며, 다음과 같은 순서로 진행된다.
// Initialize Metal -> Load a model -> Set up the pipeline -> Render
//처음에는 Metal이 필요로 하는 많은 단계들이 부담스러울 수 있지만, 같은 순서로 해당 단계들을 반복해서 수행하다보면 점차 익숙해 질 것이다.

//Getting started
//macOS Blank로 Playground 파일을 생성한다




//The view
//렌더링할 View를 만든다. 사용할 두 가지 프레임워크(framework)를 가져온다.
import PlaygroundSupport //playground의 보조 편집기(assistant editor)에서 liveView를 사용한다.
import MetalKit //Metal을 보다 쉽게 사용할 수 있는 프레임워크
//MetalKit에는 MTKView라는 사용자 정의 뷰(customized view)와
//텍스쳐 로딩, Metal 버퍼(buffer) 작업, 인테페이스 구축에 유용한 프레임워크(Model I/O)등을 사용하는 다양한 메서드들이 있다.
//device를 생성하여 GPU가 적합한지 체크한다.
guard let device = MTLCreateSystemDefaultDevice() else {
    //Metal의 default 시스템 device를 반환한다.
    fatalError("GPU is not supported")
}
//만약 오류가 발생한다면, iOS 용 playground인지 확인해 본다. Playground Settings에서 변경할 수 있다.
//view를 설정한다.
let frame = CGRect(x: 0, y: 0, width: 600, height: 600)
let view = MTKView(frame: frame, device: device) //MTKView는 macOS의 NSView, iOS의 UIView의 하위 클래스이다.
view.clearColor = MTLClearColor(red: 1, green: 1, blue: 0.8, alpha: 1) //크림 색
//MTLClearColor는 색상의 RGBA 값을 나타낸다. 해당 값을 view의 clearColor에 할당해 view의 색상을 설정해 준다.
//Metal 렌더러에서 사용할 MTKView를 구성한다.

//The model
//Model I/O는 Metal 및 SceneKit과 통합된 프레임워크이다.
//Blender나 Maya와 같은 모델링 앱에서 생성된 3D 모델을 로드하고, 데이터 버퍼를 설정해 렌더링을 용이하게 한다.
//3D 모델을 로드하는 대신 Model I/O의 기본 3D 모형(basic 3D shape)을 로드한다.
//일반적으로 정육면체(cube), 구체(sphere), 원통(cylinder), 원환면(torus)이 있다.
let allocator = MTKMeshBufferAllocator(device: device) //allocator는 메쉬(mesh) 데이터의 메모리를 관리한다.
let mdlMesh = MDLMesh(sphereWithExtent: [0.75, 0.75, 0.75],
                      segments: [100, 100],
                      inwardNormals: false,
                      geometryType: .triangles,
                      allocator: allocator)
//Model I/O는 지정된 크기의 구(sphere)를 생성하고, 데이터 버퍼(data buffer)에 있는 모든 정점 정보가 포함된 MDLMesh를 반환한다.
let mesh = try MTKMesh(mesh: mdlMesh, device: device)
//Metal이 mesh를 사용하려면, Model I/O의 mesh를 MetalKit의 mesh로 변환해야 한다.

//Queues, buffers and encoders
//각 프레임은 GPU로 보내는 명령(command)으로 구성된다. 이 command를 render command encoder에서 마무리한다.
//Command buffer는 이러한 command encoder를 구성하고, command queue는 command buffer를 구성한다. //p.33
//command queue를 작성한다.
 guard let commandQueue = device.makeCommandQueue() else {
    fatalError("Could not create a command queue")
}
//앱을 시작할 때 device와 command queue를 설정해야 하며, 일반적으로 동일한 device와 command queue를 사용해야 한다(한 번만 생성).
//각 프레임마다 command buffer와 하나 이상의 render command encoder를 만든다.
//이 객체들은 앱 시작 시 한 번만 설정하는 쉐이더 함수(shader function) 및 파이프 라인 상태(pipeline state)와 같은
//다른 객체를 가리키는(point) 경량 객체이다. //p.34

//Shader functions
//쉐이더(Shader) 함수는 GPU에서 실행되는 작은 프로그램이다. C++ 의 하위 Set(subset)인 Metal Shading Language로 작성한다.
//일반적으로 쉐이더 함수를 별도의 파일(확장자 .metal)로 만들지만, 여기에서는 쉐이더 함수 코드가 포함된 문자열을 만들어 추가한다.
let shader = """
#include <metal_stdlib>
using namespace metal;

struct VertexIn {
    float4 position [[ attribute(0) ]];
};

vertex float4 vertex_main(const VertexIn vertex_in
[[ stage_in ]]) {
    return vertex_in.position;
}

fragment float4 fragment_main() {
    return float4(1, 0, 0, 1);
}
"""
//여기에는 vertex_main이라는 정점(vertex) 함수와 fragment_main 이라는 조각(fragment) 함수, 두 가지 shader 함수가 있다.
//vertex 함수는 일반적으로 정점의 위치를 다루고, fragment 함수는 픽셀의 색상을 지정한다.
//두 함수를 포함하는 Metal library를 설정한다.
let library = try device.makeLibrary(source: shader, options: nil)
let vertexFunction = library.makeFunction(name: "vertex_main")
let fragmentFunction = library.makeFunction(name: "fragment_main")
//컴파일러는 이러한 함수가 존재하는지 확인하여, pipeline descriptor가 사용할 수 있도록 한다.

//The pipeline state
//Metal에서는 GPU의 파이프 라인 상태(state)를 설정한다. 이 상태를 설정하면, GPU는 상태가 다시 바뀔 때까지 아무것도 변경되지 않는다.
//GPU가 fixed state라면, 더욱 효율적으로 운영할 수 있다.
//파이프라인 상태에는 픽셀의 형식(pixel format)이나 렌더링 깊이(depth)와 같이 GPU가 필요로하는 모든 종류의 정보가 포함된다.
//파이프라인 상태에는 위에서 생성한 정점 및 vertex function과 fragment function도 포함되어 있다.
//파이프라인 상태(pipeline state)는 직접 생성하지 않고, descriptor로 생성한다.
//이 descriptor는 파이프라인이 알아야 하는 모든 정보를 보유하고 있어서, 렌더링 상황에 따라 필요한 속성만 변경하면 된다.
let pipelineDescriptor = MTLRenderPipelineDescriptor()
pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm //픽셀 형식을 32bit blue/green/red/alpha로 지정한다.
pipelineDescriptor.vertexFunction = vertexFunction //쉐이더 함수 설정(vertexFunction)
pipelineDescriptor.fragmentFunction = fragmentFunction //쉐이더 함수 설정(fragmentFunction)
//vertex descriptor를 사용하여, 정점을 메모리에 배치하는 방법을 GPU에 알려줘야 한다.
//Model I/O는 sphere mesh를 로드할 때 vertex descriptor를 자동으로 생성하므로 이를 그대로 사용하면 된다.
pipelineDescriptor.vertexDescriptor = MTKMetalVertexDescriptorFromModelIO(mesh.vertexDescriptor)
//MTLRenderPipelineDescriptor에는 많은 속성이 있지만, 여기서는 default만 사용한다.
//descriptor로 pipeline state를 생성한다.
let pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
//파이프라인 상태를 만드는 데에, 처리 시간이 오래 걸리기 때문에 위의 모든 항목을 한 번만 설정해야 한다.
//실제 앱에서는 여러 쉐이딩 함수를 호출하거나 다른 정점 레이아웃(layout)을 사용하기 위해 여러 파이프 라인 상태를 만들 수 있다.




//Rendering
//이제부터는 코드가 매 프레임(frame)마다 수행되어야 한다.
//MTKView에는 프레임마다 실행하는 delegate 메서드가 있지만,
//여기서는 단순히 정적(static) view를 채우는 간단한 렌더링을 수행하므로, 매 프레임마다 샐렌더링해 화면을 새로 고칠 필요가 없다.
//그래픽 렌더링 시, GPU의 임무는 3D 장면에 단일 텍스처(texture)를 출력하는 것이다. 이 텍스처는 실제 카메라로 찍은 사진과 유사하다.
//텍스처는 각 프레임마다 device의 화면에 표시된다.

//Render passes
//현실감있는 렌더링을 위해서는 그림자(shadow), 조명(lighting), 반사(reflection) 등을 고려해야 한다.
//이들 각각은 많은 계산이 필요하며, 일반적으로 별도의 렌더 패스(render pass)에서 수행된다.
//ex. shadow render pass는 3D 모델의 전체 장면을 렌더링하지만, 회색 음영 그림자(grayscale shadow) 정보만 보존한다.
//두 번째 render pass는 모델을 full color로 렌더링한다. 그런 다음 그림자, 색상 질감(texture)을 결합하여 화면에 출력되는 최종 texture를 만든다.
// Command buffer -> Render Pass Descriptor -> Command encoder //p.36
//나중에 멀티 패스 렌더링(multipass rendering)에 대해 배운다. 여기서는 단일 렌더 패스(single render pass)를 사용한다.
//편리하게 MTKView는 drawable이라는 텍스처를 담을 render pass descriptor를 제공한다.
guard let commandBuffer = commandQueue.makeCommandBuffer(),
    //GPU에서 실행되는 모든 명령이 저장된 CommandBuffer를 생성한다.
    let renderPassDescriptor = view.currentRenderPassDescriptor,
    //view의 render pass descriptor에 대한 참조를 얻는다.
    //descriptor는 렌더 대상(render destination)에 대한 데이터(attachment라고 함)를 보유한다.
    //각 attachment에는 저장할 텍스처와 렌더 패스 전체에 걸쳐 텍스트를 유지할 것인지와 같은 정보가 필요하다.
    //render pass descriptor는 render command encoder를 작성하는 데 사용된다.
    //view의 currentRenderPassDescriptor는 특정 프레임에서 사용 불가할 수 있으며, 일반적으로 렌더링 delegate 메소드에서 반환된다.
    let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
    //commandBuffer에서 render pass descriptor를 사용하여 render command encoder를 얻는다.
    //render command encoder는 정점을 그릴 때 GPU에 전송하는 모든 정보를 보유한다.
    else {
        fatalError() //시스템이 command buffer나 render encoder와 같은 Metal 객체를 생성하지 못하면, fatalError를 발생 시킨다.
}
renderEncoder.setRenderPipelineState(pipelineState)
//renderEncoder에 pipelineState를 설정한다.
//이전에 로드한 sphere mesh에는 정점 목록이 포함된 buffer가 있다. 이 버퍼를 render encoder에 설정한다.
 renderEncoder.setVertexBuffer(mesh.vertexBuffers[0].buffer, offset: 0, index: 0)
//offset은 정점 정보가 시작되는 buffer의 위치이다. index는 GPU 정점 쉐이더 함수가 이 버퍼를 찾는데 사용한다.

//Submeshes
//mesh는 submesh로 구성된다. 3D 모델을 만들때, 서로 다른 material group을 디자인하고 이는 submesh로 변환된다.
//ex. 반짝이는 차체와 고무 타이어가 있는 자동차 객체를 렌더링하는 경우, 여기서 material은 반짝이는 페인트와 고무이다.
//import 시에, Model I/O는 해당 그룹에 대해 올바른 정점을 인덱싱하는 두 개의 서로 다른 submesh를 생성한다.
//하나의 정점은 다른 submesh로 여러 번 렌더링 될 수 있다. 여기서 렌더링 하는 sphere에는 하나의 submesh만 사용한다.
guard let submesh = mesh.submeshes.first else {
    fatalError()
}
//이제 모든 것이 준비 되었으므로 Metal로 drawing 할 수 있다.
renderEncoder.drawIndexedPrimitives(type: .triangle,
                                    indexCount: submesh.indexCount,
                                    indexType: submesh.indexType,
                                    indexBuffer: submesh.indexBuffer.buffer,
                                    indexBufferOffset: 0)
//submesh index information에 따라 올바른 순서로 배치된 정점을 가진 삼각형으로 구성된 정점 버퍼(vertex buffer)를 렌더링하도록 GPU에 지시한다.
//이 코드는 실제 렌더링을 수행하지는 않는다. GPU가 모든 명령 버퍼(command buffer)의 명령을 수신해야 한다.
//render command encoder로 명령 전송을 완료하고, 프레임을 마무리 하려면 다음 코드를 추가한다.
renderEncoder.endEncoding() //render encoder에 draw call이 더 이상 없음을 알려준다.
guard let drawable = view.currentDrawable else { //MTKView에서 drawable을 얻는다.
    //MTKView는 Core Animation의 CAMetalLayer을 사용할 수 있으며, layer는 Metal이 읽고 쓸 수 있는 drawable texture를 가지고 있다.
    fatalError()
}
commandBuffer.present(drawable) //MTKView의 drawable을 추가한다.
commandBuffer.commit() //GPU가 commit 하도록 commandBuffer에 요청한다.
PlaygroundPage.current.liveView = view
//Playground의 assistant editor에서 Metal view를 확인할 수 있다. //크림 색 바탕에 빨간색 구가 표시된다.
//간단한 앱이지만, 모든 Metal app에서 자주 사용하는 많은 Metal API를 사용했다.
//p.40
