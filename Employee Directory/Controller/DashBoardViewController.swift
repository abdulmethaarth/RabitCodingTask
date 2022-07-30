//
//  ViewController.swift
//  Employee Directory
//
//  Created by Admin on 30/07/22.
//

import UIKit

class DashBoardViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchTxtField: UITextField!
    
    var empListRes: EmpListResponseModel? {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getEmpList()
        // Do any additional setup after loading the view.
    }
    
    
    
    private func getEmpList() {
        let empList = DBHelper.employees()
        guard empList.isEmpty else {
            self.empListRes = empList
            return
        }
        let Url = String(format: "http://www.mocky.io/v2/5d565297300000680030a986")
        guard let serviceUrl = URL(string: Url) else { return }
        var request = URLRequest(url: serviceUrl)
        request.httpMethod = "GET"
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        let session = URLSession.shared
        session.dataTask(with: request) { [weak self] (data, response, error) in
            if let response = response {
                print(response)
            }
            let list = data?.getDecodedObject(from: EmpListResponseModel.self) ?? []
            DBHelper.saveEmployees(list)
            self?.empListRes = list
        }.resume()
    }
    
}

extension DashBoardViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return empListRes?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: DashBoardListTableViewCell = tableView.dequeueCell(indexPath)
        cell.empName.text = empListRes?[indexPath.row].name ?? ""
        cell.companyName.text = empListRes?[indexPath.row].company?.name ?? ""
        cell.userName.text = empListRes?[indexPath.row].username ?? ""
        cell.empProfileImg.loadImageDown(String(empListRes?[indexPath.row].profileImage ?? ""))
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let nextVC = mainStoryBoard?.instantiateViewController(withIdentifier: "EmpDetailsViewController") as! EmpDetailsViewController
        nextVC.empDetails = empListRes
        nextVC.indexNo = indexPath.row
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
}

typealias EmpListResponseModel = [EmpListResponse]

struct EmpListResponse: Codable {
    var id: Int
    var name, username, email: String
    var profileImage: String?
    var address: AddressInfo
    var phone, website: String?
    var company: CompanyInfo?
    
    enum CodingKeys: String, CodingKey {
        case id, name, username, email
        case profileImage = "profile_image"
        case address, phone, website, company
    }
}

// MARK: - Address
struct AddressInfo: Codable {
    var street, suite, city, zipcode: String
    var geo: GeoInfo
}

// MARK: - Geo
struct GeoInfo: Codable {
    var lat, lng: String
}

// MARK: - Company
struct CompanyInfo: Codable {
    var name, catchPhrase, bs: String
}

extension UITableView {
    func dequeueCell<T: NSObject>(_ indexPath: IndexPath) -> T {
        return self.dequeueReusableCell(withIdentifier: T.className, for: indexPath) as! T
    }
}

extension NSObject {
    class var className: String {
        return String(describing: self)
    }
}

extension Data {
    func getDecodedObject<T>(from object : T.Type)->T? where T : Decodable {
        do {
            return try JSONDecoder().decode(object, from: self)
        } catch let error {
            print("Manually parsed  ", (try? JSONSerialization.jsonObject(with: self, options: .mutableContainers)) ?? "nil")
            print("Error in Decoding OBject ", String(describing: error))
            return nil
        }
    }
}

extension String {
    var int64Value: Int64? {
        return Int64(self.replacingOccurrences(of: ",", with: ""))
    }
}

extension UIImageView {
    func loadImageDown(_ urlString: String) {
        if let url = URL(string: urlString) {
            let assetId = urlString.components(separatedBy: "=").last ?? ""
            if let image = loadImageFromDocumentsDirectory(imageName: assetId) {
                self.image = image
            } else {
                DispatchQueue.global(qos: .userInteractive).async { [weak self] in
                    if let data = try? Data.init(contentsOf: url) {
                        if let asset = UIImage(data: data) {
                            DispatchQueue.main.async {
                                self?.image = asset
                            }
                            saveImageToDocumentsDirectory(image: asset, withName: assetId) }
                    }
                }
            }
        }else {
            self.image = UIImage(named: "no_img")
        }
    }
    
}

func getDocumentDirectoryPath() -> NSString {
    let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
    let documentsDirectory = paths[0]
    return documentsDirectory as NSString
}

func saveImageToDocumentsDirectory(image: UIImage, withName: String) -> String? {
    if let data = image.pngData() {
        let dirPath = getDocumentDirectoryPath()
        let imageFileUrl = URL(fileURLWithPath: dirPath.appendingPathComponent(withName) as String)
        do {
            try data.write(to: imageFileUrl)
            print("Successfully saved image at path: \(imageFileUrl)")
            return imageFileUrl.absoluteString
        } catch {
            print("Error saving image: \(error)")
        }
    }
    return nil
}

func loadImageFromDocumentsDirectory(imageName: String) -> UIImage? {
    let tempDirPath = getDocumentDirectoryPath()
    let imageFilePath = tempDirPath.appendingPathComponent(imageName)
    return UIImage(contentsOfFile:imageFilePath)
}

extension UIImageView {
    func makeRounded() {
        layer.borderWidth = 1
        layer.masksToBounds = false
        layer.borderColor = UIColor.black.cgColor
        layer.cornerRadius = self.frame.height / 2
        clipsToBounds = true
    }
}

extension DashBoardViewController: UITextFieldDelegate{

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newString = NSString(string: textField.text!).replacingCharacters(in: range, with: string)
        if newString.isEmpty {
            self.empListRes = DBHelper.employees()
        } else {
            self.empListRes = DBHelper.employees(newString, mailId: newString)
        }
        return true
    }
}
