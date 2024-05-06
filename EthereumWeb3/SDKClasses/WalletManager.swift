//
//  WalletManager.swift
//  EthereumWeb3
//
//  Created by Prakash Kotwal on 04/05/2024.
//
import Foundation
import web3swift
import Web3Core
import BigInt

class WalletManager {
	
	// Function to create a new wallet
	func createWallet(entropy : Int, completion: @escaping (SDKResponse, String?) -> Void) {
		
		// Perform asynchronous task
		Task {
			// Initialize SDKResponse and mnemonics
			var response = SDKResponse(success: false, message: "", error: nil)
			var mnemonics: String?
			do {
				// Generate mnemonics
				guard let newMnemonics = try BIP39.generateMnemonics(bitsOfEntropy: entropy) else {
					response.message = "Failed to create mnemonics"
					completion(response, nil)
					return
				}
				mnemonics = newMnemonics
				
				// Create keystore and wallet
//				guard let keystore = try BIP32Keystore(mnemonics: newMnemonics, password: Constants.password, mnemonicsPassword: "", language: .english),
//							let keyData = try? JSONEncoder().encode(keystore.keystoreParams),
//							let address = keystore.addresses?.first?.address 
//				else {
//					response.message = "Failed to create wallet"
//					completion(response, nil)
//					return
//				}
//				let stringFromData = String(data: keyData, encoding: .utf8)
//				print("load json", stringFromData)
//				print("check data: \(keyData)")
				
				
//				let keyData = try? JSONEncoder().encode(keystore.keystoreParams),
				// Update response and complete with mnemonics
				response.success = true
				response.message = "Wallet created successfully"
				print("generated menmonics: \(mnemonics ?? "")")
				completion(response, mnemonics)
			} catch {
				// Update response with error and complete with nil
				response.error = error
				response.message = "Failed to create wallet"
				completion(response, nil)
			}
		}
	}
	
	// Function to fetch wallet address using mnemonics
	func fetchAddressUsingMnemonics(mnemonics: String, completion: @escaping (SDKResponse, Wallet?) -> Void) {
		
		
		// Perform asynchronous task
		Task {
			// Initialize SDKResponse and wallet
			var response = SDKResponse(success: false, message: "", error: nil)
			var wallet: Wallet?
			do {
				// Create keystore and get address
				print("before keystore")
				let checkSeed = BIP39.seedFromMmemonics(mnemonics)
				print("after checkseed: \(checkSeed)")
//				let seesStore = try! BIP32Keystore.init(seed: checkSeed!, password: Constants.password)
//				print("after checkseed2: \(seesStore?.addresses?.first?.address ?? "")")
				
				
				guard let keystore = try BIP32Keystore(
					mnemonics: mnemonics,
					password: Constants.password,
					mnemonicsPassword: "",
					language: .english
				)//,
						//	let keyData = try? JSONEncoder().encode(keystore.keystoreParams),
							 else {
					response.message = "Failed to create wallet"
					completion(response, nil)
					return
				}
				print("after keystore")
				let addr = keystore.addresses?.first?.address ?? ""
				// Create wallet and update response
//				wallet = Wallet(address: addr, data: keyData, name: Constants.name, isHD: true)
				wallet = Wallet(address: addr, name: Constants.name, isHD: true)
				response.success = true
				response.message = "Address fetched successfully"
				completion(response, wallet)
			} catch {
				// Update response with error and complete with nil
				response.error = error
				response.message = "Failed to fetch address"
				completion(response, nil)
			}
		}
	}
	
	// Function to get private key for a wallet
//	func getPrivateKey(wallet: Wallet, completion: @escaping (SDKResponse, String?) -> Void) {
//		
//		// Perform asynchronous task
//		Task {
//			// Initialize SDKResponse
//			var response = SDKResponse(success: false, message: "", error: nil)
//			
//			do {
//				// Get password and data
//				let password = Constants.password
//				let data = wallet.data
//				let keystoreManager: KeystoreManager
//				
//				// Create keystore manager based on wallet type
//				if wallet.isHD {
//					guard let keystore = BIP32Keystore(data) else {
//						throw NSError(domain: "Get Private Key", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to create BIP32Keystore"])
//					}
//					keystoreManager = KeystoreManager([keystore])
//				} else {
//					guard let keystore = EthereumKeystoreV3(data) else {
//						throw NSError(domain: "Get Private Key", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to create EthereumKeystoreV3"])
//					}
//					keystoreManager = KeystoreManager([keystore])
//				}
//				
//				// Get private key data
//				let ethereumAddress = EthereumAddress(wallet.address)!
//				let pkData = try keystoreManager.UNSAFE_getPrivateKeyData(password: password, account: ethereumAddress).toHexString()
//				
//				// Update response and complete with private key
//				response.success = true
//				response.message = "Private key fetched successfully"
//				completion(response, pkData)
//			} catch {
//				// Update response with error and complete with nil
//				response.error = error
//				response.message = "Failed to fetch private key"
//				completion(response, nil)
//			}
//		}
//	}
	
	// Function to fetch balance for a wallet
	func fetchBalance(web3 : Web3, walletAddress: EthereumAddress, completion: @escaping (SDKResponse, BigUInt?) -> Void) {
		
		// Perform asynchronous task
		Task {
			// Initialize SDKResponse
			var response = SDKResponse(success: false, message: "", error: nil)
			do {
				
				// Get balance
				let balanceResult = try await web3.eth.getBalance(for: walletAddress)
				
				// Update response and complete with balance
				response.success = true
				response.message = "Balance fetched successfully"
				completion(response, balanceResult)
			} catch {
				// Update response with error and complete with nil
				response.error = error
				response.message = "Failed to fetch balance"
				completion(response, nil)
			}
		}
	}
}
