//
//  TextField+Ext.swift
//  Pocket Streamer
//
//  Created by Elizaveta Shelemekh on 07.04.2024.
//

import UIKit

extension UITextField {
    
    static func blackTinted(pleceholderText: String?, font: UIFont = Fonts.redditMonoMedium) -> UITextField {
        let field = UITextField()
        field.placeholder = pleceholderText
        field.backgroundColor = .blackTint
        field.layer.cornerRadius = 10
        field.layer.masksToBounds = true
        field.font = font
        return field
    }
    
    func setLeftView(_ view: UIView, padding: CGFloat) {
        view.translatesAutoresizingMaskIntoConstraints = true

        let outerView = UIView()
        outerView.translatesAutoresizingMaskIntoConstraints = false
        outerView.addSubview(view)

        outerView.frame = CGRect(
            origin: .zero,
            size: CGSize(
                width: view.frame.size.width + padding,
                height: view.frame.size.height + padding
            )
        )

        view.center = CGPoint(
            x: outerView.bounds.size.width / 2,
            y: outerView.bounds.size.height / 2
        )

        leftView = outerView
        leftViewMode = .always
    }
    
    func setRightView(_ view: UIView, padding: CGFloat) {
        view.translatesAutoresizingMaskIntoConstraints = true

        let outerView = UIView()
        outerView.translatesAutoresizingMaskIntoConstraints = false
        outerView.addSubview(view)

        outerView.frame = CGRect(
            origin: .zero,
            size: CGSize(
                width: view.frame.size.width + padding,
                height: view.frame.size.height + padding
            )
        )

        view.center = CGPoint(
            x: outerView.bounds.size.width / 2,
            y: outerView.bounds.size.height / 2
        )

        rightView = outerView
        rightViewMode = .always
    }
}
