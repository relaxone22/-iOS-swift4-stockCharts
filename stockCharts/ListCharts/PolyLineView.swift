//
//  PolyLineView.swift
//  stockCharts
//
//  Created by tonyliu on 2018/4/24.
//  Copyright © 2018 mitake. All rights reserved.
//

import UIKit

// MARK: 客製化視圖
class PolyLineView: UIView {
    
    fileprivate var viewModel = PolyLineModel()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init() {
        super.init(frame: CGRect.zero)
        backgroundColor = UIColor.black
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.drawLineLayer()
    }
    
// MARK: 畫圖開放的方法
    
    /// 開始畫圖
    func stockFill() {
        viewModel.config(size: bounds.size)
        setNeedsDisplay()
    }
    
    /// 畫曲線圖
    func drawLineLayer() {
        // 畫圖
        let path = UIBezierPath.drawLine(points: viewModel.points)
        
        let chartModel = viewModel.chartModel
        let polyLineLayer = CAShapeLayer()
        polyLineLayer.path = path.cgPath
        polyLineLayer.strokeColor = chartModel.lineColor.cgColor
        polyLineLayer.fillColor = UIColor.clear.cgColor
        
        polyLineLayer.lineWidth = chartModel.lineWidth
        polyLineLayer.lineCap = kCALineCapRound
        polyLineLayer.lineJoin = kCALineJoinRound
        polyLineLayer.contentsScale = UIScreen.main.scale
        layer.addSublayer(polyLineLayer)
        
        if viewModel.isFillColor, let lastPoint = viewModel.points.last {
            
            let yPosition = bounds.size.height - chartModel.topMargin
            path.addLine(to: CGPoint(x: lastPoint.xPosition, y: yPosition))
            path.addLine(to: CGPoint(x: chartModel.leftMargin, y: yPosition))
            path.lineWidth = 0
            viewModel.fillColor.setFill()
            path.fill()
            path.stroke()
            path.close()
        }
        
        // 動畫
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = 2
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        animation.fromValue = 0
        animation.toValue = 1
        polyLineLayer.add(animation, forKey: nil)
    }
}

// MARK: 折線圖資料模型
fileprivate struct PolyLineModel {
    let datas: [Int] = [12, 33, 26, 10, 7, 30, 21]
    let fillColor: UIColor = UIColor.blue
    let isFillColor: Bool = true
    
    var chartModel: ChartModel = ChartModel()
    var points: [PointModel] = []
    
    mutating func config(size: CGSize) {
        
        let height = size.height
        let width = size.width
        
        chartModel.lineSpace = (width - chartModel.leftMargin - chartModel.rightMargin) / CGFloat(datas.count - 1)
        
        chartModel.maxY = CGFloat(datas.max()!)
        chartModel.minY = CGFloat(datas.min()!)
        chartModel.scaleY = (height - chartModel.topMargin - chartModel.bottomMargin) / (chartModel.maxY - chartModel.minY)
        
        for (index, value) in datas.enumerated() {
            let x = chartModel.lineSpace * CGFloat(index) + chartModel.leftMargin
            let y = (chartModel.maxY - CGFloat(value)) * chartModel.scaleY + chartModel.topMargin
            let point = PointModel(xPosition: x, yPosition: y, lineColor: chartModel.lineColor)
            
            points.append(point)
        }
    }
}
