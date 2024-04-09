//
//  Button+Ext.swift
//  Pocket Streamer
//
//  Created by Elizaveta Shelemekh on 07.04.2024.
//

import UIKit

extension UIButton {
    
    static func tinted(title: String, font: UIFont, textColor: UIColor = .white) -> UIButton {
        var configuration = UIButton.Configuration.borderedTinted()
        configuration.attributedTitle = AttributedString(
            title,
            attributes: AttributeContainer([
                NSAttributedString.Key.font: font,
                NSAttributedString.Key.foregroundColor: textColor
            ])
        )
        let button = UIButton(configuration: configuration)
        button.tintColor = .black
        return button
    }
    
    static func tinted(color: UIColor) -> UIButton {
        var configuration = UIButton.Configuration.borderedTinted()
        let button = UIButton(configuration: configuration)
        button.tintColor = color
        return button
    }
    
    func reconfigureTitle(_ text: String) {
        configuration?.attributedTitle = AttributedString(
            text,
            attributes: AttributeContainer([
                NSAttributedString.Key.font: configuration?.attributedTitle?.font ?? Fonts.redditMonoMedium,
                NSAttributedString.Key.foregroundColor: configuration?.attributedTitle?.foregroundColor ?? .white
            ])
        )
    }
}
