//
//  TopView.swift
//  SubmissionTask1
//
//  Created by Bayu Septyan Nur Hidayat on 04/08/24.
//

import UIKit
import SnapKit

class TopView: UIView {
    
    lazy var authorLabel = FABodyLabel(alignmentText: .justified, size: 17)
    lazy var  titleLabel = FATitleLabel(alignmentText: .justified, size: 28)
    var titleString: String = "Coba saja dulu"
    var authorString: String = "Bayu"
    let topButton = FAButton(image: "arrow.left", color: UIColor(_colorLiteralRed: 0, green: 0, blue: 0, alpha: 0.2), size: 15)

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureTitle()
        configureAuthor()
        configureTopButton()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(_ title: String, _ body: String){
        super.init(frame: .zero)
        self.titleString = title
        self.authorString = body
        configureTitle()
        configureAuthor()
        configureTopButton()
    }
    

    private func configureTitle(){
        self.addSubview(titleLabel)
        titleLabel.text = titleString
//        titleLabel.layer.borderColor = UIColor.red.cgColor
//        titleLabel.layer.borderWidth = 1
//        titleLabel.backgroundColor = UIColor.red.withAlphaComponent(0.3)
        
        titleLabel.snp.makeConstraints { title in
            title.top.equalToSuperview().inset(60)
            title.trailing.equalToSuperview().inset(30)
        }
    }
    
    private func configureAuthor(){
        self.addSubview(authorLabel)
        authorLabel.text = "by \(authorString)"
        
        authorLabel.snp.makeConstraints { author in
            author.top.equalTo(titleLabel.snp.bottom).offset(10)
            author.trailing.equalToSuperview().inset(30)
        }
    }
    
    private func configureTopButton(){
        self.addSubview(topButton)
        topButton.layer.cornerRadius = 22
        topButton.tintColor = .white
//        topButton.layer.borderColor = UIColor.red.cgColor
//        topButton.layer.borderWidth = 1
//        topButton.backgroundColor = UIColor.red.withAlphaComponent(0.3)
        
        topButton.snp.makeConstraints { button in
            button.top.equalTo(titleLabel.snp.top)
            button.leading.equalToSuperview().inset(30)
            button.height.width.equalTo(40)
        }
    }

}
