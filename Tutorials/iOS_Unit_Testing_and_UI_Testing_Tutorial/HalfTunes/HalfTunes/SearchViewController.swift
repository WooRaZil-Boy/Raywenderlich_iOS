/// Copyright (c) 2019 Razeware LLC
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
import AVKit
import AVFoundation

class SearchViewController: UIViewController {
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var searchBar: UISearchBar!
  
  var searchResults: [Track] = []
  
  // create and initialize URLSession with a default session configuration
  var defaultSession: DHURLSession = URLSession(configuration: URLSessionConfiguration.default)
  // declare a URLSessionDataTask which you'll use to make an HTTP GET request to the iTunes Seach web service
  // when the user performs a search. Will be re-initialized and reused each time the user creates a new query
  var dataTask: URLSessionDataTask?
  
  // maintains a mapping between URLs and their active Download, if any
  var activeDownloads: [String: Download] = [:]
  
  lazy var tapRecognizer: UITapGestureRecognizer = {
    var recognizer = UITapGestureRecognizer(target:self, action: #selector(SearchViewController.dismissKeyboard))
    return recognizer
  }()
  
  // you initialize a separate session with a default configuration to handle all your download tasks
  // you also specify a delegate, which lets you receive URLSession events via delegate calls
  // this is useful for tracking not just when a task is complete, but also the progress of the task
  // setting the delegate to nil causes the session to create a serial operation queue, by default, to perform
  // all calls to the delegate methods and completion handlers
  // NOTE: the lazy creation of downloadsSession: this lets you delay the creation of the session until it's needed
  // most importantly, it lets you pass self as the delegate parameter to the initializer - even if self isn't initialized
  lazy var downloadsSession: URLSession = {
    // instead of using the default session configuration, you use a special background session configuration
    // you also set a unique identifier for the session here to allow you to reference and "reconnect" to the same background session if needed
    let configuration = URLSessionConfiguration.background(withIdentifier: "bgSessionConfiguration")
    let session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    return session
  }()
  
  // MARK: View controller methods
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.tableFooterView = UIView()
    // calling the lazily-loaded downloadsSession ensures the app creates exactly one background session upon initialization of SearchViewController
    _ = downloadsSession
  }
  
  // MARK: Handling Search Results
  
  // This helper method helps parse response JSON NSData into an array of Track objects.
  func updateSearchResults(_ data: Data?) {
    searchResults.removeAll()
    do {
      if
        let data = data,
        let response = try JSONSerialization.jsonObject(with: data, options:JSONSerialization.ReadingOptions(rawValue:0)) as? [String: AnyObject] {
        // Get the results array
        if let array: AnyObject = response["results"] {
          for trackDictonary in array as! [AnyObject] {
            if let trackDictonary = trackDictonary as? [String: AnyObject], let previewUrl = trackDictonary["previewUrl"] as? String {
              // Parse the search result
              let name = trackDictonary["trackName"] as? String
              let artist = trackDictonary["artistName"] as? String
              searchResults.append(Track(name: name, artist: artist, previewUrl: previewUrl))
            } else {
              print("Not a dictionary")
            }
          }
        } else {
          print("Results key not found in dictionary")
        }
      } else {
        print("JSON Error")
      }
    } catch let error as NSError {
      print("Error parsing results: \(error.localizedDescription)")
    }
    
    DispatchQueue.main.async {
      self.tableView?.reloadData()
      self.tableView?.setContentOffset(CGPoint.zero, animated: false)
    }
  }
  
  // MARK: Keyboard dismissal
  
  @objc func dismissKeyboard() {
    searchBar.resignFirstResponder()
  }
  
  // MARK: Download methods
  
  // Called when the Download button for a track is tapped
  func startDownload(_ track: Track) {
    if let urlString = track.previewUrl, let url = URL(string: urlString) {
      // initialize a Download with the preview URL of the track
      let download = Download(url: urlString)
      // using your new session object, you create a URLSessionDownloadTask with the preview URL and set it to the downloadTask property of the Download
      download.downloadTask = downloadsSession.downloadTask(with: url)
      // start the download task by calling resume() on it
      download.downloadTask!.resume()
      // indicate that the download is in progress
      download.isDownloading = true
      // finally map the download URL to its Download in the activeDownloads dictionary
      activeDownloads[download.url] = download
    }
  }
  
