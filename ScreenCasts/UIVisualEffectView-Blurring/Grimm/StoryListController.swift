/// Copyright (c) 2017 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit

class StoryListController: UITableViewController {
  
  static let segueIdentifier = "StoryListToStoryView"
  
  private var stories: [Story] = []
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    registerForNotifications()
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    guard let storyViewController = segue.destination as? StoryViewController,
      segue.identifier == StoryListController.segueIdentifier,
      let story = sender as? Story
      else { return }
    storyViewController.story = story
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let image = UIImage(named: "Bull")
    let imageView = UIImageView(image: image)
    navigationItem.titleView = imageView
    reloadTheme()
    
    let activityView = UIActivityIndicatorView(style: .gray)
    activityView.hidesWhenStopped = true
    let containerItem = UIBarButtonItem(customView: activityView)
    navigationItem.rightBarButtonItem = containerItem
    
    tableView.register(StoryCell.self, forCellReuseIdentifier: "StoryCell")
    tableView.rowHeight = UITableView.automaticDimension
    tableView.estimatedRowHeight = 78
    tableView.tableFooterView = UIView()
    
    activityView.startAnimating()
    Story.loadStories() { [weak self] loadedStories in
      guard let `self` = self else { return }
      self.stories = loadedStories
      let count = self.stories.count
      let indexPaths = (0..<count).map{ IndexPath(row: $0, section: 0) }
      self.tableView.beginUpdates()
      self.tableView.insertRows(at: indexPaths, with: .automatic)
      self.tableView.endUpdates()
      activityView.stopAnimating()
    }
  }
  
  func preferredContentSizeCategoryDidChange(notification: NSNotification!) {
    tableView.reloadData()
  }
  
  private func registerForNotifications() {
    let notificationCenter = NotificationCenter.default
    notificationCenter.addObserver(self, selector: #selector(StoryViewController.preferredContentSizeDidChange(forChildContentContainer:)),
                                   name: UIContentSizeCategory.didChangeNotification, object: nil)
    notificationCenter.addObserver(self, selector: #selector(StoryViewController.themeDidChange),
                                   name: ThemeDidChangeNotification, object: nil)
  }
  
  @objc func themeDidChange() {
    reloadTheme()
  }
  
}

extension StoryListController { // UITableViewDataSource
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int  {
    return stories.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let storyCell = tableView.dequeueReusableCell(withIdentifier: "StoryCell") as! StoryCell
    storyCell.story = stories[indexPath.row]
    return storyCell
  }
}

extension StoryListController { // UITableViewDelegate
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    let story = stories[indexPath.row]
    performSegue(withIdentifier: StoryListController.segueIdentifier, sender: story)
  }
}

extension StoryListController: ThemeAdopting {
  func reloadTheme() {
    let theme = Theme.shared
    tableView.separatorColor = theme.separatorColor
    
    if let indexPaths = tableView.indexPathsForVisibleRows {
      tableView.reloadRows(at: indexPaths, with: .none)
    }
  }
}

