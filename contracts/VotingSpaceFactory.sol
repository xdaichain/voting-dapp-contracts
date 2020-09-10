pragma solidity 0.6.7;

import "@openzeppelin/contracts-ethereum-package/contracts/access/Ownable.sol";
import "./VotingSpace.sol";

contract VotingSpaceFactory is OwnableUpgradeSafe {
    event SpaceCreated(string name, address addr);

    function initialize(address _owner) external initializer {
        require(_owner != address(0), "zero address");
        __Ownable_init();
        OwnableUpgradeSafe.transferOwnership(_owner);
    }

    function createSpace(string calldata _name, address[] calldata _admins) external {
        VotingSpace newSpace = new VotingSpace(_name, _admins);
        emit SpaceCreated(_name, address(newSpace));
    }
}
