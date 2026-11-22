'use strict';

const test = require('node:test');
const assert = require('node:assert/strict');

const {
  deriveWorkState,
  derivePRType,
  deriveReviewState,
  deriveAttentionFlags,
  extractCandidateReferences,
  validateRelationships,
  classifyBacklog
} = require('../classify');

test('deriveWorkState: distinguishes draft and ready states', () => {
  assert.equal(deriveWorkState({ isDraft: true }), 'DRAFT');
  assert.equal(deriveWorkState({ isDraft: false, labels: ['Status: WIP'] }), 'DRAFT');
  assert.equal(deriveWorkState({ isDraft: false, labels: ['not-ready-to-build'] }), 'DRAFT');
  assert.equal(deriveWorkState({ isDraft: false, labels: ['backend', 'ruby'] }), 'READY');
});

test('derivePRType: identifies automated dependency updates independently', () => {
  assert.equal(derivePRType({ author: 'dependabot[bot]' }), 'DEPENDENCY');
  assert.equal(derivePRType({ author: 'renovate[bot]' }), 'DEPENDENCY');
  assert.equal(derivePRType({ headRefName: 'dependabot/npm/lodash-4.17.21' }), 'DEPENDENCY');
  assert.equal(derivePRType({ labels: ['dependencies'] }), 'DEPENDENCY');
  assert.equal(derivePRType({ author: 'contributor', headRefName: 'feature/new-button', labels: ['ui'] }), 'REGULAR');
});

test('deriveReviewState: handles reviewDecision and reviewRequests completeness', () => {
  // 1. Authoritative decisions
  assert.equal(deriveReviewState({ isReviewDecisionAvailable: true, githubReviewDecision: 'APPROVED' }), 'APPROVED');
  assert.equal(deriveReviewState({ isReviewDecisionAvailable: true, githubReviewDecision: 'CHANGES_REQUESTED' }), 'CHANGES_REQUESTED');
  assert.equal(deriveReviewState({ isReviewDecisionAvailable: true, githubReviewDecision: 'REVIEW_REQUIRED' }), 'REVIEW_REQUIRED');

  // 2. Errored or unavailable reviewDecision
  assert.equal(deriveReviewState({ isReviewDecisionAvailable: false }), 'UNKNOWN');

  // 3. Safeguard 2: Clean null reviewDecision requires complete reviewRequests data
  assert.equal(deriveReviewState({
    isReviewDecisionAvailable: true,
    githubReviewDecision: null,
    isReviewRequestsAvailable: false
  }), 'UNKNOWN');

  // 4. Clean null with complete reviewRequests
  assert.equal(deriveReviewState({
    isReviewDecisionAvailable: true,
    githubReviewDecision: null,
    isReviewRequestsAvailable: true,
    reviewsCount: 0,
    reviewRequestsCount: 2
  }), 'REVIEW_REQUESTED_NO_SUBMITTED_REVIEWS');

  assert.equal(deriveReviewState({
    isReviewDecisionAvailable: true,
    githubReviewDecision: null,
    isReviewRequestsAvailable: true,
    reviewsCount: 0,
    reviewRequestsCount: 0
  }), 'NO_REVIEWERS_REQUESTED');
});

