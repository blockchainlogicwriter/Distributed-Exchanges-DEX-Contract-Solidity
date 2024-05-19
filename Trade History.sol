struct Trade {
    uint256 buyOrderId;
    uint256 sellOrderId;
    uint256 amount;
    uint256 price;
    uint256 timestamp;
}

mapping(uint256 => Trade) public trades;
uint256 public totalTrades;
