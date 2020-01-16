// Copyright (c) 2019 Razeware LLC
// For full license & permission details, see LICENSE.markdown.

/*:
 ## Challenge 1: How much faster?
 
 */
//자동 완성을 구현한다고 가정한다. 첫 번째 구현에는 간단한 문자열 Array를 사용하고, 두 번째 구현에는 Trie를 사용한다.
//데이터베이스에 총 100,000 개의 항목이 포함되어 있고, 4개의 항목 "prior", "print", "priority", "prius"이
//"pri" 접두사를 가진다면, trie가 array에 비해 얼마다 더 빠른지 확인한다.

//모든 O(1) 연산은 동일한 시간이 걸린다 가정한다. 따라서 n * O(1) == O(n) 이다.




//Trie가 훨씬 빠르게 실행된다. 대략적인 추정 시간은 다음과 같다.
// 1,000,000 * 3 * O(1) / 4 * 8 * O(1) = 93,750 times faster
//여기서 1,000,000는 데이터베이스 크기이다. 3의 접두사의 길이, 4는 일치 횟수, 8은 "priority" 항목의 길이이다.

//: [Next Challenge](@next)
