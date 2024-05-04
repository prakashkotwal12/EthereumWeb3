//
//  WelcomeVC.swift
//  EthereumWeb3
//
//  Created by Prakash Kotwal on 02/05/2024.
//

import UIKit

class WelcomeVC: UIViewController {
	let sdkHelper = SDKHelper()
	let sharedUtils = SharedUtilities.shared
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Dispatch a task to a background thread
		sharedUtils.showLoader(viewController: self)
		DispatchQueue.global(qos: .background).asyncAfter(deadline: .now()) {
			self.setUpWeb3SDK()
		}

		
		// Do any additional setup after loading the view.
	}
	@IBAction func onClickCreateWallet(_ sender: UIButton) {
		self.performSegue(withIdentifier: "SegToCreate", sender: self)
	}
	@IBAction func onClickFetchWallet(_ sender: UIButton) {
//		doLocalTransfer()
		self.performSegue(withIdentifier: "SegToFetch", sender: self)
	}
	func setUpWeb3SDK() {
		Constants.useLocalServer = true
		sdkHelper.setUpWeb3 { web3Response in
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
				guard web3Response.success else {
					print("Web3 setup error: \(web3Response.message)")
					
					self.sharedUtils.hideLoader()
					return
				}
				self.setUpKeyStoreManager()
			}
		}
	}
	
	func setUpKeyStoreManager(){
		self.sdkHelper.setUpKeyStoreManager(key: self.sdkHelper.privateKey1) { keyStoreResponse in
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
				guard keyStoreResponse.success else {
					self.sharedUtils.hideLoader()
					print("KeyStore setup error: \(keyStoreResponse.message)")
					return
				}
				print("I am here")
				self.sharedUtils.hideLoader()
			}
		}
	}
	
	func doLocalTransfer(){
		sdkHelper.doLocalTxn(amount: 987) { txnResponse in
			if txnResponse.success {
				print("Transaction done")
			} else {
				print("Transaction not done: \(txnResponse.message)")
			}
		}
		
		
	}
	
	/*
	 // MARK: - Navigation
	 
	 // In a storyboard-based application, you will often want to do a little preparation before navigation
	 override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
	 // Get the new view controller using segue.destination.
	 // Pass the selected object to the new view controller.
	 }
	 */	
}
