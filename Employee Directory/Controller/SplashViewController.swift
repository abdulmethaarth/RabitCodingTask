//
//  SplashViewController.swift
//  Employee Directory
//
//  Created by Admin on 30/07/22.
//

import UIKit

class SplashViewController: UIViewController {

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

        startTimer()
    }
    
    var timer: Timer?
    
    func startTimer() {
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(withTimeInterval: 1.2, repeats: false, block: { [weak self](timerr) in
            self?.stopTimer()
            DispatchQueue.main.async { [weak self] in
                self?.controlFlow()
            }
        })
    }
    
    func stopTimer() {
        self.timer?.invalidate()
        self.timer = nil
        
    }
    
    func controlFlow() {
        let loginVC = mainStoryBoard?.instantiateViewController(withIdentifier: "DashBoardViewController") as! DashBoardViewController
        navigationController?.pushViewController(loginVC, animated: true)
    }
    
}

extension UIViewController{
    var mainStoryBoard: UIStoryboard?{
        return UIStoryboard(name: "Main", bundle: nil)
    }
}
