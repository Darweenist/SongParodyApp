//
//  VideoPlayer.swift
//  ParodyApp
//
//  Created by Dawson Chen on 7/7/22.
//

import UIKit
import AVKit

class VideoPlayer: UIView {
    @IBOutlet weak var vwPlayer: UIView!
    var player: AVPlayer?
    var playerLooper: AVPlayerLooper!
    var queuePlayer: AVQueuePlayer!

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    fileprivate func commonInit() {
        print("Reached common init of Video Player")
        let viewFromXib = Bundle.main.loadNibNamed("VideoPlayer", owner: self, options: nil)![0] as! UIView
        viewFromXib.frame = self.bounds
        addSubview(viewFromXib)
        addPlayerToView(self.vwPlayer)
    }
    
    fileprivate func addPlayerToView(_ view: UIView) {
//        player = AVPlayer()
        queuePlayer = AVQueuePlayer()
//        let playerLayer = AVPlayerLayer(player: player)
        let playerLayer = AVPlayerLayer(player: queuePlayer)
        playerLayer.frame = self.bounds
        playerLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(playerLayer)
        NotificationCenter.default.addObserver(self, selector: #selector(playerEndPlay), name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    func playVideoWithFileName(_ fileName: String, ofType type:String) {
        guard let filePath = Bundle.main.path(forResource: fileName, ofType: type) else { return }
        let videoURL = URL(fileURLWithPath: filePath)
        let playerItem = AVPlayerItem(url: videoURL)
        player?.replaceCurrentItem(with: playerItem)
        player?.play()
    }
    
    func playVideoWithURL(url: URL) {
        let playerItem = AVPlayerItem(url: url)
        player?.replaceCurrentItem(with: playerItem)
        player?.play()
    }
    
    func loopVideoWithURL(url: URL) {
        let asset = AVAsset(url: url)
        let playerItem = AVPlayerItem(asset: asset)
        self.queuePlayer.replaceCurrentItem(with: playerItem)
        self.playerLooper = AVPlayerLooper(player: queuePlayer, templateItem: playerItem)
        queuePlayer.play()
    }
    
    func stopPlayingLoop() {
        queuePlayer.pause()
    }
    
    @objc func playerEndPlay() {
        print("Player ends playing video")
    }
}
