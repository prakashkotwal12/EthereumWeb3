//
//  TransactionManager.swift
//  EthereumWeb3
//
//  Created by Prakash Kotwal on 04/05/2024.
//
import web3swift
import Web3Core
import BigInt

class TransactionManager {
	
	// Function to perform a transaction
	func doTransaction(web3: Web3, from sender: EthereumAddress, to recipient: EthereumAddress, amount: BigUInt, completion: @escaping (SDKResponse, TransactionSendingResult?) -> Void) {
		// Initialize SDKResponse
		var response = SDKResponse(success: false, message: "", error: nil)
		
		// Create transaction
		createTransaction(web3: web3, from: sender, to: recipient, amount: amount) { transaction, error in
			// Check for error
			guard let transaction = transaction else {
				response.error = error
				response.message = "Error occurred while creating transaction"
				completion(response, nil)
				return
			}
			
			// Send transaction
			self.sendTransaction(web3: web3, transaction: transaction) { success, message, error, result in
				response.success = success
				response.message = message
				response.error = error
				completion(response, result)
			}
		}
	}
	
	// Function to create a transaction
	private func createTransaction(web3: Web3, from sender: EthereumAddress, to recipient: EthereumAddress, amount: BigUInt, completion: @escaping (CodableTransaction?, Error?) -> Void) {
		Task {
			do {
				// Get nonce
				let nonce = try await web3.eth.getTransactionCount(for: sender)
				
				// Create transaction
				var transaction = CodableTransaction.emptyTransaction
				transaction.to = recipient
				transaction.from = sender
				transaction.value = amount
				transaction.nonce = nonce
				
				// Complete with transaction
				completion(transaction, nil)
			} catch {
				// Complete with error
				completion(nil, error)
			}
		}
	}
	
	// Function to send a transaction
	private func sendTransaction(web3: Web3, transaction: CodableTransaction, completion: @escaping (Bool, String, Error?, TransactionSendingResult?) -> Void) {
		Task {
			do {
				// Send transaction
				let transfer = try await web3.eth.send(transaction)
				
				// Complete with success
				completion(true, "Transaction successful", nil, transfer)
			} catch {
				// Complete with error
				completion(false, "Transaction failed", error, nil)
			}
		}
	}
	
}
