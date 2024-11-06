// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import {RouterImmutables} from '../../base/RouterImmutables.sol';
import {Payments} from '../Payments.sol';
import {Permit2Payments} from '../Permit2Payments.sol';
import {Constants} from '../../libraries/Constants.sol';
import {UniversalRouterHelper} from '../../libraries/UniversalRouterHelper.sol';
import {ERC20} from 'solmate/src/tokens/ERC20.sol';
import {SafeTransferLib} from 'solmate/src/utils/SafeTransferLib.sol';
import {Ownable} from '@openzeppelin/contracts/access/Ownable.sol';
import {IStableSwap} from '../../interfaces/IStableSwap.sol';


/// @title Router for ZF Stable Trades
abstract contract StableSwapRouter is RouterImmutables, Permit2Payments, Ownable {
    using SafeTransferLib for ERC20;
    using UniversalRouterHelper for address;

    error StableTooLittleReceived();
    error StableTooMuchRequested();
    error StableInvalidPath();

    address public stableSwapFactory;
    address public stableSwapTwoPoolInfo;
    address public stableSwapThreePoolInfo;

    event SetStableSwap(address indexed factory, address stableSwapTwoPoolInfo, address stableSwapThreePoolInfo);

    constructor(
        address _stableSwapFactory,
        address _stableSwapTwoPoolInfo,
        address _stableSwapThreePoolInfo
    ) {
        stableSwapFactory = _stableSwapFactory;
        stableSwapTwoPoolInfo = _stableSwapTwoPoolInfo;
        stableSwapThreePoolInfo = _stableSwapThreePoolInfo;
    }

    /**
     * @notice Set ZF Stable Swap Factory and Info
     * @dev Only callable by contract owner
     */
    function setStableSwap(
        address _factory,
        address _stableSwapTwoPoolInfo,
        address _stableSwapThreePoolInfo
    ) external onlyOwner {
        require(_factory != address(0) && _stableSwapTwoPoolInfo != address(0) && __stableSwapThreePoolInfo != address(0));

        stableSwapFactory = _factory;
        stableSwapTwoPoolInfo = _stableSwapTwoPoolInfo;
        stableSwapThreePoolInfo = _stableSwapThreePoolInfo;

        emit SetStableSwap(stableSwapFactory, stableSwapTwoPoolInfo, stableSwapThreePoolInfo);
    }

    function _stableSwap(
        address[] calldata path,
        uint256[] calldata flag
    ) private {
        unchecked {
            if (path.length - 1 != flag.length) revert StableInvalidPath();

            for (uint256 i; i < flag.length; i++) {
                (address input, address output) = (path[i], path[i + 1]);
                (uint256 k, uint256 j, address swapContract) = stableSwapFactory.getStableInfo(input, output, flag[i]); 
                uint256 amountIn = ERC20(input).balanceOf(address(this));
                ERC20(input).safeApprove(swapContract, amountIn);
                IStableSwap(swapContract).exchange(k, j, amountIn, 0);
            }
        }
    }

    /// @notice Performs a ZF stable exact input swap
    /// @param recipient The recipient of the output tokens
    /// @param amountIn The amount of input tokens for the trade
    /// @param amountOutMinimum The minimum desired amount of output tokens
    /// @param path The path of the trade as an array of token addresses
    /// @param flag token amount in a stable swap pool. 2 for 2pool, 3 for 3pool
    /// @param payer The address that will be paying the input
    function stableSwapExactInput(
        address recipient,
        uint256 amountIn,
        uint256 amountOutMinimum,
        address[] calldata path,
        uint256[] calldata flag,
        address payer
    ) internal {
        if (
            amountIn != Constants.ALREADY_PAID && amountIn != Constants.CONTRACT_BALANCE
        ) {
            payOrPermit2Transfer(path[0], payer, address(this), amountIn);
        }

        ERC20 tokenOut = ERC20(path[path.length - 1]);

        _stableSwap(path, flag); 

        uint256 amountOut = tokenOut.balanceOf(address(this));
        if (amountOut < amountOutMinimum) revert StableTooLittleReceived();

        if (recipient != address(this)) pay(address(tokenOut), recipient, amountOut);
    }

    /// @notice Performs a ZF stable exact output swap
    /// @param recipient The recipient of the output tokens
    /// @param amountOut The amount of output tokens to receive for the trade
    /// @param amountInMaximum The maximum desired amount of input tokens
    /// @param path The path of the trade as an array of token addresses
    /// @param flag token amount in a stable swap pool. 2 for 2pool, 3 for 3pool
    /// @param payer The address that will be paying the input
    function stableSwapExactOutput(
        address recipient,
        uint256 amountOut,
        uint256 amountInMaximum,
        address[] calldata path,
        uint256[] calldata flag,
        address payer
    ) internal {
        uint256 amountIn = stableSwapFactory.getStableAmountsIn(stableSwapTwoPoolInfo, stableSwapThreePoolInfo, path, flag, amountOut)[0];

        if (amountIn > amountInMaximum) revert StableTooMuchRequested();

        payOrPermit2Transfer(path[0], payer, address(this), amountIn);

        _stableSwap(path, flag); 

        if (recipient != address(this)) pay(path[path.length - 1], recipient, amountOut);
    }
}