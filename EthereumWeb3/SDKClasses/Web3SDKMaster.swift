//
//  Web3SDKMaster.swift
//  EthereumWeb3
//
//  Created by Prakash Kotwal on 04/05/2024.
//
import web3swift
import Web3Core
import Foundation
import BigInt

class Web3SDKMaster {
	// Singleton instance
	static let shared = Web3SDKMaster()
	
	// Web3 instance
	private var web3: Web3?
	
	// Managers
	private let walletManager = WalletManager()
	private let transactionManager = TransactionManager()
	private let networkManager = NetworkManager()
	
	// Private initializer for singleton pattern
	private init() {}
	
	/// Set up Web3 instance with provided provider URL
	///
	/// - Parameter providerURL: The URL of the provider
	func setUpWeb3(providerURL: URL, completion: @escaping (SDKResponse) -> Void) {
		Task{
			do {
				web3 = try await Web3.new(providerURL)
				completion(SDKResponse(success: true, message: "Web3 setup successful", error: nil))
			} catch {
				completion(SDKResponse(success: false, message: "Failed to set up Web3", error: error))
			}
		}
	}

	/**
	 Function to generate a KeystoreManager from a private key.
	 - Parameters:
			- privateKey: The private key as a hexadecimal string.
			- completion: A closure to be called upon completion, returning an SDKResponse and the KeystoreManager if successful.
									The SDKResponse indicates whether the operation was successful or not, along with an error message if applicable.
									The KeystoreManager contains the generated keystore for the private key.

	 - Note: The private key is expected to be in hexadecimal format.
	 */
	func getKeyStoreManager(password : String, privateKey: String, completion: @escaping (SDKResponse, KeystoreManager?) -> Void) {
		let formattedKey = privateKey.trimmingCharacters(in: .whitespacesAndNewlines)
		guard let dataKey = Data.fromHex(formattedKey) else {
			completion(SDKResponse(success: false, message: "Invalid private key format", error: nil), nil)
			return
		}
		
		do {
			guard let keyStore = try EthereumKeystoreV3(privateKey: dataKey, password: password) else {
				completion(SDKResponse(success: false, message: "Can not generate Keystore", error: nil), nil)
				return
			}
			let keyData = try JSONEncoder().encode(keyStore.keystoreParams)
			guard let _ = keyStore.addresses?.first?.address else {
				completion(SDKResponse(success: false, message: "Address not found", error: nil), nil)
				return
			}
			
//			let wallet = Wallet(address: address, data: keyData, name: walletName, isHD: false)
			
			Task {
//				do {
					
					let keystoreManager: KeystoreManager
//					if wallet.isHD {
//						let keystore = BIP32Keystore(keyData)!
//						keystoreManager = KeystoreManager([keystore])
//					} else {
						let keystore = EthereumKeystoreV3(keyData)!
						keystoreManager = KeystoreManager([keystore])
//					}
					
					completion(SDKResponse(success: true, message: "KeystoreManager created successfully", error: nil), keystoreManager)
//				} catch {
//					completion(SDKResponse(success: false, message: "Failed to create KeystoreManager", error: error), nil)
//				}
			}
		} catch {
			completion(SDKResponse(success: false, message: "Failed to generate Keystore from private key", error: error), nil)
		}	
	}

	func setKeyStoreManager(keystoreManager : KeystoreManager, completion: @escaping (SDKResponse) -> Void) {
		guard let web3 = web3 else {
			let response = SDKResponse(success: false, message: "KeystoreManager not Set up and the reason is web3 is not setup yet", error: nil)
			completion(response)
			return
		}
		web3.addKeystoreManager(keystoreManager)
		let response = SDKResponse(success: true, message: "KeystoreManager Set up Successfully", error: nil)
		completion(response)
	}

	
	/// Create a new wallet
	///
	/// - Parameter completion: Completion handler returning SDKResponse and mnemonics string
	func createWallet(completion: @escaping (SDKResponse, String?) -> Void) {
		walletManager.createWallet(completion: completion)
	}
	
	/// Fetch address from mnemonics
	///
	/// - Parameters:
	///   - mnemonics: Mnemonics string
	///   - completion: Completion handler returning SDKResponse and Wallet
	func fetchAddress(mnemonics: String, completion: @escaping (SDKResponse, Wallet?) -> Void) {
		walletManager.fetchAddressUsingMnemonics(mnemonics: mnemonics, completion: completion)
	}
	
	/// Get private key for a wallet
	///
	/// - Parameters:
	///   - wallet: The wallet for which private key is to be fetched
	///   - completion: Completion handler returning SDKResponse and private key string
	func getPrivateKey(wallet: Wallet, completion: @escaping (SDKResponse, String?) -> Void) {
		walletManager.getPrivateKey(wallet: wallet, completion: completion)
	}
	
	/// Get balance for a wallet address
	///
	/// - Parameters:
	///   - address: Ethereum address
	///   - keystoreManager: Keystore manager
	///   - completion: Completion handler returning SDKResponse and balance amount
	func getBalance(for address: EthereumAddress, completion: @escaping (SDKResponse, BigUInt?) -> Void) {
		guard let web3 = web3 else {
			let response = SDKResponse(success: false, message: "Web3 not initialized", error: nil)
			completion(response, nil)
			return
		}
		walletManager.fetchBalance(web3: web3, walletAddress: address) { response, balance in
			
			completion(response, balance)
		}
	}
	
	/// Perform a transaction
	///
	/// - Parameters:
	///   - fromAddress: Sender's Ethereum address
	///   - toAddress: Recipient's Ethereum address
	///   - amount: Amount to send
	///   - completion: Completion handler returning SDKResponse and transaction sending result
	func doTransaction(fromAddress: EthereumAddress, toAddress: EthereumAddress, amount: BigUInt, completion: @escaping (SDKResponse, TransactionSendingResult?) -> Void) {
		guard let web3 = web3 else {
			let response = SDKResponse(success: false, message: "Web3 is not initialized", error: nil)
			completion(response, nil)
			return
		}
		transactionManager.doTransaction(web3: web3, from: fromAddress, to: toAddress, amount: amount) { response, txnSendingResult in
			completion(response, txnSendingResult)
		}
	}
	
	/// Get Ethereum address from private key
	///
	/// - Parameters:
	///   - privateKey: Private key string
	///   - completion: Completion handler returning SDKResponse and Ethereum address
	func getAddressFromPrivateKey(password : String, privateKey: String, completion: @escaping (SDKResponse, EthereumAddress?) -> Void) {
		networkManager.getAddressFromPrivateKey(password: password, privateKey: privateKey) { response, address in
			completion(response, address)
		}
	}
}
