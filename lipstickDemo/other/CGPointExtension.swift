//
//  CGPointExtension.swift
//  lipstickDemo
//
//  Created by 天明 on 2018/12/3.
//  Copyright © 2018 天明. All rights reserved.
//

import UIKit

extension CGPoint {
    
    /// 任意点(x,y)，绕一个坐标点center(rx0,ry0)逆时针旋转anlge角度后的新的坐标设为(x0, y0)
    func roateByCenter(_ center: CGPoint, anlge: CGFloat) -> CGPoint {
        let x0 = (x - center.x)*cos(anlge) - (y - center.y)*sin(anlge) + center.x
        let y0 = (x - center.x)*sin(anlge) + (y - center.y)*cos(anlge) + center.y
        return CGPoint(x: x0, y: y0)
    }
}