test('Attention Truth Table: comprehensive coverage of all 17 scenarios', () => {
  function testRow({ workState, reviewDecision, ciState, prType = 'REGULAR', expectedFlags }) {
    const pr = {
      workState,
      githubReviewDecision: reviewDecision,
      ciState,
      prType,
      isReviewDecisionAvailable: true,
      isReviewRequestsAvailable: true
    };
    const { attentionFlags } = deriveAttentionFlags(pr);
    assert.deepEqual(attentionFlags.sort(), expectedFlags.sort(), `Failed for ${JSON.stringify(pr)}`);
  }

  // Row 1: Ready, Approved, Passing CI, Regular -> REVIEW_AND_CI_CLEAR
  testRow({
    workState: 'READY',
    reviewDecision: 'APPROVED',
    ciState: 'PASSING',
    expectedFlags: ['REVIEW_AND_CI_CLEAR']
  });

  // Row 2: Ready, Approved, Failing CI, Regular -> CI_INTERVENTION (NO REVIEW_AND_CI_CLEAR)
  testRow({
    workState: 'READY',
    reviewDecision: 'APPROVED',
    ciState: 'FAILING',
    expectedFlags: ['CI_INTERVENTION']
  });

  // Row 3: Ready, Approved, Pending CI -> None
  testRow({
    workState: 'READY',
    reviewDecision: 'APPROVED',
    ciState: 'PENDING',
    expectedFlags: []
  });

  // Row 4: Ready, Approved, Unknown CI -> None (unknown CI blocks REVIEW_AND_CI_CLEAR)
  testRow({
    workState: 'READY',
    reviewDecision: 'APPROVED',
    ciState: 'UNKNOWN',
    expectedFlags: []
  });

  // Row 5: Ready, Changes Requested, Passing CI -> CONTRIBUTOR_ACTION
  testRow({
    workState: 'READY',
    reviewDecision: 'CHANGES_REQUESTED',
    ciState: 'PASSING',
    expectedFlags: ['CONTRIBUTOR_ACTION']
  });

  // Row 6: Ready, Changes Requested, Failing CI -> CONTRIBUTOR_ACTION, CI_INTERVENTION
  testRow({
    workState: 'READY',
    reviewDecision: 'CHANGES_REQUESTED',
    ciState: 'FAILING',
    expectedFlags: ['CONTRIBUTOR_ACTION', 'CI_INTERVENTION']
  });

  // Row 7: Ready, Review Required, Passing CI -> MAINTAINER_REVIEW
  testRow({
    workState: 'READY',
    reviewDecision: 'REVIEW_REQUIRED',
    ciState: 'PASSING',
    expectedFlags: ['MAINTAINER_REVIEW']
  });

  // Row 8: Ready, Review Required, Failing CI -> CI_INTERVENTION
  testRow({
    workState: 'READY',
    reviewDecision: 'REVIEW_REQUIRED',
    ciState: 'FAILING',
    expectedFlags: ['CI_INTERVENTION']
  });

  // Row 9: Ready, Review Required, Pending CI -> None
  testRow({
    workState: 'READY',
    reviewDecision: 'REVIEW_REQUIRED',
    ciState: 'PENDING',
    expectedFlags: []
  });

  // Row 10: Ready, Review Required, Unknown CI -> None
  testRow({
    workState: 'READY',
    reviewDecision: 'REVIEW_REQUIRED',
    ciState: 'UNKNOWN',
    expectedFlags: []
  });

  // Row 11: Ready, null decision, Passing CI -> None
  testRow({
    workState: 'READY',
    reviewDecision: null,
    ciState: 'PASSING',
    expectedFlags: []
  });

  // Row 12: Ready, Approved, Passing CI, Dependency -> REVIEW_AND_CI_CLEAR, DEPENDENCY_ATTENTION
  testRow({
    workState: 'READY',
    reviewDecision: 'APPROVED',
    ciState: 'PASSING',
    prType: 'DEPENDENCY',
    expectedFlags: ['REVIEW_AND_CI_CLEAR', 'DEPENDENCY_ATTENTION']
  });

  // Row 13: Ready, Review Required, Failing CI, Dependency -> CI_INTERVENTION, DEPENDENCY_ATTENTION
  testRow({
    workState: 'READY',
    reviewDecision: 'REVIEW_REQUIRED',
    ciState: 'FAILING',
    prType: 'DEPENDENCY',
    expectedFlags: ['CI_INTERVENTION', 'DEPENDENCY_ATTENTION']
  });

  // Row 14: Draft, Failing CI, Regular -> CI_INTERVENTION (draft does not suppress CI failure)
  testRow({
    workState: 'DRAFT',
    reviewDecision: 'APPROVED',
    ciState: 'FAILING',
    expectedFlags: ['CI_INTERVENTION']
  });

  // Row 15: Draft, Passing CI, Regular -> None (draft suppresses REVIEW_AND_CI_CLEAR)
  testRow({
    workState: 'DRAFT',
    reviewDecision: 'APPROVED',
    ciState: 'PASSING',
    expectedFlags: []
  });

  // Row 16: Draft, Failing CI, Dependency -> CI_INTERVENTION, DEPENDENCY_ATTENTION
  testRow({
    workState: 'DRAFT',
    reviewDecision: null,
    ciState: 'FAILING',
    prType: 'DEPENDENCY',
    expectedFlags: ['CI_INTERVENTION', 'DEPENDENCY_ATTENTION']
  });

  // Row 17: Draft, Passing CI, Dependency -> DEPENDENCY_ATTENTION (draft suppresses REVIEW_AND_CI_CLEAR)
  testRow({
    workState: 'DRAFT',
    reviewDecision: 'APPROVED',
    ciState: 'PASSING',
    prType: 'DEPENDENCY',
    expectedFlags: ['DEPENDENCY_ATTENTION']
  });
});

