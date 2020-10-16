pragma solidity ^0.6.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";


contract PepedexToken is ERC20 {

    struct stakeTracker {
        uint256 lastBlockChecked;
        uint256 rewards;
        uint256 ppblzStaked;
        uint256 uniV2Staked;
    }

    address private owner;
    address private fundAddress;

    uint256 private rewardsVar;
    uint256 private liquidityMultiplier;

    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    address private ppblzAddress;
    IERC20 private ppblzToken;

    address public uniV2PairAddress;
    IERC20 private uniV2PairToken;

    uint256 private _totalPpblzStaked;
    uint256 private _totalUniV2Staked;
    mapping(address => stakeTracker) private _stakedBalances;

    constructor() public ERC20("Pepedex", "PPDEX") {
        owner = msg.sender;
        _mint(msg.sender, 2 * (10 ** 18));
        rewardsVar = 100000;
        liquidityMultiplier = 10;
    }

    event PpblzStaked(address indexed user, uint256 amount, uint256 totalPpblzStaked);
    event UniV2Staked(address indexed user, uint256 amount, uint256 totalUniV2Staked);
    event PpblzWithdrawn(address indexed user, uint256 amount);
    event UniV2Withdrawn(address indexed user, uint256 amount);
    event Rewards(address indexed user, uint256 reward);

    modifier _onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    modifier updateStakingReward(address account) {
        if (block.number > _stakedBalances[account].lastBlockChecked) {
            uint256 rewardBlocks = block.number
            .sub(_stakedBalances[account].lastBlockChecked);

            if (_stakedBalances[account].ppblzStaked > 0) {
                _stakedBalances[account].rewards = _stakedBalances[account].rewards
                .add(
                    _stakedBalances[account].ppblzStaked
                    .mul(rewardBlocks)
                    / rewardsVar);
            }

            if (_stakedBalances[account].uniV2Staked > 0) {
                _stakedBalances[account].rewards = _stakedBalances[account].rewards
                .add(
                    _stakedBalances[account].uniV2Staked
                    .mul(liquidityMultiplier)
                    .mul(rewardBlocks)
                    / rewardsVar);
            }

            _stakedBalances[account].lastBlockChecked = block.number;
            emit Rewards(account, _stakedBalances[account].rewards);
        }
        _;
    }

    modifier claimRewards() {
        uint256 reward = _stakedBalances[msg.sender].rewards;
        _stakedBalances[msg.sender].rewards = 0;
        _mint(msg.sender, reward.mul(9) / 10);
        uint256 fundingPoolReward = reward.mul(1) / 10;
        _mint(fundAddress, fundingPoolReward);

        emit Rewards(msg.sender, reward);
        _;
    }

    function setPpblzAddress(address _ppblzAddress) public _onlyOwner returns (uint256) {
        ppblzAddress = _ppblzAddress;
        ppblzToken = IERC20(_ppblzAddress);
    }

    function setUniV2PairAddress(address _uniV2PairAddress) public _onlyOwner returns (uint256) {
        uniV2PairAddress = _uniV2PairAddress;
        uniV2PairToken = IERC20(_uniV2PairAddress);
    }

    function setFundAddress(address _fundAddress) public _onlyOwner returns (uint256) {
        fundAddress = _fundAddress;
    }

    function setRewardsVar(uint256 _amount) public _onlyOwner {
        rewardsVar = _amount;
    }

    function setLiquidityMultiplier(uint256 _amount) public _onlyOwner {
        liquidityMultiplier = _amount;
    }

    function getLiquidityMultiplier() public view returns (uint256) {
        return liquidityMultiplier;
    }

    function getBlockNum() public view returns (uint256) {
        return block.number;
    }

    function getLastBlockCheckedNum(address _account) public view returns (uint256) {
        return _stakedBalances[_account].lastBlockChecked;
    }

    function getAddressPpblzStakeAmount(address _account) public view returns (uint256) {
        return _stakedBalances[_account].ppblzStaked;
    }

    function getAddressUniV2StakeAmount(address _account) public view returns (uint256) {
        return _stakedBalances[_account].uniV2Staked;
    }

    function totalStakedSupply() public view returns (uint256) {
        return _totalPpblzStaked
        .add(_totalUniV2Staked
        .mul(liquidityMultiplier / 2));
    }

    function totalStakedPpblz() public view returns (uint256) {
        return _totalPpblzStaked;
    }

    function totalStakedUniV2() public view returns (uint256) {
        return _totalUniV2Staked;
    }

    function myRewardsBalance(address account) public view returns (uint256) {
        if (block.number > _stakedBalances[account].lastBlockChecked) {
            uint256 rewardBlocks = block.number
            .sub(_stakedBalances[account].lastBlockChecked);

            uint256 ppblzRewards = 0;
            uint256 uniV2Rewards = 0;

            if (_stakedBalances[account].ppblzStaked > 0) {
                ppblzRewards = _stakedBalances[account].rewards
                .add(
                    _stakedBalances[account].ppblzStaked
                    .mul(rewardBlocks)
                    / rewardsVar);
            }

            if (_stakedBalances[account].uniV2Staked > 0) {
                uniV2Rewards = _stakedBalances[account].rewards
                .add(
                    _stakedBalances[account].uniV2Staked
                    .mul(liquidityMultiplier)
                    .mul(rewardBlocks)
                    / rewardsVar);
            }

            return ppblzRewards.add(uniV2Rewards);
        }

        return 0;
    }

    function stakePpblz(uint256 amount) public updateStakingReward(msg.sender) {
        _totalPpblzStaked = _totalPpblzStaked.add(amount);
        _stakedBalances[msg.sender].ppblzStaked = _stakedBalances[msg.sender].ppblzStaked.add(amount);
        ppblzToken.safeTransferFrom(msg.sender, address(this), amount);
        emit PpblzStaked(msg.sender, amount, _totalPpblzStaked);
    }

    function stakeUniV2(uint256 amount) public updateStakingReward(msg.sender) {
        _totalUniV2Staked = _totalUniV2Staked.add(amount);
        _stakedBalances[msg.sender].uniV2Staked = _stakedBalances[msg.sender].uniV2Staked.add(amount);
        uniV2PairToken.safeTransferFrom(msg.sender, address(this), amount);
        emit UniV2Staked(msg.sender, amount, _totalUniV2Staked);
    }

    function withdrawPpblz(uint256 amount) public updateStakingReward(msg.sender) claimRewards() {
        _totalPpblzStaked = _totalPpblzStaked.sub(amount);
        _stakedBalances[msg.sender].ppblzStaked = _stakedBalances[msg.sender].ppblzStaked.sub(amount);
        ppblzToken.safeTransfer(msg.sender, amount);
        emit PpblzWithdrawn(msg.sender, amount);
    }

    function withdrawUniV2(uint256 amount) public updateStakingReward(msg.sender) claimRewards() {
        _totalUniV2Staked = _totalUniV2Staked.sub(amount);
        _stakedBalances[msg.sender].uniV2Staked = _stakedBalances[msg.sender].uniV2Staked.sub(amount);
        uniV2PairToken.safeTransfer(msg.sender, amount);
        emit UniV2Withdrawn(msg.sender, amount);
    }

    function getReward() public updateStakingReward(msg.sender) {
        uint256 reward = _stakedBalances[msg.sender].rewards;
        _stakedBalances[msg.sender].rewards = 0;
        _mint(msg.sender, reward.mul(9) / 10);
        uint256 fundingPoolReward = reward.mul(1) / 10;
        _mint(fundAddress, fundingPoolReward);
        emit Rewards(msg.sender, reward);
    }
}
