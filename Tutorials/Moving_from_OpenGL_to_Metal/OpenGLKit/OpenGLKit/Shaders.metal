//
//  Shaders.metal
//  OpenGLKit
//
//  Created by 근성가이 on 23/01/2019.
//  Copyright © 2019 근성가이. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

//Matrices in Shaders
struct SceneMatrices { //Shader에서 행렬을 받기 위한 구조체를 추가해 준다.
    float4x4 projectionMatrix;
    float4x4 viewModelMatrix;
};

struct VertexIn {
    packed_float3 position;
    packed_float4 color;
};

struct VertexOut {
    float4 computedPosition [[position]];
    float4 color;
};

//Writing a Vertex Shader
//Vertex Shader는 각 정점을 그릴 때 실행되는 함수이다.
vertex VertexOut basic_vertex( //vertex 키워드로 이 함수가 vertex shader function 임을 알려준다.
                              //반환 유형은 VertexOut이다.
                              const device VertexIn* vertex_array [[ buffer(0) ]],
                              //command encoder로 전달한 vertex buffer를 가져온다.
                              const device SceneMatrices& scene_matrices [[ buffer(1) ]],
                              //행렬을 매개변수로 받는다.
                              unsigned int vid [[ vertex_id ]]) {
                              //Shader가 호출된 정점의 id
    
    float4x4 viewModelMatrix = scene_matrices.viewModelMatrix; //view model matrix
    float4x4 projectionMatrix = scene_matrices.projectionMatrix; //projection matrix
    
    VertexIn v = vertex_array[vid];
    //현재 vertex id에 대한 input vertex를 가져온다.
    
    VertexOut outVertex = VertexOut(); //VertexOut 생성
    outVertex.computedPosition = projectionMatrix * viewModelMatrix * float4(v.position, 1.0);
    //projectionMatrix과 viewModelMatrix를 곱해 위치를 지정해 준다.
    
    outVertex.color = v.color;
    //동일한 색상을 사용한다.
    
    return outVertex;
}

//Writing a Fragment Shader
//vertex shader가 완료되면, 각 잠재적인 픽셀에 대해 fragment shader가 실행된다.
fragment float4 basic_fragment(VertexOut interpolated [[stage_in]]) {
    //Fragment Shader는 vertex shader의 ouput을 받는다(VertexOut).
    return float4(interpolated.color); //색상 반환
}

//Adding Shaders
//File ▸ New ▸ File… 에서 iOS ▸ Source ▸ Metal File 를 선택해 Metal 파일을 생성한다.
//Metal은 Shader를 작성하기 위해 C++을 사용한다. OpenGL에서 사용하는 GLSL과 유사하다.














