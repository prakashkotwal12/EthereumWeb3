//
//  WelcomeVC.swift
//  EthereumWeb3
//
//  Created by Prakash Kotwal on 02/05/2024.
//

import UIKit

class WelcomeVC: UIViewController {
	let sdkHelper = SDKHelper.sharedSDKHelper
	let sharedUtils = SharedUtilities.shared
	
	@IBOutlet weak var lblSelectServer: UILabel!
	@IBOutlet weak var serverSelection: UISegmentedControl!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		serverSelection.selectedSegmentIndex = Constants.useAlchemyServer ? 1 : 0
//		serverSelection.isHidden = true
//		lblSelectServer.isHidden = true
		// Dispatch a task to a background thread
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
			self.sharedUtils.showLoader(viewController: self)
		}
		DispatchQueue.global(qos: .background).asyncAfter(deadline: .now()) {
			self.setUpWeb3SDK()
		}
	}
	
	@IBAction func onClickCreateWallet(_ sender: UIButton) {
		self.performSegue(withIdentifier: "SegToCreate", sender: self)
	}
	@IBAction func onClickFetchWallet(_ sender: UIButton) {
		self.performSegue(withIdentifier: "SegToFetch", sender: self)
	}
	
	@IBAction func doShowTransferVC(_ sender: Any) {
		self.performSegue(withIdentifier: "SegToTransfer", sender: self)
	}
	@IBAction func doChangeServer(_ sender: Any) {
		Constants.useAlchemyServer = serverSelection.selectedSegmentIndex == 1
		self.sharedUtils.showLoader(viewController: self)
		setUpWeb3SDK()
	}
	
	
	func setUpWeb3SDK() {
		sdkHelper.setUpWeb3 { web3Response in
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
				guard web3Response.success else {
					print("Web3 setup error: \(web3Response.message)")
					
					self.sharedUtils.hideLoader()
					return
				}
				self.sharedUtils.hideLoader()
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
