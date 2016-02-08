//
//  DetailViewController.swift
//  Feeds
//
//  Created by Daniel Salber on 01/12/15.
//  Copyright © 2015 mackey.nl. All rights reserved.
//

import UIKit

@objc class DetailViewController: UIViewController, YTPlayerViewDelegate {

    @IBOutlet weak var playerView: YTPlayerView!
    var video: GTLYouTubeVideo?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.playerView.delegate = self
        
        let playerSettings: Dictionary = ["autoplay": 1, "playsinline": 1, "showinfo": 0]
        self.playerView.loadWithVideoId(video!.identifier, playerVars: playerSettings)
    }

    func playerViewDidBecomeReady(playerView: YTPlayerView) {
        self.playerView.playVideo()
    }
}
