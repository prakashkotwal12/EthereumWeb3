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
		getBalance()
	}
	func getBalance(){
		sharedUtils.showLoader(viewController: self)
		guard let address = wallet?.address else{
			print("Address not added in wallet")
			sharedUtils.hideLoader()
			return
		}
		SDKHelper().getBalance(from: address) { response, balance in
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
				self.sharedUtils.hideLoader()
				if response.success{
					guard let amount = balance else{
						return
					}
					self.walletBalanceLabel.text = "Balance: \(amount)"
				}
				else{
					print("Error in fetching balance: \(response.message)")
				}
			}
		}
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
		SDKHelper().getAddress(from: mnemonics) { response, wallet in
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
				if response.success{
					let address = wallet?.address ?? ""
					print("Address fetched: \(address)")
					self.wallet = wallet
					self.walletAddressLabel.text = address
					print("Address fetched after: \(self.walletAddressLabel.text!)")
				}
				else{
					print("Error in fetching Address: \(response.message)")
				}
				self.sharedUtils.hideLoader()
			}
		}
	}
	
	func handleFetchError(_ error: Error) {
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
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

