//
//  LiveSportViewController.swift
//  Pods
//
//  Created by ByteDance on 2026/6/23.
//

public class LiveSportViewController : UIViewController {
    
    private var isNavbarHidden = false
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isNavbarHidden = navigationController?.isNavigationBarHidden ?? false
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(isNavbarHidden, animated: animated)
    }
}
