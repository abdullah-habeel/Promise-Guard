class DriftCheckResult {
  final bool driftDetected;
  final String term;
  final String stateLabel;
  final String matchedLine;

  const DriftCheckResult({
    required this.driftDetected,
    required this.term,
    required this.stateLabel,
    required this.matchedLine,
  });
}

class LiveDriftChecker {
  // Tentative patterns — early soft commitment
  static const _tentativePatterns = [
    'i think we can',
    'i think we could',
    'probably around',
    'roughly',
    'i could probably',
    'should be around',
    'i believe we can',
    'most likely',
    'i think so',
    'we might be able',
    'around that price',
    'somewhere around',
    'approximately',
  ];

  // Conditional patterns — depends on something
  static const _conditionalPatterns = [
    'subject to',
    'if finance',
    'if we get approval',
    'pending approval',
    'assuming approval',
    'if management agrees',
    'once approved',
    'contingent on',
    'depending on',
    'as long as',
    'provided that',
    'if the budget',
  ];

  // Apparent commitment patterns — assumed without confirmation
  static const _apparentCommitmentPatterns = [
    'so we are going with',
    'so we agreed',
    'as we discussed',
    'like we said',
    'as mentioned',
    'that should work',
    'yeah that works',
    'sounds good',
    'we will go ahead',
    'let us go with',
    'so the price is',
    'so delivery is',
    'we can do that',
    'i will make it happen',
    'consider it done',
    'that is confirmed',
    'we are good to go',
    'i will get that for you',
  ];

  /// Check a list of committed lines for drift signals.
  /// Returns the first drift signal found, or no drift if clean.
  static DriftCheckResult check(List<String> lines) {
    // We only look at the last 15 lines max
    final window = lines.length > 15
        ? lines.sublist(lines.length - 15)
        : lines;

    // First scan for tentative/conditional earlier in the window
    bool hasEarlierWeakCommitment = false;
    for (final line in window.take(window.length - 1)) {
      final lower = line.toLowerCase();
      for (final pattern in _tentativePatterns) {
        if (lower.contains(pattern)) {
          hasEarlierWeakCommitment = true;
          break;
        }
      }
      if (!hasEarlierWeakCommitment) {
        for (final pattern in _conditionalPatterns) {
          if (lower.contains(pattern)) {
            hasEarlierWeakCommitment = true;
            break;
          }
        }
      }
    }

    // Then check the most recent lines for apparent commitment
    final recentLines = window.length > 5
        ? window.sublist(window.length - 5)
        : window;

    for (final line in recentLines) {
      final lower = line.toLowerCase();
      for (final pattern in _apparentCommitmentPatterns) {
        if (lower.contains(pattern)) {
          // Drift = earlier weak commitment + later apparent commitment
          if (hasEarlierWeakCommitment) {
            return DriftCheckResult(
              driftDetected: true,
              term: _extractTerm(line),
              stateLabel: 'TENTATIVE → APPARENT COMMITMENT',
              matchedLine: line,
            );
          }
          // Even without earlier weak commitment, flag apparent commitment alone
          return DriftCheckResult(
            driftDetected: true,
            term: _extractTerm(line),
            stateLabel: 'APPARENT COMMITMENT',
            matchedLine: line,
          );
        }
      }
    }

    return const DriftCheckResult(
      driftDetected: false,
      term: '',
      stateLabel: '',
      matchedLine: '',
    );
  }

  /// Try to extract a commercial term from the line.
  /// Looks for price, delivery, quantity, discount signals.
  static String _extractTerm(String line) {
    final lower = line.toLowerCase();
    if (lower.contains(r'$') ||
        lower.contains('price') ||
        lower.contains('cost') ||
        lower.contains('rate') ||
        lower.contains('discount')) {
      return 'Pricing';
    }
    if (lower.contains('deliver') ||
        lower.contains('ship') ||
        lower.contains('date') ||
        lower.contains('deadline')) {
      return 'Delivery';
    }
    if (lower.contains('unit') ||
        lower.contains('quantity') ||
        lower.contains('amount') ||
        lower.contains('units')) {
      return 'Quantity';
    }
    if (lower.contains('install') ||
        lower.contains('support') ||
        lower.contains('service') ||
        lower.contains('include')) {
      return 'Scope';
    }
    return 'Commercial Term';
  }
}