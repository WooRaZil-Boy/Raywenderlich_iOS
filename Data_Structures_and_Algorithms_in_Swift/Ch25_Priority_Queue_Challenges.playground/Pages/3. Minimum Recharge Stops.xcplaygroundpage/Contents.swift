/*:
 [Previous Challenge](@previous)
 ## 3. Minimum Recharge Stops
 
 Swift-la is a new electric car company that is looking to add a new feature into their vehicles. They want to add the ability for their customers to check if the car can reach a given destination.  Since the journey to the destination may be far, there are charging stations that the car can recharge at. The company wants to find the **minimum number of charging stops** needed for the vehicle to reach its destination.

 You're given the following information:

 - The `target` distance the vehicle needs to travel.
 - The `startCharge`, how much charge the car has to begin the journey.
 - An ordered list of `stations` that the car can potentially stop at to charge along the way.

 Each `ChargingStation` has a `distance` from the start location and a `chargeCapacity`. This is the amount of charge a station can add to the car.

 You may assume the following:

 1. An electric car has an **infinite** charge capacity.
 2. One charge capacity is equivalent to one mile.
 3. The list of `stations` is sorted by distance from the start location:

 ```swift
 stations[0].distance < stations[1].distance < stations[k].distance
 ```
 */

//전기차가 지정된 목적지에 도착할 수 있는지 확인할 수 있는 함수를 추가한다.
//목적지까지 이동하는 동안 충전소를 이용할 수 있다. 차량이 목적지에 도착할 때까지 들러야 하는 충전소의 최소값을 알고자 한다. //p.255
//제공되는 정보는 다음과 같다.
// • 차량이 주행해야 하는 거리 : target
// • 차량이 주행을 시작할 때 충전량 : startCharge
// • 주행 중 충전할 수 있는 충전소의 목록: stations
//ChargingStation 객체는 distance와 chargeCapacity 속성을 가지고 있다.
//distance는 출발 위치로부터 얼만큼 떨어져 있는지를 나타내고, chargeCapacity는 해당 충전소에서 충전할 수 있는 양을 나타낸다.
//문제 해결을 위해 다음과 같은 가정을 한다.
// 1. 전기차는 충전 용량이 무한대이다.
// 2. 충전 단위 1으로 1마일을 주행할 수 있다.
// 3. 충전소의 목록은 출발 위치와의 거리를 기준으로 정렬되어 있다.
//  ex. stations[0].distance < stations[1].distance < stations[k].distance

struct ChargingStation {
  /// Distance from start location.
  let distance: Int
  /// The amount of electricity the station has to charge a car.
  /// 1 capacity = 1 mile
  let chargeCapacity: Int
}

enum DestinationResult {
  /// Able to reach your destination with the minimum number of stops.
  case reachable(rechargeStops: Int)
  /// Unable to reach your destination.
  case unreachable
}

//문제 해결을 위해 ChargingStation(struct)와 DestinationResult(enum) 두 개의 entity가 주어진다.
//ChargingStation는 충전소의 정보를, DestinationResult는 차량이 주행을 완료할 수 있는 지 여부를 나타낸다.
//그리고 세 가지 매개변수가 있는 minRechargeStops(_:) 함수가 있다. 이 함수의 매개변수는 다음과 같다.
// • target : 차량이 주행해야 하는 거리(마일)
// • startCharge : 주행 전 출발 위치에서의 충전된 양
// • stations : 거리 기준으로 정렬된 충전소 목록

/// Returns the minimum number of charging stations an electric vehicle needs to reach it's destination.
/// - Parameter target: the distance in miles the vehicle needs to travel.
/// - Parameter startCharge: the starting charge you have to start the journey.
/// - Parameter stations: the charging stations along the way.
func minRechargeStops(target: Int, startCharge: Int, stations: [ChargingStation]) -> DestinationResult {
    guard startCharge <= target else {
        //출발 지점에서 전기차의 충전량이 목표 주행 거리보다 크거나 같은 경우, 충전소에 들리지 않고도 목적지에 도착할 수 있다.
        return .reachable(rechargeStops: 0)
    }
    
    var minStops = -1 //목적지에 도착하는 데 필요한 최소 충전소 수를 트래킹한다.
    var currentCharge = 0 //주행 중 차량의 현재 충전량을 트래킹한다.
    var currentStation = 0 //현재까지 들린 충전소 수를 트래킹한다.
    var chargePriority = PriorityQueue(sort: >, elements:[startCharge])
    //들릴 수 있는 모든 충전소를 보유하고 있는 우선 순위 큐이다. 충전 용량이 가장 높은 충전소 부터 dequeue 된다.
    //Queue는 startCharge로 초기화된다.
    
    while !chargePriority.isEmpty { //우선 순위 큐 chargePriority는 가장 높은 충전 용량을 지닌 충전소를 우선순위로 한다.
        //chargePriority이 비어 있지 않다면, 도달 가능한 충전소가 있다는 의미이다.
        guard let charge = chargePriority.dequeue() else {
            //dequeue로 충전 용량이 가장 큰 충전소를 가져온다.
            return .unreachable
        }
        
        currentCharge += charge //차량 충전
        minStops += 1 //최소 충전소 수 증가
        
        if currentCharge >= target { //currentCharge로 목적지에 도착할 수 있는지 확인한다.
            return .reachable(rechargeStops: minStops) //도착할 수 있다면, 현재까지 들린 충전소 수를 .reachable과 반환한다.
        }
        
        while currentStation < stations.count && currentCharge >= stations[currentStation].distance {
            //현재 남은 충전량으로 목적지에 도달할 수는 없지만, 아직 남은 충전소가 있으며 다음 충전소까지 운행할 수 있다면
            let distance = stations[currentStation].chargeCapacity //충전소의 chargeCapacity
            _ = chargePriority.enqueue(distance) //우선 순위 큐에 거리를 추가한다.
            currentStation += 1
        }
    }
    
    return .unreachable //목적지에 도착할 수 없다.
}
//들러야 하는 충전소의 최소 값을 구하기 위해, 우선 순위 큐를 사용하는 것이 하나의 해결책이다.
//구현한 함수의 우선 순위 큐는 도달 가능한 충전소 중 최대 용량을 가진 곳을 dequeue하는 greedy algorithm 이다.

let stations = [ChargingStation(distance: 10, chargeCapacity: 60),
                ChargingStation(distance: 20, chargeCapacity: 30),
                ChargingStation(distance: 30, chargeCapacity: 30),
                ChargingStation(distance: 60, chargeCapacity: 40)]

minRechargeStops(target: 100, startCharge: 10, stations: stations)
