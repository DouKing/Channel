//===----------------------------------------------------------*- swift -*-===//
//
// Created by Yikai Wu on 2023/1/1.
// Copyright © 2023 Yikai Wu. All rights reserved.
//
//===----------------------------------------------------------------------===//

import UIKit
import Channel

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .random
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        toast("这是一个 toast", duration: .seconds(3))
        view.toast("这也是一个 toast ")
    }
}

