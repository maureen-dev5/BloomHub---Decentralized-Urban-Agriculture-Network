# BloomHub - Decentralized Urban Agriculture Network

[![Clarity](https://img.shields.io/badge/Clarity-Smart%20Contract-5546FF)](https://clarity-lang.org/)
[![Stacks](https://img.shields.io/badge/Stacks-Blockchain-6B50FF)](https://www.stacks.co/)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

## Overview

BloomHub is a revolutionary decentralized platform built on Stacks blockchain that connects urban growers, tracks agricultural yields, and rewards sustainable cultivation practices. By leveraging blockchain technology, BloomHub creates a transparent, incentivized ecosystem where community members can share growing spaces, document harvests, and build reputation through verifiable on-chain records.

## Vision

Urban agriculture faces challenges of fragmented knowledge, lack of recognition for sustainable practices, and difficulty in building trust within growing communities. BloomHub addresses these pain points by:

- **Democratizing Knowledge**: Creating an immutable database of cultivation plots and yield data
- **Rewarding Contribution**: Tokenizing community participation through BGT rewards
- **Building Trust**: Establishing transparent reputation systems through blockchain verification
- **Fostering Community**: Connecting growers through decentralized plot sharing and assessment

## Core Features

### 🌱 Plot Registration System
- **Decentralized Database**: Register urban growing spaces with comprehensive metadata
- **Detailed Specifications**: Track plot size, soil type, light exposure, and location data
- **Classification System**: Categorize plots as community, rooftop, urban, or suburban
- **Registration Rewards**: Earn 2.4 BGT for contributing new plots to the network

### 📊 Yield Tracking & Documentation
- **Comprehensive Logging**: Record cultivar types, harvest weights, growing methods, and seasonal data
- **Success Metrics**: Track harvest outcomes with binary success indicators
- **Method Tracking**: Document organic, traditional, or hydroponic cultivation styles
- **Incentive Structure**: 
  - Successful harvests: 1.9 BGT
  - Learning experiences (unsuccessful): 0.633 BGT

### 👨‍🌾 Grower Profiles
- **Identity Management**: Customizable display names and specialty designations
- **Performance Metrics**: Automatic tracking of yields, plots contributed, and cultivars grown
- **Tier Progression**: Dynamic ranking system (1-5) based on cumulative harvest mass
- **Portfolio Building**: Comprehensive on-chain history of all agricultural activities

### ⭐ Community Assessment System
- **Plot Reviews**: Rate growing spaces on a 1-10 scale with detailed commentary
- **Output Evaluation**: Classify plots by productivity (high, medium, low)
- **Endorsement Mechanism**: Community validation of helpful assessments
- **Reputation Building**: Aggregated ratings provide trust signals for plot quality

### 🏆 Achievement Framework
- **Milestone Recognition**: Unlock badges based on activity thresholds
- **Substantial Rewards**: 8.8 BGT per achievement unlocked
- **Built-in Achievements**:
  - `grower-50`: Complete 50 successful yields
  - `community-9`: Register 9 cultivation plots
- **Extensible Design**: Framework supports future badge additions

## Tokenomics

### BloomHub Growth Token (BGT)

**Token Specifications**
- **Symbol**: BGT
- **Precision**: 6 decimals
- **Maximum Supply**: 41,000 BGT
- **Distribution Model**: Activity-based minting

**Incentive Breakdown**

| Activity | Reward | Purpose |
|----------|--------|---------|
| Successful Yield | 1.9 BGT | Encourage consistent documentation |
| Unsuccessful Yield | 0.633 BGT | Reward honesty and learning |
| Plot Registration | 2.4 BGT | Expand network database |
| Achievement Unlock | 8.8 BGT | Recognize long-term commitment |

**Economic Principles**
1. **Merit-Based Distribution**: Rewards align with value creation
2. **Failure Tolerance**: Partial rewards encourage honest reporting
3. **Long-Term Incentives**: Achievement bonuses reward sustained participation
4. **Supply Constraints**: Fixed cap ensures token scarcity and value

## Technical Architecture

### Smart Contract Structure

**State Management**
- Token ledger with supply tracking
- Sequential ID generation for plots and yields
- Five core data maps for comprehensive state storage
- Efficient helper functions for profile management

**Data Models**

#### Grower Registry
```clarity
{
  display-name: (string-ascii 24),
  specialty: (string-ascii 12),
  yield-entries: uint,
  plot-contributions: uint,
  cultivars-tracked: uint,
  grower-tier: uint,
  enrollment-block: uint
}
```

#### Plot Database
```clarity
{
  plot-title: (string-ascii 36),
  geo-location: (string-ascii 26),
  plot-classification: (string-ascii 12),
  area-sqm: uint,
  substrate: (string-ascii 10),
  light-exposure: (string-ascii 8),
  coordinator: principal,
  yield-records: uint,
  community-rating: uint
}
```

#### Yield Registry
```clarity
{
  plot-reference: uint,
  grower: principal,
  cultivar: (string-ascii 20),
  mass-grams: uint,
  cultivation-style: (string-ascii 12),
  growing-season: (string-ascii 8),
  yield-commentary: (string-ascii 110),
  recorded-block: uint,
  harvest-success: bool
}
```

### Security Features

✅ **Input Validation**: Comprehensive checks on all user inputs  
✅ **Access Control**: Permission checks for sensitive operations  
✅ **Duplicate Prevention**: Guards against review and achievement spam  
✅ **Supply Cap Enforcement**: Prevents token inflation  
✅ **Immutable Records**: Core data cannot be altered post-creation  
✅ **Event Logging**: Transparent audit trail for all activities  

## Usage Examples

### Register a Growing Plot

```clarity
(contract-call? .bloomhub register-plot
  "Urban Rooftop Garden - Block 5"
  "40.7580° N, 73.9855° W"
  "rooftop"
  u25                    ;; 25 square meters
  "loamy"
  "full"
)
```

### Record Harvest Yield

```clarity
(contract-call? .bloomhub record-yield
  u1                     ;; plot-reference
  "Cherry Tomatoes"
  u3500                  ;; 3.5 kg in grams
  "organic"
  "summer"
  "Excellent yield from heirloom variety, minimal pest issues"
  true                   ;; harvest-success
)
```

### Submit Plot Assessment

```clarity
(contract-call? .bloomhub submit-assessment
  u1                     ;; plot-reference
  u8                     ;; score out of 10
  "Well-maintained space with good drainage. Great for leafy greens and herbs. Afternoon shade limits tomato production."
  "medium"               ;; output-level
)
```

### Claim Achievement Badge

```clarity
(contract-call? .bloomhub claim-badge "grower-50")
```

### Update Profile Information

```clarity
;; Update display name
(contract-call? .bloomhub update-display-name "UrbanFarmer2025")

;; Update specialty
(contract-call? .bloomhub update-specialty "herbs")
```

## Query Interface

### Read-Only Functions

```clarity
;; Fetch grower statistics
(contract-call? .bloomhub fetch-grower-profile 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM)

;; Get plot details
(contract-call? .bloomhub fetch-plot-info u1)

;; Retrieve yield record
(contract-call? .bloomhub fetch-yield-record u1)

;; Check plot assessment
(contract-call? .bloomhub fetch-plot-assessment u1 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM)

;; Verify achievement status
(contract-call? .bloomhub fetch-achievement 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM "grower-50")

;; Check token balance
(contract-call? .bloomhub get-balance 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM)
```

## Development Setup

### Prerequisites

- **Clarinet** v1.0+ - Clarity development environment
- **Node.js** v16+ - For tooling and scripts
- **Git** - Version control

### Installation

```bash
# Clone repository
git clone https://github.com/yourusername/bloomhub.git
cd bloomhub

# Install Clarinet (macOS)
brew install clarinet

# Verify installation
clarinet --version
```

### Testing

```bash
# Run full test suite
clarinet test

# Run with coverage
clarinet test --coverage

# Watch mode for development
clarinet test --watch
```

### Local Development

```bash
# Start local blockchain
clarinet integrate

# Deploy to local environment
clarinet deploy --devnet

# Interactive console
clarinet console
```

## Deployment Guide

### Testnet Deployment

```bash
# Configure testnet settings in Clarinet.toml
clarinet deploy --testnet

# Verify deployment
clarinet contracts check --testnet
```

### Mainnet Deployment

```bash
# Review contract one final time
clarinet check

# Deploy to mainnet
clarinet deploy --mainnet

# Confirm transaction
clarinet transactions list
```

## Error Reference

| Code | Constant | Description |
|------|----------|-------------|
| u100 | `err-admin-privileges` | Requires platform administrator access |
| u101 | `err-resource-missing` | Referenced plot or record not found |
| u102 | `err-duplicate-record` | Assessment or achievement already exists |
| u103 | `err-permission-denied` | Operation not authorized for caller |
| u104 | `err-validation-failed` | Input parameters failed validation |

## Roadmap

### Phase 1: Foundation (Q1 2025) ✅
- Core plot and yield tracking
- Token incentive system
- Basic achievement framework
- Community assessment mechanism

### Phase 2: Enhancement (Q2 2025)
- [ ] Advanced analytics dashboard
- [ ] Peer-to-peer token transfers
- [ ] Plot ownership marketplace
- [ ] Enhanced search and filtering

### Phase 3: Integration (Q3 2025)
- [ ] Mobile application (iOS/Android)
- [ ] Weather API integration
- [ ] Growing calendar automation
- [ ] Social networking features

### Phase 4: Expansion (Q4 2025)
- [ ] DAO governance structure
- [ ] Community fund management
- [ ] NFT cultivation certificates
- [ ] Multi-chain compatibility

## Contributing

We welcome contributions from developers, growers, and sustainability advocates!

### How to Contribute

1. **Fork** the repository
2. **Create** a feature branch (`git checkout -b feature/amazing-addition`)
3. **Commit** your changes (`git commit -m 'Add amazing feature'`)
4. **Push** to branch (`git push origin feature/amazing-addition`)
5. **Open** a Pull Request

### Contribution Guidelines

- Follow Clarity best practices and conventions
- Write comprehensive tests for new features
- Update documentation for API changes
- Ensure all tests pass before submission
- Use descriptive commit messages

### Code Review Process

1. Automated tests must pass
2. Peer review from core maintainers
3. Security audit for contract changes
4. Documentation review and update

## Community & Support

### Get Help

- **Documentation**: [docs.bloomhub.io](https://docs.bloomhub.io)
- **Discord**: [discord.gg/bloomhub](https://discord.gg/bloomhub)
- **Twitter**: [@BloomHubDAO](https://twitter.com/bloomhubdao)
- **Forum**: [forum.bloomhub.io](https://forum.bloomhub.io)
- **Email**: support@bloomhub.io

### Stay Updated

- Follow development on [GitHub](https://github.com/bloomhub)
- Join monthly community calls
- Subscribe to newsletter for updates
- Participate in governance discussions

## License

This project is licensed under the MIT License - see [LICENSE](LICENSE) file for details.

## Acknowledgments

- Built on [Stacks](https://www.stacks.co/) blockchain infrastructure
- Powered by [Clarity](https://clarity-lang.org/) smart contract language
- Inspired by sustainable urban agriculture movements worldwide
- Community-driven development and governance

## Disclaimer

**Important Notice**: BloomHub is a community platform for sharing agricultural information and does not provide professional agricultural advice. Users should follow local regulations regarding urban farming, food safety, and land use. Token rewards represent community recognition and should not be considered financial instruments. Always verify local laws before establishing growing operations.

---

**Growing Together, On-Chain** 🌱