  // Called when the Pause button for a track is tapped
  func pauseDownload(_ track: Track) {
    if let urlString = track.previewUrl, let download = activeDownloads[urlString] {
      if download.isDownloading {
        // you retrieve the resume data from the closure provided by cancel(byProducingResumeData:)
        // and save it to the appropriate Download for future resumption
        download.downloadTask?.cancel(byProducingResumeData: { data in
          if data != nil {
            download.resumeData = data
          }
        })
        // set isDownloading to false, to signify that the download is paused
        download.isDownloading = false
      }
    }
  }
  
  // Called when the Cancel button for a track is tapped
  func cancelDownload(_ track: Track) {
    if let urlString = track.previewUrl, let download = activeDownloads[urlString] {
      // call cancel on the corresponding Download in the dictionary of active downloads
      download.downloadTask?.cancel()
      // you then remove it from the dictionary of active downloads
      activeDownloads[urlString] = nil
    }
  }
  
  // Called when the Resume button for a track is tapped
  func resumeDownload(_ track: Track) {
    if let urlString = track.previewUrl, let download = activeDownloads[urlString] {
      // is resume data present
      if let resumeData = download.resumeData {
        // if resumeData found, create a new downloadTask by invoking downloadTask(withResumeData:) with the resume data
        // and start the task by calling resume()
        download.downloadTask = downloadsSession.downloadTask(withResumeData: resumeData as Data)
        download.downloadTask!.resume()
        download.isDownloading = true
      } else if let url = URL(string: download.url) {
        // if resume data is absent for some reason, you create a new download task from scratch with the download URL and start it
        download.downloadTask = downloadsSession.downloadTask(with: url)
        download.downloadTask!.resume()
        download.isDownloading = true
      }
    }
  }
  
  // This method attempts to play the local file (if it exists) when the cell is tapped
  func playDownload(_ track: Track) {
    if let urlString = track.previewUrl, let url = localFilePathForUrl(urlString) {
      let tunePlayerViewController = AVPlayerViewController()
      tunePlayerViewController.player = AVPlayer(url: url)
      tunePlayerViewController.player?.play()
      present(tunePlayerViewController, animated: true, completion: nil)
    }
  }
  
  // MARK: Download helper methods
  
  // This method generates a permanent local file path to save a track to by appending
  // the lastPathComponent of the URL (i.e. the file name and extension of the file)
  // to the path of the app’s Documents directory.
  func localFilePathForUrl(_ previewUrl: String) -> URL? {
    let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
    if let url = URL(string: previewUrl) {
      let fullPath = documentsPath.appendingPathComponent(url.lastPathComponent)
      return URL(fileURLWithPath:fullPath)
    }
    return nil
  }
  
  // This method checks if the local file exists at the path generated by localFilePathForUrl(_:)
  func localFileExistsForTrack(_ track: Track) -> Bool {
    if let urlString = track.previewUrl, let localUrl = localFilePathForUrl(urlString) {
      var isDir: ObjCBool = false
       return FileManager.default.fileExists(atPath: localUrl.path, isDirectory: &isDir)
     }
    return false
  }
  
  // simply returns the index of the Track in the searchResults list that has the given URL
  func trackIndexForDownloadTask(downloadTask: URLSessionDownloadTask) -> Int? {
    if let url = downloadTask.originalRequest?.url?.absoluteString {
      for (index, track) in searchResults.enumerated() {
        if url == track.previewUrl! {
          return index
        }
      }
    }
    return nil
  }
}

// MARK: - UISearchBarDelegate

extension SearchViewController: UISearchBarDelegate {
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    // Dimiss the keyboard
    dismissKeyboard()
    
