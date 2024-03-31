import Foundation
import ARKit

extension simd_float4x4: Collection {
    public var startIndex: Int {
        return 0
    }

    public var endIndex: Int {
        return 4
    }

    public func index(after i: Int) -> Int {
        return i + 1
    }
}

extension ARFaceAnchor {
    
    var eyeNoseMouthData: [String: Float] {
        var blendShapes = Dictionary(uniqueKeysWithValues:
                                        blendShapes.map { key, value in (key.rawValue, value.floatValue) })
        blendShapes["timeCode"] = Float(DispatchTime.now().uptimeNanoseconds)
        
//        blendShapes["lookAtPointX"] = lookAtPoint.x
//        blendShapes["lookAtPointY"] = lookAtPoint.y
//        blendShapes["lookAtPointZ"] = lookAtPoint.z

        let text = "faceAnchorM"
        
        let matrix = transform.compactMap{ $0 }
        
        for i in 0...3 {
            for j in 0...3 {
                blendShapes["\(text)\(i)\(j)"] = transform[i][j]
            }
        }
        
        return blendShapes
    }
}

extension ARBodyAnchor {
    
//    var data: [String: Float] {
//        // Get an index for a foot.
//        skeleton.localTransform(for: .leftFoot)
//        let footIndex = ARSkeletonDefinition.defaultBody3D.index(for: .leftFoot)
//            // Get the foot's world-space offset from the hip.
//        let footTransform = ARSkeletonDefinition.defaultBody3D.neutralBodySkeleton3D?.jointModelTransforms[footIndex]
//            // Return the height by getting just the y-value.
//        let distanceFromHipOnY = abs(footTransform?.columns.3.y ?? 0)
//        // return distanceFromHipOnY
//    }
}

extension float4x4 {
    var translationArray: [Float] {
        return [columns.3.x, columns.3.y, columns.3.z]
    }
}
