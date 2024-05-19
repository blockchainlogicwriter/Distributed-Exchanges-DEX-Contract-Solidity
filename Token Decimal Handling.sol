function getTokenDecimals(IERC20 _token) public view returns (uint8) {
    return _token.decimals();
}
