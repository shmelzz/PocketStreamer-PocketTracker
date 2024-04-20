import Foundation
import RealityKit
import ARKit

extension simd_float4x4: Collection, Encodable {
    public var startIndex: Int {
        return 0
    }
    
    public var endIndex: Int {
        return 4
    }
    
    public func index(after i: Int) -> Int {
        return i + 1
    }
    
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        try self.init(container.decode([SIMD4<Float>].self))
    }
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode([columns.0,columns.1, columns.2, columns.3])
    }
}

extension ARFaceAnchor {
    
    var eyeNoseMouthData: [String: Float] {
        var blendShapes = Dictionary(uniqueKeysWithValues:
                                        blendShapes.map { key, value in (key.rawValue, value.floatValue) })
        blendShapes["timeCode"] = Float(DispatchTime.now().uptimeNanoseconds)
        
        let text = "faceAnchorM"
        for i in 0...3 {
            for j in 0...3 {
                blendShapes["\(text)\(i)\(j)"] = transform[i][j]
            }
        }
        
        return blendShapes
    }
}

extension ARBodyAnchor {
    
    var data: [String: simd_float4x4] {
        
        let modelJoints = ["hips_joint": "Hips",
                           "spine_4_joint": "Spine",
                           "spine_7_joint": "Chest",
                           "neck_1_joint": "UpperChest",
                           "neck_3_joint": "Neck",
                           "head_joint": "Head",
                           "left_shoulder_1_joint": "Shoulder_L",
                           "left_arm_joint": "UpperArm_L",
                           "left_forearm_joint": "LowerArm_L",
                           "left_hand_joint": "Hand_L",
                           "right_shoulder_1_joint": "Shoulder_R",
                           "right_arm_joint": "UpperArm_R",
                           "right_forearm_joint": "LowerArm_R",
                           "right_hand_joint": "Hand_R",
                           "left_upLeg_joint": "UpperLeg_L",
                           "left_leg_joint": "LowerLeg_L",
                           "left_foot_joint": "Foot_L",
                           "left_toes_joint": "ToeBase_L",
                           "right_upLeg_joint": "UpperLeg_R",
                           "right_leg_joint": "LowerLeg_R",
                           "right_foot_joint": "Foot_R",
                           "right_toes_joint": "ToeBase_R"
        ]
        
        let toSent = ["Shoulder_L", "UpperArm_L", "LowerArm_L", "Hand_L",
                      "Shoulder_R", "UpperArm_R", "LowerArm_R", "Hand_R",
                      "UpperLeg_L",
                      "Hips"
                      
        ]
        
        let transforms = skeleton.jointModelTransforms
        let jointNames = skeleton.definition.jointNames
        
        var result = Dictionary(keys: jointNames, values: transforms).filter {
            modelJoints.keys.contains($0.key)
        }
        
        for key in result.keys {
            guard let modelKey = modelJoints[key] else { continue }
            result.changeKey(from: key, to: modelKey)
        }
//        
//        for key in result.keys {
//            if toSent.contains(key) { continue }
//            result[key] = simd_float4x4.init()
//        }
        
        
//        var fin: [String: [[SIMD3<Float>]]] = [:]
//        
//        for key in result.keys {
//            guard let matrix = result[key] else { return fin }
//            
//            fin[key] = [[quatToEulerAngles(Transform(matrix:matrix).rotation)]]
//        }
        
        return result
    }
    
    func quatToEulerAngles(_ quat: simd_quatf) -> SIMD3<Float>{
        let n = SCNNode()
        n.simdOrientation = quat
        return n.simdEulerAngles
    }
}

extension float4x4 {
    var translationArray: [Float] {
        return [columns.3.x, columns.3.y, columns.3.z]
    }
}

extension Dictionary {
    init(keys: [Key], values: [Value]) {
        self.init()
        
        for (key, value) in zip(keys, values) {
            self[key] = value
        }
    }
    
    mutating func changeKey(from: Key, to: Key) {
        self[to] = self[from]
        removeValue(forKey: from)
    }
}
