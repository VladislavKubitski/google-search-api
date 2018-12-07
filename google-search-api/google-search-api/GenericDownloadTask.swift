//
//  GenericDownloadTask.swift
//  google-search-api
//
//  Created by Kubitski Vlad on 07.12.2018.
//  Copyright © 2018 Kubitski Vlad. All rights reserved.
//

import Foundation


protocol DownloadDelegate: class {
    func downloadProgressUpdated(for progress: Float)
}

class GenericDownloadTask: DownloadTask {
    
    weak var delegate: DownloadDelegate?
    private(set) var task: URLSessionDataTask
    var expectedContentLength: Int64 = 0
    var buffer = Data()
    
    var progress: Float = 0.0 {
        didSet {
            updateProgress()
        }
    }
    
    init(task: URLSessionDataTask) {
        self.task = task
    }
    
    deinit {
        print("Deinit: \(task.originalRequest?.url?.absoluteString ?? "")")
    }
    
    func resume() {
        task.resume()
    }
    
    func suspend() {
        task.suspend()
    }
    
    func cancel() {
        task.cancel()
    }
    
    private func updateProgress() {
        delegate?.downloadProgressUpdated(for: progress)
    }
}
