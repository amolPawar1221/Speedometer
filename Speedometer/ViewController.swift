//
//  ViewController.swift
//  Speedometer
//
//  Created by Amol Pawar on 22/12/17.
//  Copyright © 2017 Amol Pawar Software. All rights reserved.
//

import UIKit
import CoreGraphics

class ViewController: UIViewController {
    @IBOutlet weak var pinImageview: UIImageView!
    
   // @IBOutlet weak var speedoView: UIView!
    @IBOutlet weak var rotateView: UIView!
    
    
    var circleRadius:CGFloat!
    var angleDifference: CGFloat!
    var startangle:CGFloat!
    var endAngle:CGFloat!
    var partsAngle:Float!
    
    var previousAngle:CGFloat = 0;
    let lineWidth:CGFloat = 40
    var totalParts = 10
    let startingAngleInDegree:Float = 165
    let endAngleInDegree:Float = 15
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
//        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
//        pinImageview.isUserInteractionEnabled = true
//        pinImageview.addGestureRecognizer(pan)
        
        
        
        circleRadius = UIScreen.main.bounds.width / 3
        
        startangle = CGFloat(degreeToRadian(degree: startingAngleInDegree))
        endAngle = CGFloat(degreeToRadian(degree: endAngleInDegree))
       
        angleDifference = CGFloat(radiansToDegrees(radian: Float(2 * .pi - startangle + endAngle)))
        
        partsAngle = Float(angleDifference / CGFloat(totalParts))
        
        addShapeLayer(startangle: startangle, endAngle: endAngle, lineWidth: lineWidth)
        
        basicAnimationForPin(fromValue: Float(startangle), toValue: Float(startangle))
        
        drawTheLines()
        
