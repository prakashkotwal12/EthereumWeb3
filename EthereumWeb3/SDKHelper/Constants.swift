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
	let AlchemyAPIKey = "WRlCfxhHHf6cbM51qW03_o95x2SCsRX4"
	let AlchemyURL = "https://eth-mainnet.g.alchemy.com/v2/WRlCfxhHHf6cbM51qW03_o95x2SCsRX4"
	let ganacheURL = GanacheConstants().url
	static let bitsOfEntropy = 128 // Entropy is a measure of password strength.
	static var useLocalServer: Bool {
		get {
			return UserDefaults.standard.bool(forKey: "UseLocalServer")
		}
		set {
			UserDefaults.standard.set(newValue, forKey: "UseLocalServer")
		}
	}	
}