    if !searchBar.text!.isEmpty {
      // check if data task is already initialized.
      // If so, you can cancel the task as you want to reuse the data task object for the latest query
      if dataTask != nil {
        dataTask?.cancel()
      }
      // enable the network indicator on the status bar to indicate to the user that a network process is running
      UIApplication.shared.isNetworkActivityIndicatorVisible = true
      // before passing the user's search string as a parameter to the query URL, you call addingPercentEncoding on the string to ensure that it's properly escaped
      let expectedCharSet = NSCharacterSet.urlQueryAllowed
      let searchTerm = searchBar.text!.addingPercentEncoding(withAllowedCharacters: expectedCharSet)!
      // construct a URL by appending the escaped search string as a GET parameter to the iTunes Search API base url
      let url = URL(string: "https://itunes.apple.com/search?media=music&entity=song&term=\(searchTerm)")
      // from the session you created, you initialize a URLSessionDataTask to handle the HTTP GET request.
      // the constructor of URLSessionDataTask takes in the URL that you constructed along with a completion handler to be called when the data task completed
      dataTask = defaultSession.dataTask(with: url!) {
        data, response, error in
        // invoke the UI update in the main thread and hide the activity indicator to show that the task is completed
        DispatchQueue.main.async {
          UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
        // if HTTP request is successful you call updateSearchResults(_:) which parses the response NSData into Tracks and updates the table view
        if let error = error {
          print(error.localizedDescription)
        } else if let httpResponse = response as? HTTPURLResponse {
          if httpResponse.statusCode == 200 {
            self.updateSearchResults(data)
          }
        }
      }
      // all tasks start in a suspended state by default, calling resume() starts the data task
      dataTask?.resume()
    }
  }
  
  func position(for bar: UIBarPositioning) -> UIBarPosition {
    return .topAttached
  }
  
  func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
    view.addGestureRecognizer(tapRecognizer)
  }
  
  func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
    view.removeGestureRecognizer(tapRecognizer)
  }
}

// MARK: TrackCellDelegate

extension SearchViewController: TrackCellDelegate {
  func pauseTapped(_ cell: TrackCell) {
    if let indexPath = tableView.indexPath(for: cell) {
      let track = searchResults[indexPath.row]
      pauseDownload(track)
      tableView.reloadRows(at: [IndexPath(row: indexPath.row, section: 0)], with: .none)
    }
  }
  
  func resumeTapped(_ cell: TrackCell) {
    if let indexPath = tableView.indexPath(for: cell) {
      let track = searchResults[indexPath.row]
      resumeDownload(track)
      tableView.reloadRows(at: [IndexPath(row: indexPath.row, section: 0)], with: .none)
    }
  }
  
  func cancelTapped(_ cell: TrackCell) {
    if let indexPath = tableView.indexPath(for: cell) {
      let track = searchResults[indexPath.row]
      cancelDownload(track)
      tableView.reloadRows(at: [IndexPath(row: indexPath.row, section: 0)], with: .none)
    }
  }
  
  func downloadTapped(_ cell: TrackCell) {
    if let indexPath = tableView.indexPath(for: cell) {
      let track = searchResults[indexPath.row]
      startDownload(track)
      tableView.reloadRows(at: [IndexPath(row: indexPath.row, section: 0)], with: .none)
    }
  }
}

// MARK: UITableViewDataSource

extension SearchViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return searchResults.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "TrackCell", for: indexPath) as!TrackCell
    
    // Delegate cell button tap events to this view controller
    cell.delegate = self
    
    let track = searchResults[indexPath.row]
    
    // Configure title and artist labels
    cell.titleLabel.text = track.name
    cell.artistLabel.text = track.artist
    
    // for tracks with active downloads, you set showDownloadControls to true; otherwise, you set it to false
    // you then display the progress views and labels, provided with the sample project, in accordance with the value of showDownloadControls
    // for paused downloads, display "Paused" for the status; otherwise "Downloading..."
    var showDownloadControls = false
    if let download = activeDownloads[track.previewUrl!] {
      showDownloadControls = true
      
      cell.progressView.progress = download.progress
      cell.progressLabel.text = (download.isDownloading) ? "Downloading..." : "Paused"
      
      // this toggles the button between the two states pause and resume
      let title = (download.isDownloading) ? "Pause" : "Resume"
      cell.pauseButton.setTitle(title, for: .normal)
    }
    cell.progressView.isHidden = !showDownloadControls
    cell.progressLabel.isHidden = !showDownloadControls
    
    // If the track is already downloaded, enable cell selection and hide the Download button
    let downloaded = localFileExistsForTrack(track)
    cell.selectionStyle = downloaded ? .gray : .none
    
    // hide the Download button also if its track is downloading
    cell.downloadButton.isHidden = downloaded || showDownloadControls
    
    // show the pause and cancel buttons only if a download is active
    cell.pauseButton.isHidden = !showDownloadControls
    cell.cancelButton.isHidden = !showDownloadControls
    
    return cell
  }
}

