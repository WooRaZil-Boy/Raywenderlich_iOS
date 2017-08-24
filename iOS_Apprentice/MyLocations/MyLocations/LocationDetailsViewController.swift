//
//  LocationDetailsViewController.swift
//  MyLocations
//
//  Created by 근성가이 on 2016. 11. 27..
//  Copyright © 2016년 근성가이. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData

private let dateFormatter: DateFormatter = { //글로벌 변수이지만, 접근제한이 Private이므로 이 파일 내에서만 접근 가능 //클로저로 특정 시점에 생성 //스위프트에서 전역변수는 항상 lazy로 생성된다.
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    
    return formatter
}() //뒤에 클로저를 실행하는 ()가 없으면 단순한 코드의 블럭이 된다.

class LocationDetailsViewController: UITableViewController {
    //MARK: - Properties
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var addPhotoLabel: UILabel!
    
    var coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0) //This contains the latitude and longitude from the CLLocation object that you received from the location manager.
    var placemark: CLPlacemark?
    var categoryName = "No Category"
    
    var managedObjectContext: NSManagedObjectContext!
    
    var date = Date()
    
    var locationToEdit: Location? { //add일 때는 nil
        didSet { //옵저버. 일일히 대입해 만들 필요 없이 이렇게 하는 게 더 나은 듯.
            if let location = locationToEdit {
                descriptionText = location.locationDescription
                categoryName = location.category
                date = location.date
                coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
                placemark = location.placemark
            }
        }
    }
    var descriptionText = ""
    
    var image: UIImage?
    var observer: Any!
    
    deinit {
        print("*** deinit \(self)")
        NotificationCenter.default.removeObserver(observer) //옵저버가 이 뷰 컨트롤러 내에서만 필요하므로
    }
}

//MARK: - ViewLifeCycle 
extension LocationDetailsViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let location = locationToEdit {
            title = "Edit Location"
            if location.hasPhoto {
                if let theImage = location.photoImage {
                    show(image: theImage)
                }
            }
        }
        
        descriptionTextView.text = descriptionText
        categoryLabel.text = categoryName
        
        latitudeLabel.text = String(format: "%.8f", coordinate.latitude)
        longitudeLabel.text = String(format: "%.8f", coordinate.longitude)
        
        if let placemark = placemark {
            addressLabel.text = string(from: placemark)
        } else {
            addressLabel.text = "No Address Found"
        }
        
        dateLabel.text = format(date: date)
        
        //FIXME: 이거 스토리보드에서 할 수도 있음
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        gestureRecognizer.cancelsTouchesInView = false
        tableView.addGestureRecognizer(gestureRecognizer)
        
        listenForBackgroundNotification()
        
        tableView.backgroundColor = UIColor.black
        tableView.separatorColor = UIColor(white: 1.0, alpha: 0.2)
        tableView.indicatorStyle = .white
        
        descriptionTextView.textColor = UIColor.white
        descriptionTextView.backgroundColor = UIColor.black
        
        addPhotoLabel.textColor = UIColor.white
        addPhotoLabel.highlightedTextColor = addPhotoLabel.textColor
        
        addressLabel.textColor = UIColor(white: 1.0, alpha: 0.4)
        addressLabel.highlightedTextColor = addressLabel.textColor
    }
}

