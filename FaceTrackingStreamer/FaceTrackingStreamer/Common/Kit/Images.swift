//
//  Images.swift
//  Pocket Streamer
//
//  Created by Elizaveta Shelemekh on 07.04.2024.
//

import UIKit

enum ImageAssets {
    static let backBlack = UIImage(named: "background_black")
    static let backRainbow = UIImage(named: "background_rainbow")
    static let bodyMesh = UIImage(named: "body_mesh")
    static let faceMesh = UIImage(named: "face_mesh")
    static let connectCircle = UIImage(named: "connection")
    static let backNavy = UIImage(named: "background_navy")
    
    
    static let account = UIImage(systemName: "person.crop.circle")?.withRenderingMode(.alwaysOriginal).withTintColor(.white)
    static let key = UIImage(systemName: "key")?.withRenderingMode(.alwaysOriginal).withTintColor(.white)
    static let eye = UIImage(systemName: "eye")?.withRenderingMode(.alwaysOriginal).withTintColor(.white)
    static let eyeCross = UIImage(systemName: "eye.slash")?.withRenderingMode(.alwaysOriginal).withTintColor(.white)
}
