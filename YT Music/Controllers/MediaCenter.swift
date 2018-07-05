//
//  MediaCenter.swift
//  YT Music
//
//  Created by Stephen Radford on 05/07/2018.
//  Copyright © 2018 Cocoon Development Ltd. All rights reserved.
//

import Cocoa
import WebKit

class MediaCenter: NSObject, WKScriptMessageHandler {
    
    static let `default` = MediaCenter()
    
    override private init() { }
    
    var title: String? {
        didSet {
            
        }
    }
    
    var by: String? {
        didSet {
            
        }
    }
    
    var thumbnail: String?
    
    var length: Int = 0
    
    var progress: Int = 0
    
    var isPlaying = false {
        didSet {
            (NSApp.delegate as? AppDelegate)?.dockMenu.item(at: 0)?.title = isPlaying ? "Pause" : "Play"
        }
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let dict = message.body as? [String:Any] else { return }
        
        title = dict["title"] as? String
        by = dict["by"] as? String
        thumbnail = dict["thumbnail"] as? String
        length = dict["length"] as? Int ?? 0
        progress = dict["progress"] as? Int ?? 0
        isPlaying = dict["isPlaying"] as? Bool ?? false
    }
    
}