//MARK: - Actions
extension LocationDetailsViewController {
    @IBAction func done() {
        let hudView = HudView.hud(inView: navigationController!.view, animated: true)        
        let location: Location
        if let temp = locationToEdit { //수정이라면
            hudView.text = "Updated"
            location = temp //객체를 옮겨 담는다.
        } else { //생성이라면
            hudView.text = "Tagged"
            location = Location(context: managedObjectContext) //객체를 새로 생성한다.
            location.photoID = nil //nil로 하지 않으면 기본값(0)을 가지게 된다. - 수정과 혼동
        }
        
        location.locationDescription = descriptionTextView.text
        location.category = categoryName
        location.latitude = coordinate.latitude
        location.longitude = coordinate.longitude
        location.date = date
        location.placemark = placemark
        
        if let image = image {
            if !location.hasPhoto { //사진을 새로 추가하는 경우에만. 사진 수정 시는 동일한 ID를 유지하고 덮어쓰기.
                location.photoID = Location.nextPhotoID() as NSNumber
            }
            if let data = UIImageJPEGRepresentation(image, 0.5) { //UIImage를 JPEG 포맷으로 변경해 Data로 return. Data is an object that represents a blob of binary data, usually the contents of a file.
                do {
                    try data.write(to: location.photoURL, options: .atomic) //경로에 저장
                } catch {
                    print("Error writing file: \(error)")
                }
            }
        }
        
        do {
            try managedObjectContext.save()
            
            afterDelay(0.6) {
                self.dismiss(animated: true, completion: nil)
            }
        } catch {
            fatalCoreDataError(error)
        }
    }
    
    @IBAction func cancel() {
        dismiss(animated: true, completion: nil)
    }
}

extension LocationDetailsViewController {
    func string(from placemark: CLPlacemark) -> String {
        var line = ""
        line.add(text: placemark.subThoroughfare)
        line.add(text: placemark.thoroughfare, separatedBy: " ")
        line.add(text: placemark.locality, separatedBy: ", ")
        line.add(text: placemark.administrativeArea, separatedBy: ", ")
        line.add(text: placemark.postalCode, separatedBy: " ")
        line.add(text: placemark.country, separatedBy: ", ")
        
        return line
    }
    
    func format(date: Date) -> String {
        return dateFormatter.string(from: date)
    }
    
    func show(image: UIImage) {
        imageView.image = image
        imageView.isHidden = false
        imageView.frame = CGRect(x: 10, y: 10, width: 260, height: 260)
        addPhotoLabel.isHidden = true
    }
}

// MARK: - UITableViewDelegate
extension LocationDetailsViewController {
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        switch (indexPath.section, indexPath.row) { //여기서 if - else if - else는 조건문에서 중복 되는 부분이 많기에 switch가 더 효율적이다.
        case (0, 0):
            return 88
        case (1, _):
            return imageView.isHidden ? 44 : 280
        case (2, 2):
            addressLabel.frame.size = CGSize(width: view.bounds.size.width - 115, height: 10000)
            addressLabel.sizeToFit()
            addressLabel.frame.origin.x = view.bounds.size.width - addressLabel.frame.size.width - 15
            
            return addressLabel.frame.size.height + 20 //margin 상하 10씩
        default:
            return 44
        }
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? { //셀을 선택하려고 할 때
        if indexPath.section == 0 || indexPath.section == 1 { //첫 번째나 두 번째 섹션이면 선택 되게. textView인 경우 가장자리도 선택이 된다
            return indexPath
        } else { //나머지(세 번째 섹션)은 read only
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 { //텍스트 뷰
            descriptionTextView.becomeFirstResponder()
        } else if indexPath.section == 1 && indexPath.row == 0 { //이미지 피커
            tableView.deselectRow(at: indexPath, animated: true)
            pickPhoto()
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) { //static cell로 구현해 cellForRowAt이 없기 때문에 여기서 셀 설정을 해 준다. //셀이 보여지기 전에 호출된다.
        cell.backgroundColor = UIColor.black
        
        if let textLabel = cell.textLabel {
            textLabel.textColor = UIColor.white
            textLabel.highlightedTextColor = textLabel.textColor
        }
        
        if let detailLabel = cell.detailTextLabel {
            detailLabel.textColor = UIColor(white: 1.0, alpha: 0.4)
            detailLabel.highlightedTextColor = detailLabel.textColor
        }
        
        let selectionView = UIView(frame: CGRect.zero)
        selectionView.backgroundColor = UIColor(white: 1.0, alpha: 0.2)
        cell.selectedBackgroundView = selectionView
        
        if indexPath.row == 2 {
            let addressLabel = cell.viewWithTag(100) as! UILabel
            addressLabel.textColor = UIColor.white
            addressLabel.highlightedTextColor = addressLabel.textColor
        }
    }
}

//MARK: - Navigations
extension LocationDetailsViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PickCategory" {
            let controller = segue.destination as! CategoryPickerViewController
            controller.selectedCategoryName = categoryName
        }
    }
    
    @IBAction func categoryPickerDidPickCategory(_ segue: UIStoryboardSegue) { //exit segue. 화면이 하나 뿐이면서 반드시 돌아오는 그런 경우. delegate 필요없이 unwind 세그로 간단하게 구현. 돌아와서 보여지는 뷰 컨트롤러에
        let controller = segue.source as! CategoryPickerViewController
        categoryName = controller.selectedCategoryName
        categoryLabel.text = categoryName
    }
}

