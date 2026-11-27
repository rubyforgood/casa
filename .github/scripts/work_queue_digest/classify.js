'use strict';

/**
 * Classification layer for Contributor Work Queue Digest.
 * Pure business logic with zero side-effects.
 * Uses only Node.js built-ins.
 */

function deriveWorkState(pr) {
  if (pr.isDraft) return 'DRAFT';
  const hasWipLabel = (pr.labels || []).some((l) => {
    const lower = l.toLowerCase();
    return lower.includes('status: wip') || lower.includes('wip') || lower.includes('not-ready-to-build');
  });
  return hasWipLabel ? 'DRAFT' : 'READY';
}

function derivePRType(pr) {
  const author = (pr.author || '').toLowerCase();
  const branch = (pr.headRefName || '').toLowerCase();
  const labels = (pr.labels || []).map((l) => l.toLowerCase());

  const isDepBot = author === 'dependabot[bot]' || author === 'dependabot' || author === 'renovate[bot]';
  const isDepBranch = branch.startsWith('dependabot/') || branch.startsWith('renovate/');
  const hasDepLabel = labels.some((l) =>
    l.includes('dependencies') || l.includes('devdependencies') || l.includes('github-actions') || l.includes('renovate')
  );

  return (isDepBot || isDepBranch || hasDepLabel) ? 'DEPENDENCY' : 'REGULAR';
}

function deriveReviewState(pr) {
  if (!pr.isReviewDecisionAvailable) {
    return 'UNKNOWN';
  }

  const decision = pr.githubReviewDecision;

  if (decision === 'APPROVED') return 'APPROVED';
  if (decision === 'CHANGES_REQUESTED') return 'CHANGES_REQUESTED';
  if (decision === 'REVIEW_REQUIRED') return 'REVIEW_REQUIRED';

  if (decision === null) {
    // Safeguard 2: only derive requests state if reviewRequests and reviews data are available and complete
    if (
      !pr.isReviewRequestsAvailable ||
      pr.isReviewsAvailable === false ||
      pr.isReviewRequestsComplete === false ||
      pr.isReviewsComplete === false
    ) {
      return 'UNKNOWN';
    }

    if (pr.reviewsCount === 0 && pr.reviewRequestsCount > 0) {
      return 'REVIEW_REQUESTED_NO_SUBMITTED_REVIEWS';
    }
    if (pr.reviewsCount === 0 && pr.reviewRequestsCount === 0) {
      return 'NO_REVIEWERS_REQUESTED';
    }

    return 'UNKNOWN';
  }

  return 'UNKNOWN';
}

function deriveAttentionFlags(pr) {
  const flags = new Set();
  const reasons = [];

  // 1. Dependency Attention
  if (pr.prType === 'DEPENDENCY') {
    flags.add('DEPENDENCY_ATTENTION');
    reasons.push('Automated dependency update');
  }

  // 2. CI Intervention: applies whenever CI is FAILING, including draft & dependency PRs
  if (pr.ciState === 'FAILING' || pr.ciState === 'FAILURE' || pr.ciState === 'ERROR') {
    flags.add('CI_INTERVENTION');
    reasons.push('Reported CI checks are failing');
  }

  // 3. Contributor Action
  if (pr.workState === 'READY' && pr.githubReviewDecision === 'CHANGES_REQUESTED') {
    flags.add('CONTRIBUTOR_ACTION');
    reasons.push('Reviewer requested changes');
  }

  // 4. Maintainer Review: requires REVIEW_REQUIRED and PASSING CI
  if (
    pr.workState === 'READY' &&
    (pr.ciState === 'PASSING' || pr.ciState === 'SUCCESS') &&
    pr.githubReviewDecision === 'REVIEW_REQUIRED'
  ) {
    flags.add('MAINTAINER_REVIEW');
    reasons.push('Required review gate open; reported CI passing');
  }

  // 5. Review & CI Clear: requires READY, APPROVED, and PASSING CI
  if (
    pr.workState === 'READY' &&
    (pr.ciState === 'PASSING' || pr.ciState === 'SUCCESS') &&
    pr.githubReviewDecision === 'APPROVED'
  ) {
    flags.add('REVIEW_AND_CI_CLEAR');
    reasons.push('Review approved and reported CI checks passing');
  }

  return {
    attentionFlags: Array.from(flags),
    attentionReasons: reasons
  };
}

/**
 * Extracts candidate issue references from PR text and branches.
 */
