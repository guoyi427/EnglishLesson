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
    
    let homePath = "https://www.naiabc.com/nbabc/course?id=7&source=undefined"
    
    var webTitle: String = ""
    var webTime: String = ""
    var webBody: String = ""
    var audioUrl: String = ""
    
    var homeIndex: Int = 1
    var currentPagePath: String = ""
    
    var lessonIndex: Int = 0
    var currentLessonPath: String = ""
    
    
    
    /// content view
    @IBOutlet weak var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func awakeFromNib() {
        // https://www.naiabc.com/nbabc/course?id=7&source=undefined

        webView.navigationDelegate = self
        guard let contentURL = URL(string: homePath) else { return }
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
    
    /// 解析内容
    @IBAction func linkButtonAction(_ sender: NSButton) {

        clearCache()
        
        webView.evaluateJavaScript("document.getElementsByClassName('title')[0].innerHTML") { (response, error) in
            guard let titleString = response as? String else { return }
            self.webTitle = titleString
            self.writeToFile()
        }
    
        webView.evaluateJavaScript("document.body.outerHTML") { (response, error) in
            if let n_resp = response as? String {
                self.webBody = n_resp
                //  日期
                let timeList = n_resp.components(separatedBy: "<p class=\"time\">")
                guard let timeString = timeList.count == 2 ? timeList[1] : nil else { return }
                let timeList2 = timeString.components(separatedBy: "</p>")
                guard let timeString2 = timeList2.first else { return }
                self.webTime = timeString2
                self.writeToFile()
            }
        }
    
        webView.evaluateJavaScript("document.getElementsByTagName('audio')[0].src") { (response, error) in
            if let n_resp = response as? String {
                self.audioUrl = n_resp
                self.writeToFile()
            }
        }
    }
   
    /// 返回
    @IBAction func backButtonAction(_ sender: NSButton) {
        webView.goBack()
    }
    
    /// 扫描
    @IBAction func scanButtonAction(_ sender: NSButton) {
        webView.evaluateJavaScript("document.getElementsByClassName('item-container')[\(homeIndex)].href") { (response, error) in
            guard let n_resp = response as? String else { return }
            print("host page = \(n_resp)")
            self.currentPagePath = n_resp
            self.jumpTo(path: n_resp)
        }
    }
    
}

// MARK: - Private Methods
extension ViewController {
    fileprivate func writeToFile() {
        if webTitle.isEmpty || webTime.isEmpty || webBody.isEmpty || audioUrl.isEmpty {
            return
        }
        print("parameter is prepare: title = \(webTitle), time = \(webTime), body = \(webBody.count), audio = \(audioUrl)")
        print("执行保存操作")
        
        //  保存操作后 跳转回课程列表页 跳转到下一节课
        lessonIndex += 1
        jumpTo(path: currentPagePath)
    }
    
    fileprivate func clearCache() {
        webTitle = ""
        webTime = ""
        webBody = ""
        audioUrl = ""
    }
    
    @objc fileprivate func analysisLessonPage() {
        webView.evaluateJavaScript("document.getElementsByClassName('item-container')[\(lessonIndex)].href") { (response, error) in
            guard let n_resp = response as? String else {
                //  无内容 清空课程下标， 首页下标+1 返回首页继续扫描
                self.lessonIndex = 0
                self.homeIndex += 1
                self.jumpTo(path: self.homePath)
                return
            }
            print("lesson page = \(n_resp)")
            self.currentLessonPath = n_resp
            self.jumpTo(path: n_resp)
        }
        
    }
    
    fileprivate func jumpTo(path: String) {
        guard let pathUrl = URL(string: path) else { return }
        webView.load(URLRequest(url: pathUrl))
    }
}

// MARK: - WKWebView Delegate
extension ViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        clearCache()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if webView.url?.absoluteString == currentPagePath {
            self.perform(#selector(analysisLessonPage), with: nil, afterDelay: 1)
        } else if webView.url?.absoluteString == currentLessonPath {
            self.perform(#selector(linkButtonAction(_:)), with: nil, afterDelay: 1)
        } else if webView.url?.absoluteString == homePath {
            self.perform(#selector(scanButtonAction(_:)), with: nil, afterDelay: 2)
        }
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print(error, webView.url!)
    }
}
