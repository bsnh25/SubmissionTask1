//
//  MainVC.swift
//  SubmissionTask1
//
//  Created by Bayu Septyan Nur Hidayat on 04/08/24.
//

import UIKit
import SnapKit
import AVFoundation
import Combine

class MainVC: UIViewController {
    
    @Published var savedURL: String = ""
    
    let managerService = ManagerService()
    let bottomView = BottomView()
    let videoView = UIView()
    private var timeObserverToken: Any?
    var playerLayer: AVPlayerLayer!
    var player: AVPlayer?
    var cancellable: AnyCancellable?
    var isFirstTime: Bool = true
//    var mainView: MainImageView?
    
    
    lazy var imageView = UIImageView()
    lazy var topView: TopView = {
        let top = TopView(managerService.titleImage, managerService.author)
        return top
    }()
    lazy var effectView: UIVisualEffectView = {
        let blur        = UIBlurEffect(style: .dark)
        let effect      = UIVisualEffectView(effect: blur)
        effect.alpha    = 1
        return effect
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        mainView = MainImageView(manager: managerService)
        Task {
            await observeURL()
        }
        setupBgImageView()
        configureTopView()
        configureBottomView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if isFirstTime{
            managerService.processAndUploadVideo(title: managerService.titleImage, duration: 10, author: managerService.author)
            print("isi user deafult : \(String(describing: UserDefaults.standard.string(forKey: "afterFirstTime")))")
            isFirstTime = false
        } else {
            savedURL = UserDefaults.standard.string(forKey: "afterFirstTime") ?? ""
        }
        //        debugPrint(view.subviews)
    }
    
    private func setupVideoView(with url: URL){
        
//        guard let mainView = mainView else { return }
        
        view.addSubview(videoView)
        
        player = AVPlayer(url: url)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = view.bounds
        playerLayer.videoGravity = .resizeAspect
        
        videoView.layer.addSublayer(playerLayer)
        
//        videoView.layer.borderColor = UIColor.red.cgColor
//        videoView.layer.borderWidth = 1
//        videoView.backgroundColor = UIColor.red.withAlphaComponent(0.3)
        
        let rotation = CGAffineTransform(rotationAngle: .pi)
        let scale = CGAffineTransform(scaleX: -1, y: 1)
        videoView.layer.setAffineTransform(rotation.concatenating(scale))
        
        videoView.snp.makeConstraints { main in
            main.top.equalTo(topView.snp.bottom)
            //            main.centerX.centerY.equalToSuperview()
            main.leading.trailing.equalToSuperview()
            main.width.equalTo(view.bounds.width)
            main.height.equalTo(view.bounds.width * (0.4/0.3))
        }
        
        view.layoutIfNeeded()
        playerLayer.frame = videoView.bounds
        
        // Tambahkan observer untuk mendeteksi ketika video selesai diputar
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: player?.currentItem)
        
        addPeriodicTimeObserver()
        
        managerService.player = player
    }
    
    @objc private func playerDidFinishPlaying() {
        bottomView.updatePlayButton(isPlaying: false) // Ubah tombol play di BottomView
    }
    
    private func observeURL() async {
        if isFirstTime {
            cancellable = managerService.$url.sink { [weak self] newURL in
                guard let self = self, !newURL.isEmpty, let videoURL = URL(string: newURL) else { return }
                
                setupVideoView(with: videoURL)
                print("setup video first time : \(videoURL)")
            }
        } else {
            cancellable = self.$savedURL.sink { [weak self] url in
                guard let self = self, url.isEmpty, let videoURL = URL(string: url) else { return }
                managerService.url = url
                setupVideoView(with: videoURL)
                print("setup video returning user : \(videoURL)")
            }
        }
    }
    
    private func setupBgImageView(){
        view.addSubview(imageView)
        view.addSubview(effectView)
        effectView.frame = view.bounds
        imageView.image = UIImage(named: "image_exp")
        imageView.snp.makeConstraints { image in
            image.top.bottom.leading.trailing.equalToSuperview()
        }
    }
    
    private func configureTopView(){
        view.addSubview(topView)
        
        topView.snp.makeConstraints { top in
            top.top.equalToSuperview()
            //            top.centerX.equalToSuperview()
            top.trailing.equalToSuperview().inset(view.bounds.width * 0.01)
            top.leading.equalToSuperview()
            top.height.equalTo(view.bounds.height * 0.17)
        }
    }
    
    private func configureBottomView(){
        
        view.addSubview(bottomView)
        bottomView.delegate = self
        bottomView.isUserInteractionEnabled = true
        
//        bottomView.layer.borderColor = UIColor.red.cgColor
//        bottomView.layer.borderWidth = 1
//        bottomView.backgroundColor = UIColor.red.withAlphaComponent(0.3)
        
        bottomView.snp.makeConstraints { btm in
//            btm.top.equalTo(videoView.snp.bottom)
            btm.bottom.equalToSuperview().inset(view.bounds.height * 0.08)
            btm.trailing.leading.equalToSuperview()
            btm.height.equalTo(80)
        }
    }
    
    private func addPeriodicTimeObserver() {
        // Memperbarui progressView setiap detik
        let interval = CMTime(seconds: 1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        
        timeObserverToken = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self = self, let duration = self.player?.currentItem?.duration else { return }
            let currentTime = CMTimeGetSeconds(time)
            let totalDuration = CMTimeGetSeconds(duration)
            self.bottomView.updateProgressView(currentTime: currentTime, duration: totalDuration)
        }
    }
    
}

extension MainVC: BottomViewDelegate {
    func handlePlayPause() {
        if player?.timeControlStatus == .playing {
            player?.pause()
            bottomView.updatePlayButton(isPlaying: false)
        } else {
            if player?.currentTime().seconds == 10 {
                player?.seek(to: .zero)
                player?.play()
                bottomView.updatePlayButton(isPlaying: true)
            } else {
                player?.play()
                bottomView.updatePlayButton(isPlaying: true)
            }
        }
    }
    
    func handleRewind() {
        let currentTime = player?.currentTime() ?? .zero
        let newTime = CMTimeSubtract(currentTime, CMTimeMake(value: 5, timescale: 1))
        player?.seek(to: newTime)
    }
    
    func handleForward() {
        let currentTime = player?.currentTime() ?? .zero
        let newTime = CMTimeAdd(currentTime, CMTimeMake(value: 5, timescale: 1))
        player?.seek(to: newTime)
    }
}

#Preview(traits: .defaultLayout, body: {
    MainVC()
})


