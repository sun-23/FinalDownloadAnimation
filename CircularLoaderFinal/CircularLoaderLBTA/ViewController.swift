//
//  ViewController.swift
//  CircularLoaderLBTA
//
//  Created by Brian Voong on 12/8/17.
//  Copyright © 2017 Lets Build That App. All rights reserved.
//

import UIKit

class ViewController: UIViewController, URLSessionDownloadDelegate {
    
    // เส้น download
    var shapeLayer: CAShapeLayer!
    // วงกลมที่ ขยายหด ได้
    var pulsatingLayer: CAShapeLayer!
    
    let percentageLabel: UILabel = {
        let label = UILabel()
        label.text = "Start"
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 32)
        label.textColor = .white
        return label
    }()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    private func setupNotificationObservers() {
       NotificationCenter.default.addObserver(self, selector: #selector(handleEnterForeground), name: .UIApplicationWillEnterForeground, object: nil)
    }
    
    @objc private func handleEnterForeground() {
        animatePulsatingLayer()
    }
    
    // สร้างวงกลม
    private func createCircleShapeLayer(strokeColor: UIColor, fillColor: UIColor) -> CAShapeLayer {
        
        let layer = CAShapeLayer()
        let circularPath = UIBezierPath(arcCenter: .zero, radius: 100, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true)
        layer.path = circularPath.cgPath
        layer.strokeColor = strokeColor.cgColor //สีขอบ
        layer.lineWidth = 20 // ความกว้างขอบ ของวงกลม
        layer.fillColor = fillColor.cgColor // สีด้านใน
        layer.lineCap = kCALineCapRound // ทำให้ หัวท้ายของเส้น download โค้งมน (ความจริงคือทำให็เส้นรอบวงมีหัวท้ายที่โค้งมน)
        layer.position = view.center // ตำแหน่ง
        return layer
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
     setupNotificationObservers() // ฟังชั่นนี้ไม่มีผลต่อ program
        
        view.backgroundColor = UIColor.backgroundColor
        
        setupCircleLayers()
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
        
        setupPercentageLabel()
    }
    
    // กดหนดตำแหน่งของ percentageLabel
    private func setupPercentageLabel() {
        view.addSubview(percentageLabel)
        percentageLabel.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        percentageLabel.center = view.center
    }
    
    // setup
    private func setupCircleLayers() {
    
        // วงกลมที่ขยายหดได้
        pulsatingLayer = createCircleShapeLayer(strokeColor: .clear, fillColor: UIColor.pulsatingFillColor)
        view.layer.addSublayer(pulsatingLayer)
        
        animatePulsatingLayer()
        
        // เส้นพื้นหลังเส้น download (ความจริง คือ วงกลมที่มีขอบเป็นสี trackStrokeColor และสีด้านในคือ สี backgroundColor)
        let trackLayer = createCircleShapeLayer(strokeColor: .trackStrokeColor, fillColor: .backgroundColor)
        view.layer.addSublayer(trackLayer)
        
        // เส้น download (ความจริงคือวงกลม ที่ ไม่มีสีด้านใน มีแต่สีขอบ แล้วขอบคือ เส้น download)
        shapeLayer = createCircleShapeLayer(strokeColor: .outlineStrokeColor, fillColor: .clear)
        
//        กำหนดด้าน และจุดเริ่มต้นของเส้น download
        shapeLayer.transform = CATransform3DMakeRotation(-CGFloat.pi / 2, 0, 0, 1)
        //        กำหนดความยาวเส้น download = 0
        shapeLayer.strokeEnd = 0
        view.layer.addSublayer(shapeLayer)
    }
    
    /* วงกลม layer หลังสุด ที่ ขยายแล้วหด ได้ */
    private func animatePulsatingLayer()  {
        
        let animation = CABasicAnimation(keyPath: "transform.scale")
        
        animation.toValue = 1.5 // ความหนาของเส้น animatePulsatingLayer
        animation.duration = 0.8 // เวลาของ animatePulsatingLayer
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        animation.autoreverses = true
        animation.repeatCount = Float.infinity
        
        pulsatingLayer.add(animation, forKey: "pulsing")
        
    }
    
    let urlString = "https://firebasestorage.googleapis.com/v0/b/firestorechat-e64ac.appspot.com/o/intermediate_training_rec.mp4?alt=media&token=e20261d0-7219-49d2-b32d-367e1606500c"
    
    //downloadfile
    private func beginDownloadingFile() {
        print("Attempting to download file")
        
//        ความยาวเส้น download = 0
        shapeLayer.strokeEnd = 0
        
        let configuration = URLSessionConfiguration.default
        let operationQueue = OperationQueue()
        let urlSession = URLSession(configuration: configuration, delegate: self, delegateQueue: operationQueue)
        
        guard let url = URL(string: urlString) else { return }
        let downloadTask = urlSession.downloadTask(with: url)
        downloadTask.resume()
    }
    
    // calculate by download
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let percentage = CGFloat(totalBytesWritten) / CGFloat(totalBytesExpectedToWrite)
        
        DispatchQueue.main.async {
            self.percentageLabel.text = "\(Int(percentage * 100))%"
            self.shapeLayer.strokeEnd = percentage // update ความยาวเส้น download
        }
        
        print("percentage of doenload byte = \(Int(percentage * 100)) form \(totalBytesWritten) byte of \(totalBytesExpectedToWrite) byte ")
    }
    
    // Action when Downloadfinish
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        print("Finished downloading file")
    }
    
    // อันนี้เป็น function พื้นฐานในการทำ animation เส้น download แต่เราไม่ใช้
    fileprivate func animateCircle() {
        let basicAnimation = CABasicAnimation(keyPath: "strokeEnd")
        
        basicAnimation.toValue = 1
        
        basicAnimation.duration = 2
        
        basicAnimation.fillMode = kCAFillModeForwards
        basicAnimation.isRemovedOnCompletion = false
        
        shapeLayer.add(basicAnimation, forKey: "urSoBasic")
    }
    
    @objc private func handleTap() {
        print("Attempting to animate stroke")
        
        beginDownloadingFile()
        
   //     animateCircle()
    }

}

