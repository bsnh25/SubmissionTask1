//
//  ManagerService.swift
//  SubmissionTask1
//
//  Created by Bayu Septyan Nur Hidayat on 04/08/24.
//

import Foundation
import AVFoundation
import FirebaseStorage
import FirebaseFirestore

class ManagerService: ObservableObject {

    @Published var url: String = ""
    @Published var player: AVPlayer?
    @Published var isPlaying: Bool = false
    
    var titleImage: String = "The Big Idea"
    var author: String = "Komala"
    var video: [Video] = [Video]()
    
    private let db = Firestore.firestore()
    private let screenSize = UIScreen.main.bounds.size
    private let fps: Int32 = 20
//    private var URLAfterFirstTime = ""
    
    
    func loadAllImages() -> [UIImage]? {
        let imageCount = 200
        var images: [UIImage] = []
        
        for index in 1...imageCount {
            let imageName = "\(index)"
            
            if let image = UIImage(named: imageName) {
                images.append(image)
                
            } else {
                print("Failed to load image: \(imageName)")
            }
        }
        
        return images
    }
    
    
    func createVideo(completion: @escaping (URL?) -> Void) {
        guard let images = loadAllImages() else {
            print("Error loading all images")
            return
        }
        
        let videoWidth = screenSize.width
        let videoHeight = (4.0 / 3.0) * videoWidth
        
        let videoSize = CGSize(width: videoWidth, height: videoHeight)
        let videoPath = NSTemporaryDirectory() + "output.mov"
        let videoURL = URL(fileURLWithPath: videoPath)
        
        // Set up video writer
        guard let videoWriter = try? AVAssetWriter(outputURL: videoURL, fileType: .mov) else {
            completion(nil)
            return
        }
        
        let videoSettings: [String: Any] = [
            AVVideoCodecKey: AVVideoCodecType.h264,
            AVVideoWidthKey: videoSize.width,
            AVVideoHeightKey: videoSize.height
        ]
        
        let videoInput = AVAssetWriterInput(mediaType: .video, outputSettings: videoSettings)
        videoWriter.add(videoInput)
        
        let pixelBufferAdaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: videoInput, sourcePixelBufferAttributes: [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32ARGB
        ])
        
        // Apply transform to correct orientation
        videoInput.transform = CGAffineTransform(rotationAngle: 0)
        
        videoWriter.startWriting()
        videoWriter.startSession(atSourceTime: .zero)
        
        let frameDuration = CMTime(seconds: 1.0 / Double(fps), preferredTimescale: 600)
        var frameTime = CMTime.zero
        
        for image in images {
            autoreleasepool {
                let pixelBuffer = pixelBufferFromImage(image, size: videoSize)
                if videoInput.isReadyForMoreMediaData {
                    pixelBufferAdaptor.append(pixelBuffer, withPresentationTime: frameTime)
                    frameTime = CMTimeAdd(frameTime, frameDuration)
                }
            }
        }
        
        videoInput.markAsFinished()
        videoWriter.finishWriting {
            completion(videoURL)
        }
    }
    
    func pixelBufferFromImage(_ image: UIImage, size: CGSize) -> CVPixelBuffer {
        let options: [String: Any] = [
            kCVPixelBufferCGImageCompatibilityKey as String: kCFBooleanTrue!,
            kCVPixelBufferCGBitmapContextCompatibilityKey as String: kCFBooleanTrue!
        ]
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(size.width), Int(size.height), kCVPixelFormatType_32ARGB, options as CFDictionary, &pixelBuffer)
        
        guard status == kCVReturnSuccess, let buffer = pixelBuffer else {
            fatalError("Failed to create pixel buffer")
        }
        
        CVPixelBufferLockBaseAddress(buffer, .readOnly)
        let pixelData = CVPixelBufferGetBaseAddress(buffer)
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: pixelData, width: Int(size.width), height: Int(size.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(buffer), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
        
        UIGraphicsPushContext(context!)
        image.draw(in: CGRect(origin: .zero, size: size))
        UIGraphicsPopContext()
        CVPixelBufferUnlockBaseAddress(buffer, .readOnly)
        
        return buffer
    }
    
    func uploadVideo(url: URL, completion: @escaping (String?) -> Void) {
        let storageRef = Storage.storage().reference()
        let videoRef = storageRef.child("videos/\(UUID().uuidString).mov")
        
        videoRef.putFile(from: url, metadata: nil) { metadata, error in
            if let error = error {
                print("Error uploading video: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            videoRef.downloadURL { url, error in
                if let error = error {
                    print("Error getting download URL: \(error.localizedDescription)")
                    completion(nil)
                    return
                }
                
                guard let downloadURL = url else {
                    print("Download URL is nil")
                    completion(nil)
                    return
                }
                
                completion(downloadURL.absoluteString)
            }
        }
    }
    
    
    func uploadMetadata(title: String, duration: Int, author: String, videoURL: String) {
        self.url = videoURL
        print("Video URL : \(videoURL)")
        UserDefaults.standard.set(self.url, forKey: "afterFirstTime")
        let db = Firestore.firestore()
        let timestamp = Timestamp(date: Date())
        let metadata: [String: Any] = [
            "time": timestamp,
            "title": title,
            "duration": duration,
            "author": author,
            "videoURL": videoURL
        ]
        
        db.collection("videos").addDocument(data: metadata) { error in
            if let error = error {
                print("Error adding document: \(error)")
            } else {
                print("Document successfully added!")
            }
        }
    }
    
    func processAndUploadVideo(title: String, duration: Int, author: String) {
        createVideo { [weak self] videoURL in
            guard let self = self else { return }
            
            guard let videoURL = videoURL else {
                print("Failed to create video")
                return
            }
            
            self.uploadVideo(url: videoURL) { videoDownloadURL in
                guard let videoDownloadURL = videoDownloadURL else {
                    print("Failed to upload video")
                    return
                }
                self.uploadMetadata(title: title, duration: duration, author: author, videoURL: videoDownloadURL)
            }
            getLatestVideo()
            
        }
    }
    
    func getLatestVideo() {
        db.collection("videos").order(by: "timestamp", descending: true).getDocuments{ (querySnapshot, error) in
            guard let doc = querySnapshot?.documents else { print("no documents")
                return }
            
            self.video = doc.map{ (query) -> Video in
                let data = query.data()
                let titleDb = data["title"] as? String ?? ""
                let authDb = data["author"] as? String ?? ""
                let duration = data["duration"] as? Int ?? 0
                let videoURLString = data["videoURL"] as? String
                let videoURL = URL(string: videoURLString ?? "")
                
                return Video(title: titleDb, author: authDb, duration: duration, videoURL: videoURL)
            }
        }
    }
    
    func togglePlayAndPause(){
        isPlaying ? player?.play() : player?.pause()
        isPlaying.toggle()
    }
}
