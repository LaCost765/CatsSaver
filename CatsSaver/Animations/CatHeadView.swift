//
//  CatHeadView.swift
//  CatsSaver
//
//  Created by Egor on 13.09.2021.
//

import UIKit

@IBDesignable
class CatHeadView: UIView {
    
    // MARK: - Свойства
    
    private var catLayer: CAShapeLayer!
    
    // MARK: - Инициализаторы
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    //MARK: - Методы

    /// - Устанавливает цвет обводки, заливки, а также толщину обводки
    private func setup() {
        
        catLayer = CAShapeLayer()
        catLayer.path = generateCatPath().cgPath
        catLayer.strokeColor = UIColor.systemBlue.cgColor
        catLayer.fillColor = UIColor.systemGray6.cgColor
        catLayer.lineWidth = 2.5
        self.layer.addSublayer(catLayer)
    }
    
    /// - Создает форму с помощью UIBezierPath в форме головы кота
    private func generateCatPath() -> UIBezierPath {
        let width = self.bounds.width
        let height = self.bounds.height
        
        let startPoint = CGPoint(x: width * 0.1, y: height * 0.25)
        let catPath = UIBezierPath()
        catPath.move(to: startPoint)
        catPath.addLine(to: CGPoint(x: startPoint.x, y: startPoint.y - height * 0.25))
        catPath.addLine(to: CGPoint(x: startPoint.x + width * 0.2, y: startPoint.y - height * 0.0625))
        
        catPath.addCurve(to: CGPoint(x: startPoint.x + 0.6 * width, y: startPoint.y - height * 0.0625),
                         controlPoint1: CGPoint(x: startPoint.x + 0.3 * width, y: startPoint.y - 0.125 * height),
                         controlPoint2: CGPoint(x: startPoint.x + 0.5 * width, y: startPoint.y - 0.125 * height))
        
        catPath.addLine(to: CGPoint(x: startPoint.x + 0.8 * width, y: startPoint.y - height * 0.25))
        catPath.addLine(to: CGPoint(x: startPoint.x + 0.8 * width, y: startPoint.y))
        catPath.addCurve(to: startPoint,
                         controlPoint1: CGPoint(x: startPoint.x + 1.1 * width, y: startPoint.y + 0.75 * height),
                         controlPoint2: CGPoint(x: startPoint.x - 0.3 * width, y: startPoint.y + 0.75 * height))
        
        return catPath
    }
    
    /// - Добавляет анимацию вокруг вью в стиле индикатора загрузки
    func addAnimation() {
        let strokeStartAnimation = CABasicAnimation(keyPath: "strokeStart")
        strokeStartAnimation.fromValue = -0.5
        strokeStartAnimation.toValue = 1.0
        
        let strokeEndAnimation = CABasicAnimation(keyPath: "strokeEnd")
        strokeEndAnimation.fromValue = 0
        strokeEndAnimation.toValue = 1
        
        let animationGroup = CAAnimationGroup()
        animationGroup.duration = 1.2
        animationGroup.beginTime = CACurrentMediaTime()
        animationGroup.animations = [strokeEndAnimation, strokeStartAnimation]
        animationGroup.fillMode = .backwards
        animationGroup.repeatCount = .infinity
        catLayer.add(animationGroup, forKey: nil)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        addAnimation()
    }
}
