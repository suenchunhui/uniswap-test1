// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// Import necessary contracts and interfaces from OpenZeppelin
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract DecentralizedExchange {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    // This structure represents a token pair
    struct TokenPair {
        address token1;
        address token2;
    }

    // An array to store all registered tokens
    address[] public registeredTokens;
    
    // An array to store all created token pairs
    TokenPair[] public tokenPairs;
    
    // Mapping to track the balance of each token for each user
    mapping(address => mapping(address => uint256)) public balance;

    // Event to track token registration
    event TokenRegistered(address indexed tokenAddress);
    
    // Event to track the creation of a token pair
    event TokenPairCreated(address indexed token1, address indexed token2);
    
    // Event to track token swap between two tokens
    event TokenSwap(address indexed token1, address indexed token2, address indexed sender, uint256 amount);

    // Function to register a new ERC20 token
    function registerToken(address _tokenAddress) external {
        // Ensure the token is not already registered
        require(isTokenRegistered(_tokenAddress) == false, "Token is already registered");

        // Add the token to the registeredTokens array
        registeredTokens.push(_tokenAddress);

        emit TokenRegistered(_tokenAddress);
    }

    // Function to check if a token is already registered
    function isTokenRegistered(address _tokenAddress) internal view returns (bool) {
        for (uint256 i = 0; i < registeredTokens.length; i++) {
            if (registeredTokens[i] == _tokenAddress) {
                return true;
            }
        }
        return false;
    }
    
    // Function to create a new token pair
    function createTokenPair(address _token1, address _token2) external {
        // Ensure both tokens are registered
        require(isTokenRegistered(_token1) == true, "Token1 is not registered");
        require(isTokenRegistered(_token2) == true, "Token2 is not registered");
        
        // Create a new TokenPair struct and add it to the tokenPairs array
        TokenPair memory newTokenPair = TokenPair(_token1, _token2);
        tokenPairs.push(newTokenPair);

        emit TokenPairCreated(_token1, _token2);
    }
    
    // Function to swap one token for another token
    function swapToken(address _token1, address _token2, uint256 _amount) external {
        // Ensure the token pair exists
        require(isTokenPairCreated(_token1, _token2) == true, "Token pair does not exist");
        
        // Ensure the sender has enough balance
        require(balance[msg.sender][_token1] >= _amount, "Insufficient balance");
        
        // Calculate the amount of _token2 based on the current exchange rate
        // In this example, we are assuming a 1:1 exchange rate
        uint256 token2Amount = _amount;
        
        // Transfer _amount of _token1 from the sender to the contract
        IERC20(_token1).safeTransferFrom(msg.sender, address(this), _amount);
        
        // Transfer token2Amount of _token2 from the contract to the sender
        IERC20(_token2).safeTransfer(msg.sender, token2Amount);
        
        // Update the balance of the sender
        balance[msg.sender][_token1] = balance[msg.sender][_token1].sub(_amount);
        
        emit TokenSwap(_token1, _token2, msg.sender, _amount);
    }
    
    // Function to check if a specific token pair is created
    function isTokenPairCreated(address _token1, address _token2) internal view returns (bool) {
        for (uint256 i = 0; i < tokenPairs.length; i++) {
            TokenPair memory pair = tokenPairs[i];
            if ((pair.token1 == _token1 && pair.token2 == _token2) || (pair.token1 == _token2 && pair.token2 == _token1)) {
                return true;
            }
        }
        return false;
    }
}