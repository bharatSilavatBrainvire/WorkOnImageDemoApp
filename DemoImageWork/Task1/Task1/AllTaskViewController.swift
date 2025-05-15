//
//  AllTaskViewController.swift
//  Task1
//
//  Created by Bharat Shilavat on 15/05/25.
//

import UIKit

class AllTaskViewController: UIViewController {
    
    @IBOutlet weak var tasksTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
    }
    
    private func setupUI() {
        tasksTableView.dataSource = self
        tasksTableView.delegate = self
    }
    
}

extension AllTaskViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    
}

extension AllTaskViewController: UITableViewDelegate {
    
}
