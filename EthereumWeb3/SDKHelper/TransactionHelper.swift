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

class TransactionHelper {
	let sharedSDK = Web3SDKMaster.shared
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
	
	private func fetchAddressAndDoTxn(amount: BigUInt, completion: @escaping (SDKResponse, TransactionSendingResult?) -> Void) {
		GanacheHelper().fetchAddresses { response, address1, address2 in
			if response.success {
				guard let fromAddress = address1,
							let toAddress = address2 else {
					completion(SDKResponse(success: false, message: "Failed to get local addresses", error: nil), nil)
					return
				}
				self.performTransaction(from: fromAddress, to: toAddress, amount: amount, completion: completion)
			} else {
				completion(SDKResponse(success: false, message: "Failed to get local addresses", error: nil), nil)
			}
		}
		
	}

	func doAlchemyTransaction(address1 : EthereumAddress?, address2 : EthereumAddress?, amount: BigUInt, completion: @escaping (SDKResponse, TransactionSendingResult?) -> Void) {
		
		let parameters = [
			"id": 1,
			"jsonrpc": "2.0",
			"method": "alchemy_getAssetTransfers",
			"params": [
				[
					"fromAddress" : address1?.address ?? "",
					"toAddress": address2?.address ?? "",
					"withMetadata": false,
					"excludeZeroValue": true,
					"maxCount": "0x3e8"
				]
			]
		] as [String : Any?]
		do{
			Task{
				let postData = try JSONSerialization.data(withJSONObject: parameters, options: [])
				let url = URL(string: AlchemyConstants().AlchemyURL)!
				var request = URLRequest(url: url)
				request.httpMethod = "POST"
				request.timeoutInterval = 10
				request.allHTTPHeaderFields = [
					"accept": "application/json",
					"content-type": "application/json"
				]
				request.httpBody = postData
				
				do{
					let (data, _) = try await URLSession.shared.data(for: request)
					print(String(decoding: data, as: UTF8.self))
				}
				catch {
					print("error localization: \(error.localizedDescription)")
				}
			}
		}
		catch {
			print("error localization: \(error.localizedDescription)")
		}	
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
				// Check if balance of address1 is sufficient
				if balance1 ?? 0 < amount {
					completion(SDKResponse(success: false, message: "Balance is not sufficient for address 1", error: nil), nil)
					return
				}
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
			
			// Proceed with the transaction
			self.sharedSDK.doTransaction(fromAddress: address1, toAddress: address2, amount: amount) { response, result in
				completion(response, result)
			}
		}
	}
}
