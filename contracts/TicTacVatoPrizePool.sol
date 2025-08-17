// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";

/**
 * @title TicTacVatoPrizePool
 * @notice UUPS-upgradeable prize pool contract for Tic Tac Vato.
 *         Tracks spenders per round and rewards the top three once the pool
 *         reaches a threshold. Designed for Arbitrum One (chainId 42161).
 */
contract TicTacVatoPrizePool is Initializable, UUPSUpgradeable, OwnableUpgradeable, ReentrancyGuardUpgradeable {
    // ---------------------------------------------------------------------
    // Constants
    // ---------------------------------------------------------------------

    uint256 public constant MIN_POOL = 0.001 ether; // minimum prize pool
    uint256 public constant MAX_POOL = 0.1 ether;   // max before payout triggers

    uint16 public constant FEE_BPS = 100;           // 1% fee (basis points)
    uint16 public constant HOUSE_SPLIT_BPS = 5000;  // 50% of fee to house
    uint16 public constant POOL_SPLIT_BPS = 5000;   // 50% of fee to pool

    // Payout basis points for top three spenders (40/30/20)
    uint16 public constant P1_BPS = 4000;
    uint16 public constant P2_BPS = 3000;
    uint16 public constant P3_BPS = 2000;

    // ---------------------------------------------------------------------
    // State
    // ---------------------------------------------------------------------

    uint256 public roundId;              // current round identifier
    uint256 public prizePool;            // wei held for active round
    address public houseWallet;          // recipient of house fees

    // Cumulative spend per player per round
    mapping(uint256 => mapping(address => uint256)) public roundSpend;

    // In-round leaderboard (descending by spend)
    address[3] public topAddrs;
    uint256[3] public topAmts;

    // ---------------------------------------------------------------------
    // Events
    // ---------------------------------------------------------------------

    event Played(
        address indexed player,
        uint256 indexed roundId,
        uint256 fee,
        uint256 toHouse,
        uint256 toPool,
        uint256 newPool
    );

    event PayoutTriggered(
        uint256 indexed roundId,
        address[3] winners,
        uint256[3] prizes,
        uint256 carryover
    );

    event NewRound(uint256 indexed roundId, uint256 seed);
    event Funded(address indexed from, uint256 amount, uint256 newPool);
    event HouseWalletUpdated(address indexed prev, address indexed next);

    // ---------------------------------------------------------------------
    // Initialization
    // ---------------------------------------------------------------------

    /// @notice Initialize contract with the house wallet.
    /// @param _houseWallet Address that receives the house portion of fees.
    function initialize(address _houseWallet) external initializer {
        require(_houseWallet != address(0), "house zero");

        __Ownable_init(msg.sender);
        __UUPSUpgradeable_init();
        __ReentrancyGuard_init();

        houseWallet = _houseWallet;
        roundId = 0;
    }

    // ---------------------------------------------------------------------
    // Funding
    // ---------------------------------------------------------------------

    /// @notice Seed the initial prize pool. Only once and by the owner.
    function seedInitialPool() external payable onlyOwner nonReentrant {
        require(prizePool == 0 && msg.value >= MIN_POOL, "bad seed");

        prizePool += msg.value;
        emit Funded(msg.sender, msg.value, prizePool);
    }

    /// @notice Fund the current prize pool.
    function fund() external payable {
        prizePool += msg.value;
        emit Funded(msg.sender, msg.value, prizePool);
    }

    // ---------------------------------------------------------------------
    // Views
    // ---------------------------------------------------------------------

    /// @notice Current fee required to play.
    function currentFee() public view returns (uint256) {
        uint256 fee = (prizePool * FEE_BPS) / 10000;
        if (fee < 1) fee = 1;
        return fee;
    }

    /// @notice Get the current leaderboard (addresses and amounts).
    function getLeaderboard() external view returns (address[3] memory, uint256[3] memory) {
        return (topAddrs, topAmts);
    }

    /// @notice Get configuration constants.
    function getConfig() external pure returns (uint256 minPool, uint256 maxPool, uint16 feeBps) {
        return (MIN_POOL, MAX_POOL, FEE_BPS);
    }

    /// @notice Preview payout amounts and carryover given current state.
    function previewPayouts() external view returns (uint256 p1, uint256 p2, uint256 p3, uint256 carry) {
        uint256 pool = prizePool;
        uint256[3] memory prizes = [
            (pool * P1_BPS) / 10000,
            (pool * P2_BPS) / 10000,
            (pool * P3_BPS) / 10000
        ];

        carry = pool;
        if (topAddrs[0] != address(0) && topAmts[0] > 0) {
            p1 = prizes[0];
            carry -= p1;
        }
        if (topAddrs[1] != address(0) && topAmts[1] > 0) {
            p2 = prizes[1];
            carry -= p2;
        }
        if (topAddrs[2] != address(0) && topAmts[2] > 0) {
            p3 = prizes[2];
            carry -= p3;
        }
    }

    // ---------------------------------------------------------------------
    // Gameplay
    // ---------------------------------------------------------------------

    /// @notice Play the game by paying the current fee.
    function play() external payable nonReentrant {
        require(prizePool >= MIN_POOL, "pool low");
        uint256 fee = currentFee();
        require(msg.value == fee, "fee mismatch");

        uint256 toHouse = (msg.value * HOUSE_SPLIT_BPS) / 10000;
        uint256 toPool = msg.value - toHouse; // remainder stays in pool

        // send to house
        (bool ok, ) = payable(houseWallet).call{value: toHouse}("");
        require(ok, "house fail");

        // update pool
        prizePool += toPool;

        // track spend
        uint256 total = roundSpend[roundId][msg.sender] + msg.value;
        roundSpend[roundId][msg.sender] = total;

        // update leaderboard
        _updateLeaderboard(msg.sender, total);

        emit Played(msg.sender, roundId, fee, toHouse, toPool, prizePool);

        if (prizePool >= MAX_POOL) {
            _payoutAndRoll();
        }
    }

    // ---------------------------------------------------------------------
    // Internal leaderboard helper
    // ---------------------------------------------------------------------

    function _updateLeaderboard(address player, uint256 amount) internal {
        uint256 i;
        // Check if player already on leaderboard
        for (i = 0; i < 3; i++) {
            if (topAddrs[i] == player) {
                topAmts[i] = amount;
                // bubble up
                while (i > 0 && topAmts[i] > topAmts[i - 1]) {
                    (topAmts[i], topAmts[i - 1]) = (topAmts[i - 1], topAmts[i]);
                    (topAddrs[i], topAddrs[i - 1]) = (topAddrs[i - 1], topAddrs[i]);
                    i--;
                }
                return;
            }
        }

        // Not on leaderboard, check if qualifies
        if (amount > topAmts[2]) {
            topAddrs[2] = player;
            topAmts[2] = amount;
            i = 2;
            while (i > 0 && topAmts[i] > topAmts[i - 1]) {
                (topAmts[i], topAmts[i - 1]) = (topAmts[i - 1], topAmts[i]);
                (topAddrs[i], topAddrs[i - 1]) = (topAddrs[i - 1], topAddrs[i]);
                i--;
            }
        }
    }

    // ---------------------------------------------------------------------
    // Payout and rollover
    // ---------------------------------------------------------------------

    function _payoutAndRoll() internal {
        uint256 pool = prizePool;
        uint256[3] memory prizes = [
            (pool * P1_BPS) / 10000,
            (pool * P2_BPS) / 10000,
            (pool * P3_BPS) / 10000
        ];

        address[3] memory winners = topAddrs;
        uint256 paid;

        for (uint256 i = 0; i < 3; i++) {
            address winner = winners[i];
            uint256 prize = prizes[i];
            if (winner != address(0) && topAmts[i] > 0 && prize > 0) {
                (bool ok, ) = payable(winner).call{value: prize}("");
                require(ok, "payout fail");
                paid += prize;
            } else {
                prizes[i] = 0; // not paid
            }
        }

        uint256 carry = pool - paid;
        emit PayoutTriggered(roundId, winners, prizes, carry);

        roundId += 1;
        prizePool = carry;

        // reset leaderboard
        for (uint256 j = 0; j < 3; j++) {
            topAddrs[j] = address(0);
            topAmts[j] = 0;
        }

        emit NewRound(roundId, prizePool);
    }

    // ---------------------------------------------------------------------
    // Admin & Upgrade
    // ---------------------------------------------------------------------

    /// @notice Update the house wallet.
    function setHouseWallet(address newHouse) external onlyOwner {
        require(newHouse != address(0), "house zero");
        emit HouseWalletUpdated(houseWallet, newHouse);
        houseWallet = newHouse;
    }

    /// @inheritdoc UUPSUpgradeable
    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

    // Reserve storage to allow future upgrades.
    uint256[45] private __gap;
}

