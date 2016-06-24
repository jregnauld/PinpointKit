//
//  ArrowAnnotationView.swift
//  Pinpoint
//
//  Created by Caleb Davenport on 3/29/15.
//  Copyright (c) 2015 Lickability. All rights reserved.
//

import UIKit

/// The default arrow annotation view.
public class ArrowAnnotationView: AnnotationView {

    // MARK: - Properties

    /// The corresponding annotation.
    var annotation: ArrowAnnotation? {
        didSet {
            setNeedsDisplay()
            layer.shadowPath = annotation?.path?.cgPath
        }
    }

    override var annotationFrame: CGRect? {
        return annotation?.path?.bounds
    }

    // MARK: - Initializers

    convenience init() {
        self.init(frame: CGRect.zero)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        isOpaque = false
        contentMode = .redraw

        layer.shadowOffset = CGSize.zero
        layer.shadowColor = UIColor.black().cgColor
        layer.shadowOpacity = 1
        layer.shadowRadius = 4
    }
    
    @available(*, unavailable)
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UIView

    override public func tintColorDidChange() {
        super.tintColorDidChange()
        setNeedsDisplay()
    }

    override public func draw(_ rect: CGRect) {
        tintColor.setFill()
        annotation?.strokeColor.setStroke()

        let path = annotation?.path
        path?.fill()
        path?.stroke()
    }

    override public func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return annotation?.touchTargetPath?.contains(point) ?? false
    }


    // MARK: - AnnotationView

    override func setSecondControlPoint(_ point: CGPoint) {
        guard let previousAnnotation = annotation else { return }
        
        annotation = ArrowAnnotation(startLocation: previousAnnotation.startLocation, endLocation: point, strokeColor: previousAnnotation.strokeColor)
    }

    override func moveControlPoints(_ translation: CGPoint) {
        guard let previousAnnotation = annotation else { return }
        let startLocation = CGPoint(x: previousAnnotation.startLocation.x + translation.x, y: previousAnnotation.startLocation.y + translation.y)
        let endLocation = CGPoint(x: previousAnnotation.endLocation.x + translation.x, y: previousAnnotation.endLocation.y + translation.y)
        
        annotation = ArrowAnnotation(startLocation: startLocation, endLocation: endLocation, strokeColor: previousAnnotation.strokeColor)
    }
    
    override func scaleControlPoints(_ scale: CGFloat) {
        guard let previousAnnotation = annotation else { return }
        let startLocation = previousAnnotation.scaledPoint(previousAnnotation.startLocation, scale: scale)
        let endLocation = previousAnnotation.scaledPoint(previousAnnotation.endLocation, scale: scale)
        
        annotation = ArrowAnnotation(startLocation: startLocation, endLocation: endLocation, strokeColor: previousAnnotation.strokeColor)
    }
}

private extension ArrowAnnotation {
    
    var path: UIBezierPath? {
        if arrowLength < headLength * 2.0 {
            return nil
        }
        
        let path = UIBezierPath.arrowBezierPath(
            startPoint: startLocation,
            endPoint: endLocation
        )
        
        path.lineWidth = strokeWidth
        return path
    }
    
    var touchTargetPath: UIBezierPath? {
        guard let path = path else { return nil }
        
        let outsideStrokeWidth = strokeWidth * 5.0
        guard let strokedPath = CGPath(copyByStroking: path.cgPath, transform: nil, lineWidth: outsideStrokeWidth, lineCap: .butt, lineJoin: .bevel, miterLimit: 0) else { return nil }
        
        return UIBezierPath(cgPath: strokedPath)
    }
}