        self.view.bringSubview(toFront: rotateView)
    }
    func handlePan(recognizer:UIPanGestureRecognizer){
        let translation = recognizer.translation(in: self.view)
        if let view = recognizer.view {
           // view.center = CGPoint(x:view.center.x + translation.x,
            //                      y:view.center.y + translation.y)
             calculatePoints(touchLocation:translation)
        }
        recognizer.setTranslation(CGPoint.zero, in: self.view)
    }
    private func drawTheLines(){
        var totalAngle:CGFloat = startangle
        
        for i in 0...totalParts {
            
            self.addLines(angle: totalAngle, circleRadius: (circleRadius + 25), strokeColor: .black)
            
            self.addLabel(angle: totalAngle, circleRadius: (circleRadius + 36), labelText: i)
            
            var inSideAngle = totalAngle
            inSideAngle = inSideAngle + CGFloat(Float(partsAngle/(Float(totalParts) - 1)) / 180.0 * .pi)
            
            totalAngle = totalAngle + CGFloat(partsAngle / 180.0 * .pi)
            
            if i < totalParts {
                
                for _ in 0...totalParts-3 {
                    
                    self.addLines(angle: inSideAngle, circleRadius: (circleRadius + 20), strokeColor: .yellow)
                    inSideAngle = inSideAngle + CGFloat(Float(partsAngle/(Float(totalParts) - 1)) / 180.0 * .pi)
                }
            }
        }
    }
    
    private func addShapeLayer(startangle:CGFloat,endAngle:CGFloat,lineWidth:CGFloat){
        let shapelayer = CAShapeLayer()
        shapelayer.fillColor = UIColor.clear.cgColor
        shapelayer.strokeColor = UIColor.red.cgColor
        shapelayer.path = UIBezierPath(arcCenter: .zero, radius: circleRadius, startAngle: CGFloat(startangle), endAngle: CGFloat(endAngle), clockwise: true).cgPath
        shapelayer.lineWidth = CGFloat(lineWidth)
        
        shapelayer.position = view.center
        
        let gradient = CAGradientLayer()
        gradient.frame = view.frame
        gradient.position = view.center
        gradient.colors = [UIColor.blue.cgColor,
                           UIColor.red.cgColor]
        gradient.startPoint = CGPoint(x: 0, y: 1)
        gradient.endPoint = CGPoint(x: 1, y: 0)
        gradient.mask = shapelayer
        
        view.layer.addSublayer(gradient)
    }
    
    private func addLines(angle:CGFloat,circleRadius:CGFloat ,strokeColor:UIColor){
        
        let x0 = circleRadius * cos(angle) + view.center.x
        let y0 = circleRadius * sin(angle) + view.center.y
        
        let x1 = (self.circleRadius - 20) * cos(angle) + view.center.x
        let y1 = (self.circleRadius - 20) * sin(angle) + view.center.y
        
        let bPath = UIBezierPath()
        bPath.move(to: CGPoint(x: x0, y: y0))
        bPath.addLine(to: CGPoint(x: x1, y: y1))
        
        let shapeLayer2 = CAShapeLayer()
        shapeLayer2.path = bPath.cgPath
        shapeLayer2.strokeColor = strokeColor.cgColor
        shapeLayer2.fillColor = strokeColor.cgColor
        shapeLayer2.lineWidth = 1.0
        bPath.close()
        view.layer.insertSublayer(shapeLayer2, at:UInt32(view.layer.sublayers?.count ?? 0))
    }
    
    private func addLabel(angle:CGFloat,circleRadius:CGFloat,labelText:Int){
        let x = circleRadius * cos(angle) + view.center.x
        let y = circleRadius * sin(angle) + view.center.y
        let uilabel = UILabel(frame: CGRect(x: 0, y: 0, width: 22, height: 22))
        uilabel.center = CGPoint(x: x, y: y)
        uilabel.text = "\(labelText)"
        uilabel.textColor = .black
        uilabel.textAlignment = .center
        uilabel.font = UIFont.systemFont(ofSize: 10)
        view.addSubview(uilabel)
    }
    
    private func basicAnimationForPin(fromValue:Float,toValue:Float){
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotationAnimation.fromValue = NSNumber(value:  fromValue)
        rotationAnimation.toValue = NSNumber(value: toValue)
        rotationAnimation.duration = 1.0
        rotationAnimation.isRemovedOnCompletion = false;
        rotationAnimation.fillMode = kCAFillModeForwards;
        rotationAnimation.autoreverses = false;
        previousAngle = CGFloat(toValue)
        rotateView.layer.add(rotationAnimation, forKey: "rotationAnimation")
    }
    
    func handleShapeLayerPan(panGesture:UIPanGestureRecognizer){
        switch panGesture.state {
        case .began:
            
            break
            
        case .changed:
            let touchLocation = panGesture.location(in: view)
            calculatePoints(touchLocation:touchLocation)
            break
            
        case .ended:
            break
            
        default:
            break
        }
    }
    func degreeToRadian(degree:Float)->Float{
        return degree * .pi / 180
    }
    func radiansToDegrees(radian:Float)->Float{
        return radian * 180 / .pi
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchLocation = touch.location(in: self.view)
            calculatePoints(touchLocation:touchLocation)
        }
    }
    
    func calculatePoints(touchLocation:CGPoint){
        let x = (touchLocation.x - view.center.x)
        let y = (touchLocation.y - view.center.y)
        
        let distance =  sqrt((x * x) + (y * y))
        
        if (Float(distance) <= Float(circleRadius + 22)) && (Float(distance) >= Float(circleRadius + 18) - Float(lineWidth)){
            
            var angleInDegree = angleToPoint(tapPoint: touchLocation)
            
            if angleInDegree <= 15 {
                angleInDegree = 360 + angleInDegree
            }
            
            if angleInDegree >= Float(startangle) || angleInDegree <= Float(endAngle) {
                
                let finalAngle = sectionOfAngle(angleInDegree)
                let angleInRandian = degreeToRadian(degree: finalAngle.angle)
                
                basicAnimationForPin(fromValue: Float(previousAngle), toValue: angleInRandian)
            }
        }
    }
    
    func angleToPoint(tapPoint:CGPoint) -> Float{
        let x = self.view.center.x
        let y = self.view.center.y
        
        let dx = tapPoint.x - x;
        let dy = tapPoint.y - y;
        
        var angle = atan2(dy, dx) * 180.0 / .pi;
        if (angle < 0)
        {
            angle += 360.0
        }
        return Float(angle);
    }
    
    func sectionOfAngle(_ angle:Float)->(sectionNo:Int,angle:Float){
        
        let startangle1 = radiansToDegrees(radian: Float(startangle))
        let nextRange = (startangle1 + Float(partsAngle/2))
        
        switch angle {
        case startangle1...nextRange:
            
            return (0,startangle1)
            
        case nextRange...(nextRange + partsAngle):
            
            return (1,startangle1 + partsAngle)
            
        case (nextRange + partsAngle)...(nextRange + (partsAngle * 2)):
            
            return (2,startangle1 + (partsAngle * 2))
            
        case (nextRange + (partsAngle * 2))...(nextRange + (partsAngle * 3)):
            
            return (3,startangle1 + (partsAngle * 3))
            
        case (nextRange + (partsAngle * 3))...(nextRange + (partsAngle * 4)):
            
            return (4,startangle1 + (partsAngle * 4))
            
        case (nextRange + (partsAngle * 4))...(nextRange + (partsAngle * 5)):
            
            return (5,startangle1 + (partsAngle * 5))
            
        case (nextRange + (partsAngle * 5))...(nextRange + (partsAngle * 6)):
            
            return (6,startangle1 + (partsAngle * 6))
            
        case (nextRange + (partsAngle * 6))...(nextRange + (partsAngle * 7)):
            
            return (7,startangle1 + (partsAngle * 7))
            
        case (nextRange + (partsAngle * 7))...(nextRange + (partsAngle * 8)):
            
            return (8,startangle1 + (partsAngle * 8))
            
        case (nextRange + (partsAngle * 8))...(nextRange + (partsAngle * 9)):
            
            return (9,startangle1 + (partsAngle * 9))
            
        case (nextRange + Float(partsAngle/2))...(radiansToDegrees(radian: Float(endAngle)) + 360):
            
            return (10,startangle1 + (partsAngle * 10))
            
        default:
            return (-1 ,radiansToDegrees(radian: Float(previousAngle)))
        }
    }
    
    
}

