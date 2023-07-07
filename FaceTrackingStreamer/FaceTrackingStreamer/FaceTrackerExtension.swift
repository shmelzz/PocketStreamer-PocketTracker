//
//  FaceTrackerExtension.swift
//  FaceTrackingStreamer
//
//  Created by ZhengWu Pan on 06.05.2023.
//

import Foundation
import ARKit

extension ARFaceAnchor {
    
    var eyeNoseMouthData: [String: Float] {
        var blendShapes = Dictionary(uniqueKeysWithValues:
                                        blendShapes.map { key, value in (key.rawValue, value.floatValue) })
        blendShapes["timeCode"] = Float(DispatchTime.now().uptimeNanoseconds)
        print(blendShapes["timeCode"])
        return blendShapes
    }
}

extension float4x4 {
    var positionArray: [Float] {
        return [columns.3.x, columns.3.y, columns.3.z]
    }
}
