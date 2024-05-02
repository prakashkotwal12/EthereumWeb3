//
//  FetchWalletVC.swift
//  TestPortalLab
//
//  Created by Prakash Kotwal on 01/05/2024.
//

import UIKit
import Web3Core
import web3swift

class FetchWalletVC: UIViewController {
	
	@IBOutlet weak var walletBalanceLabel: UILabel!
	@IBOutlet weak var walletAddressLabel: UILabel!
	@IBOutlet weak var walletPhraseTextView: UITextView!
	
	let sharedUtils = SharedUtilities.shared
	var wallet: Wallet?
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	@IBAction func onClickFetchBalance(_ sender: UIButton) {
		getPrivateKey()
	}
	
	@IBAction func onClickFetchAddress(_ sender: UIButton) {
		fetchAddressUsingMnemonics()
	}
	
	@IBAction func onClickPastePhrase(_ sender: UIButton) {
		if let copiedText = UIPasteboard.general.string {
			walletPhraseTextView.text = copiedText
		} else {
			print("No text found in the pasteboard.")
		}
	}
	
	func fetchAddressUsingMnemonics() {
		guard let mnemonics = walletPhraseTextView.text else {
			showAlert(title: "Error", message: "Mnemonics is empty")
			return
		}
		
		sharedUtils.showLoader(viewController: self)
		DispatchQueue.global().async {
			do {
				guard let keystore = try BIP32Keystore(
					mnemonics: mnemonics,
					password: Constants.password,
					mnemonicsPassword: "",
					language: .english
				),
							let keyData = try? JSONEncoder().encode(keystore.keystoreParams),
							let address = keystore.addresses?.first?.address else {
					throw NSError(domain: "Fetch Address", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to create wallet"])
				}
				
				self.wallet = Wallet(address: address, data: keyData, name: Constants.name, isHD: true)
				
				DispatchQueue.main.async {
					self.walletAddressLabel.text = self.wallet?.address
					self.sharedUtils.hideLoader()
				}
			} catch {
				self.handleFetchError(error)
			}
		}
	}
	
	func getPrivateKey() {
		guard let wallet = wallet else {
			showAlert(title: "Error", message: "Wallet not created yet")
			return
		}
		
		sharedUtils.showLoader(viewController: self)
		DispatchQueue.global().async {
			do {
				let password = Constants.password
				let data = wallet.data
				let keystoreManager: KeystoreManager
				if wallet.isHD {
					let keystore = BIP32Keystore(data)!
					keystoreManager = KeystoreManager([keystore])
				} else {
					let keystore = EthereumKeystoreV3(data)!
					keystoreManager = KeystoreManager([keystore])
				}
				
				let ethereumAddress = EthereumAddress(wallet.address)!
				let pkData = try keystoreManager.UNSAFE_getPrivateKeyData(password: password, account: ethereumAddress).toHexString()
				print("pkdata: \(dump(pkData))")
				
				DispatchQueue.main.async {
					self.fetchBalance(keystoreManager: keystoreManager)
				}
			} catch {
				self.handleFetchError(error)
			}
		}
	}
	
	func fetchBalance(keystoreManager: KeystoreManager) {
		Task {
			do {
				let web3 = try await Web3.InfuraMainnetWeb3()
				web3.addKeystoreManager(keystoreManager)
				
				guard let walletAddress = EthereumAddress(self.walletAddressLabel.text ?? "") else {
					throw NSError(domain: "Fetch Balance", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid wallet address"])
				}
				
				let balanceResult = try await web3.eth.getBalance(for: walletAddress)
				
				DispatchQueue.main.async {
					self.walletBalanceLabel.text = "Balance: \(balanceResult)"
					self.sharedUtils.hideLoader()
				}
			} catch {
				self.handleFetchError(error)
			}
		}
	}
	
	func handleFetchError(_ error: Error) {
		DispatchQueue.main.async {
			print("Error fetching data: \(error.localizedDescription)")
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

