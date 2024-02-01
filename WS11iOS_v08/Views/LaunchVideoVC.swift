//
//  LaunchVideoVC.swift
//  WS11iOS_v08
//
//  Created by Nick Rodriguez on 31/01/2024.
//

import UIKit
import AVFoundation

class LaunchVideoVC: UIViewController {

    var player: AVPlayer!
    var playerLayer: AVPlayerLayer!
    var skipButton: UIButton!
    var delayedTransitionTask: DispatchWorkItem?

    override func viewDidLoad() {
        super.viewDidLoad()
        print("- LaunchVideoVC viewDidLoad")
        setupVideoPlayer()
        setupSkipButton()
    }

    private func setupVideoPlayer() {
        guard let path = Bundle.main.path(forResource: "LaunchVideo_v02", ofType:"mp4") else {
            debugPrint("video.mp4 not found")
            return
        }
        player = AVPlayer(url: URL(fileURLWithPath: path))
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = self.view.bounds
        self.view.layer.addSublayer(playerLayer)
        player.play()

//        // Automatically transition to LoginVC after 20 seconds
//        DispatchQueue.main.asyncAfter(deadline: .now() + 18) { [weak self] in
//            self?.showLoginVC()
//        }
        // Use a DispatchWorkItem for the delayed transition
        let task = DispatchWorkItem { [weak self] in
            self?.showLoginVC()
        }
        self.delayedTransitionTask = task

        DispatchQueue.main.asyncAfter(deadline: .now() + 18, execute: task)
    }

    private func setupSkipButton() {
        skipButton = UIButton()
        skipButton.setTitle(" skip ", for: .normal)
        skipButton.translatesAutoresizingMaskIntoConstraints=false
        skipButton.addTarget(self, action: #selector(skipTapped), for: .touchUpInside)
        view.addSubview(skipButton)
        NSLayoutConstraint.activate([
        skipButton.topAnchor.constraint(equalTo: view.topAnchor, constant: heightFromPct(percent: 10)),
        skipButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: widthFromPct(percent: -4))
        ])
    }

    @objc private func skipTapped() {
        delayedTransitionTask?.cancel()
        showLoginVC()
    }

    // Inside LaunchVideoVC
    private func showLoginVC() {
        let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
        self.navigationController?.pushViewController(loginVC, animated: true)
    }
    
    
}
