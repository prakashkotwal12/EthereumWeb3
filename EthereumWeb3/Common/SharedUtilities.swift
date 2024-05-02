//
//  SharedUtilities.swift
//  EthereumWeb3
//
//  Created by Prakash Kotwal on 02/05/2024.
//
import UIKit

class SharedUtilities: NSObject {
	
	static let shared = SharedUtilities()
	
	private var loaderAlert: UIAlertController?
	
	func showAlert(title: String, message: String, viewController: UIViewController) {
		let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
		viewController.present(alert, animated: true, completion: nil)
	}
	
	func showLoader(viewController: UIViewController) {
			loaderAlert = UIAlertController(title: "Loading...", message: "", preferredStyle: .alert)
			
//			let loadingIndicator = UIActivityIndicatorView(style: .medium)
//			loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
//			loadingIndicator.startAnimating()
//			
//			loaderAlert?.view.addSubview(loadingIndicator)
//			
//			let constraints = [
//					loadingIndicator.centerXAnchor.constraint(equalTo: loaderAlert!.view.centerXAnchor),
//					loadingIndicator.centerYAnchor.constraint(equalTo: loaderAlert!.view.centerYAnchor)
//			]
//			
//			NSLayoutConstraint.activate(constraints)
			
			viewController.present(loaderAlert!, animated: true) {
					// After presenting the alert, set the loading message
//					self.loaderAlert?.message = "Loading..."
			}
	}

	
	func hideLoader() {
		loaderAlert?.dismiss(animated: true, completion: nil)
	}
}
