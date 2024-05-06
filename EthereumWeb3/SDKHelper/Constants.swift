//
//  Constants.swift
//  EthereumWeb3
//
//  Created by Prakash Kotwal on 02/05/2024.
//

import UIKit
struct Constants {
	static let name = "Web3TestPrakash"
	static let password = "web3swift" // Recommend using the password set by the user.
	let AlchemyURL = AlchemyConstants().AlchemyURL
	let ganacheURL = GanacheConstants().url
	static let bitsOfEntropy = 128 // Entropy is a measure of password strength.
	static var useAlchemyServer: Bool {
		get {
			return UserDefaults.standard.bool(forKey: "UseAlchemyServer")
		}
		set {
			UserDefaults.standard.set(newValue, forKey: "UseAlchemyServer")
		}
	}	
}
