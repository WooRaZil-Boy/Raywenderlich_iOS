//
//  NASAViewController.swift
//  Spacetime
//
//  Created by Ellen Shapiro on 10/22/17.
//  Copyright © 2017 RayWenderlich.com. All rights reserved.
//

import UIKit

class NASAViewController: UIViewController {

  @IBOutlet var explanationLabel: UILabel!
  @IBOutlet var tableView: UITableView!
  
  private var rovers: [NASAMarsRover]?
  
  private var task: URLSessionTask?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.title = UserVisibleString.NASA
    self.tableView.refreshControl = UIRefreshControl()
    self.explanationLabel.text = UserVisibleString.NASASummary
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    guard rovers == nil else {
      // Nothing more to do here
      return
    }
    
    self.tableView.refreshControl?.beginRefreshing()
    self.task = NASAAPIController.fetchListOfRovers(errorCompletion: {
                                                      [weak self]
                                                      error in
                                                      self?.loadCompleted()
                                                      NSLog("Error getting rovers: \(error)")
                                                    },
                                                    successCompletion: {
                                                      [weak self]
                                                      rovers in
                                                      self?.rovers = rovers
                                                      self?.loadCompleted()
                                                      self?.tableView.reloadData()
                                                    })
  }
  
  private func loadCompleted() {
    self.task = nil
    self.tableView.refreshControl?.endRefreshing()
    
    // Remove the refresh control after it's off the screen
    DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
      [weak self] in
      self?.tableView.refreshControl = nil
    })
  }
  
}

// MARK: - Table View Data Source

extension NASAViewController: UITableViewDataSource {
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    guard let rovers = self.rovers else {
      return 0
    }
    
    return rovers.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let roverCell = tableView.dequeueReusableCell(withIdentifier: RoverCell.identifier, for: indexPath) as? RoverCell else {
      return UITableViewCell()
    }
    
    let rover = self.rovers![indexPath.row]
    roverCell.configure(for: rover)
    
    return roverCell
  }
}

//MARK: - Table View Delegate

extension NASAViewController: UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let rover = self.rovers![indexPath.row]
    tableView.deselectRow(at: indexPath, animated: true)
    NSLog("Picked \(rover.name)")
  }
  
}

