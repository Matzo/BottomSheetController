//
//  ContentsViewController.swift
//  MiniPlayer
//
//  Created by Matsuo Keisuke on 9/21/19.
//  Copyright © 2019 Matsuo Keisuke. All rights reserved.
//

import UIKit
import BottomSheetController

class ContentsViewController: UIViewController, BottomSheetPresentable {

    var bottomSheetController: BottomSheetController?

    var scrollView: UIScrollView? { return self.tableView }

    let tableView = UITableView()

    var items: [String] = []

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print(#function)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print(#function)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print(#function)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print(#function)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: String(describing: UITableViewCell.self))
        tableView.dataSource = self
        tableView.delegate = self

        items = [
            "open fixed height 400",
            "open half size",
            "open preferred size",
            "closeAll",
            "closeAllAndRoot",
            "close"
        ]

        tableView.reloadData()
        preferredContentSize = CGSize(width: tableView.contentSize.width,
                                      height: tableView.contentSize.height)
    }

    static func create() -> ContentsViewController {
        let vc: ContentsViewController = ContentsViewController()
        return vc
    }
}

extension ContentsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            let vc = ContentsViewController.create()
            BottomSheetController.present(vc, from: self, height: .fixed(400), animated: true)
        case 1:
            let vc = ContentsViewController.create()
            BottomSheetController.present(vc, from: self, height: .half, animated: true)
        case 2:
            let vc = ContentsViewController.create()
            BottomSheetController.present(vc, from: self, height: .preferred, animated: true)
        case 3:
            BottomSheetController.dismissStackedBottomSheets(frontSheet: self, alsoParent: false)
        case 4:
            BottomSheetController.dismissStackedBottomSheets(frontSheet: self, alsoParent: true)
        default:
            dismiss(animated: true, completion: nil)
        }
    }
}

extension ContentsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: UITableViewCell.self), for: indexPath)
        cell.textLabel?.text = items[indexPath.row]
        return cell
    }
}
