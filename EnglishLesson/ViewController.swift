//
//  ViewController.swift
//  EnglishLesson
//
//  Created by 郭毅 on 2018/9/16.
//  Copyright © 2018年 郭毅. All rights reserved.
//

import Cocoa

import WebKit

class ViewController: NSViewController {
    
    var webTitle: String = ""
    var webTime: String = ""
    var webBody: String = ""
    var audioUrl: String = ""
    
    /// content view
    @IBOutlet weak var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func awakeFromNib() {
        // https://www.naiabc.com/nbabc/course?id=7&source=undefined

        webView.navigationDelegate = self
        guard let contentURL = URL(string: "https://www.naiabc.com/nbabc/course?id=7&source=undefined") else { return }
        let webRequest = URLRequest(url: contentURL)
        webView.load(webRequest)
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
}

// MARK: - NSButton Action
extension ViewController {
    
    @IBAction func linkButtonAction(_ sender: NSButton) {

        let group = DispatchGroup()
        
        DispatchQueue.main.async(group: group, execute: DispatchWorkItem(block: {
            self.webView.evaluateJavaScript("document.getElementsByClassName('title')[0].innerHTML") { (response, error) in
                guard let titleString = response as? String else { return }
                self.webTitle = titleString
                print("title")
            }
        }))
        
        DispatchQueue.main.async(group: group, execute: DispatchWorkItem(block: {
            self.webView.evaluateJavaScript("document.body.outerHTML") { (response, error) in
                if let n_resp = response as? String {
                    self.webBody = n_resp
                    //  日期
                    let timeList = n_resp.components(separatedBy: "<p class=\"time\">")
                    guard let timeString = timeList.count == 2 ? timeList[1] : nil else { return }
                    let timeList2 = timeString.components(separatedBy: "</p>")
                    guard let timeString2 = timeList2.first else { return }
                    self.webTime = timeString2
                    print("time body")
                }
            }
        }))
        
        DispatchQueue.main.async(group: group, execute: DispatchWorkItem(block: {
            self.webView.evaluateJavaScript("document.getElementsByTagName('audio')[0].src") { (response, error) in
                if let n_resp = response as? String {
                    self.audioUrl = n_resp
                    print("audio")
                }
            }
        }))
        
        group.notify(queue: DispatchQueue.main) {
            print("123")
        }
    }
   
    @IBAction func backButtonAction(_ sender: NSButton) {
        webView.goBack()
    }
    
    
    @IBAction func saveButtonAction(_ sender: NSButton) {
        if webTitle.count > 0 && webTime.count > 0 && webBody.count > 0 && audioUrl.count > 0 {
            print(webTitle, webTime, webBody, audioUrl)
        }
    }
}

extension ViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        webTitle = ""
        webTime = ""
        webBody = ""
        audioUrl = ""
    }
}
