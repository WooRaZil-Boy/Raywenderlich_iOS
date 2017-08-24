//
//  ViewController.swift
//  Snow Scene
//
//  Created by 근성가이 on 2017. 1. 21..
//  Copyright © 2017년 근성가이. All rights reserved.
//

import UIKit
import QuartzCore

class ViewController: UIViewController {
    
    @IBOutlet var bgImageView: UIImageView!
    
    @IBOutlet var summaryIcon: UIImageView!
    @IBOutlet var summary: UILabel!
    
    @IBOutlet var flightNr: UILabel!
    @IBOutlet var gateNr: UILabel!
    @IBOutlet var departingFrom: UILabel!
    @IBOutlet var arrivingTo: UILabel!
    @IBOutlet var planeImage: UIImageView!
    
    @IBOutlet var flightStatus: UILabel!
    @IBOutlet var statusBanner: UIImageView!
    
    //MARK: view controller methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //adjust ui
        summary.addSubview(summaryIcon)
        summaryIcon.center.y = summary.frame.size.height/2
        
        //start rotating the flights
        changeFlightDataTo(londonToParis)
        
        let rect = CGRect(x: 0.0, y: -70.0, width: view.bounds.width, height: 50.0)
        let emitter = CAEmitterLayer() //CAEmitterLayer생성. 특수한 레이어.
        emitter.frame = rect
        view.layer.addSublayer(emitter)
        
        emitter.emitterShape = kCAEmitterLayerRectangle //이미터 모양에는 크게 Point(모든 입자가 같은 지점에서 - 스파크, 불꽃), Line(프레임 상단 - 폭포), Rectangle(주어진 직사각형 안에서 임의의 위치 - 거품, 팝콘) //cuboid, circle, sphere 등이 더 있다.
        emitter.emitterPosition = CGPoint(x: rect.width / 2, y: rect.height / 2) //위치를 레이어 중심으로
        emitter.emitterSize = rect.size //크기는 같게
        
        //cell #1
        let emitterCell = CAEmitterCell()
        emitterCell.contents = #imageLiteral(resourceName: "flake").cgImage //이미터 셀은 입자의 한 소스를 나타내는 데이터 모델이다. //여러 개의 이미터 셀이 하나의 이미터 레이어에 추가 될 수 있다.
        emitterCell.birthRate = 20 //매 초 마다 이미터 20개 생성
        emitterCell.lifetime = 3.5 //하나의 이미터당 3.5초간 지속
        emitterCell.lifetimeRange = 1.0 //지속 시간 범위. 2.5 ~ 4.5
        emitterCell.yAcceleration = 70.0 //y축 가속도
        emitterCell.xAcceleration = 10.0 //x축 가속도
        emitterCell.velocity = 20.0 //초기 속도
        emitterCell.velocityRange = 200.0 //초기 속도에 임의의 값 범위 설정 //초기 속도가 20 이므로 여기서는 -180 ~ 220까지의 속도를 가진다.
        emitterCell.emissionLongitude = -.pi //초기 경도 //이미터 쏘는 각도
        emitterCell.emissionRange = .pi * 0.5 //초기 범위 //이미터 쏘는 각도 범위 //-180 이 초기 경도 이므로  -270 ~ -90 까지의 범위를 가진다.
        emitterCell.color = UIColor(red: 0.9, green: 1.0, blue: 1.0, alpha: 1.0).cgColor //색상 설정
        emitterCell.redRange = 0.1 //R 색상 범위 설정 //0.8 ~ 1.0
        emitterCell.greenRange = 0.1 //G 색상 범위 설정 //0.9 ~ 1.1
        emitterCell.blueRange  = 0.1 //B 색상 범위 설정 //0.9 ~ 1.1
        emitterCell.scale = 0.8 //이미터 0.8배
        emitterCell.scaleRange = 0.8 //이미터 크기 범위 0 ~ 1.6배 까지
        emitterCell.scaleSpeed = -0.15 //애니메이션 중 크기를 줄이거나 늘릴 수 있다. //초당 15%씩 축소
        emitterCell.alphaRange = 0.75 //투명도 범위 //0.25 ~ 1.0
        emitterCell.alphaSpeed = -0.15 //애니메이션 중 투명도를 줄이거나 늘릴 수 있다. //초당 15%씩 축소
        
        //cell #2
        let cell2 = CAEmitterCell()
        cell2.contents = #imageLiteral(resourceName: "flake2").cgImage
        cell2.birthRate = 50
        cell2.lifetime = 2.5
        cell2.lifetimeRange = 1.0
        cell2.yAcceleration = 50
        cell2.xAcceleration = 50
        cell2.velocity = 80
        cell2.emissionLongitude = .pi
        cell2.velocityRange = 20
        cell2.emissionRange = .pi * 0.25
        cell2.scale = 0.8
        cell2.scaleRange = 0.2
        cell2.scaleSpeed = -0.1
        cell2.alphaRange = 0.35
        cell2.alphaSpeed = -0.15
        cell2.spin = .pi
        cell2.spinRange = .pi
        
        //cell #3
        let cell3 = CAEmitterCell()
        cell3.contents = #imageLiteral(resourceName: "flake3").cgImage
        cell3.birthRate = 20
        cell3.lifetime = 7.5
        cell3.lifetimeRange = 1.0
        cell3.yAcceleration = 20
        cell3.xAcceleration = 10
        cell3.velocity = 40
        cell3.emissionLongitude = .pi
        cell3.velocityRange = 50
        cell3.emissionRange = .pi * 0.25
        cell3.scale = 0.8
        cell3.scaleRange = 0.2
        cell3.scaleSpeed = -0.05
        cell3.alphaRange = 0.5
        cell3.alphaSpeed = -0.05
        
        //cell #4
        let cell4 = CAEmitterCell()
        cell4.contents = #imageLiteral(resourceName: "flake4").cgImage
        cell4.birthRate = 20
        cell4.lifetime = 7.5
        cell4.lifetimeRange = 1.0
        cell4.yAcceleration = 20
        cell4.xAcceleration = 10
        cell4.velocity = 40
        cell4.emissionLongitude = .pi
        cell4.velocityRange = 50
        cell4.emissionRange = .pi * 0.25
        cell4.scale = 0.8
        cell4.scaleRange = 0.2
        cell4.scaleSpeed = -0.05
        cell4.alphaRange = 0.5
        cell4.alphaSpeed = -0.05
        
        emitter.emitterCells = [emitterCell, cell2, cell3, cell4] //셀 추가. //여러 개의 이미터를 배열로 추가해 줄 수 있다.
    }
    
    //MARK: custom methods
    
    func changeFlightDataTo(_ data: FlightData) {
        
        // populate the UI with the next flight's data
        summary.text = data.summary
        flightNr.text = data.flightNr
        gateNr.text = data.gateNr
        departingFrom.text = data.departingFrom
        arrivingTo.text = data.arrivingTo
        flightStatus.text = data.flightStatus
        bgImageView.image = UIImage(named: data.weatherImageName)
    }
}

