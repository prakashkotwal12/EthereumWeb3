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
	
	/// Generates mnemonics and returns them along with an SDKResponse.
	///
	/// - Parameter completion: A closure to be called once the operation is completed, containing an SDKResponse and optional mnemonics string.
	func getMnemonics(completion: @escaping (SDKResponse, String?, Wallet?) -> Void) {
		sharedSDK.createWallet { response, mnemonics in
			if response.success {
				print("Mnemonics: \(mnemonics ?? "")")
				self.getAddress(from: mnemonics ?? "") { responseFromAddress, wallet in
					if responseFromAddress.success {
						print("Get Address from mnemonics: \(wallet?.address ?? "")")
					} else {
						print("Error while getting address from mnemonics: \(responseFromAddress.message)")
					}
					completion(response, mnemonics, wallet)
				}
			} else {
				print("Error getting Mnemonics")
				completion(response, nil, nil)
			}
		}
		
	}
	
	/// Retrieves the wallet address associated with the given mnemonics.
	///
	/// - Parameters:
	///   - mnemonics: The mnemonics string.
	///   - completion: A closure to be called once the operation is completed, containing an SDKResponse and optional Wallet object.
	func getAddress(from mnemonics: String, completion: @escaping (SDKResponse, Wallet?) -> Void) {
		sharedSDK.fetchAddress(mnemonics: mnemonics) { response, wallet in
			if response.success {
				print("Wallet Address: \(wallet?.address ?? "")")
			} else {
				print("Error getting Wallet Address")
			}
			completion(response, wallet)
		}
	}
	
	func getBalance(from address: String, completion: @escaping (SDKResponse, BigUInt?) -> Void) {
		
		sharedSDK.getBalance(for: EthereumAddress(address)!) { response, balance in
			if response.success{
				print("Availbale balance is : \(balance ?? 0)")
			}
			completion(response, balance)
		}
	}
}

