//
//  SearchView.swift
//  google-search-api
//
//  Created by Kubitski Vlad on 07.12.2018.
//  Copyright © 2018 Kubitski Vlad. All rights reserved.
//

import Foundation
import UIKit


class SearchView: UIView, UISearchBarDelegate {
    
    @IBOutlet private weak var searchBarView: UISearchBar!
    @IBOutlet private weak var button: UIButton!
    
    private var array: [String] = []
    private var tapStartSearchButtonClosure: ((String) -> Void)?
    private var tapStopSearchButtonClosure: (() -> Void)?
    private var requestInProgress = false
    
    func setTapSearchButtonHandlers(tapStartSearchButtonClosure: @escaping (String) -> Void, tapStopSearchButtonClosure: @escaping () -> Void) {
        self.tapStartSearchButtonClosure = tapStartSearchButtonClosure
        self.tapStopSearchButtonClosure = tapStopSearchButtonClosure
        self.searchBarView.delegate = self
    }
    
    @IBAction func actionGoogleSearchButton(_ sender: UIButton) {
        guard let searchText = searchBarView.text,
            !searchText.isEmpty else {
                searchBarView.resignFirstResponder()
                return
        }
        
        if button.titleLabel?.text == "Google Search" {
            tapStartSearchButtonClosure(searchText: searchText)
        } else {
            setButtonTitle("Google Search")
            tapStopSearchButtonClosure?()
        }
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchRequestName = searchBarView.text,
            !searchRequestName.isEmpty else {
                searchBar.resignFirstResponder()
                return
        }
        tapStartSearchButtonClosure(searchText: searchRequestName)
    }
    
    func setButtonTitle(_ title: String) {
        button.setTitle(title, for: .normal)
        searchBarView.resignFirstResponder()
    }
    
    func tapStartSearchButtonClosure(searchText: String) {
        setButtonTitle("Stop")
        tapStartSearchButtonClosure?(searchText)
    }
}
