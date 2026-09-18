enum CommitmentState {
  possibility,
  tentative,
  conditional,
  apparentCommitment,
  confirmed;

  static CommitmentState? fromLabel(String? label) {
    switch (label?.toUpperCase().trim()) {
      case 'POSSIBILITY':
        return CommitmentState.possibility;
      case 'TENTATIVE':
        return CommitmentState.tentative;
      case 'CONDITIONAL':
        return CommitmentState.conditional;
      case 'APPARENT_COMMITMENT':
        return CommitmentState.apparentCommitment;
      case 'CONFIRMED':
        return CommitmentState.confirmed;
      default:
        return null;
    }
  }

  String get label {
    switch (this) {
      case CommitmentState.possibility:
        return 'POSSIBILITY';
      case CommitmentState.tentative:
        return 'TENTATIVE';
      case CommitmentState.conditional:
        return 'CONDITIONAL';
      case CommitmentState.apparentCommitment:
        return 'APPARENT_COMMITMENT';
      case CommitmentState.confirmed:
        return 'CONFIRMED';
    }
  }

  String get displayName {
    switch (this) {
      case CommitmentState.possibility:
        return 'Possibility';
      case CommitmentState.tentative:
        return 'Tentative';
      case CommitmentState.conditional:
        return 'Conditional';
      case CommitmentState.apparentCommitment:
        return 'Apparent Commitment';
      case CommitmentState.confirmed:
        return 'Confirmed';
    }
  }

  int get rank {
    switch (this) {
      case CommitmentState.possibility:
        return 1;
      case CommitmentState.tentative:
        return 2;
      case CommitmentState.conditional:
        return 3;
      case CommitmentState.apparentCommitment:
        return 4;
      case CommitmentState.confirmed:
        return 5;
    }
  }

  bool isHigherThan(CommitmentState other) => rank > other.rank;
}