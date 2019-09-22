//
//  ViewController.swift
//  BottomSheetController
//
//  Created by ksk.matsuo@gmail.com on 09/22/2019.
//  Copyright (c) 2019 ksk.matsuo@gmail.com. All rights reserved.
//

import UIKit
import BottomSheetController

class ViewController: UIViewController {

    @IBAction func openBottomSheet() {
        let vc = ContentsViewController.create()
        present(vc, animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

