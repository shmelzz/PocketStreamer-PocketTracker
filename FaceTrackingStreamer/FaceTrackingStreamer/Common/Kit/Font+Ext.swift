//
//  Font+Ext.swift
//  Pocket Streamer
//
//  Created by Elizaveta Shelemekh on 07.04.2024.
//

import UIKit

enum Fonts {
    
    private enum RedditFontNames {
        static let black = "RedditMono-Black"
        static let bold = "RedditMono-Bold"
        static let extraBold = "RedditMono-ExtraBold"
        static let extraLight = "RedditMono-ExtraLight"
        static let light = "RedditMono-Light"
        static let medium = "RedditMono-Medium"
        static let regular = "RedditMono-Regular"
        static let semibold = "RedditMono-SemiBold"
    }
    
    static let redditMonoBlack = UIFont(name: RedditFontNames.black, size: UIFont.labelFontSize) ?? .default
    
    static let redditMonoBold = UIFont(name: RedditFontNames.bold, size: UIFont.labelFontSize) ?? .default
    
    static let redditMonoExtraBold = UIFont(name: RedditFontNames.extraBold, size: UIFont.labelFontSize) ?? .default
    
    static let redditMonoExtraLight = UIFont(name: RedditFontNames.extraLight, size: UIFont.labelFontSize) ?? .default
    
    static let redditMonoLight = UIFont(name: RedditFontNames.light, size: UIFont.labelFontSize) ?? .default
    
    static let redditMonoMedium = UIFont(name: RedditFontNames.medium, size: UIFont.labelFontSize) ?? .default
    
    static let redditMonoRegular = UIFont(name: RedditFontNames.regular, size: UIFont.labelFontSize) ?? .default
    
    static let redditMonoSemiBold = UIFont(name: RedditFontNames.semibold, size: UIFont.labelFontSize) ?? .default
}

private extension UIFont {
    static let `default`: UIFont = .systemFont(ofSize:  UIFont.labelFontSize)
}
