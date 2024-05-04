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
	
	@IBOutlet weak var walletAddressLabel: UILabel!
	@IBOutlet weak var phraseLabel: UILabel!
	
	let sharedUtils = SharedUtilities.shared
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	@IBAction func onClickCreateWallet(_ sender: UIButton) {
		createWallet()
	}
	
	@IBAction func onClickCopyAddress(_ sender: UIButton) {
		copyToClipboard(text: walletAddressLabel.text)
	}
	
	@IBAction func onClickCopyPhrase(_ sender: UIButton) {
		copyToClipboard(text: phraseLabel.text)
	}
	
	func createWallet() {
		sharedUtils.showLoader(viewController: self)
		
		DispatchQueue.global().async {
			do {
				guard let mnemonics = try BIP39.generateMnemonics(bitsOfEntropy: Constants.bitsOfEntropy),
							let keystore = try BIP32Keystore(mnemonics: mnemonics, password: Constants.password, mnemonicsPassword: "", language: .english),
							let keyData = try? JSONEncoder().encode(keystore.keystoreParams),
							let address = keystore.addresses?.first?.address else {
					throw NSError(domain: "Create Wallet", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to create wallet"])
				}
				
				let wallet = Wallet(address: address, data: keyData, name: Constants.name, isHD: true)
				
				DispatchQueue.main.async {
					self.walletAddressLabel.text = wallet.address
					self.phraseLabel.text = mnemonics
					self.sharedUtils.hideLoader()
				}
			} catch {
				self.handleCreateWalletError(error)
			}
		}
	}
	
	func copyToClipboard(text: String?) {
		guard let text = text else { return }
		UIPasteboard.general.string = text
	}
	
	func handleCreateWalletError(_ error: Error) {
		DispatchQueue.main.async {
			self.sharedUtils.hideLoader()
			self.showAlert(title: "Error", message: error.localizedDescription)
		}
	}
	
	func showAlert(title: String, message: String) {
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
			self.sharedUtils.showAlert(title: title, message: message, viewController: self)
		}
	}	
	
	
}
