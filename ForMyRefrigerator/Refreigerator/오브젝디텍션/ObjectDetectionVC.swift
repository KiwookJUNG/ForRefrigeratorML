//
//  ObjectDetectionVC.swift
//  ForMyRefrigerator
//
//  Created by 정기욱 on 02/06/2019.
//  Copyright © 2019 Nudge. All rights reserved.
//

// Object Detection을 위한 카메라 설정 클래스

import UIKit
import AVFoundation
import Vision

class ObjectDetectionVC: CameraVC {
    
    private var detectionOverlay: CALayer! = nil
    
    // 번역된 재료를 사용한다.
    var ingredient : [String : String] = ["cabbage":"양배추", "soybean":"된장","spam":"스팸","egg":"계란","RedPepperPaste":"고추장","kimchi":"김치","milk":"우유","carrot":"당근","tomato":"토마토","onion":"양파"]
    
    // 다음 뷰 컨트롤러로 전달할 배열
    var hasIngredient : [String] = []
    
    // Vision Parts
    // VNRequest의 배열을 만들어준다.
    private var requests = [VNRequest]()
    
    
    // Vision 세팅 메소드 : ML model을 설정 해준다.
    @discardableResult
    func setupVision() -> NSError? {
        // Setup Vision parts
        let error: NSError! = nil
        
        // ML 모델 설정
        guard let modelURL = Bundle.main.url(forResource: "NudgeOD02", withExtension: "mlmodelc") else {
            return NSError(domain: "VisionObjectRecognitionViewController", code: -1, userInfo: [NSLocalizedDescriptionKey: "Model file is missing"])
        }
        do {
            let visionModel = try VNCoreMLModel(for: MLModel(contentsOf: modelURL))
            // 설정한 ML Model을 사용해 분석한 결과를 매개변수로 하여 drawVisionRequestResults 메소드를 호출해준다
            // drawVisionrequestResults 메소드는 결과값을 사용해 바운딩 박스를 그려주는 메소드이다.
            let objectRecognition = VNCoreMLRequest(model: visionModel, completionHandler: { (request, error) in
                
                // 비동기 메소드를 사용하여 들어오는 모든 요청의 바운딩 박스를 그려준다.
                DispatchQueue.main.async(execute: {
                    if let results = request.results {
                        self.drawVisionRequestResults(results)
                    }
                })
            })
            self.requests = [objectRecognition]
        } catch let error as NSError {
            print("Model loading went wrong: \(error)")
        }
        
        return error
    }
    
    // ML Model을 사용하여 바운딩 박스를 그려주는 메소드
    func drawVisionRequestResults(_ results: [Any]) {
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        detectionOverlay.sublayers = nil // remove all the old recognized objects
        for observation in results where observation is VNRecognizedObjectObservation {
            guard let objectObservation = observation as? VNRecognizedObjectObservation else {
                continue
            }
            // Select only the label with the highest confidence.
            let topLabelObservation = objectObservation.labels[0]
            
            // 인식률이 95%가 넘으면 다음 뷰 컨트롤러에 전달해줄 hasIngredient 배열에 추가해준다.
            DispatchQueue.main.async(execute: {
                if( topLabelObservation.confidence > 0.95){
                    print(topLabelObservation.identifier)
                    if ( !self.hasIngredient.contains(topLabelObservation.identifier))
                    {
                        self.hasIngredient.append(topLabelObservation.identifier)
                    }
                }
            })
            
            // 바운딩 박스
            let objectBounds = VNImageRectForNormalizedRect(objectObservation.boundingBox, Int(bufferSize.width), Int(bufferSize.height))
            
            // 바운딩 박스의 배경 및 테두리 설정
            let shapeLayer = self.createRoundedRectLayerWithBounds(objectBounds)
            
            // 바운딩 박스에 들어갈 텍스트 및 정확도 설정
            let textLayer = self.createTextSubLayerInBounds(objectBounds,
                                                            identifier: topLabelObservation.identifier,
                                                            confidence: topLabelObservation.confidence)
            shapeLayer.addSublayer(textLayer)
            detectionOverlay.addSublayer(shapeLayer)
        }
        self.updateLayerGeometry()
        CATransaction.commit()
    }
    
