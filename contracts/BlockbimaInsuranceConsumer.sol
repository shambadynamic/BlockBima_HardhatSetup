// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import "@shambadynamic/contracts/contracts/ShambaGeoConsumer.sol";

contract BlockbimaInsuranceConsumer is ShambaGeoConsumer {
    address payable private insurer;
    address payable public client;
    uint256 public payoutValue;
    uint256 public commission;
    string public request_IPFS_CID;
    int256 public geostatsThreshold;
    bool public isContractActive;
    bool public isContractPaid = false;
    address private shamba = 0x8C244f0B2164E6A3BED74ab429B0ebd661Bb14CA;

    /**
     * @dev Creates a new Insurance contract
     */
    constructor(
        address payable _client,
        uint256 _payoutValue,
        uint256 _totalValue,
        string memory requestIpfsCid,
        int256 _geostatsThreshold,
        uint256 _chainId
    ) payable ShambaGeoConsumer(_chainId) {
        // ensure that the contract is fully funded (payout + 1% commission)
        require(msg.value >= _totalValue);
        
        request_IPFS_CID = requestIpfsCid;
        geostatsThreshold = _geostatsThreshold;
        insurer = payable(msg.sender);
        client = _client;
        payoutValue = _payoutValue;
        commission = _totalValue - _payoutValue;
        isContractActive = true;
    }

    /**
     * @dev
     * This function will return the current geostats data returned by the getGeostatsData function of the imported ShambaGeoConsumer contract
     */
    function getShambaGeostatsData(address payable _insurer) public {
        require(isContractActive);

        require(
            ShambaGeoConsumer.getLatestGeostatsData() != 0 &&
                ShambaGeoConsumer.getLatestGeostatsData() != -1
        );

        if (ShambaGeoConsumer.getLatestGeostatsData() <= geostatsThreshold) {
            // threshold has been met
            payOutContract();
        } else {
            refundInsurer(_insurer);
        }
    }

    /**
     * @dev Insurance conditions have been met, do payout of total cover amount to client
     */
    function payOutContract() private {
        //Transfer agreed amount to client
        client.transfer(payoutValue);
        payable(shamba).transfer(commission);
        isContractPaid = true;
        isContractActive = false;
    }

    /**
     * @dev Insurance conditions haven't met, refund payout of total cover amount back to the insurer
     */
    function refundInsurer(address payable _insurer) private {
        //Transfer amount back to insurer
        _insurer.transfer(payoutValue);
        payable(shamba).transfer(commission);
        isContractActive = false;
    }
}
