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
	///
	
	func sendTxn(address1 : EthereumAddress?, address2 : EthereumAddress?, amount: BigUInt, completion: @escaping (SDKResponse, TransactionSendingResult?) -> Void) {
		guard let fromAddress = address1, let toAddress = address2 else{
			fetchAddressAndDoTxn(amount: amount, completion: completion)
			return
		}
		performTransaction(from: fromAddress, to: toAddress, amount: amount, completion: completion)
		
	}
	
	private func performTransaction(from address1: EthereumAddress, to address2: EthereumAddress, amount: BigUInt, completion: @escaping (SDKResponse, TransactionSendingResult?) -> Void) {
		let group = DispatchGroup()
		var balance1: BigUInt?
		var balance2: BigUInt?
		var error1: Error?
		var error2: Error?
		
		// Fetch balance for address1
		group.enter()
		sharedSDK.getBalance(for: address1) { response, balance in
			if response.success {
				balance1 = balance
			} else {
				error1 = response.error
			}
			group.leave()
		}
		
		// Fetch balance for address2
		group.enter()
		sharedSDK.getBalance(for: address2) { response, balance in
			if response.success {
				balance2 = balance
			} else {
				error2 = response.error
			}
			group.leave()
		}
		
		group.notify(queue: .main) {
			// Check if both balances are fetched successfully
			guard let balance1 = balance1, let balance2 = balance2 else {
				completion(SDKResponse(success: false, message: "Failed to get balance for one or more addresses", error: nil), nil)
				return
			}
			
			// Check if balance of address1 is sufficient
			if balance1 < amount {
				completion(SDKResponse(success: false, message: "Balance is not sufficient for address 1", error: nil), nil)
				return
			}
			
			// Proceed with the transaction
			self.sharedSDK.doTransaction(fromAddress: address1, toAddress: address2, amount: amount) { response, result in
				completion(response, result)
			}
		}
	}
	
	private func fetchAddressAndDoTxn(amount: BigUInt, completion: @escaping (SDKResponse, TransactionSendingResult?) -> Void) {
			let dispatchGroup = DispatchGroup()
			var address1: EthereumAddress?
			var address2: EthereumAddress?
			var error: SDKResponse?

			// Fetch address1
			dispatchGroup.enter()
			getLocalAddress1 { fetchedAddress1 in
					if let fetchedAddress1 = fetchedAddress1 {
							address1 = fetchedAddress1
					} else {
							error = SDKResponse(success: false, message: "Failed to get local address 1", error: nil)
					}
					dispatchGroup.leave()
			}

			// Fetch address2
			dispatchGroup.enter()
			getLocalAddress2 { fetchedAddress2 in
					if let fetchedAddress2 = fetchedAddress2 {
							address2 = fetchedAddress2
					} else {
							error = SDKResponse(success: false, message: "Failed to get local address 2", error: nil)
					}
					dispatchGroup.leave()
			}

			// Notify when both addresses are fetched or if there's an error
			dispatchGroup.notify(queue: .global()) {
					guard error == nil else {
							completion(error!, nil)
							return
					}
					
					guard let address1 = address1, let address2 = address2 else {
							completion(SDKResponse(success: false, message: "Failed to get one or more addresses", error: nil), nil)
							return
					}

					// Both addresses fetched successfully, proceed with the transaction
				self.performTransaction(from: address1, to: address2, amount: amount, completion: completion)
			}
	}


}