// MARK: UITableViewDelegate

extension SearchViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 62.0
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let track = searchResults[indexPath.row]
    if localFileExistsForTrack(track) {
      playDownload(track)
    }
    tableView.deselectRow(at: indexPath, animated: true)
  }
}

// MARK: URLSessionDownloadDelegate

extension SearchViewController: URLSessionDownloadDelegate {
  func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
    // extract the original request URL from the task and pass it to the provided localFilePathForUrl(_:) helper method.
    // localFilePathForUrl(_:) then generates a permanent local file path to save to by appending the lastPastComponent of the URL
    // (i.e. the file name and extension of the file) to the path of the app's Documents directory
    if
      let originalURL = downloadTask.originalRequest?.url?.absoluteString,
      let destinationURL = localFilePathForUrl(originalURL) {
      print(destinationURL)
      
      // with FileManager you move the downloaded file from its temporary file location to the desired destination file path by
      // clearing out any item at that location before you start the copy task
      let fileManager = FileManager.default
      do {
        try fileManager.removeItem(at: destinationURL)
      } catch {
        // Non-fatal: file probably doesn't exist
      }
      do {
        try fileManager.copyItem(at: location, to: destinationURL)
      } catch let error as NSError {
        print("Could not copy file to disk: \(error.localizedDescription)")
      }
    }
    
    // look up the corresponding Download in your active downloads and remove it
    if let url = downloadTask.originalRequest?.url?.absoluteString {
      activeDownloads[url] = nil
      // look up the Track in your table view and reload the corresponding cell
      if let trackIndex = trackIndexForDownloadTask(downloadTask: downloadTask) {
        DispatchQueue.main.async {
          self.tableView.reloadRows(at: [IndexPath(row: trackIndex, section: 0)], with: .none)
        }
      }
    }
  }
  
  func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
    // using the provided downloadTask, you extract the URL and use it to find the Download in your dictionary of active downloads.
    if
      let downloadUrl = downloadTask.originalRequest?.url?.absoluteString,
      let download = activeDownloads[downloadUrl] {
      // method returns total bytes written and the total bytes expected to be written. You calculate the progress as the ratio of the two
      // values and save the result in the Download. You'll use this value to update the progress view.
      download.progress = Float(totalBytesWritten)/Float(totalBytesExpectedToWrite)
      // ByteCountFormatter takes a byte value and generates a human-readable string showing the total download file size. You'll use this string to show the size of the download alongside the percentage complete
      let totalSize = ByteCountFormatter.string(fromByteCount: totalBytesExpectedToWrite, countStyle: ByteCountFormatter.CountStyle.binary)
      // find the cell responsible for displaying the Track and update both its progress view and progress label with the values derived form the previous steps
      DispatchQueue.main.async {
        if let trackIndex = self.trackIndexForDownloadTask(downloadTask: downloadTask), let trackCell = self.tableView.cellForRow(at: IndexPath(row: trackIndex, section: 0)) as? TrackCell {
          trackCell.progressView.progress = download.progress
          trackCell.progressLabel.text = String(format: "%.1f%% of %@", download.progress * 100, totalSize)
        }
      }
    }
  }
}

// MARK: URLSessionDelegate
extension SearchViewController: URLSessionDelegate {
  // simply grabs the stored completion handler from the app delegate and invokes it on the main thread
  func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
    if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
      if let completionHandler = appDelegate.backgroundSessionCompletionHandler {
        appDelegate.backgroundSessionCompletionHandler = nil
        DispatchQueue.main.async {
          completionHandler()
        }
      }
    }
  }
}