test('extractCandidateReferences: extracts confirmed and inferred references while respecting boundaries', () => {
  const pr = {
    headRefName: '7307-delete-dead-validated-form-js',
    title: 'Delete dead read_more.js (#7305)',
    body: 'Resolves [[#7305](https://github.com/rubyforgood/casa/issues/7305)]\nAlso see #1234 and external org/other#999',
    confirmedClosingIssueNumbers: [7443]
  };

  const refs = extractCandidateReferences(pr);
  const numbers = refs.map((r) => r.issueNumber);

  // Confirmed
  assert.equal(numbers.includes(7443), true);
  // Branch match
  assert.equal(numbers.includes(7307), true);
  // Title match
  assert.equal(numbers.includes(7305), true);
  // Body mention
  assert.equal(numbers.includes(1234), true);
  // Cross-repo ignored
  assert.equal(numbers.includes(999), false);
});

test('validateRelationships: rejects PR numbers from being treated as issue links', () => {
  const candidateRefs = [
    { issueNumber: 7305, confidence: 'HIGH_INFERRED', intent: 'IMPLEMENTS', source: 'title' },
    { issueNumber: 7334, confidence: 'HIGH_INFERRED', intent: 'IMPLEMENTS', source: 'title' }
  ];

  const openIssuesMap = new Map([[7305, { number: 7305, title: 'Issue 7305' }]]);
  const openPRsMap = new Map([[7334, { number: 7334, title: 'PR 7334' }]]);

  const validated = validateRelationships({
    candidateRefs,
    openIssuesMap,
    openPRsMap,
    resolvedBatchMap: new Map()
  });

  // 7305 is kept
  assert.equal(validated.some((v) => v.issueNumber === 7305), true);
  // 7334 (a PR) is rejected
  assert.equal(validated.some((v) => v.issueNumber === 7334), false);
});

test('classifyBacklog: excludes issues with unavailable assignee data from contributor opportunities', () => {
  const normalizedIssues = [
    {
      number: 1001,
      title: 'Good First Issue with Available Empty Assignees',
      isGoodFirstIssue: true,
      isHelpWanted: false,
      isAssigneesAvailable: true,
      assigneesTotal: 0,
      assignees: []
    },
    {
      number: 1002,
      title: 'Good First Issue with Unavailable Assignees (Error/Missing)',
      isGoodFirstIssue: true,
      isHelpWanted: false,
      isAssigneesAvailable: false,
      assigneesTotal: 0,
      assignees: []
    },
    {
      number: 1003,
      title: 'Help Wanted with Unavailable Assignees',
      isGoodFirstIssue: false,
      isHelpWanted: true,
      isAssigneesAvailable: false,
      assigneesTotal: 0,
      assignees: []
    },
    {
      number: 1004,
      title: 'Help Wanted with Available Empty Assignees',
      isGoodFirstIssue: false,
      isHelpWanted: true,
      isAssigneesAvailable: true,
      assigneesTotal: 0,
      assignees: []
    }
  ];

  const result = classifyBacklog({
    normalizedIssues,
    normalizedPRs: [],
    normalizedMergedPRs: [],
    resolvedBatchMap: new Map()
  });

  const goodFirstNums = result.opportunities.goodFirst.map((i) => i.number);
  const helpWantedNums = result.opportunities.helpWanted.map((i) => i.number);

  // 1001 is included, 1002 (unavailable) is excluded
  assert.equal(goodFirstNums.includes(1001), true);
  assert.equal(goodFirstNums.includes(1002), false);

  // 1004 is included, 1003 (unavailable) is excluded
  assert.equal(helpWantedNums.includes(1004), true);
  assert.equal(helpWantedNums.includes(1003), false);
});

test('classifyBacklog: preserves closing relationship overflow and omitted counts in cross-references', () => {
  const normalizedIssues = [
    { number: 5001, title: 'Open Issue 5001', isGoodFirstIssue: false, isHelpWanted: false, isAssigneesAvailable: true, assignees: [] },
    { number: 5002, title: 'Open Issue 5002', isGoodFirstIssue: false, isHelpWanted: false, isAssigneesAvailable: true, assignees: [] }
  ];

  const normalizedPRs = [
    {
      number: 6001,
      title: 'PR 1 Addressing 5001',
      isDraft: false,
      author: 'contributor1',
      confirmedClosingIssueNumbers: [5001],
      closingIssuesOverflow: true,
      omittedClosingIssuesCount: 4,
      body: 'Closes #5001'
    },
    {
      number: 6002,
      title: 'PR 2 Addressing 5001',
      isDraft: false,
      author: 'contributor2',
      confirmedClosingIssueNumbers: [5001],
      closingIssuesOverflow: false,
      omittedClosingIssuesCount: 0,
      body: 'Resolves #5001'
    }
  ];

  const normalizedMergedPRs = [
    {
      number: 6500,
      title: 'Merged PR referencing 5002',
      mergedAt: '2026-11-20T10:00:00Z',
      confirmedClosingIssueNumbers: [5002],
      closingIssuesOverflow: true,
      omittedClosingIssuesCount: 3,
      body: 'Resolves #5002'
    }
  ];

  const result = classifyBacklog({
    normalizedIssues,
    normalizedPRs,
    normalizedMergedPRs,
    resolvedBatchMap: new Map()
  });

  // Verify competing PRs retain closingIssuesOverflow and omittedClosingCount
  const competing = result.relationships.competingPRs.find((c) => c.issueNumber === 5001);
  assert.equal(Boolean(competing), true);
  const pr6001 = competing.prs.find((p) => p.prNumber === 6001);
  assert.equal(pr6001.closingIssuesOverflow, true);
  assert.equal(pr6001.omittedClosingCount, 4);

  // Verify potentially resolved issues retain closingIssuesOverflow
  const potResolved = result.relationships.potentiallyResolvedIssues.find((r) => r.issueNumber === 5002);
  assert.equal(Boolean(potResolved), true);
  assert.equal(potResolved.closingIssuesOverflow, true);
  assert.equal(potResolved.omittedClosingCount, 3);
});

