//
//  GanacheHelper.swift
//  EthereumWeb3
//
//  Created by Prakash Kotwal on 06/05/2024.
//

import Foundation
import web3swift
import Web3Core
import BigInt

class GanacheHelper{
	let sharedSDK = Web3SDKMaster.shared
	let privateKey1 = GanacheConstants().privateKey1
	let privateKey2 = GanacheConstants().privateKey2
	
	func fetchAddresses(completion: @escaping (SDKResponse, EthereumAddress?, EthereumAddress?) -> Void) {
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
							completion(error!, nil, nil)
							return
					}
					
					guard let address1 = address1, let address2 = address2 else {
							completion(SDKResponse(success: false, message: "Failed to get one or more addresses", error: nil), nil, nil)
							return
					}

					// Both addresses fetched successfully, proceed with the transaction
				completion(SDKResponse(success: true, message: "fetched both addresses", error: nil), address1, address2)
			}
	}
	
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
}
