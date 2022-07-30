//
//  EmpDetailsViewController.swift
//  Employee Directory
//
//  Created by Admin on 30/07/22.
//

import UIKit
import CoreData

class EmpDetailsViewController: UIViewController {

    @IBOutlet weak var empName: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var companyName: UILabel!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var phoneNumber: UILabel!
    @IBOutlet weak var website: UILabel!
    @IBOutlet weak var companyPhrase: UILabel!
    @IBOutlet weak var headerTitle: UILabel!
    @IBOutlet weak var companyBs: UILabel!
    @IBOutlet weak var empProfileImg: UIImageView!
    
    var empDetails: EmpListResponseModel?
    var indexNo: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        empProfileImg.makeRounded()
        headerTitle.text =  "Details of " + (empDetails?[indexNo].name ?? "")
        empName.text = empDetails?[indexNo].name ?? ""
        userName.text = empDetails?[indexNo].username ?? ""
        companyName.text = empDetails?[indexNo].company?.name ?? ""
        address.text = empDetails?[indexNo].address.street ?? ""
        email.text = empDetails?[indexNo].email ?? ""
        phoneNumber.text = empDetails?[indexNo].phone ?? ""
        website.text = empDetails?[indexNo].website ?? ""
        companyPhrase.text = empDetails?[indexNo].company?.catchPhrase ?? ""
        companyBs.text = empDetails?[indexNo].company?.bs ?? ""
        empProfileImg.loadImageDown(String(empDetails?[indexNo].profileImage ?? ""))
       
    }
}


class DBHelper {
    
    private static let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    static func saveEmployees(_ employees: [EmpListResponse]) {
       var employeeList = [Employee]()
        employees.forEach {
            employeeList.append(getObjectWithEmployeeInfo($0))
        }
        try? context.save()
    }
    
    static func getObjectWithEmployeeInfo(_ employeeInfo: EmpListResponse!) -> Employee {
        let employee = Employee(context: context)
        employee.id = Int64(employeeInfo.id)
        employee.name = employeeInfo.name
        employee.username = employeeInfo.username
        employee.email = employeeInfo.email
        employee.profileImage = employeeInfo.profileImage
        employee.address = getObjectWithAddressInfo(employeeInfo.address)
        employee.phone = employeeInfo.phone
        employee.website = employeeInfo.website
        employee.company = getObjectWithCompanyInfo(employeeInfo.company)
        return employee
    }
    
    static func getObjectWithAddressInfo(_ addressInfo: AddressInfo!) -> Address {
        let address = Address(context: context)
        address.street = addressInfo.street
        address.suite = addressInfo.suite
        address.city = addressInfo.city
        address.zipcode = addressInfo.zipcode
        address.geo = getObjectWithGeoInfo(addressInfo.geo)
        return address
    }
    
    static func getObjectWithGeoInfo(_ geoInfo: GeoInfo!) -> Geo {
        let geo = Geo(context: context)
        geo.lat = geoInfo.lat
        geo.lng = geoInfo.lng
        return geo
    }
    
    static func getObjectWithCompanyInfo(_ companyInfo: CompanyInfo!) -> Company {
        let company = Company(context: context)
        company.name = companyInfo?.name ?? ""
        company.catchPhrase = companyInfo?.catchPhrase ?? ""
        company.bs = companyInfo?.bs ?? ""
        return company
    }
    
    static func employees(_ name: String! = nil, mailId: String! = nil) -> [EmpListResponse] {
        let request = Employee.fetchRequest()
        if name != nil || mailId != nil {
            let predicate1 = NSPredicate(format: "name CONTAINS[c] %@", name)
            let predicate2 = NSPredicate(format: "email CONTAINS[c] %@", mailId)
            let predicateCompound = NSCompoundPredicate.init(type: .or, subpredicates: [predicate1,predicate2])
            request.predicate = predicateCompound
        }
        return ((try? context.fetch(request)) ?? []).employees
    }
    
}

extension Array where Element == Employee {
    var employees: [EmpListResponse] {
        var list = [EmpListResponse]()
        self.forEach {
            list.append(
                EmpListResponse(
                    id: Int($0.id),
                    name: $0.name ?? "",
                    username: $0.username ?? "",
                    email: $0.email ?? "",
                    profileImage: $0.profileImage ?? "",
                    address: AddressInfo(
                        street: $0.address?.street ?? "",
                        suite: $0.address?.suite ?? "",
                        city: $0.address?.city ?? "",
                        zipcode: $0.address?.zipcode ?? "",
                        geo: GeoInfo(
                            lat: $0.address?.geo?.lat ?? "",
                                lng: $0.address?.geo?.lng ?? ""
                            )
                        ),
                    phone:$0.phone,
                    website: $0.website,
                    company: CompanyInfo(
                        name: $0.company?.name ?? "",
                            catchPhrase: $0.company?.catchPhrase ?? "",
                        bs: $0.company?.bs ?? ""
                    )
                )
            )
        }
        return list
    }
}
