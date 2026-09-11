//
//  RASPCallback.swift
//  ricapp
//
//  Created by Technical RML on 11/09/26.
//

import iXGCallbackBridge
import UIKit

class CallbackController: UIAlertController {}
class CustomViewController: UIViewController {}

let callbackTitle = "Warning";
let callbackMessage = "Your device is compromised";
let callbackButton = "Continue";

func presentAlert() {
    let window = UIApplication.shared.connectedScenes
        .compactMap { $0 as? UIWindowScene }
        .first?
        .windows
        .first
    guard let window = window,
          let _ = window.rootViewController else {
        DispatchQueue.main.async {
            presentAlert()
        }
        return
    }

    var currentController = window.rootViewController!
    while let presentedController = currentController.presentedViewController {
        currentController = presentedController
    }

    // ⬇️ langsung lanjut ke sini, blok CustomViewController dihapus

    if !currentController.isKind(of: CallbackController.self) {
        let alertController = CallbackController(title: callbackTitle,
                                                 message: callbackMessage,
                                                 preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: callbackButton,
                                                style: .default,
                                                handler: nil))
        currentController.present(alertController, animated: true, completion: {})
    }
}

@_cdecl("my_callback")
public func myCallback() {
  DispatchQueue.main.async {
    presentAlert()
  }
}
