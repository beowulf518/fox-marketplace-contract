// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "./FoxNFT.sol";


contract FOX {
    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {}
    function approve(address spender, uint256 amount) public returns (bool) {}
    function transfer(address recipient, uint256 amount) public returns (bool) {}
    function allowance(address owner, address spender) public view returns (uint256) {}
}

contract Marketplace is AccessControl {

    int maxQuantity = 10;

    struct FoxProd {
        string name;
        string description;
        int price;
        int quantity;
        uint8 flag;
    }
    
    bytes32 public constant PRODUCE_ROLE = keccak256("PRODUCE_ROLE");
    
    mapping (string => FoxProd) public foxProds;
    string [] hashes;
    
    FoxNFT ft;
    FOX fox;
    
    constructor(FoxNFT _ft, address _fox) {
        ft = _ft;
        fox = FOX(address(_fox));
        _setupRole(PRODUCE_ROLE, _msgSender());
    }
    
    function setMaxQuantity(int _quantity) public {
        maxQuantity = _quantity;
    }
    
    function getMaxQuantity() public view returns(int) {
        return maxQuantity;
    }
    
    function addNewProduction(string memory _name, string memory _description, int _price, string memory _hash) public returns (bool) {
        require(hasRole(PRODUCE_ROLE, _msgSender()), "Must have produce role to mint");
        require(foxProds[_hash].flag != 1);
        foxProds[_hash] = FoxProd(_name, _description, _price, maxQuantity, 1);
        hashes.push(_hash);
        return true;
    }
    
    function getProdList() public view returns(string[] memory){
        return hashes;
    }
    
    function getProdByHash(string memory _hash) public view returns(FoxProd memory){
        return foxProds[_hash];
    }
    
    
    function buy(address to, string memory _hash ) public payable returns (int) {
        require(foxProds[_hash].quantity >= 1, "Must have quantity more than 1");
        ft.mint(to, _hash);
        foxProds[_hash].quantity = foxProds[_hash].quantity - 1;
        return foxProds[_hash].quantity;
    }
}