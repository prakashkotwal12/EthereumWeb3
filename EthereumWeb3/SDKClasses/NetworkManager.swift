//
//  NetworkManager.swift
//  EthereumWeb3
//
//  Created by Prakash Kotwal on 04/05/2024.
//
import Foundation
import web3swift
import Web3Core

class NetworkManager {
	
	func getAddressFromPrivateKey(password: String, privateKey: String, completion: @escaping (SDKResponse, EthereumAddress?) -> Void) {
		// Initialize SDKResponse
		var response = SDKResponse(success: false, message: "", error: nil)
		
		// Trim and convert private key to data
		let formattedKey = privateKey.trimmingCharacters(in: .whitespacesAndNewlines)
		guard let dataKey = Data.fromHex(formattedKey) else {
			// Invalid private key error
			response.message = "Invalid private key"
			completion(response, nil)
			return
		}
		
		// Create EthereumKeystoreV3 instance
		guard let keyStore = try? EthereumKeystoreV3(privateKey: dataKey, password: password) else {
			// Failed to create EthereumKeystoreV3 instance error
			response.message = "Failed to create EthereumKeystoreV3 instance"
			completion(response, nil)
			return
		}
		
//		 Encode keystore params
		guard let keyData = try? JSONEncoder().encode(keyStore.keystoreParams) else {
			// Failed to encode keystore params error
			response.message = "Failed to encode keystore params"
			completion(response, nil)
			return
		}
		
		guard let address = keyStore.addresses?.first?.address else {
			// Address not found error
			response.message = "Address not found"
			completion(response, nil)
			return
		}
		
//		let wallet = Wallet(address: address, data: keyData, name: walletName, isHD: false)
		
		// Return EthereumAddress and other data
		response.success = true
		response.message = "Address fetched successfully"
		completion(response, EthereumAddress(address))
	}
	
}
