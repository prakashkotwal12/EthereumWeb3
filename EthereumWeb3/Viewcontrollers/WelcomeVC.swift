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
		self.performSegue(withIdentifier: "SegToFetch", sender: self)
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