test('Finding #6: classifyBacklog excludes issues with positive assigneesTotal or unavailable data from contributor opportunities', () => {
  const normalizedIssues = [
    {
      number: 2001,
      title: 'Explicitly unassigned (total 0, empty list)',
      isGoodFirstIssue: true,
      isHelpWanted: false,
      isAssigneesAvailable: true,
      assigneesTotal: 0,
      assignees: []
    },
    {
      number: 2002,
      title: 'Positive totalCount but empty list (ghost user/unavailable)',
      isGoodFirstIssue: true,
      isHelpWanted: false,
      isAssigneesAvailable: false,
      assigneesTotal: 1,
      assignees: []
    },
    {
      number: 2003,
      title: 'Accidental available flag with positive assigneesTotal',
      isGoodFirstIssue: true,
      isHelpWanted: false,
      isAssigneesAvailable: true,
      assigneesTotal: 1,
      assignees: []
    },
    {
      number: 2004,
      title: 'Clean unassigned help wanted',
      isGoodFirstIssue: false,
      isHelpWanted: true,
      isAssigneesAvailable: true,
      assigneesTotal: 0,
      assignees: []
    },
    {
      number: 2005,
      title: 'Help wanted with missing assigneesTotal',
      isGoodFirstIssue: false,
      isHelpWanted: true,
      isAssigneesAvailable: true,
      assigneesTotal: null,
      assignees: []
    }
  ];

  const result = classifyBacklog({
    normalizedIssues,
    normalizedPRs: [],
    normalizedMergedPRs: [],
    resolvedBatchMap: new Map()
  });

  const goodFirstNums = result.opportunities.goodFirst.map((i) => i.number);
  const helpWantedNums = result.opportunities.helpWanted.map((i) => i.number);

  // 2001 is included; 2002 and 2003 are excluded
  assert.equal(goodFirstNums.includes(2001), true);
  assert.equal(goodFirstNums.includes(2002), false);
  assert.equal(goodFirstNums.includes(2003), false);

  // 2004 is included; 2005 is excluded
  assert.equal(helpWantedNums.includes(2004), true);
  assert.equal(helpWantedNums.includes(2005), false);
});

