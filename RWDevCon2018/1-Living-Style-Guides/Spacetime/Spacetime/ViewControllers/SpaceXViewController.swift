//
//  SpaceXViewController.swift
//  Spacetime
//
//  Created by Ellen Shapiro on 10/22/17.
//  Copyright © 2017 RayWenderlich.com. All rights reserved.
//

import UIKit

class SpaceXViewController: UIViewController {
  
  @IBOutlet var explanationLabel: UILabel!
  @IBOutlet var tableView: UITableView!
  
  private var launches: [SpaceXLaunch]?
  private var activeTask: URLSessionTask?
  
  //MARK: - View Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.title = UserVisibleString.SpaceX
    self.explanationLabel.text = UserVisibleString.SpaceXSummary
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    guard launches == nil else {
      return
    }
    
    self.loadLaunches()
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    guard segue.identifier == "ToDetailSegue" else {
      assertionFailure("Unhandled segue \(String(describing: segue.identifier))")
      return
    }
    
    guard let detail = segue.destination as? LaunchViewController else {
      assertionFailure("Wrong kind of destination!")
      return
    }
    
    guard
      let indexPath = self.tableView.indexPathForSelectedRow,
      let launch = self.launches?[indexPath.row] else {
        assertionFailure("Could not get launch!")
        return
    }
    
    detail.launch = launch
  }

  //MARK: - Networking
  
  private func loadLaunches() {
    self.tableView.refreshControl = UIRefreshControl()
    self.tableView.refreshControl?.beginRefreshing()
    self.activeTask = SpaceXAPIController.fetchAllLaunches(errorCompletion: {
                                                            [weak self]
                                                            error in
                                                            NSLog("Error retrieving launches: \(error)")
                                                            self?.launchCallCompleted()
                                                           },
                                                           successCompletion: {
                                                            [weak self]
                                                            launches in
                                                            
                                                            self?.launches = launches
                                                            self?.tableView.reloadData()
                                                            self?.launchCallCompleted()
                                                           })
  }
  
  private func launchCallCompleted() {
    self.activeTask = nil
    self.tableView.refreshControl?.endRefreshing()
    
    // Remove the refresh control after it's off the screen
    DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
      [weak self] in
      self?.tableView.refreshControl = nil
    })
  }
}

//MARK: - Table View Data source

extension SpaceXViewController: UITableViewDataSource {
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.launches?.count ?? 0
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let launchCell = tableView.dequeueReusableCell(withIdentifier: LaunchCell.identifier, for: indexPath) as? LaunchCell else {
      return UITableViewCell()
    }
    let launch = self.launches![indexPath.row]
    launchCell.configureForLaunch(launch)
    
    return launchCell
  }
}

// MARK: - Table View Delegate

extension SpaceXViewController: UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let launch = self.launches![indexPath.row]
    tableView.deselectRow(at: indexPath, animated: true)
    NSLog("Selected launch #\(launch.flightNumber)")
  }
}

