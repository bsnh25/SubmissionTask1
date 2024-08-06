//
//  BottomView.swift
//  SubmissionTask1
//
//  Created by Bayu Septyan Nur Hidayat on 06/08/24.
//

import UIKit
import SnapKit

protocol BottomViewDelegate: AnyObject {
    func handlePlayPause()
    func handleRewind()
    func handleForward()
}

class BottomView: UIView {
    
    weak var delegate : BottomViewDelegate? = nil
    
    var progressView = UIProgressView(progressViewStyle: .default)
    
    var backwardButton = FAButton(image: "gobackward.5", color: .clear, size: 30)
    var forwardButton = FAButton(image: "goforward.5", color: .clear, size: 30)
    var playButton = FAButton(image: "play.fill", color: .clear, size: 30)
    var isPlayed: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        configureView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureView(){
        self.addSubview(playButton)
        self.addSubview(backwardButton)
        self.addSubview(forwardButton)
        self.addSubview(progressView)
        
        playButton.tintColor = .faPink
        forwardButton.tintColor = .faPink
        backwardButton.tintColor = .faPink
        progressView.tintColor = .faProgress
//        progressView.progress = 0.5
        progressView.trackTintColor = .clear
        
        playButton.addTarget(self, action: #selector(tapPlayPause), for: .touchUpInside)
        backwardButton.addTarget(self, action: #selector(tapRewind), for: .touchUpInside)
        forwardButton.addTarget(self, action: #selector(tapForward), for: .touchUpInside)
        
        // Apply constraints
        backwardButton.snp.makeConstraints { backward in
            backward.centerY.equalToSuperview()
            backward.trailing.equalTo(playButton.snp.leading).offset(-50)
            backward.width.height.equalTo(60)
        }
        
        playButton.snp.makeConstraints { playPause in
            playPause.centerX.centerY.equalToSuperview()
            playPause.width.height.equalTo(60)
        }
        
        forwardButton.snp.makeConstraints { forward in
            forward.centerY.equalToSuperview()
            forward.leading.equalTo(playButton.snp.trailing).offset(50)
            forward.width.height.equalTo(60)
        }
        
        progressView.snp.makeConstraints { slider in
            //            btm.centerX.centerY.equalToSuperview()
            slider.bottom.equalTo(playButton.snp.top).inset(-30)
            slider.trailing.leading.equalToSuperview()
            slider.height.equalTo(10)
        }
    }
    
    @objc
    private func tapPlayPause(){
        isPlayed.toggle()
        let buttonImageName = isPlayed ? "pause.fill" : "play.fill"
        playButton.setImage(UIImage(systemName: buttonImageName), for: .normal)
        delegate?.handlePlayPause()
    }
    
    @objc
    private func tapRewind() {
        delegate?.handleRewind()
    }
    
    @objc
    private func tapForward() {
        delegate?.handleForward()
    }
    
    func updatePlayButton(isPlaying: Bool) {
        let buttonImageName = isPlaying ? "pause.fill" : "play.fill"
        playButton.setImage(UIImage(systemName: buttonImageName), for: .normal)
    }
    
    func updateProgressView(currentTime: Double, duration: Double) {
        progressView.progress = Float(currentTime / duration)
    }
    
}