    // 캡쳐 아웃풋이 샘플버퍼에 저장될 때 마다 실행되는 델리게이트 메소드
    override func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        let exifOrientation = exifOrientationFromDeviceOrientation()
        
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: exifOrientation, options: [:])
        do {
            try imageRequestHandler.perform(self.requests)
        } catch {
            print(error)
        }
    }
    
    // 캡쳐 설정
    override func setupAVCapture() {
        super.setupAVCapture()
        
        // setup Vision parts
        setupLayers()
        updateLayerGeometry()
        setupVision()
        
        // start the capture
        startCaptureSession()
    }
    
    // 카메라의 비디오를 보여주는 뷰의 레이어 설정 메소드
    func setupLayers() {
        detectionOverlay = CALayer() // container layer that has all the renderings of the observations
        detectionOverlay.name = "DetectionOverlay"
        detectionOverlay.bounds = CGRect(x: 0.0,
                                         y: 0.0,
                                         width: bufferSize.width,
                                         height: bufferSize.height)
        detectionOverlay.position = CGPoint(x: rootLayer.bounds.midX, y: rootLayer.bounds.midY)
        rootLayer.addSublayer(detectionOverlay)
    }
    
    func updateLayerGeometry() {
        let bounds = rootLayer.bounds
        var scale: CGFloat
        
        let xScale: CGFloat = bounds.size.width / bufferSize.height
        let yScale: CGFloat = bounds.size.height / bufferSize.width
        
        scale = fmax(xScale, yScale)
        if scale.isInfinite {
            scale = 1.0
        }
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        
        // rotate the layer into screen orientation and scale and mirror
        detectionOverlay.setAffineTransform(CGAffineTransform(rotationAngle: CGFloat(.pi / 2.0)).scaledBy(x: scale, y: -scale))
        // center the layer
        detectionOverlay.position = CGPoint (x: bounds.midX, y: bounds.midY)
        
        CATransaction.commit()
        
    }
    
    // 바운딩 박스의 배경 및 테두리 설정
    func createTextSubLayerInBounds(_ bounds: CGRect, identifier: String, confidence: VNConfidence) -> CATextLayer {
        let textLayer = CATextLayer()
        textLayer.name = "Object Label"
        let translated = self.ingredient[identifier]!
        
        let formattedString = NSMutableAttributedString(string: String(format: "\(translated)\n정확도:  %.2f", confidence))
        let largeFont = UIFont(name: "Helvetica", size: 24.0)!
        formattedString.addAttributes([NSAttributedString.Key.font: largeFont], range: NSRange(location: 0, length: identifier.count))
        textLayer.string = formattedString
        textLayer.bounds = CGRect(x: 0, y: 0, width: bounds.size.height - 10, height: bounds.size.width - 10)
        textLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
        textLayer.shadowOpacity = 0.7
        textLayer.shadowOffset = CGSize(width: 2, height: 2)
        textLayer.foregroundColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [0.0, 0.0, 0.0, 1.0])
        textLayer.contentsScale = 2.0 // retina rendering
        // rotate the layer into screen orientation and scale and mirror
        textLayer.setAffineTransform(CGAffineTransform(rotationAngle: CGFloat(.pi / 2.0)).scaledBy(x: 1.0, y: -1.0))
        return textLayer
    }
    
    // 바운딩 박스에 들어갈 텍스트 및 정확도 설정
    func createRoundedRectLayerWithBounds(_ bounds: CGRect) -> CALayer {
        let shapeLayer = CALayer()
        shapeLayer.bounds = bounds
        shapeLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
        shapeLayer.name = "Found Object"
        shapeLayer.backgroundColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [1.00, 0.58, 0.48, 0.4])
        //shapeLayer.borderColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [1.0, 1.0, 0.2, 0.4])
        shapeLayer.cornerRadius = 7
        return shapeLayer
    }
    
    // 화면이 바뀌기전 수행되는 메소드
    // 다음 뷰컨트롤러로 인식된 hasIngredient ( 식재료 배열 ) 을 전달한다.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "IngredientSegue2" {
            
            // 화면을 전환해주기전 인식한 재료를 전달해준다.
            let IngredientInfo = segue.destination as? DetailViewController
            IngredientInfo?.hasIngredient = self.hasIngredient
        }
    }
    
}

