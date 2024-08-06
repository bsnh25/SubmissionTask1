//
//  FATitleLabel.swift
//  SubmissionTask1
//
//  Created by Bayu Septyan Nur Hidayat on 04/08/24.
//

import UIKit

class FATitleLabel: UILabel {

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(alignmentText: NSTextAlignment, size: CGFloat){
        super.init(frame: .zero)
        self.textAlignment = alignmentText
        self.font = UIFont.systemFont(ofSize: size, weight: .heavy)
        configure()
    }
    
    private func configure(){
        textColor = .faPink
        
    }

}
