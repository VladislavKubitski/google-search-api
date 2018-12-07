//
//  DownloadTask.swift
//  google-search-api
//
//  Created by Kubitski Vlad on 07.12.2018.
//  Copyright © 2018 Kubitski Vlad. All rights reserved.
//

import Foundation


protocol DownloadTask {
    
    var expectedContentLength: Int64 { get set }
    var buffer: Data { get set }
    var progress: Float { get set }
    weak var delegate: DownloadDelegate? { get set }
    
    func resume()
    func suspend()
    func cancel()
}

