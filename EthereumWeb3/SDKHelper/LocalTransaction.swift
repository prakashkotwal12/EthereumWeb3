//
//  LocalTransaction.swift
//  EthereumWeb3
//
//  Created by Prakash Kotwal on 04/05/2024.
//

import Foundation
import web3swift
import Web3Core
import BigInt

class LocalTransaction {
	let sharedSDK = Web3SDKMaster.shared
	let privateKey1 = GanacheConstants().privateKey1
	let privateKey2 = GanacheConstants().privateKey2
	
	/// Get the local address 1.
	/// - Parameter completion: A closure to call upon completion. Receives an `EthereumAddress`.
	func getLocalAddress1(completion: @escaping (EthereumAddress?) -> Void) {
		sharedSDK.getAddressFromPrivateKey(password: Constants.password, privateKey: privateKey1) { response, address in
			if response.success {
				completion(address)
			} else {
				completion(nil)
			}
		}
	}
	
	/// Get the local address 2.
	/// - Parameter completion: A closure to call upon completion. Receives an `EthereumAddress`.
	func getLocalAddress2(completion: @escaping (EthereumAddress?) -> Void) {
		sharedSDK.getAddressFromPrivateKey(password: Constants.password, privateKey: privateKey2) { response, address in
			if response.success {
				completion(address)
			} else {
				completion(nil)
			}
		}
	}
	
	/// Send a transaction.
	/// - Parameters:
	///   - keystore: The keystore manager.
	///   - amount: The amount to transfer.
	///   - completion: A closure to call upon completion. Receives an `SDKResponse`.
	func sendTxn(keystore: KeystoreManager, amount: BigUInt, completion: @escaping (SDKResponse) -> Void) {
		getLocalAddress1 { address1 in
			guard let address1 = address1 else {
				completion(SDKResponse(success: false, message: "Failed to get local address 1", error: nil))
				return
			}
			print("Fetched Address1: \(address1)")
			self.sharedSDK.getBalance(for: address1, keystoreManager: keystore) { response, balance in
				if response.success {
					let balanceInAddress1 = balance ?? 0
					if balanceInAddress1 < amount{
						completion(SDKResponse(success: false, message: "Balance is not sufficient.", error: nil))
						return
					}
					print("Address1 Balance: \(balance ?? 0)")
					self.getLocalAddress2 { address2 in
						guard let address2 = address2 else {
							completion(SDKResponse(success: false, message: "Failed to get local address 2", error: nil))
							return
						}
						print("Fetched Address2: \(address2)")
						self.sharedSDK.getBalance(for: address2, keystoreManager: keystore) { response, balance2 in
							if response.success {
								print("Address2 Balance: \(balance ?? 0)")
								self.sharedSDK.doTransaction(fromAddress: address1, toAddress: address2, amount: amount) { response, result in
									completion(response)
								}
							} else {
								completion(SDKResponse(success: false, message: "Failed to get balance for address 2", error: nil))
							}
						}
					}
				} else {
					completion(SDKResponse(success: false, message: "Failed to get balance for address 1", error: nil))
				}
			}
		}
	}	
}
