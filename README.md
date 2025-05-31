# ClinicalTrialData

A blockchain-based platform for secure clinical trial data management built on the Stacks blockchain.

## Overview

ClinicalTrialData provides a secure, transparent, and auditable system for managing clinical trial data. The platform ensures data integrity, proper access controls, and complete traceability of all research activities.

## Features

- Secure registration and management of clinical trials
- Cryptographic verification of data integrity
- Granular access control for researchers
- Complete audit trail of all data submissions
- Transparent trial status tracking

## Smart Contract Functions

- `register-trial`: Create a new clinical trial in the system
- `update-trial-status`: Update the status of a trial (e.g., "recruiting", "active", "completed")
- `add-data-point`: Submit a new data point to a clinical trial
- `grant-researcher-access`: Provide access to a researcher with specific permissions
- `revoke-researcher-access`: Remove a researcher's access to trial data
- `get-trial-details`: Retrieve information about a clinical trial
- `get-data-point`: Access a specific data point from a trial
- `check-researcher-access`: Verify a researcher's access level for a trial

## Getting Started

1. Clone this repository
2. Install Clarinet: `npm install -g @stacks/clarinet`
3. Run tests: `clarinet test`

## Security Considerations

- The contract stores only hashes of data, not the actual trial data
- Granular access control with different permission levels
- Complete audit trail of all data submissions and access grants
- Only the principal investigator can manage researcher access