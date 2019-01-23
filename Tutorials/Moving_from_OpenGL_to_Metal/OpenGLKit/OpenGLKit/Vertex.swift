//
//  Vertex.swift
//  OpenGLKit
//
//  Created by 근성가이 on 22/01/2019.
//  Copyright © 2019 근성가이. All rights reserved.
//

import GLKit

//Matrices
struct SceneMatrices { //Scene를 조작하려면, projection행렬과 Model View 행렬을 GPU에 전달해야 한다.
    //GLKit의 GLKMatrix4를 사용한다. GLKMatrix4는 deprecated 되지 않았으므로 Metal에서 사용할 수 있다.
    var projectionMatrix: GLKMatrix4 = GLKMatrix4Identity
    //projection matrix를 사용 하면, 가까이 있는 물체가 멀리 있는 물체보다 크게 보이도록 조정할 수 있다.
    var modelviewMatrix: GLKMatrix4 = GLKMatrix4Identity
    //model view matrix를 사용하면, 객체 또는 전체 장면의 위치, 회전, 축적을 조정할 수 있다.
}




struct Vertex { //Swift 구조체를 사용한다.
    var x: GLfloat //GLFloat은 Swift의 Float의 alias이다.
    var y: GLfloat
    var z: GLfloat
    //x, y, z 좌표
    
    var r: GLfloat
    var g: GLfloat
    var b: GLfloat
    var a: GLfloat
    //rgba 색상
}

//Creating Vertex Data for a Simple Square
//사각형을 그릴 때에는 vertex(정점)를 만들어야 한다. 정점은 그리려는 모양의 윤곽을 정의하는 점이다.
//OpenGL은 삼각형 geometry 만 지원한다. 하지만, 삼각형을 두개 합쳐 사각형을 만들 수 있다.
//OpenGL ES은 원하는 대로 정점 데이터를 정리할 수 있다.
//Swift를 사용해, 정점의 위치와 색상 정보등을 저장하고 그릴 때 사용할 수 있다.
//Vertex.swift 파일을 생성해 해당 정보를 저장한다.