test('Phase 2F Finding A: Comprehensive Good First and Help Wanted assignee classification (all 6 cases)', () => {
  // Test all 6 cases for Good First Issue
  const gfIssues = [
    // 1. Available connection, totalCount 0, empty nodes -> included
    { number: 3001, isGoodFirstIssue: true, isHelpWanted: false, isAssigneesAvailable: true, assigneesTotal: 0, assignees: [] },
    // 2. Available connection, totalCount null, empty nodes -> excluded
    { number: 3002, isGoodFirstIssue: true, isHelpWanted: false, isAssigneesAvailable: true, assigneesTotal: null, assignees: [] },
    // 3. Unavailable connection -> excluded
    { number: 3003, isGoodFirstIssue: true, isHelpWanted: false, isAssigneesAvailable: false, assigneesTotal: 0, assignees: [] },
    // 4. Positive totalCount with empty normalized nodes -> excluded
    { number: 3004, isGoodFirstIssue: true, isHelpWanted: false, isAssigneesAvailable: true, assigneesTotal: 1, assignees: [] },
    // 5. Positive totalCount with actual assignee -> excluded
    { number: 3005, isGoodFirstIssue: true, isHelpWanted: false, isAssigneesAvailable: true, assigneesTotal: 1, assignees: ['alice'] },
    // 6. Missing or malformed assignee array -> excluded
    { number: 3006, isGoodFirstIssue: true, isHelpWanted: false, isAssigneesAvailable: true, assigneesTotal: 0, assignees: null },
    { number: 3007, isGoodFirstIssue: true, isHelpWanted: false, isAssigneesAvailable: true, assigneesTotal: 0, assignees: 'invalid-string' }
  ];

  // Test all 6 cases for Help Wanted
  const hwIssues = [
    // 1. Available connection, totalCount 0, empty nodes -> included
    { number: 3101, isGoodFirstIssue: false, isHelpWanted: true, isAssigneesAvailable: true, assigneesTotal: 0, assignees: [] },
    // 2. Available connection, totalCount null, empty nodes -> excluded
    { number: 3102, isGoodFirstIssue: false, isHelpWanted: true, isAssigneesAvailable: true, assigneesTotal: null, assignees: [] },
    // 3. Unavailable connection -> excluded
    { number: 3103, isGoodFirstIssue: false, isHelpWanted: true, isAssigneesAvailable: false, assigneesTotal: 0, assignees: [] },
    // 4. Positive totalCount with empty normalized nodes -> excluded
    { number: 3104, isGoodFirstIssue: false, isHelpWanted: true, isAssigneesAvailable: true, assigneesTotal: 1, assignees: [] },
    // 5. Positive totalCount with actual assignee -> excluded
    { number: 3105, isGoodFirstIssue: false, isHelpWanted: true, isAssigneesAvailable: true, assigneesTotal: 1, assignees: ['bob'] },
    // 6. Missing or malformed assignee array -> excluded
    { number: 3106, isGoodFirstIssue: false, isHelpWanted: true, isAssigneesAvailable: true, assigneesTotal: 0, assignees: null },
    { number: 3107, isGoodFirstIssue: false, isHelpWanted: true, isAssigneesAvailable: true, assigneesTotal: 0, assignees: 'invalid-string' }
  ];

  const resGF = classifyBacklog({ normalizedIssues: gfIssues });
  const gfNumbers = resGF.opportunities.goodFirst.map((i) => i.number);
  assert.equal(gfNumbers.includes(3001), true);
  assert.equal(gfNumbers.includes(3002), false);
  assert.equal(gfNumbers.includes(3003), false);
  assert.equal(gfNumbers.includes(3004), false);
  assert.equal(gfNumbers.includes(3005), false);
  assert.equal(gfNumbers.includes(3006), false);
  assert.equal(gfNumbers.includes(3007), false);

  const resHW = classifyBacklog({ normalizedIssues: hwIssues });
  const hwNumbers = resHW.opportunities.helpWanted.map((i) => i.number);
  assert.equal(hwNumbers.includes(3101), true);
  assert.equal(hwNumbers.includes(3102), false);
  assert.equal(hwNumbers.includes(3103), false);
  assert.equal(hwNumbers.includes(3104), false);
  assert.equal(hwNumbers.includes(3105), false);
  assert.equal(hwNumbers.includes(3106), false);
  assert.equal(hwNumbers.includes(3107), false);
});

