// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import {IAllowanceTransfer} from '../permit2/src/interfaces/IAllowanceTransfer.sol';
import {ERC20} from 'solmate/src/tokens/ERC20.sol';
import {IWETH9} from '../interfaces/IWETH9.sol';

struct RouterParameters {
    address permit2;
    address weth9;
    address seaportV1_5; // Unsupported
    address seaportV1_4; // Unsupported 
    address openseaConduit; // Unsupported
    address x2y2; // Unsupported
    address looksRareV2; // Unsupported
    address routerRewardsDistributor; // Unsupported
    address looksRareRewardsDistributor; // Unsupported
    address looksRareToken; // Unsupported
    address v2Factory;
    address v3Factory;
    address v3Deployer;
    bytes32 v3InitCodeHash;
    address stableFactory;
    address stableTwoPoolInfo;
    address stableThreePoolInfo;
    address zfNFTMarket; // Unsupported
}

/// @title Router Immutable Storage contract
/// @notice Used along with the `RouterParameters` struct for ease of cross-chain deployment
contract RouterImmutables {
    /// @dev WETH9 address
    IWETH9 internal immutable WETH9;

    /// @dev Permit2 address
    IAllowanceTransfer internal immutable PERMIT2;

    /// @dev Seaport 1.5 address
    address internal immutable SEAPORT_V1_5;

    /// @dev Seaport 1.4 address
    address internal immutable SEAPORT_V1_4;

    /// @dev The address of OpenSea's conduit used in both Seaport 1.4 and Seaport 1.5
    address internal immutable OPENSEA_CONDUIT;

    /// @dev The address of X2Y2
    address internal immutable X2Y2;

    /// @dev The address of LooksRareV2
    address internal immutable LOOKS_RARE_V2;

    /// @dev The address of LooksRare token
    ERC20 internal immutable LOOKS_RARE_TOKEN;

    /// @dev The address of LooksRare rewards distributor
    address internal immutable LOOKS_RARE_REWARDS_DISTRIBUTOR;

    /// @dev The address of router rewards distributor
    address internal immutable ROUTER_REWARDS_DISTRIBUTOR;

    /// @dev The address of ZFV2Factory
    address internal immutable ZF_V2_FACTORY;

    /// @dev The address of ZFV3Factory
    address internal immutable ZF_V3_FACTORY;

    /// @dev The ZFV3Pool initcodehash
    bytes32 internal immutable ZF_V3_POOL_INIT_CODE_HASH;

    /// @dev The address of ZF V3 Deployer
    address internal immutable ZF_V3_DEPLOYER;

    /// @dev The address of ZF NFT Market
    address internal immutable ZF_NFT_MARKET;

    enum Spenders {
        OSConduit
    }

    constructor(RouterParameters memory params) {
        PERMIT2 = IAllowanceTransfer(params.permit2);
        WETH9 = IWETH9(params.weth9);
        SEAPORT_V1_5 = params.seaportV1_5;
        SEAPORT_V1_4 = params.seaportV1_4;
        OPENSEA_CONDUIT = params.openseaConduit;
        X2Y2 = params.x2y2;
        LOOKS_RARE_V2 = params.looksRareV2;
        LOOKS_RARE_TOKEN = ERC20(params.looksRareToken);
        LOOKS_RARE_REWARDS_DISTRIBUTOR = params.looksRareRewardsDistributor;
        ROUTER_REWARDS_DISTRIBUTOR = params.routerRewardsDistributor;
        ZF_V2_FACTORY = params.v2Factory;
        ZF_V3_FACTORY = params.v3Factory;
        ZF_V3_POOL_INIT_CODE_HASH = params.v3InitCodeHash;
        ZF_V3_DEPLOYER = params.v3Deployer;
        ZF_NFT_MARKET = params.zfNFTMarket;
    }
}
