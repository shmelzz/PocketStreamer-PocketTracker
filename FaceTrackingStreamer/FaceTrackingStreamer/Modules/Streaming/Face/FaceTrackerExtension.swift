import Foundation
import ARKit

extension ARFaceAnchor {
    
    var eyeNoseMouthData: [String: Float] {
        var blendShapes = Dictionary(uniqueKeysWithValues:
                                        blendShapes.map { key, value in (key.rawValue, value.floatValue) })
        blendShapes["timeCode"] = Float(DispatchTime.now().uptimeNanoseconds)
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
    var positionArray: [Float] {
        return [columns.3.x, columns.3.y, columns.3.z]
    }
}