test('Phase 2F Finding B: CHANGES_REQUESTED never relies on timestamps and requires contributor action (all 5 cases)', () => {
  // Case 1: CHANGES_REQUESTED with later latestCommitAt (latestCommitAt > latestReviewAt)
  // Must NOT promote back to MAINTAINER_REVIEW; remains CONTRIBUTOR_ACTION
  const prLaterCommit = {
    workState: 'READY',
    ciState: 'PASSING',
    githubReviewDecision: 'CHANGES_REQUESTED',
    latestCommitAt: '2026-11-20T15:00:00Z',
    latestReviewAt: '2026-11-19T10:00:00Z'
  };
  const res1 = deriveAttentionFlags(prLaterCommit);
  assert.equal(res1.attentionFlags.includes('CONTRIBUTOR_ACTION'), true);
  assert.equal(res1.attentionFlags.includes('MAINTAINER_REVIEW'), false);

  // Case 2: CHANGES_REQUESTED with earlier latestCommitAt (latestCommitAt < latestReviewAt)
  const prEarlierCommit = {
    workState: 'READY',
    ciState: 'PASSING',
    githubReviewDecision: 'CHANGES_REQUESTED',
    latestCommitAt: '2026-11-18T10:00:00Z',
    latestReviewAt: '2026-11-19T10:00:00Z'
  };
  const res2 = deriveAttentionFlags(prEarlierCommit);
  assert.equal(res2.attentionFlags.includes('CONTRIBUTOR_ACTION'), true);
  assert.equal(res2.attentionFlags.includes('MAINTAINER_REVIEW'), false);

  // Case 3: CHANGES_REQUESTED with missing timestamps
  const prMissingTimestamps = {
    workState: 'READY',
    ciState: 'PASSING',
    githubReviewDecision: 'CHANGES_REQUESTED',
    latestCommitAt: null,
    latestReviewAt: null
  };
  const res3 = deriveAttentionFlags(prMissingTimestamps);
  assert.equal(res3.attentionFlags.includes('CONTRIBUTOR_ACTION'), true);
  assert.equal(res3.attentionFlags.includes('MAINTAINER_REVIEW'), false);

  // Case 4: Other review states preserve their existing behavior
  const prReviewRequired = {
    workState: 'READY',
    ciState: 'PASSING',
    githubReviewDecision: 'REVIEW_REQUIRED'
  };
  const res4A = deriveAttentionFlags(prReviewRequired);
  assert.equal(res4A.attentionFlags.includes('MAINTAINER_REVIEW'), true);
  assert.equal(res4A.attentionFlags.includes('CONTRIBUTOR_ACTION'), false);

  const prApproved = {
    workState: 'READY',
    ciState: 'PASSING',
    githubReviewDecision: 'APPROVED'
  };
  const res4B = deriveAttentionFlags(prApproved);
  assert.equal(res4B.attentionFlags.includes('REVIEW_AND_CI_CLEAR'), true);
  assert.equal(res4B.attentionFlags.includes('CONTRIBUTOR_ACTION'), false);
  assert.equal(res4B.attentionFlags.includes('MAINTAINER_REVIEW'), false);

  // Case 5: Draft and failing-CI behavior remains unchanged
  const prDraftWithChanges = {
    workState: 'DRAFT',
    ciState: 'PASSING',
    githubReviewDecision: 'CHANGES_REQUESTED'
  };
  const res5A = deriveAttentionFlags(prDraftWithChanges);
  // Draft PRs do not enter CONTRIBUTOR_ACTION queue
  assert.equal(res5A.attentionFlags.includes('CONTRIBUTOR_ACTION'), false);

  const prFailingCIWithChanges = {
    workState: 'READY',
    ciState: 'FAILING',
    githubReviewDecision: 'CHANGES_REQUESTED'
  };
  const res5B = deriveAttentionFlags(prFailingCIWithChanges);
  // Failing CI triggers CI_INTERVENTION and keeps CONTRIBUTOR_ACTION
  assert.equal(res5B.attentionFlags.includes('CI_INTERVENTION'), true);
  assert.equal(res5B.attentionFlags.includes('CONTRIBUTOR_ACTION'), true);
  assert.equal(res5B.attentionFlags.includes('MAINTAINER_REVIEW'), false);
});

test('Phase 2G Finding A: Comprehensive Review and CI Classification truth table (all CI states and Draft vs Ready)', () => {
  function checkFlags({ workState, reviewDecision, ciState, prType = 'REGULAR', expected }) {
    const res = deriveAttentionFlags({
      workState,
      githubReviewDecision: reviewDecision,
      ciState,
      prType,
      isReviewDecisionAvailable: true,
      isReviewRequestsAvailable: true
    });
    assert.deepEqual(res.attentionFlags.sort(), expected.sort(), `Failed for ${workState} / ${reviewDecision} / ${ciState}`);
  }

  // 1. Ready + APPROVED + CI states
  checkFlags({ workState: 'READY', reviewDecision: 'APPROVED', ciState: 'SUCCESS', expected: ['REVIEW_AND_CI_CLEAR'] });
  checkFlags({ workState: 'READY', reviewDecision: 'APPROVED', ciState: 'PASSING', expected: ['REVIEW_AND_CI_CLEAR'] });
  checkFlags({ workState: 'READY', reviewDecision: 'APPROVED', ciState: 'FAILURE', expected: ['CI_INTERVENTION'] });
  checkFlags({ workState: 'READY', reviewDecision: 'APPROVED', ciState: 'ERROR', expected: ['CI_INTERVENTION'] });
  checkFlags({ workState: 'READY', reviewDecision: 'APPROVED', ciState: 'FAILING', expected: ['CI_INTERVENTION'] });
  checkFlags({ workState: 'READY', reviewDecision: 'APPROVED', ciState: 'PENDING', expected: [] });
  checkFlags({ workState: 'READY', reviewDecision: 'APPROVED', ciState: 'UNKNOWN', expected: [] });
  checkFlags({ workState: 'READY', reviewDecision: 'APPROVED', ciState: 'NO_CHECKS_CONFIRMED', expected: [] });

  // 2. Ready + REVIEW_REQUIRED + CI states
  checkFlags({ workState: 'READY', reviewDecision: 'REVIEW_REQUIRED', ciState: 'SUCCESS', expected: ['MAINTAINER_REVIEW'] });
  checkFlags({ workState: 'READY', reviewDecision: 'REVIEW_REQUIRED', ciState: 'PASSING', expected: ['MAINTAINER_REVIEW'] });
  checkFlags({ workState: 'READY', reviewDecision: 'REVIEW_REQUIRED', ciState: 'FAILURE', expected: ['CI_INTERVENTION'] });
  checkFlags({ workState: 'READY', reviewDecision: 'REVIEW_REQUIRED', ciState: 'ERROR', expected: ['CI_INTERVENTION'] });
  checkFlags({ workState: 'READY', reviewDecision: 'REVIEW_REQUIRED', ciState: 'FAILING', expected: ['CI_INTERVENTION'] });
  checkFlags({ workState: 'READY', reviewDecision: 'REVIEW_REQUIRED', ciState: 'PENDING', expected: [] });
  checkFlags({ workState: 'READY', reviewDecision: 'REVIEW_REQUIRED', ciState: 'UNKNOWN', expected: [] });
  checkFlags({ workState: 'READY', reviewDecision: 'REVIEW_REQUIRED', ciState: 'NO_CHECKS_CONFIRMED', expected: [] });

  // 3. Draft suppresses review queues regardless of CI
  checkFlags({ workState: 'DRAFT', reviewDecision: 'APPROVED', ciState: 'SUCCESS', expected: [] });
  checkFlags({ workState: 'DRAFT', reviewDecision: 'REVIEW_REQUIRED', ciState: 'SUCCESS', expected: [] });
  checkFlags({ workState: 'DRAFT', reviewDecision: 'APPROVED', ciState: 'FAILURE', expected: ['CI_INTERVENTION'] });
  checkFlags({ workState: 'DRAFT', reviewDecision: 'APPROVED', ciState: 'ERROR', expected: ['CI_INTERVENTION'] });
});

