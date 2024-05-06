//
//  TransferVC.swift
//  EthereumWeb3
//
//  Created by Prakash Kotwal on 05/05/2024.
//

import UIKit

class TransferVC: UIViewController {
	@IBOutlet weak var txtAmount: UITextField!
	@IBOutlet weak var lblBalanceAddress2: UILabel!
	@IBOutlet weak var lblAddress2: UILabel!
	@IBOutlet weak var lblBalanceAddress1: UILabel!
	@IBOutlet weak var lblAddress1: UILabel!
	
	let sdkHelper = SDKHelper.sharedSDKHelper
	let ganacheHelper = LocalTransaction()
	let sharedUtils = SharedUtilities.shared
	
	var address1: String!
	var address2: String!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		updateUI()
	}
	
	@IBAction func doHideKeyboard(_ sender: Any) {
		self.view.endEditing(true)
	}
	
	func updateUI() {
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
			self.sharedUtils.showLoader(viewController: self)
		}
		if Constants.useAlchemyServer {
			self.sharedUtils.hideLoader()
			// Handle Alchemy server setup
		} else {
			DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 0.1) {
				self.getLocalAddress1()
			}
			DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 0.1) {
				self.getLocalAddress2()
			}
		}
	}
	
	func getLocalAddress1() {
		ganacheHelper.getLocalAddress1 { address in
			guard let address1 = address else {
				print("Failed to get local address 1")
				return
			}
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
				self.lblAddress1.text = "Address: " + address1.address
				self.address1 = address1.address
				self.updateBalance(for: self.lblBalanceAddress1, address: self.address1)
			}
		}
	}
	
	func updateBalance(for label: UILabel, address: String) {
		sdkHelper.getBalance(from: address) { response, balance in
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
				self.sharedUtils.hideLoader()
				if response.success {
					print("Address \(address) Balance: \(balance ?? 0)")
					label.text = "Balance: \(balance ?? 0)"
				} else {
					print("Failed to get balance for address: \(address)")
				}
			}
		}
	}
	
	func getLocalAddress2() {
		ganacheHelper.getLocalAddress2 { address in
			guard let address2 = address else {
				print("Failed to get local address 2")
				return
			}
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
				self.lblAddress2.text = "Address: " + address2.address
				self.address2 = address2.address
				self.updateBalance(for: self.lblBalanceAddress2, address: self.address2)
			}
		}
	}
	
	@IBAction func doTransfer(_ sender: Any) {
		self.view.endEditing(true)
		sharedUtils.showLoader(viewController: self)
		let numberInField = Int(txtAmount.text ?? "") ?? 0
		DispatchQueue.global(qos: .background).async {
			self.doLocalTransfer(amount: numberInField)
		}
	}
	
	func doLocalTransfer(amount: Int) {
		sdkHelper.doLocalTxn(address1: self.address1, address2: self.address2, amount: amount) { txnResponse, result in
			if txnResponse.success {
				print("Transaction done")
				self.updateBalance(for: self.lblBalanceAddress1, address: self.address1)
				self.updateBalance(for: self.lblBalanceAddress2, address: self.address2)
			} else {
				print("Transaction not done: \(txnResponse.message)")
			}
		}
	}	
}
