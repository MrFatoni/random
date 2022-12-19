//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.6.12;

pragma experimental ABIEncoderV2;

interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}

interface IWETH is IERC20 {
    function deposit() external payable;
    function withdraw(uint) external;
}


contract rawr {
    address private immutable owner;
    IWETH private constant WETH = IWETH(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    uint256 minimalopit = 0.01 ether;


    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    constructor() public payable {
        owner = msg.sender;
        if (msg.value > 0) {
            WETH.deposit{value: msg.value}();
        }
    }

    receive() external payable {
    }

    function rawrexecute(uint256 _weth, address[] memory _to, bytes[] memory datae) external onlyOwner payable {
        require (_to.length == datae.length);
        uint256 ETHawal = WETH.balanceOf(address(this));
        WETH.transfer(_to[0], _weth);
        for (uint256 i = 0; i < _to.length; i++) {
            (bool _success, bytes memory _return) = _to[i].call(datae[i]);
            require(_success); _return;
        }
        
        uint256 ETHakhir = WETH.balanceOf(address(this));
        require(ETHakhir > ETHawal + minimalopit);
        if (minimalopit == 0) return;

        uint256 _ethBalance = address(this).balance;
        if (_ethBalance < minimalopit) {
            WETH.withdraw(minimalopit - _ethBalance);
        }
        //hasil / minimalopit disimpen di kontrak aja y
    }

    function call(address payable _to, uint256 _value, bytes calldata _data) external onlyOwner payable returns (bytes memory) {
        require(_to != address(0));
        (bool _success, bytes memory _result) = _to.call{value: _value}(_data);
        require(_success);
        return _result;
    }
}
