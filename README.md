# Distributed-Exchanges-DEX-Contract-Solidity
This contract is a Simple Decentralized Exchange (DEX) implemented in Solidity, allowing users to trade ERC20 tokens and Ether (ETH). Here's a breakdown of its functionality:

Interface Definition (IERC20): This interface defines standard functions for ERC20 tokens.

SimpleDEX Contract: The main contract SimpleDEX implements the DEX functionality.

Order Struct: Defines the structure of an order, containing details like order ID, trader's address, whether it's a buy or sell order, token being traded, amount, price, and filled amount.

State Variables:

nextOrderId: Tracks the ID for the next order.
orders: Maps order IDs to their respective orders.
balances: Maps user addresses to their token balances.
Events:

NewOrder: Triggered when a new order is created.
CancelOrder: Triggered when an order is canceled.
Trade: Triggered when a trade occurs.
Functions:

deposit: Allows users to deposit ERC20 tokens into the DEX.
withdraw: Allows users to withdraw ERC20 tokens from the DEX.
createOrder: Allows users to create buy or sell orders.
cancelOrder: Allows traders to cancel their own unfilled orders.
matchOrders: Matches buy and sell orders, executing trades.
min: Private function to find the minimum of two numbers.
Modifiers & Error Handling:

Functions use require statements to ensure conditions are met before executing.
License Identifier:

The contract starts with a SPDX license identifier (MIT), indicating the licensing terms.
Overall, this contract provides a basic DEX functionality for trading ERC20 tokens and Ether in a decentralized manner. Users can deposit tokens, create orders, match orders, and withdraw tokens.
