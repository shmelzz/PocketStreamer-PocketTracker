//
//  FaceTrackerExtension.swift
//  FaceTrackingStreamer
//
//  Created by ZhengWu Pan on 06.05.2023.
//

import Foundation
import ARKit

extension ARFaceAnchor {
    var eyeNoseMouthData: [String: Any] {
        let leftEye = leftEyeTransform.positionArray
        let rightEye = rightEyeTransform.positionArray
        let geometry_vertices = geometry.vertices.map { [$0.x, $0.y, $0.z] }.flatMap { $0 }.map{ Float32($0) }
        let geometry_textureCoordinates = geometry.textureCoordinates.map { [$0.x, $0.y] }.flatMap { $0 }.map{ Float32($0) }
        let geometry_triangleIndices = geometry.triangleIndices.map { Float32($0) }
        let geometry_triangleCount = Int32(geometry.triangleCount)


        return [
            "timeCode": DispatchTime.now().uptimeNanoseconds,
            "leftEye": leftEye,
            "rightEye": rightEye,
            "geometryVertices": geometry_vertices,
            "geometryTextureCoordinates": geometry_textureCoordinates,
            "geometryTriangleIndices": geometry_triangleIndices,
            "geometryTriangleCount": geometry_triangleCount,
        ]
    }
}

extension float4x4 {
    var positionArray: [Float] {
        return [columns.3.x, columns.3.y, columns.3.z]
    }
}
