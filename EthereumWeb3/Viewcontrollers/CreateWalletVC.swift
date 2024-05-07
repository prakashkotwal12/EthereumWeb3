//
//  CreateWalletVC.swift
//  EthereumWeb3
//
//  Created by Prakash Kotwal on 01/05/2024.
//

import UIKit
import Foundation
import Web3Core
import web3swift

class CreateWalletVC: UIViewController {
	let sdkHelper = SDKHelper.sharedSDKHelper
	@IBOutlet weak var walletAddressLabel: UILabel!
	@IBOutlet weak var phraseLabel: UILabel!
	
	let sharedUtils = SharedUtilities.shared
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	@IBAction func onClickCreateWallet(_ sender: UIButton) {
		sharedUtils.showLoader(viewController: self)
		DispatchQueue.global(qos: .background).asyncAfter(deadline: .now()) {
			self.createWallet()
		}
	}
	
	@IBAction func onClickCopyAddress(_ sender: UIButton) {
		copyToClipboard(text: walletAddressLabel.text)
	}
	
	@IBAction func onClickCopyPhrase(_ sender: UIButton) {
		copyToClipboard(text: phraseLabel.text)
	}
	
	func createWallet() {
		sdkHelper.getMnemonics { response, mnemonics, wallet in
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
				self.sharedUtils.hideLoader()
				if response.success {
					self.walletAddressLabel.text = wallet?.address ?? ""
					self.phraseLabel.text = mnemonics
				} else {
					self.showAlert(title: "Error", message: response.message)
				}
			}
		}
	}
	
	func copyToClipboard(text: String?) {
		guard let text = text else { return }
		UIPasteboard.general.string = text
	}
	
	func showAlert(title: String, message: String) {
		sharedUtils.showAlert(title: title, message: message, viewController: self)
	}
}
