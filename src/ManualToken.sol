// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;

contract ManualToken {
    // error TransferFailed();

    mapping(address => uint256) private s_balances;

    function name() public pure returns (string memory) {
        return "ManualToken";
    }

    function decimals() public pure returns (uint8) {
        return 18;
    }

    function totalSupply() public pure returns (uint256) {
        return 100 ether;
    }

    function balanceOf(address _owner) public view returns (uint256) {
        return s_balances[_owner];
    }

    function transfer(address _to, uint256 _amount) public {
        uint256 previousBalances = balanceOf(msg.sender) + balanceOf(_to);
        s_balances[msg.sender] -= _amount;
        s_balances[_to] += _amount;

        // if (previousBalances == balanceOf(msg.sender) + balanceOf(_to)) {
        //     revert TransferFailed();
        // }

        require(
            previousBalances == balanceOf(msg.sender) + balanceOf(_to),
            "ManualToken: transfer failed"
        );
    }
}