extension LocationDetailsViewController {
    func hideKeyboard(_ gestureRecognizer: UIGestureRecognizer) {
        let point = gestureRecognizer.location(in: tableView)
        let indexPath = tableView.indexPathForRow(at: point) //x, y좌표로 indexPath 얻어낸다.
        
        if indexPath != nil && indexPath!.section == 0 && indexPath!.row == 0 { //description 적는 뷰를 탭한 경우에는 return. //셀이 아닌 테이블 뷰의 다른 곳을 탭한 경우 indexPath가 nil이 된다.
            return
        }
        
        descriptionTextView.resignFirstResponder()
    }
}

//MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate
extension LocationDetailsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func pickPhoto() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) { //카메라 사용 가능하면
            showPhotoMenu()
        } else {
            choosePhotoFromLibrary()
        }
    }
    
    func takePhotoWithCamera() {
        let imagePicker = MyImagePickerController()
        imagePicker.sourceType = .camera //시뮬레이터가 카메라 없어서 디바이스에서만 됨
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.view.tintColor = view.tintColor
        present(imagePicker, animated: true, completion: nil)
    }
    
    func choosePhotoFromLibrary() {
        let imagePicker = MyImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.view.tintColor = view.tintColor
        present(imagePicker, animated: true, completion: nil)
    }
    
    func showPhotoMenu() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        let takePhotoAction = UIAlertAction(title: "Take Photo", style: .default, handler: { _ in self.takePhotoWithCamera() })
        alertController.addAction(takePhotoAction)
        let chooseFromLibraryAction = UIAlertAction(title: "Choose From Library", style: .default, handler: {_ in self.choosePhotoFromLibrary() })
        alertController.addAction(chooseFromLibraryAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        image = info[UIImagePickerControllerEditedImage] as? UIImage //다른 키로 원본 이미지를 가져올 수도 있다.
        
        if let theImage = image { //image 프로퍼티의 didSet 옵저버를 사용해도 된다.
            show(image: theImage)
        }
        
        tableView.reloadData()
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

//MARK: - Background Notification
extension LocationDetailsViewController {
    func listenForBackgroundNotification() { //Apple은 앱이 백그라운드로 들어갈 때 어떤 알림창이나 액션 시트 같은 것이 보이지 않기를 권장한다. 한참 뒤에 실행할 경우 유저 자신조차 전에 하던 것을 잘 모르거나 민감한 정보가 떠 있는 경우가 발생하기 때문.
        observer = NotificationCenter.default.addObserver(forName: Notification.Name.UIApplicationDidEnterBackground, object: nil, queue: OperationQueue.main) { [weak self] _ in //강한 순환 참조가 일어나기 때문에 weak self. capture list를 만들어 준다. self가 nil이 될 수 있다.
            
            if let strongSelf = self {
                if strongSelf.presentedViewController != nil { //현재 뷰 컨트롤러 위의 모달 뷰의 존재 여부 (여기서는 이미지 피커) //category picker가 올라와져 있는 경우에는 nil을 반환한다. (이건 modal이 아닌 push이기 때문)
                    strongSelf.dismiss(animated: false, completion: nil)
                }
                
                strongSelf.descriptionTextView.resignFirstResponder()
            }
        }
    }
}
