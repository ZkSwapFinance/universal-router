// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.5.0;

import './pool/IZFV3PoolImmutables.sol';
import './pool/IZFV3PoolState.sol';
import './pool/IZFV3PoolDerivedState.sol';
import './pool/IZFV3PoolActions.sol';
import './pool/IZFV3PoolOwnerActions.sol';
import './pool/IZFV3PoolEvents.sol';

/// @title The interface for a ZF V3 Pool
/// @notice A ZF pool facilitates swapping and automated market making between any two assets that strictly conform
/// to the ERC20 specification
/// @dev The pool interface is broken up into many smaller pieces
interface IZFV3Pool is
    IZFV3PoolImmutables,
    IZFV3PoolState,
    IZFV3PoolDerivedState,
    IZFV3PoolActions,
    IZFV3PoolOwnerActions,
    IZFV3PoolEvents
{

}
