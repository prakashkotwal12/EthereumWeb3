//
//  WelcomeVC.swift
//  EthereumWeb3
//
//  Created by Prakash Kotwal on 02/05/2024.
//

import UIKit

class WelcomeVC: UIViewController {
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Do any additional setup after loading the view.
	}
	@IBAction func onClickCreateWallet(_ sender: UIButton) {
		self.performSegue(withIdentifier: "SegToCreate", sender: self)
	}
	@IBAction func onClickFetchWallet(_ sender: UIButton) {
		doLocalTransfer()
//		self.performSegue(withIdentifier: "SegToFetch", sender: self)
	}
	func doLocalTransfer(){
		let sdkHelper = SDKHelper()
		Constants.useLocalServer = true
		sdkHelper.setUpWeb3 { web3Response in
			guard web3Response.success else {
				print("Web3 setup error: \(web3Response.message)")
				return
			}
			
			sdkHelper.setUpKeyStoreManager(key: sdkHelper.privateKey1) { keyStoreResponse in
				guard keyStoreResponse.success else {
					print("KeyStore setup error: \(keyStoreResponse.message)")
					return
				}
				
				sdkHelper.doLocalTxn(amount: 987) { txnResponse in
					if txnResponse.success {
						print("Transaction done")
					} else {
						print("Transaction not done: \(txnResponse.message)")
					}
				}
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
