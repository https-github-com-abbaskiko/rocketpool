pragma solidity 0.6.12;

// SPDX-License-Identifier: GPL-3.0-only

import "../RocketBase.sol";
import "../../interface/settings/RocketDAOSettingsInterface.sol";

// Settings in RP which the DAO will have full control over

contract RocketDAOSettings is RocketBase, RocketDAOSettingsInterface {

    // Construct
    constructor(address _rocketStorageAddress) RocketBase(_rocketStorageAddress) public {
        // Set version 
        version = 1;
        // Initialize settings on deployment
        if (!getBoolS("settings.dao.init")) {
            // Apply settings
            setInflationIntervalRate(1000133680617113500); // 5% annual calculated on a daily interval of blocks (6170 = 1 day approx in 14sec blocks)
            setInflationIntervalBlocks(6170); // Inflation daily block interval (default is 6170 = 1 day approx in 14sec blocks) 
            setInflationIntervalStartBlock(block.number+(getInflationIntervalBlocks()*28)); // Set the default start date for inflation to begin as 4 weeks from contract deployment (this can be changed after deployment)
            // Settings initialized
            setBoolS("settings.dao.init", true);
        }
    }

    /*** RPL Settings *****************************************/

    // RPL yearly inflation rate per interval (daily by default)
    function getInflationIntervalRate() override public view returns (uint256) {
        return getUintS("settings.dao.rpl.inflation.interval.rate");
    }
    // The inflation rate per day calculated using the yearly target in mind
    // Eg. Calculate inflation daily with 5% (0.05) yearly inflation 
    // Calculate in js example: let dailyInflation = web3.utils.toBN((1 + 0.05) ** (1 / (365)) * 1e18);
    function setInflationIntervalRate(uint256 _value) public onlyOwner {
        setUintS("settings.dao.rpl.inflation.interval.rate", _value);
    }
 
    
    // Inflation block interval (default is 6170 = 1 day approx in 14sec blocks) 
    function getInflationIntervalBlocks() override public view returns (uint256) {
        return getUintS("settings.dao.rpl.inflation.interval.blocks"); 
    }

    // How often the inflation is calculated, if this is changed significantly, then the above setInflationIntervalRate() will need to be adjusted
    function setInflationIntervalBlocks(uint256 _value) public onlyOwner {
        // Cannot be 0, set 'setInflationIntervalRate' to 0 if inflation is no longer required
        require(_value > 0, "Inflation interval block amount cannot be 0 or less");
        // We get a perc, so lets calculate that inflation rate for the current
        setUintS("settings.dao.rpl.inflation.interval.blocks", _value);
    }

    // The block to start inflation at
    function getInflationIntervalStartBlock() override public view returns (uint256) {
        return getUintS("settings.dao.rpl.inflation.interval.start"); 
    }

    // The block to start inflation at, can only be set if that block has not already passed
    function setInflationIntervalStartBlock(uint256 _value) public onlyOwner {
        // Must be a block in the future
        require(_value > block.number, "Inflation interval start block must be a future block");
        // If it's already set and started, a new start block cannot be set
        if(getInflationIntervalStartBlock() > 0) {
            require(getInflationIntervalStartBlock() > block.number, "Inflation has already started");
        }
        // We get a perc, so lets calculate that inflation rate for the current
        setUintS("settings.dao.rpl.inflation.interval.start", _value);
    }

}