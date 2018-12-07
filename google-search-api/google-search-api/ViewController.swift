//
//  ViewController.swift
//  google-search-api
//
//  Created by Kubitski Vlad on 07.12.2018.
//  Copyright © 2018 Kubitski Vlad. All rights reserved.
//

import UIKit
import Foundation


class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet private weak var searchContainerView: UIView!
    @IBOutlet private weak var tableView: UITableView!
    
    private var progressView: UIProgressView!
    private var links: [String] = []
    private var requestWasCancelled: Bool = false
    
    private var searchView: SearchView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        createView()
        createProgressView()
    }
    
    private func createProgressView() {
        let progressView: UIProgressView = UIProgressView()
        progressView.frame = CGRect(x: 0.0, y: 0, width: 120.0, height: 40.0)
        progressView.center = view.center
        progressView.isHidden = true
        view.addSubview(progressView)
        self.progressView = progressView
    }
    
    private func createView() {
        let searchView: SearchView = SearchView.loadFromXib()
        
        searchView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 110)
        searchView.translatesAutoresizingMaskIntoConstraints = false
        searchView.setTapSearchButtonHandlers(
            tapStartSearchButtonClosure: { [weak self] (requestName: String) in
                self?.getLinksFromServer(withRequestName: requestName)
            },
            tapStopSearchButtonClosure: { [weak self] in
                self?.stopGetLinksFromServer()
                self?.requestWasCancelled = true
            }
        )
        self.searchView = searchView
        searchContainerView.addSubview(searchView)
        view.layoutIfNeeded()
    }
    
    private func showActivityIndicatory(view: UIView) {
        self.progressView.progress = 0.0
        progressView.isHidden = false
    }
    
    private func hideActivityIndicatory() {
        self.progressView.isHidden = true
        searchView.setButtonTitle("Google Search")
    }
    
    private func getLinksFromServer(withRequestName requestName: String) {
        GoogleService.sharedManager().getLinks(
            requestName: requestName,
            success: { [weak self] links in
                self?.handleGetLinksSuccess(links: links)
            },
            failure: { [weak self] error in
                self?.handleGetLinksFailure(error: error)
            },
            successWithoutLinks: { [weak self] in
                self?.handleGetLinksSuccessWithoutLinks()
            },
            viewController: self
        )
        showActivityIndicatory(view: self.view)
    }
    
    private func handleGetLinksSuccess(links: [String]) {
        self.links = links
        DispatchQueue.main.async {
            self.hideActivityIndicatory()
            self.tableView.reloadData()
        }
    }
    
    private func handleGetLinksSuccessWithoutLinks() {
        self.links = []
        DispatchQueue.main.async {
            self.hideActivityIndicatory()
            self.tableView.reloadData()
        }
    }
    
    private func handleGetLinksFailure(error: Error) {
        DispatchQueue.main.async {
            if !self.requestWasCancelled {
                let messageError = String(format: "Connection error: %@", error.localizedDescription)
                let alert = UIAlertController(title: "Alert", message: messageError, preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true, completion: nil)
            }
            
            self.requestWasCancelled = false
            self.hideActivityIndicatory()
        }
    }
    
    private func stopGetLinksFromServer() {
        GoogleService.sharedManager().stopRequest()
        hideActivityIndicatory()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return links.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "Cell"
        
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier)
        cell?.textLabel?.text = String(links[indexPath.row])
        return cell!
    }
}

extension ViewController: DownloadDelegate {
    
    func downloadProgressUpdated(for progress: Float) {
        DispatchQueue.main.async {
            self.progressView.progress = progress
        }
    }
}
