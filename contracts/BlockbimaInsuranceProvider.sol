// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import "./BlockbimaInsuranceConsumer.sol";

contract BlockbimaInsuranceProvider {
    address payable public insurer;
    uint256 private chain_Id;
    uint256 public totalInsuranceContracts;

    //here is where all the insurance contracts are stored.
    BlockbimaInsuranceConsumer[] public insuranceContracts;

    constructor(uint256 chain_id) payable {
        chain_Id = chain_id;
        insurer = payable(msg.sender);
    }

    /**
     * @dev Event to log when a contract is created
     */
    event contractCreated(address _insuranceContract, uint256 _payoutValue);

    /**
     * @dev Create a new insurance contract for client, automatically approved and deployed to the blockchain
     */
    function deployInsuranceContract(
        address payable _client,
        uint256 _payoutValue,
        int256 _geostatsThreshold,
        string memory requestIpfsCid
    ) public payable returns (address) {
        // payout + 1% commission
        uint256 _totalValue = _payoutValue + (_payoutValue / 100);

        // first ensure that only insurer is creating new insurance contract and has fully funded the contract (payout + 1% commission)
        require(msg.sender == insurer && msg.value >= _totalValue);

        BlockbimaInsuranceConsumer i = (new BlockbimaInsuranceConsumer){
            value: _totalValue
        }(
            _client,
            _payoutValue,
            _totalValue,
            requestIpfsCid,
            _geostatsThreshold,
            chain_Id
        );

        insuranceContracts.push(i);

        totalInsuranceContracts += 1;

        emit contractCreated(address(i), _payoutValue);

        return address(i);
    }

    /**
     * @dev whitelist the insurance provider for a given contract address
     * @notice this function can only be called by Shamba (can be contacted via email at info@shamba.network)
     */
    function whitelistInsuranceContract(address _contract) external {
        BlockbimaInsuranceConsumer(_contract).addAddressToWhitelist(
            address(this)
        );
    }

    /**
     * @dev checks whether the insurance provider is whitelisted or not, for a given contract address
     */
    function isInsuranceContractWhitelisted(
        address _contract
    ) external view returns (bool) {
        return
            BlockbimaInsuranceConsumer(_contract).isWhitelisted(address(this));
    }

    /**
     * @dev gets the client for a given contract address
     */
    function client(address _contract) external view returns (address) {
        return BlockbimaInsuranceConsumer(_contract).client();
    }

    /**
     * @dev gets the payout value for a given contract address
     */
    function payoutValue(address _contract) external view returns (uint256) {
        return BlockbimaInsuranceConsumer(_contract).payoutValue();
    }

    /**
     * @dev sends the request to Shamba Oracle for a given contract address (only eligible after executing the whitelistInsuranceContract() function)
     * @notice only the insurance contracts that are having the corresponding whitelisted insurance provider can call this function
     */
    function sendContractRequestToShambaOracle(address _contract) external {
        require(BlockbimaInsuranceConsumer(_contract).isContractActive());
        BlockbimaInsuranceConsumer(_contract).requestGeostatsData(
            BlockbimaInsuranceConsumer(_contract).request_IPFS_CID()
        );
    }

    /**
     * @dev update the geostats for a given contract address
     */
    function updateContractGeostats(address _contract) external {
        BlockbimaInsuranceConsumer(_contract).getShambaGeostatsData(insurer);
    }

    /**
     * @dev gets the request ipfs cid for a given contract address
     */
    function getContractRequestIpfsCid(
        address _contract
    ) external view returns (string memory) {
        return BlockbimaInsuranceConsumer(_contract).request_IPFS_CID();
    }

    /**
     * @dev gets the latest geostats data for a given contract address
     */
    function getContractLatestGeostats(
        address _contract
    ) external view returns (int256) {
        return BlockbimaInsuranceConsumer(_contract).getLatestGeostatsData();
    }

    /**
     * @dev gets the latest ipfs cid for a given contract address
     */
    function getContractLatestIpfsCid(
        address _contract
    ) external view returns (string memory) {
        return BlockbimaInsuranceConsumer(_contract).getLatestCid();
    }

    /**
     * @dev gets the geostats threshold for a given contract address
     */
    function getContractGeostatsThreshold(
        address _contract
    ) external view returns (int256) {
        return BlockbimaInsuranceConsumer(_contract).geostatsThreshold();
    }

    /**
     * @dev gets the current paid status for a given contract address
     */
    function isContractPaid(address _contract) external view returns (bool) {
        return BlockbimaInsuranceConsumer(_contract).isContractPaid();
    }

    /**
     * @dev gets the current active status for a given contract address
     */
    function isContractActive(address _contract) external view returns (bool) {
        return BlockbimaInsuranceConsumer(_contract).isContractActive();
    }
}