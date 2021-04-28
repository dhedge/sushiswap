// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;
import "./interfaces/IRewarder.sol";
import "@boringcrypto/boring-solidity/contracts/libraries/BoringERC20.sol";
import "@boringcrypto/boring-solidity/contracts/libraries/BoringMath.sol";
import "./Ownable.sol";


contract DHTRewarder is IRewarder, Ownable {

    using BoringMath for uint256;
    using BoringERC20 for IERC20;

    uint256 private constant REWARD_MULTIPLIER = 5;
    uint256 private constant REWARD_TOKEN_DIVISOR = 1e18;
    //DHT dht.dhedge.eth
    IERC20 private constant REWARD_TOKEN = IERC20(0xca1207647Ff814039530D7d35df0e1Dd2e91Fa84);
    address private immutable MASTERCHEF_V2;

    constructor (address _MASTERCHEF_V2) public {
        MASTERCHEF_V2 = _MASTERCHEF_V2;

        //dHEDGE DAO
        owner = 0xB76E40277B79B78dFa954CBEc863D0e4Fd0656ca;
        emit OwnershipTransferred(msg.sender, owner);
    }

    function onSushiReward (uint256, address user, address to, uint256 sushiAmount, uint256) onlyMCV2 override external {
        uint256 pendingReward = sushiAmount.mul(REWARD_MULTIPLIER) / REWARD_TOKEN_DIVISOR;
        uint256 rewardBal = REWARD_TOKEN.balanceOf(address(this));
        if (pendingReward > rewardBal) {
            REWARD_TOKEN.safeTransfer(to, rewardBal);
        } else {
            REWARD_TOKEN.safeTransfer(to, pendingReward);
        }
    }
    
    function pendingTokens(uint256 pid, address user, uint256 sushiAmount) override external view returns (IERC20[] memory rewardTokens, uint256[] memory rewardAmounts) {
        IERC20[] memory _rewardTokens = new IERC20[](1);
        _rewardTokens[0] = (REWARD_TOKEN);
        uint256[] memory _rewardAmounts = new uint256[](1);
        _rewardAmounts[0] = sushiAmount.mul(REWARD_MULTIPLIER) / REWARD_TOKEN_DIVISOR;
        return (_rewardTokens, _rewardAmounts);
    }

    function emergencyWithdraw(IERC20 _token, uint256 _amount) public onlyOwner {
        _token.safeTransfer(msg.sender, _amount);
    }

    modifier onlyMCV2 {
        require(
            msg.sender == MASTERCHEF_V2,
            "Only MCV2 can call this function."
        );
        _;
    }
  
}
