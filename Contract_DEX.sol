// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract SimpleDEX {
    struct Order {
        uint256 id;
        address trader;
        bool isBuyOrder;
        IERC20 token;
        uint256 amount;
        uint256 price; // price in wei per token unit
        uint256 filled;
    }

    uint256 public nextOrderId;
    mapping(uint256 => Order) public orders;
    mapping(address => mapping(IERC20 => uint256)) public balances;
    
    event NewOrder(
        uint256 id,
        address trader,
        bool isBuyOrder,
        address token,
        uint256 amount,
        uint256 price
    );

    event CancelOrder(
        uint256 id,
        address trader,
        bool isBuyOrder,
        address token,
        uint256 amount,
        uint256 price
    );

    event Trade(
        uint256 orderId,
        address trader,
        bool isBuyOrder,
        address token,
        uint256 amount,
        uint256 price
    );

    function deposit(IERC20 token, uint256 amount) public {
        require(token.transferFrom(msg.sender, address(this), amount), "Transfer failed");
        balances[msg.sender][token] += amount;
    }

    function withdraw(IERC20 token, uint256 amount) public {
        require(balances[msg.sender][token] >= amount, "Insufficient balance");
        balances[msg.sender][token] -= amount;
        require(token.transfer(msg.sender, amount), "Transfer failed");
    }

    function createOrder(bool isBuyOrder, IERC20 token, uint256 amount, uint256 price) public {
        if (isBuyOrder) {
            require(balances[msg.sender][IERC20(address(0))] >= amount * price, "Insufficient ETH balance");
        } else {
            require(balances[msg.sender][token] >= amount, "Insufficient token balance");
        }

        orders[nextOrderId] = Order(nextOrderId, msg.sender, isBuyOrder, token, amount, price, 0);
        emit NewOrder(nextOrderId, msg.sender, isBuyOrder, address(token), amount, price);
        nextOrderId++;
    }

    function cancelOrder(uint256 orderId) public {
        Order storage order = orders[orderId];
        require(order.trader == msg.sender, "Only the trader can cancel the order");
        require(order.filled == 0, "Order is already filled");

        emit CancelOrder(orderId, msg.sender, order.isBuyOrder, address(order.token), order.amount, order.price);
        delete orders[orderId];
    }

    function matchOrders(uint256 buyOrderId, uint256 sellOrderId) public {
        Order storage buyOrder = orders[buyOrderId];
        Order storage sellOrder = orders[sellOrderId];

        require(buyOrder.isBuyOrder, "First order must be a buy order");
        require(!sellOrder.isBuyOrder, "Second order must be a sell order");
        require(buyOrder.token == sellOrder.token, "Token mismatch");
        require(buyOrder.price >= sellOrder.price, "Price mismatch");
        require(buyOrder.amount > buyOrder.filled, "Buy order already filled");
        require(sellOrder.amount > sellOrder.filled, "Sell order already filled");

        uint256 tradeAmount = min(buyOrder.amount - buyOrder.filled, sellOrder.amount - sellOrder.filled);
        uint256 tradePrice = sellOrder.price;

        buyOrder.filled += tradeAmount;
        sellOrder.filled += tradeAmount;

        uint256 tradeValue = tradeAmount * tradePrice;

        balances[buyOrder.trader][IERC20(address(0))] -= tradeValue;
        balances[sellOrder.trader][IERC20(address(0))] += tradeValue;

        balances[sellOrder.trader][sellOrder.token] -= tradeAmount;
        balances[buyOrder.trader][buyOrder.token] += tradeAmount;

        emit Trade(buyOrderId, buyOrder.trader, true, address(buyOrder.token), tradeAmount, tradePrice);
        emit Trade(sellOrderId, sellOrder.trader, false, address(sellOrder.token), tradeAmount, tradePrice);
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }
}