function extractCandidateReferences(pr) {
  const references = [];
  const seenNumbers = new Set();

  function addRef(numStr, confidence, intent, source) {
    const num = parseInt(numStr, 10);
    if (!num || num <= 0 || num > Number.MAX_SAFE_INTEGER || seenNumbers.has(num)) return;
    seenNumbers.add(num);
    references.push({ issueNumber: num, confidence, intent, source });
  }

  // 1. Confirmed native closing references
  for (const cNum of pr.confirmedClosingIssueNumbers || []) {
    addRef(cNum, 'CONFIRMED', 'RESOLVES', 'closingIssuesReferences');
  }

  // 2. Branch name match: e.g. 7307-delete-dead... or fix/7307-delete...
  const branch = pr.headRefName || '';
  const branchMatch = branch.match(/^(?:issue-)?([0-9]{3,5})-[a-z0-9-]+$/i) ||
                      branch.match(/^(?:fix|bug|feat|chore|perf)[/-]([0-9]{3,5})-[a-z0-9-]+$/i);
  if (branchMatch) {
    addRef(branchMatch[1], 'HIGH_INFERRED', 'IMPLEMENTS', 'branch');
  }

  // 3. Title match: e.g. "Delete dead read_more.js (#7305)" or "7404 - Stop reporting..."
  const title = pr.title || '';
  const titleParensMatch = title.match(/\(#?([0-9]{3,5})\)$/);
  if (titleParensMatch) {
    addRef(titleParensMatch[1], 'HIGH_INFERRED', 'IMPLEMENTS', 'title');
  } else {
    const titlePrefixMatch = title.match(/^#?([0-9]{3,5})\s*[-:]\s+/);
    if (titlePrefixMatch) {
      addRef(titlePrefixMatch[1], 'HIGH_INFERRED', 'IMPLEMENTS', 'title');
    }
  }

  // 4. Body closing keywords: "Resolves #7305", "Fixes [[#7305](...)]"
  const body = pr.body || '';
  const closingRegex = /(?:^|\s)(?:resolves|fixes|closes)\s+(?:\[+)?(?:([a-zA-Z0-9_.-]+)\/([a-zA-Z0-9_.-]+))?#?([0-9]{3,5})/gi;
  let match;
  while ((match = closingRegex.exec(body)) !== null) {
    const owner = match[1];
    const repo = match[2];
    if (owner && repo && (owner.toLowerCase() !== 'rubyforgood' || repo.toLowerCase() !== 'casa')) {
      continue;
    }
    addRef(match[3], 'HIGH_INFERRED', 'IMPLEMENTS', 'body_closing');
  }

  // 5. Body mention keywords: "Part of #1017", "See #1234", "Addresses #7265"
  const mentionRegex = /(?:^|\s)(?:see|part of|ref|addresses|reverts)\s+(?:\[+)?(?:([a-zA-Z0-9_.-]+)\/([a-zA-Z0-9_.-]+))?#?([0-9]{3,5})/gi;
  while ((match = mentionRegex.exec(body)) !== null) {
    const owner = match[1];
    const repo = match[2];
    if (owner && repo && (owner.toLowerCase() !== 'rubyforgood' || repo.toLowerCase() !== 'casa')) {
      continue;
    }
    addRef(match[3], 'LOW_MENTION', 'MENTIONS', 'body_mention');
  }

  return references;
}

/**
 * Validates candidate references against open issues, open PRs, and batch resolved map.
 */
function validateRelationships({
  candidateRefs,
  openIssuesMap,
  openPRsMap,
  resolvedBatchMap
}) {
  const validated = [];

  for (const ref of candidateRefs) {
    const num = ref.issueNumber;

    // Reject if number belongs to an open Pull Request
    if (openPRsMap.has(num)) {
      continue;
    }

    // Check open issues
    if (openIssuesMap.has(num)) {
      const issue = openIssuesMap.get(num);
      validated.push({
        ...ref,
        issueState: 'OPEN',
        issueTitle: issue.title
      });
      continue;
    }

    // Check batch resolved entities
    if (resolvedBatchMap && resolvedBatchMap.has(num)) {
      const resolved = resolvedBatchMap.get(num);
      if (resolved.isPR) {
        // Discard: It is a PR
        continue;
      }
      if (resolved.state === 'NOT_FOUND') {
        validated.push({
          ...ref,
          issueState: 'NOT_FOUND'
        });
      } else {
        validated.push({
          ...ref,
          issueState: resolved.state || 'UNVERIFIED',
          issueTitle: resolved.title || ''
        });
      }
      continue;
    }

    // Unverified fallback
    validated.push({
      ...ref,
      issueState: 'UNVERIFIED'
    });
  }

  return validated;
}

/**
 * Top-level classification orchestrator.
 */
function classifyBacklog({
  normalizedIssues = [],
  normalizedPRs = [],
  normalizedMergedPRs = [],
  resolvedBatchMap = new Map(),
  metrics = {}
}) {
  const openIssuesMap = new Map(normalizedIssues.map((i) => [i.number, i]));
  const openPRsMap = new Map(normalizedPRs.map((p) => [p.number, p]));

  // 1. Classify Pull Requests
  const classifiedPRs = normalizedPRs.map((pr) => {
    const workState = deriveWorkState(pr);
    const prType = derivePRType(pr);
    const reviewState = deriveReviewState(pr);
    const { attentionFlags, attentionReasons } = deriveAttentionFlags({
      ...pr,
      workState,
      prType,
      inferredReviewState: reviewState
    });

    const candidateRefs = extractCandidateReferences(pr);
    const relationships = validateRelationships({
      candidateRefs,
      openIssuesMap,
      openPRsMap,
      resolvedBatchMap
    });

    return {
      ...pr,
      workState,
      prType,
      reviewState,
      attentionFlags,
      attentionReasons,
      relationships
    };
  });

  // 2. Identify Contributor Opportunities
  const unassignedGoodFirstIssues = normalizedIssues.filter(
    (i) =>
      i.isGoodFirstIssue &&
      i.isAssigneesAvailable === true &&
      i.assigneesTotal === 0 &&
      Array.isArray(i.assignees) &&
      i.assignees.length === 0
  );
  const unassignedHelpWantedIssues = normalizedIssues.filter(
    (i) =>
      i.isHelpWanted &&
      i.isAssigneesAvailable === true &&
      i.assigneesTotal === 0 &&
      Array.isArray(i.assignees) &&
      i.assignees.length === 0
  );

  // 3. Competing PRs Detection
  const issueToPRsMap = new Map();
  for (const pr of classifiedPRs) {
    for (const rel of pr.relationships) {
      if (rel.issueState === 'OPEN') {
        if (!issueToPRsMap.has(rel.issueNumber)) {
          issueToPRsMap.set(rel.issueNumber, []);
        }
        issueToPRsMap.get(rel.issueNumber).push({
          prNumber: pr.number,
          confidence: rel.confidence,
          source: rel.source,
          closingIssuesOverflow: Boolean(pr.closingIssuesOverflow),
          omittedClosingCount: pr.omittedClosingIssuesCount || 0,
          isClosingIssuesComplete: Boolean(pr.isClosingIssuesComplete)
        });
      }
    }
  }

  const competingPRs = [];
  for (const [issueNum, prList] of issueToPRsMap.entries()) {
    if (prList.length > 1) {
      competingPRs.push({
        issueNumber: issueNum,
        prs: prList
      });
    }
  }

  // 4. Classify Merged PRs & Potentially Resolved Issues Detection
  const potentiallyResolvedIssues = [];
  const classifiedMergedPRs = normalizedMergedPRs.map((mpr) => {
    const candidateRefs = extractCandidateReferences(mpr);
    const relationships = validateRelationships({
      candidateRefs,
      openIssuesMap,
      openPRsMap,
      resolvedBatchMap
    });

    const linkedIssues = relationships.map((rel) => ({
      number: rel.issueNumber,
      title: rel.issueTitle || '',
      state: rel.issueState,
      isClosed: rel.issueState === 'CLOSED',
      confidence: rel.confidence,
      source: rel.source,
      status: rel.confidence === 'CONFIRMED' ? 'CONFIRMED' : (rel.issueState === 'UNVERIFIED' ? 'UNVERIFIED' : 'INFERRED')
    }));

    for (const rel of relationships) {
      if (rel.issueState === 'OPEN') {
        potentiallyResolvedIssues.push({
          issueNumber: rel.issueNumber,
          issueTitle: rel.issueTitle || openIssuesMap.get(rel.issueNumber)?.title || '',
          mergedPRNumber: mpr.number,
          mergedAt: mpr.mergedAt,
          confidence: rel.confidence,
          source: rel.source,
          closingIssuesOverflow: Boolean(mpr.closingIssuesOverflow),
          omittedClosingCount: mpr.omittedClosingIssuesCount || 0,
          isClosingIssuesComplete: Boolean(mpr.isClosingIssuesComplete)
        });
      }
    }

    return {
      ...mpr,
      relationships,
      linkedIssues
    };
  });

  // 5. Audit & calculate relationship metrics covering both open and merged PRs exactly once
  let confirmedCount = 0;
  let inferredCount = 0;
  let unverifiedCount = 0;

  for (const pr of classifiedPRs) {
    for (const rel of pr.relationships || []) {
      if (rel.confidence === 'CONFIRMED') {
        confirmedCount++;
      } else if (rel.confidence === 'HIGH_INFERRED' || rel.confidence === 'LOW_MENTION') {
        if (rel.issueState === 'OPEN' || rel.issueState === 'CLOSED') {
          inferredCount++;
        } else {
          unverifiedCount++;
        }
      }
    }
  }

  for (const mpr of classifiedMergedPRs) {
    for (const rel of mpr.relationships || []) {
      if (rel.confidence === 'CONFIRMED') {
        confirmedCount++;
      } else if (rel.confidence === 'HIGH_INFERRED' || rel.confidence === 'LOW_MENTION') {
        if (rel.issueState === 'OPEN' || rel.issueState === 'CLOSED') {
          inferredCount++;
        } else {
          unverifiedCount++;
        }
      }
    }
  }

  metrics.confirmedCount = confirmedCount;
  metrics.inferredCount = inferredCount;
  metrics.unverifiedCount = unverifiedCount;

  return {
    classifiedPRs,
    classifiedMergedPRs,
    opportunities: {
      goodFirst: unassignedGoodFirstIssues,
      helpWanted: unassignedHelpWantedIssues
    },
    relationships: {
      competingPRs,
      potentiallyResolvedIssues
    },
    metrics
  };
}

module.exports = {
  deriveWorkState,
  derivePRType,
  deriveReviewState,
  deriveAttentionFlags,
  extractCandidateReferences,
  validateRelationships,
  classifyBacklog
};
