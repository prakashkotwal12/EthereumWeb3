//
//  SDKMain.swift
//  EthereumWeb3
//
//  Created by Prakash Kotwal on 04/05/2024.
//

import Foundation
import Foundation
import web3swift
import Web3Core
import BigInt

class SDKHelper {
	let sharedSDK = Web3SDKMaster.shared
	let privateKey1 = GanacheConstants().privateKey1
	var keystoreManager: KeystoreManager!
	
	/// Set up Web3 SDK.
	/// - Parameter completion: A closure to call upon completion. Receives an `SDKResponse`.
	func setUpWeb3(completion: @escaping (SDKResponse) -> Void) {
		let isLocalServerEnabled = Constants.useLocalServer
		var urlString = Constants().AlchemyURL
		if isLocalServerEnabled{
			urlString = Constants().ganacheURL
		}
		 
		guard let url = URL(string: urlString) else {
			completion(SDKResponse(success: false, message: "Error while setting up URL", error: nil))
			return
		}
		sharedSDK.setUpWeb3(providerURL: url) { response in
			if response.success {
				print("Web3 Setup done")
				completion(SDKResponse(success: true, message: "Setup done", error: nil))
			} else {
				completion(SDKResponse(success: false, message: "Error setting up SDK", error: response.error))
			}
		}
	}
	
	/// Set up keystore manager.
	/// - Parameters:
	///   - key: The private key.
	///   - completion: A closure to call upon completion. Receives an `SDKResponse`.
	func setUpKeyStoreManager(key: String, completion: @escaping (SDKResponse) -> Void) {
		sharedSDK.getKeyStoreManager(password: Constants.password, privateKey: key) { response, keystore in
			if response.success {
				guard let keystoreManager = keystore else {
					completion(SDKResponse(success: false, message: response.message, error: nil))
					return
				}
				self.keystoreManager = keystoreManager
				self.sharedSDK.setKeyStoreManager(keystoreManager: keystoreManager) { response in
					if response.success {
						print("Keystoremanager set up done")
						completion(SDKResponse(success: true, message: response.message, error: nil))
					} else {
						completion(SDKResponse(success: false, message: response.message, error: nil))
					}
				}
			} else {
				completion(SDKResponse(success: false, message: response.message, error: nil))
			}
		}
	}
	
	/// Perform a local transaction.
	/// - Parameters:
	///   - amount: The amount to transfer.
	///   - completion: A closure to call upon completion. Receives an `SDKResponse`.
	func doLocalTxn(amount: BigUInt = 100, completion: @escaping (SDKResponse) -> Void) {
		LocalTransaction().sendTxn(keystore: self.keystoreManager, amount: amount, completion: completion)
	}	
}