test('Phase 2G Finding D: Merged PR Relationship Resolution and Candidate Discrimination', () => {
  const openIssues = [
    { number: 8001, title: 'Open CASA Issue 8001' }
  ];
  const openPRs = [
    { number: 8005, title: 'Open PR 8005' }
  ];
  const resolvedBatch = new Map([
    [8002, { isIssue: true, isPR: false, state: 'CLOSED', title: 'Closed Issue 8002' }],
    [8003, { isIssue: true, isPR: false, state: 'UNVERIFIED', title: 'Unverified Issue 8003' }],
    [8005, { isIssue: false, isPR: true, state: 'OPEN' }]
  ]);

  const mergedPRs = [
    {
      number: 8100,
      title: 'Fix issue 8001 and closed 8002',
      body: 'Closes #8001. Closes #8002. Also see #8003. See #8005',
      mergedAt: '2026-11-20T12:00:00Z',
      headRefName: 'fix-8001',
      confirmedClosingIssueNumbers: [8001],
      isClosingIssuesComplete: true,
      isClosingIssuesAvailable: true,
      closingIssuesTotal: 1,
      closingIssuesOverflow: false,
      omittedClosingIssuesCount: 0
    }
  ];

  const result = classifyBacklog({
    normalizedIssues: openIssues,
    normalizedPRs: openPRs,
    normalizedMergedPRs: mergedPRs,
    resolvedBatchMap: resolvedBatch
  });

  assert.equal(result.classifiedMergedPRs.length, 1);
  const mpr = result.classifiedMergedPRs[0];
  assert.equal(mpr.number, 8100);

  // Verify candidate PR 8005 was discarded and NOT included
  const linkedNumbers = mpr.linkedIssues.map((l) => l.number);
  assert.equal(linkedNumbers.includes(8005), false);

  // Verify confirmed closing ref 8001
  const l8001 = mpr.linkedIssues.find((l) => l.number === 8001);
  assert.ok(l8001);
  assert.equal(l8001.confidence, 'CONFIRMED');
  assert.equal(l8001.state, 'OPEN');
  assert.equal(l8001.isClosed, false);
  assert.equal(l8001.status, 'CONFIRMED');

  // Verify closed issue 8002
  const l8002 = mpr.linkedIssues.find((l) => l.number === 8002);
  assert.ok(l8002);
  assert.equal(l8002.state, 'CLOSED');
  assert.equal(l8002.isClosed, true);

  // Verify unverified issue 8003
  const l8003 = mpr.linkedIssues.find((l) => l.number === 8003);
  assert.ok(l8003);
  assert.equal(l8003.state, 'UNVERIFIED');
  assert.equal(l8003.status, 'UNVERIFIED');

  // Verify potentiallyResolvedIssues was populated for open issue 8001
  const pot = result.relationships.potentiallyResolvedIssues;
  assert.equal(pot.length, 1);
  assert.equal(pot[0].issueNumber, 8001);
  assert.equal(pot[0].mergedPRNumber, 8100);
});

