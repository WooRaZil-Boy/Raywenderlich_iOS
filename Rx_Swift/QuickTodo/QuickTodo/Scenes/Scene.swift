/*
 * Copyright (c) 2016 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import Foundation

enum Scene {
    //응용 프로그램 Scene이 enum으로 나열되는 Model을 배치할 수 있으며, 각 관련 데이터로 Scene View Model이 있다.
    //이 열거형으로 Scene에 대한 View Controller를 인스턴스화하는 유일한 장소인 함수를 노출한다.
    //이 함수는 각 Scene에 대한 리소스에서 View Controller를 가지고 온다.
    case tasks(TasksViewModel)
    case editTask(EditTaskViewModel)
}

//Scene은 View Model에 의해 관리되는 Screen으로 구성되는 논리적 프리젠테이션 유닛이다.
//Scene의 규칙은 다음과 같다.
//• View Model은 비즈니스 로직을 처리한다. 이것은 다른 Scene으로 전환을 시작하기 까지 이어진다.
//• View Model은 Scene를 표현하는데 사용된 실제 View Contrller와 View에 대해 아무것도 알지 못한다.
//• View Controller는 다른 Scene으로 전환을 시작해선 안 된다. View Model에서 실행해야 한다.

//View Model은 다른 View Model을 인스턴스화하고 이를 전환할 준비가 된 Scene에 할당할 수 있다.
//View Model의 UIKit에 의존하지 않아야 한다.
