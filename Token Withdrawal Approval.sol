mapping(address => mapping(IERC20 => bool)) public withdrawalApprovals;

function approveTokenWithdrawal(IERC20 _token) public {
    withdrawalApprovals[msg.sender][_token] = true;
}
