# EthereumWeb3
iOS App demonstrating Ethereum Wallet functionality.

This app is designed for macOS and showcases the functionality of an Ethereum Wallet. For demonstration purposes, it utilizes the Ganache local server, providing flexibility in handling various coins and an easy-to-use transfer interface.


To install Ganache, follow these steps:[GitHub](https://github.com/trufflesuite/ganache).

1. Open Terminal and install Ganache globally:
   $ npm install ganache --global

2. Run Ganache:
   $ ganache


Once Ganache is running, you'll find the generated address and private keys in the Terminal.

The app features three main buttons:

1. **Create Wallet**: Generates a new mnemonic, allowing you to fetch the corresponding address.
2. **Fetch Wallet**: Retrieves the address from a copied phrase and fetches the balance associated with that address.
3. **Transfer Balance**: Initiates a transfer. To perform the transfer, use the addresses provided by Ganache. Ensure to use Address1 and Address2 from the GanacheConstants file and add these constant values from the Terminal after running the Ganache server.
