//
//  FAButton.swift
//  SubmissionTask1
//
//  Created by Bayu Septyan Nur Hidayat on 06/08/24.
//

import UIKit

class FAButton : UIButton {
    
    var image: String = ""
    var size: CGFloat?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(image: String, color: UIColor, size: CGFloat){
        super.init(frame: .zero)
        self.setImage(UIImage(systemName: image), for: .normal)
        self.layer.backgroundColor = color.cgColor
        self.size = size
        configure()
    }
    
    private func configure(){
        var config = UIButton.Configuration.plain()
        contentMode = .scaleAspectFit
        imageView?.contentMode = .scaleAspectFit
        config.imagePadding = 5
        config.imagePlacement = .all
        config.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: size!)
        self.configuration = config
    }
    
}