test('Phase 2H P1 Finding 2: classifyBacklog accurately computes relationship metrics across open and merged PRs without double counting', () => {
  const normalizedIssues = [
    { number: 9001, title: 'Open Issue 9001' },
    { number: 9002, title: 'Open Issue 9002' }
  ];

  const resolvedBatchMap = new Map([
    [9003, { isIssue: true, isPR: false, state: 'CLOSED', title: 'Closed Issue 9003' }],
    [9004, { isIssue: true, isPR: false, state: 'UNVERIFIED', title: 'Unverified 9004' }],
    [9099, { isIssue: false, isPR: true, state: 'OPEN' }] // PR, should be discarded
  ]);

  // Open PR with 1 confirmed ref, 1 inferred open ref, and 1 unverified ref
  const normalizedPRs = [
    {
      number: 101,
      title: 'Open PR 101',
      headRefName: 'feat/9002-feature', // High inferred to open issue 9002
      body: 'See #9004 and #9099', // Low mention to unverified 9004, PR 9099
      confirmedClosingIssueNumbers: [9001] // Confirmed to open issue 9001
    }
  ];

  // Merged PR with 1 confirmed ref, 1 inferred closed ref, and 1 unverified ref
  const normalizedMergedPRs = [
    {
      number: 201,
      title: 'Merged PR 201',
      headRefName: 'fix/9003-bug-fix', // High inferred to closed issue 9003
      body: 'Ref #9004', // Low mention to unverified 9004
      confirmedClosingIssueNumbers: [9001], // Confirmed to open issue 9001
      mergedAt: '2026-11-20T10:00:00Z'
    }
  ];

  const metrics = {};
  const classification = classifyBacklog({
    normalizedIssues,
    normalizedPRs,
    normalizedMergedPRs,
    resolvedBatchMap,
    metrics
  });

  // Confirmed: 1 from open PR (9001) + 1 from merged PR (9001) = 2
  assert.equal(classification.metrics.confirmedCount, 2);
  assert.equal(metrics.confirmedCount, 2);

  // Inferred: 1 from open PR (9002) + 1 from merged PR (9003) = 2
  assert.equal(classification.metrics.inferredCount, 2);
  assert.equal(metrics.inferredCount, 2);

  // Unverified: 1 from open PR (9004) + 1 from merged PR (9004) = 2 (9099 discarded as PR)
  assert.equal(classification.metrics.unverifiedCount, 2);
  assert.equal(metrics.unverifiedCount, 2);
});

test('Phase 2H P2 Finding 4: deriveReviewState returns UNKNOWN when reviewRequests or reviews data is incomplete or unavailable', () => {
  // 1. Incomplete reviewRequests (e.g. overflow or totalCount mismatch)
  assert.equal(deriveReviewState({
    isReviewDecisionAvailable: true,
    githubReviewDecision: null,
    isReviewRequestsAvailable: true,
    isReviewRequestsComplete: false,
    isReviewsAvailable: true,
    isReviewsComplete: true,
    reviewsCount: 0,
    reviewRequestsCount: 0
  }), 'UNKNOWN');

  // 2. Incomplete reviews (e.g. overflow or malformed node)
  assert.equal(deriveReviewState({
    isReviewDecisionAvailable: true,
    githubReviewDecision: null,
    isReviewRequestsAvailable: true,
    isReviewRequestsComplete: true,
    isReviewsAvailable: true,
    isReviewsComplete: false,
    reviewsCount: 0,
    reviewRequestsCount: 0
  }), 'UNKNOWN');

  // 3. Unavailable reviews
  assert.equal(deriveReviewState({
    isReviewDecisionAvailable: true,
    githubReviewDecision: null,
    isReviewRequestsAvailable: true,
    isReviewRequestsComplete: true,
    isReviewsAvailable: false,
    isReviewsComplete: false,
    reviewsCount: 0,
    reviewRequestsCount: 0
  }), 'UNKNOWN');

  // 4. Fully complete reviewRequests and reviews data derives definitive state
  assert.equal(deriveReviewState({
    isReviewDecisionAvailable: true,
    githubReviewDecision: null,
    isReviewRequestsAvailable: true,
    isReviewRequestsComplete: true,
    isReviewsAvailable: true,
    isReviewsComplete: true,
    reviewsCount: 0,
    reviewRequestsCount: 0
  }), 'NO_REVIEWERS_REQUESTED');

  assert.equal(deriveReviewState({
    isReviewDecisionAvailable: true,
    githubReviewDecision: null,
    isReviewRequestsAvailable: true,
    isReviewRequestsComplete: true,
    isReviewsAvailable: true,
    isReviewsComplete: true,
    reviewsCount: 0,
    reviewRequestsCount: 2
  }), 'REVIEW_REQUESTED_NO_SUBMITTED_REVIEWS');
});
