'use strict';

const test = require('node:test');
const assert = require('node:assert/strict');
const path = require('node:path');
const fs = require('node:fs');

const {
  parseValidISODate,
  hasFieldErrorForPRField,
  hasFieldErrorForIssueAssignees,
  hasFieldErrorForIssueComments,
  extractReviewDecision,
  extractReviewRequests,
  extractReviews,
  extractCIState,
  extractAssignees,
  extractComments,
  extractClosingIssues,
  normalizePullRequest,
  normalizeIssue,
  normalizeMergedPR
} = require('../normalize');

function loadFixture(name) {
  const file = path.join(__dirname, 'fixtures', name);
  return JSON.parse(fs.readFileSync(file, 'utf8'));
}

test('Safeguard 1: extractReviewDecision handles null and malformed inputs without throwing', () => {
  // Null and undefined
  assert.doesNotThrow(() => {
    const res = extractReviewDecision(null, 123);
    assert.equal(res.isAvailable, false);
    assert.equal(res.isError, true);
    assert.equal(res.value, null);
  });

  assert.doesNotThrow(() => {
    const res = extractReviewDecision(undefined, 123);
    assert.equal(res.isAvailable, false);
  });

  // Primitives and non-objects
  assert.doesNotThrow(() => {
    assert.equal(extractReviewDecision('not-an-object', 123).isAvailable, false);
    assert.equal(extractReviewDecision(42, 123).isAvailable, false);
  });

  // Malformed objects without reviewDecision property
  assert.doesNotThrow(() => {
    const res = extractReviewDecision({ other: 'field' }, 123);
    assert.equal(res.isAvailable, false);
    assert.equal(res.isError, true);
  });

  // Valid objects with clean null reviewDecision
  const cleanNull = extractReviewDecision({ number: 123, reviewDecision: null }, 123);
  assert.equal(cleanNull.isAvailable, true);
  assert.equal(cleanNull.isError, false);
  assert.equal(cleanNull.value, null);

  // Field error presence
  const fieldErrors = new Map([['pr_123_reviewDecision', { message: 'Forbidden' }]]);
  const errored = extractReviewDecision({ number: 123, reviewDecision: 'APPROVED' }, 123, fieldErrors);
  assert.equal(errored.isAvailable, false);
  assert.equal(errored.isError, true);
});

test('Safeguard 2: extractReviewRequests requires complete, error-free review request data', () => {
  // Null and undefined inputs
  assert.equal(extractReviewRequests(null, 123).isAvailable, false);
  assert.equal(extractReviewRequests(undefined, 123).isAvailable, false);

  // Missing reviewRequests property
  assert.equal(extractReviewRequests({ number: 123 }, 123).isAvailable, false);

  // Field error presence
  const fieldErrors = new Map([['pr_123_reviewRequests', { message: 'Error' }]]);
  assert.equal(extractReviewRequests({ number: 123, reviewRequests: { totalCount: 2 } }, 123, fieldErrors).isAvailable, false);

  // Clean, available reviewRequests
  const clean = extractReviewRequests({
    number: 123,
    reviewRequests: { totalCount: 2, nodes: [{ requestedReviewer: { login: 'user1' } }] }
  }, 123);
  assert.equal(clean.isAvailable, true);
  assert.equal(clean.count, 2);
  assert.equal(clean.overflow, true);
});

test('extractCIState: strict NO_CHECKS_CONFIRMED requires clean confirmation on all 3 check interfaces', () => {
  // 1. Confirmed zero checks: rollup is null, checkSuites totalCount is strictly 0, status is null
  const cleanNoChecks = {
    commit: {
      statusCheckRollup: null,
      status: null,
      checkSuites: { totalCount: 0 }
    }
  };
  const res1 = extractCIState(cleanNoChecks, 123);
  assert.equal(res1.state, 'NO_CHECKS_CONFIRMED');
  assert.equal(res1.hasConfirmedNoChecks, true);
  assert.equal(res1.isAvailable, true);

  // 2. Rollup is null, but checkSuites is null -> UNKNOWN (cannot prove absence)
  const nullSuites = {
    commit: {
      statusCheckRollup: null,
      status: null,
      checkSuites: null
    }
  };
  assert.equal(extractCIState(nullSuites, 123).state, 'UNKNOWN');

  // 3. Rollup is null, but legacy status is present -> UNKNOWN
  const hasStatus = {
    commit: {
      statusCheckRollup: null,
      status: { contexts: [{ id: '1' }] },
      checkSuites: { totalCount: 0 }
    }
  };
  assert.equal(extractCIState(hasStatus, 123).state, 'UNKNOWN');

  // 4. Field error on check fields -> UNKNOWN
  const fieldErrors = new Map([['pr_123_statusCheckRollup', { message: 'Forbidden' }]]);
  assert.equal(extractCIState(cleanNoChecks, 123, fieldErrors).state, 'UNKNOWN');

  // 5. Standard rollup states
  const passing = { commit: { statusCheckRollup: { state: 'SUCCESS' } } };
  assert.equal(extractCIState(passing, 123).state, 'SUCCESS');

  const failing = { commit: { statusCheckRollup: { state: 'FAILURE' } } };
  assert.equal(extractCIState(failing, 123).state, 'FAILURE');

  const errored = { commit: { statusCheckRollup: { state: 'ERROR' } } };
  assert.equal(extractCIState(errored, 123).state, 'ERROR');

  const pending = { commit: { statusCheckRollup: { state: 'PENDING' } } };
  assert.equal(extractCIState(pending, 123).state, 'PENDING');

  const expected = { commit: { statusCheckRollup: { state: 'EXPECTED' } } };
  assert.equal(extractCIState(expected, 123).state, 'PENDING');
});

test('normalizePullRequest: normalizes pull request fixture correctly', () => {
  const fixture = loadFixture('fixture_prs.json');
  const pr7334 = fixture.data.repository.pullRequests.nodes[0];

  const normalized = normalizePullRequest(pr7334);
  assert.equal(normalized.number, 7334);
  assert.equal(normalized.author, 'compwron');
  assert.equal(normalized.isDraft, false);
  assert.equal(normalized.githubReviewDecision, 'APPROVED');
  assert.equal(normalized.ciState, 'SUCCESS');
  assert.deepEqual(normalized.confirmedClosingIssueNumbers, [7305]);
});

test('normalizeIssue: normalizes issue fixture correctly', () => {
  const fixture = loadFixture('fixture_issues.json');
  const issue5563 = fixture.data.repository.issues.nodes[0];

  const normalized = normalizeIssue(issue5563);
  assert.equal(normalized.number, 5563);
  assert.equal(normalized.isGoodFirstIssue, true);
  assert.equal(normalized.isHelpWanted, true);
  assert.equal(normalized.difficulty, 'Easy');
  assert.equal(normalized.assignees.length, 0);
  assert.equal(normalized.isAssigneesAvailable, true);
});

test('extractAssignees: safety checks for null, missing, malformed, and errored assignees', () => {
  // 1. Null assignee connection
  const nullAssignees = { number: 10, assignees: null };
  const res1 = extractAssignees(nullAssignees);
  assert.equal(res1.isAvailable, false);
  assert.deepEqual(res1.assignees, []);

  // 2. Missing assignee property
  const missingAssignees = { number: 11 };
  const res2 = extractAssignees(missingAssignees);
  assert.equal(res2.isAvailable, false);
  assert.deepEqual(res2.assignees, []);

  // 3. Malformed assignee connection (primitive or array instead of object)
  const malformed1 = { number: 12, assignees: 'invalid-string' };
  assert.equal(extractAssignees(malformed1).isAvailable, false);
  const malformed2 = { number: 13, assignees: [{ login: 'user' }] }; // should be connection object
  assert.equal(extractAssignees(malformed2).isAvailable, false);

  // 4. Alias-level assignee error
  const aliasErrors = new Map([
    ['issue_14_assignees', { message: 'Forbidden' }]
  ]);
  const res4 = extractAssignees({ number: 14, assignees: { totalCount: 0, nodes: [] } }, aliasErrors);
  assert.equal(res4.isAvailable, false);

  // 5. Indexed GraphQL field error (repository.issues.nodes.0.assignees)
  const indexedErrors = new Map([
    ['repository.issues.nodes.0.assignees', { path: ['repository', 'issues', 'nodes', 0, 'assignees'] }]
  ]);
  const res5 = extractAssignees({ number: 15, assignees: { totalCount: 0, nodes: [] } }, indexedErrors, 0);
  assert.equal(res5.isAvailable, false);

  // Another index (index 1) should not be affected by index 0 error
  const res5Other = extractAssignees({ number: 16, assignees: { totalCount: 0, nodes: [] } }, indexedErrors, 1);
  assert.equal(res5Other.isAvailable, true);

  // 6. Valid empty assignee connection
  const validEmpty = { number: 17, assignees: { totalCount: 0, nodes: [] } };
  const res6 = extractAssignees(validEmpty);
  assert.equal(res6.isAvailable, true);
  assert.equal(res6.assignees.length, 0);
  assert.equal(res6.overflow, false);

  // 7. Valid non-empty assignee connection
  const validNonEmpty = { number: 18, assignees: { totalCount: 1, nodes: [{ login: 'contributor1' }] } };
  const res7 = extractAssignees(validNonEmpty);
  assert.equal(res7.isAvailable, true);
  assert.deepEqual(res7.assignees, ['contributor1']);
  assert.equal(res7.overflow, false);
});

test('extractClosingIssues: checks overflow, omitted count, and missing/errored connection', () => {
  // 1. Open PR with more than 10 closing references
  const openPROverflow = {
    number: 7001,
    closingIssuesReferences: {
      totalCount: 15,
      nodes: Array.from({ length: 10 }, (_, i) => ({ number: 8000 + i, title: `Issue ${i}` }))
    }
  };
  const res1 = extractClosingIssues(openPROverflow);
  assert.equal(res1.isAvailable, true);
  assert.equal(res1.overflow, true);
  assert.equal(res1.omittedCount, 5);
  assert.equal(res1.numbers.length, 10);

  // 2. Merged PR with more than 10 closing references
  const mergedPROverflow = {
    number: 7002,
    closingIssuesReferences: {
      totalCount: 12,
      nodes: Array.from({ length: 10 }, (_, i) => ({ number: 8100 + i, title: `Issue ${i}` }))
    }
  };
  const res2 = extractClosingIssues(mergedPROverflow);
  assert.equal(res2.isAvailable, true);
  assert.equal(res2.overflow, true);
  assert.equal(res2.omittedCount, 2);

  // 3. No overflow when all references are retrieved (<= 10)
  const noOverflow = {
    number: 7003,
    closingIssuesReferences: {
      totalCount: 3,
      nodes: [{ number: 9001 }, { number: 9002 }, { number: 9003 }]
    }
  };
  const res3 = extractClosingIssues(noOverflow);
  assert.equal(res3.isAvailable, true);
  assert.equal(res3.overflow, false);
  assert.equal(res3.omittedCount, 0);
  assert.deepEqual(res3.numbers, [9001, 9002, 9003]);

  // 4. Missing or errored relationship connection
  const missingClosing = { number: 7004 };
  const res4 = extractClosingIssues(missingClosing);
  assert.equal(res4.isAvailable, false);
  assert.equal(res4.isComplete, false);
  assert.equal(res4.overflow, false);
  assert.equal(res4.omittedCount, null);
  assert.equal(res4.totalCount, null);

  const erroredClosing = { number: 7005, closingIssuesReferences: { totalCount: 5, nodes: [] } };
  const fieldErrors = new Map([
    ['pr_7005_closingIssuesReferences', { message: 'Forbidden' }]
  ]);
  const res5 = extractClosingIssues(erroredClosing, fieldErrors);
  assert.equal(res5.isAvailable, false);
  assert.equal(res5.isComplete, false);
  assert.equal(res5.isError, true);
  assert.equal(res5.omittedCount, null);
  assert.equal(res5.totalCount, null);
});

test('Finding #1 & #2: PR extractors and normalizer correctly handle indexed GraphQL errors across multiple PR nodes', () => {
  const pr0Raw = {
    number: 7101,
    title: 'PR 0 with reviewDecision error',
    reviewDecision: null,
    reviewRequests: { totalCount: 0, nodes: [] },
    reviews: { totalCount: 0, nodes: [] },
    commits: {
      nodes: [{
        commit: {
          statusCheckRollup: null,
          checkSuites: { totalCount: 0 },
          status: null
        }
      }]
    },
    closingIssuesReferences: { totalCount: 1, nodes: [{ number: 8001 }] }
  };

  const pr1Raw = {
    number: 7102,
    title: 'PR 1 clean',
    reviewDecision: 'APPROVED',
    reviewRequests: { totalCount: 1, nodes: [{ requestedReviewer: { login: 'reviewer1' } }] },
    reviews: { totalCount: 1, nodes: [{ author: { login: 'reviewer1' }, state: 'APPROVED', submittedAt: '2026-11-20T12:00:00Z' }] },
    commits: {
      nodes: [{
        commit: {
          statusCheckRollup: { state: 'SUCCESS' },
          checkSuites: { totalCount: 1 },
          status: null
        }
      }]
    },
    closingIssuesReferences: { totalCount: 0, nodes: [] }
  };

  // Field errors affecting only PR 0 (at index 0)
  const fieldErrors = new Map([
    ['repository.pullRequests.nodes.0.reviewDecision', { path: ['repository', 'pullRequests', 'nodes', 0, 'reviewDecision'] }],
    ['repository.pullRequests.nodes.0.commits.nodes.0.commit.statusCheckRollup', {
      path: ['repository', 'pullRequests', 'nodes', 0, 'commits', 'nodes', 0, 'commit', 'statusCheckRollup']
    }]
  ]);

  const norm0 = normalizePullRequest(pr0Raw, fieldErrors, 0);
  const norm1 = normalizePullRequest(pr1Raw, fieldErrors, 1);

  // PR 0 review decision was errored: must be unavailable/unknown
  assert.equal(norm0.isReviewDecisionAvailable, false);
  assert.equal(norm0.githubReviewDecision, null);

  // PR 0 statusCheckRollup was errored: CANNOT establish NO_CHECKS_CONFIRMED even though checkSuites totalCount is 0!
  assert.equal(norm0.isCIAvailable, false);
  assert.equal(norm0.ciState, 'UNKNOWN');
  assert.equal(norm0.hasConfirmedNoChecks, false);

  // PR 1 was at index 1: MUST NOT be affected by index 0 errors!
  assert.equal(norm1.isReviewDecisionAvailable, true);
  assert.equal(norm1.githubReviewDecision, 'APPROVED');
  assert.equal(norm1.isCIAvailable, true);
  assert.equal(norm1.ciState, 'SUCCESS');
  assert.equal(norm1.hasConfirmedNoChecks, false);
});

test('Finding #1: normalizeMergedPR preserves closing references and respects totalCount and overflow', () => {
  const mergedPRWithOverflow = {
    number: 7424,
    title: 'Merged PR with 12 closing references',
    mergedAt: '2026-11-20T10:00:00Z',
    closingIssuesReferences: {
      totalCount: 12,
      nodes: Array.from({ length: 10 }, (_, i) => ({ number: 9100 + i, state: 'CLOSED' }))
    }
  };

  const norm = normalizeMergedPR(mergedPRWithOverflow);
  assert.equal(norm.number, 7424);
  assert.equal(norm.isClosingIssuesAvailable, true);
  assert.equal(norm.isClosingIssuesComplete, false);
  assert.equal(norm.confirmedClosingIssueNumbers.length, 10);
  assert.equal(norm.confirmedClosingIssueNumbers[0], 9100);
  assert.equal(norm.closingIssuesTotal, 12);
  assert.equal(norm.closingIssuesOverflow, true);
  assert.equal(norm.omittedClosingIssuesCount, 2);
});

test('Finding #5: Substring prefix error matching does not collide between issue numbers', () => {
  // Error belongs specifically to issue 140
  const fieldErrors = new Map([
    ['issue_140_assignees', { message: 'Forbidden on issue 140' }]
  ]);

  // Issue 14 (whose digits are a prefix of 140) must NOT be affected!
  const issue14 = { number: 14, assignees: { totalCount: 0, nodes: [] } };
  const res14 = extractAssignees(issue14, fieldErrors, 0);
  assert.equal(res14.isAvailable, true);
  assert.equal(res14.assignees.length, 0);

  // Issue 140 MUST be affected!
  const issue140 = { number: 140, assignees: { totalCount: 0, nodes: [] } };
  const res140 = extractAssignees(issue140, fieldErrors, 1);
  assert.equal(res140.isAvailable, false);

  // Similarly for PR closing issues: pr_140 error must not affect pr_14
  const prFieldErrors = new Map([
    ['pr_140_closingIssuesReferences', { message: 'Forbidden on pr 140' }]
  ]);
  const pr14 = { number: 14, closingIssuesReferences: { totalCount: 1, nodes: [{ number: 999 }] } };
  const resPR14 = extractClosingIssues(pr14, prFieldErrors, 0);
  assert.equal(resPR14.isAvailable, true);
  assert.equal(resPR14.numbers.length, 1);

  const pr140 = { number: 140, closingIssuesReferences: { totalCount: 1, nodes: [{ number: 999 }] } };
  const resPR140 = extractClosingIssues(pr140, prFieldErrors, 1);
  assert.equal(resPR140.isAvailable, false);
});

test('Finding #6: extractAssignees correctly classifies unassigned, assigned, and incomplete totalCount states', () => {
  // 1. { totalCount: 0, nodes: [] } -> explicitly unassigned
  const unassigned = { number: 1, assignees: { totalCount: 0, nodes: [] } };
  const res1 = extractAssignees(unassigned);
  assert.equal(res1.isAvailable, true);
  assert.equal(res1.totalCount, 0);
  assert.deepEqual(res1.assignees, []);

  // 2. { totalCount: 1, nodes: [{ login: 'someone' }] } -> assigned
  const assigned = { number: 2, assignees: { totalCount: 1, nodes: [{ login: 'someone' }] } };
  const res2 = extractAssignees(assigned);
  assert.equal(res2.isAvailable, true);
  assert.equal(res2.totalCount, 1);
  assert.deepEqual(res2.assignees, ['someone']);

  // 3. { totalCount: 1, nodes: [] } -> positive totalCount but empty nodes: UNAVAILABLE, not unassigned!
  const ghostEmpty = { number: 3, assignees: { totalCount: 1, nodes: [] } };
  const res3 = extractAssignees(ghostEmpty);
  assert.equal(res3.isAvailable, false);
  assert.equal(res3.totalCount, 1);

  // 4. { totalCount: 1, nodes: [null] } -> positive totalCount but null node: UNAVAILABLE
  const ghostNull = { number: 4, assignees: { totalCount: 1, nodes: [null] } };
  const res4 = extractAssignees(ghostNull);
  assert.equal(res4.isAvailable, false);

  // 5. Missing totalCount: UNAVAILABLE
  const missingTotal = { number: 5, assignees: { nodes: [] } };
  const res5 = extractAssignees(missingTotal);
  assert.equal(res5.isAvailable, false);

  // 6. Malformed nodes: UNAVAILABLE
  const malformedNodes = { number: 6, assignees: { totalCount: 0, nodes: 'not-an-array' } };
  const res6 = extractAssignees(malformedNodes);
  assert.equal(res6.isAvailable, false);
});

test('Phase 2E Fix A: Comprehensive closing-reference completeness and safety checks (12 cases)', () => {
  // Case 1: totalCount: 0 and empty nodes -> available and complete; zero references
  const c1 = extractClosingIssues({
    number: 101,
    closingIssuesReferences: { totalCount: 0, nodes: [], pageInfo: { hasNextPage: false } }
  });
  assert.equal(c1.isAvailable, true);
  assert.equal(c1.isComplete, true);
  assert.deepEqual(c1.numbers, []);
  assert.equal(c1.totalCount, 0);
  assert.equal(c1.overflow, false);
  assert.equal(c1.omittedCount, 0);
  assert.equal(c1.isError, false);

  // Case 2: Matching totalCount and valid returned nodes -> available and complete
  const c2 = extractClosingIssues({
    number: 102,
    closingIssuesReferences: {
      totalCount: 2,
      nodes: [{ number: 201 }, { number: 202 }],
      pageInfo: { hasNextPage: false }
    }
  });
  assert.equal(c2.isAvailable, true);
  assert.equal(c2.isComplete, true);
  assert.deepEqual(c2.numbers, [201, 202]);
  assert.equal(c2.totalCount, 2);
  assert.equal(c2.overflow, false);
  assert.equal(c2.omittedCount, 0);
  assert.equal(c2.isError, false);

  // Case 3: Positive overflow with omitted count -> available but incomplete due to overflow
  const c3 = extractClosingIssues({
    number: 103,
    closingIssuesReferences: {
      totalCount: 12,
      pageInfo: { hasNextPage: true },
      nodes: Array.from({ length: 10 }, (_, i) => ({ number: 300 + i }))
    }
  });
  assert.equal(c3.isAvailable, true);
  assert.equal(c3.isComplete, false);
  assert.equal(c3.numbers.length, 10);
  assert.equal(c3.totalCount, 12);
  assert.equal(c3.overflow, true);
  assert.equal(c3.omittedCount, 2);
  assert.equal(c3.isError, false);

  // Case 4: Missing totalCount -> preserve usable nodes if safe; completeness unknown
  const c4 = extractClosingIssues({
    number: 104,
    closingIssuesReferences: { nodes: [{ number: 401 }, { number: 402 }] }
  });
  assert.equal(c4.isAvailable, true);
  assert.equal(c4.isComplete, false);
  assert.deepEqual(c4.numbers, [401, 402]);
  assert.equal(c4.totalCount, null);
  assert.equal(c4.overflow, false);
  assert.equal(c4.omittedCount, null);
  assert.equal(c4.isError, false);

  // Case 5: Explicit totalCount: null -> preserve usable nodes if safe; completeness unknown
  const c5 = extractClosingIssues({
    number: 105,
    closingIssuesReferences: { totalCount: null, nodes: [{ number: 501 }] }
  });
  assert.equal(c5.isAvailable, true);
  assert.equal(c5.isComplete, false);
  assert.deepEqual(c5.numbers, [501]);
  assert.equal(c5.totalCount, null);
  assert.equal(c5.overflow, false);
  assert.equal(c5.omittedCount, null);
  assert.equal(c5.isError, false);

  // Case 6: Missing connection -> unavailable
  const c6 = extractClosingIssues({ number: 106 });
  assert.equal(c6.isAvailable, false);
  assert.equal(c6.isComplete, false);
  assert.deepEqual(c6.numbers, []);
  assert.equal(c6.totalCount, null);
  assert.equal(c6.overflow, false);
  assert.equal(c6.omittedCount, null);
  assert.equal(c6.isError, false);

  // Case 7: Null connection -> unavailable
  const c7 = extractClosingIssues({ number: 107, closingIssuesReferences: null });
  assert.equal(c7.isAvailable, false);
  assert.equal(c7.isComplete, false);
  assert.deepEqual(c7.numbers, []);
  assert.equal(c7.totalCount, null);
  assert.equal(c7.overflow, false);
  assert.equal(c7.omittedCount, null);
  assert.equal(c7.isError, false);

  // Case 8: Missing or malformed nodes -> unavailable
  const c8a = extractClosingIssues({ number: 108, closingIssuesReferences: { totalCount: 5 } });
  assert.equal(c8a.isAvailable, false);
  assert.equal(c8a.isComplete, false);
  assert.deepEqual(c8a.numbers, []);
  assert.equal(c8a.totalCount, null);
  assert.equal(c8a.omittedCount, null);

  const c8b = extractClosingIssues({
    number: 108,
    closingIssuesReferences: { totalCount: 5, nodes: 'not-an-array' }
  });
  assert.equal(c8b.isAvailable, false);
  assert.equal(c8b.isComplete, false);
  assert.deepEqual(c8b.numbers, []);
  assert.equal(c8b.totalCount, null);
  assert.equal(c8b.omittedCount, null);

  // Case 9: Malformed individual nodes -> preserve valid numbers, but completeness cannot be confirmed
  const c9 = extractClosingIssues({
    number: 109,
    closingIssuesReferences: {
      totalCount: 2,
      nodes: [{ number: 901 }, null, { title: 'no number' }, { number: -5 }, { number: 'invalid' }]
    }
  });
  assert.equal(c9.isAvailable, true);
  assert.equal(c9.isComplete, false);
  assert.deepEqual(c9.numbers, [901]);
  assert.equal(c9.totalCount, 2);
  assert.equal(c9.overflow, false);
  assert.equal(c9.omittedCount, null);

  // When all nodes are malformed, data is unavailable
  const c9AllBad = extractClosingIssues({
    number: 109,
    closingIssuesReferences: {
      totalCount: 1,
      nodes: [{ title: 'no number' }]
    }
  });
  assert.equal(c9AllBad.isAvailable, false);
  assert.equal(c9AllBad.isComplete, false);
  assert.deepEqual(c9AllBad.numbers, []);

  // Case 10: totalCount lower than returned node count (inconsistent response)
  const c10 = extractClosingIssues({
    number: 110,
    closingIssuesReferences: { totalCount: 1, nodes: [{ number: 1001 }, { number: 1002 }] }
  });
  assert.equal(c10.isAvailable, true);
  assert.equal(c10.isComplete, false);
  assert.deepEqual(c10.numbers, [1001, 1002]);
  assert.equal(c10.totalCount, 1);
  assert.equal(c10.overflow, false);
  assert.equal(c10.omittedCount, null);

  // Case 11: Indexed field error on closing references -> do not claim complete or available data
  const fieldErrors = new Map([
    ['repository.pullRequests.nodes.0.closingIssuesReferences', {
      path: ['repository', 'pullRequests', 'nodes', 0, 'closingIssuesReferences']
    }]
  ]);
  const c11 = extractClosingIssues(
    { number: 111, closingIssuesReferences: { totalCount: 2, nodes: [{ number: 1101 }, { number: 1102 }] } },
    fieldErrors,
    0
  );
  assert.equal(c11.isAvailable, false);
  assert.equal(c11.isComplete, false);
  assert.deepEqual(c11.numbers, []);
  assert.equal(c11.totalCount, null);
  assert.equal(c11.overflow, false);
  assert.equal(c11.omittedCount, null);
  assert.equal(c11.isError, true);

  // Case 12: Verify both normalizePullRequest() and normalizeMergedPR() preserve completeness semantics
  const prComplete = normalizePullRequest({
    number: 7201,
    closingIssuesReferences: { totalCount: 1, nodes: [{ number: 8201 }], pageInfo: { hasNextPage: false } }
  });
  assert.equal(prComplete.isClosingIssuesComplete, true);
  assert.equal(prComplete.isClosingIssuesAvailable, true);
  assert.equal(prComplete.closingIssuesTotal, 1);
  assert.equal(prComplete.closingIssuesOverflow, false);
  assert.equal(prComplete.omittedClosingIssuesCount, 0);

  const prIncomplete = normalizePullRequest({
    number: 7202,
    closingIssuesReferences: { nodes: [{ number: 8202 }] }
  });
  assert.equal(prIncomplete.isClosingIssuesComplete, false);
  assert.equal(prIncomplete.isClosingIssuesAvailable, true);
  assert.equal(prIncomplete.closingIssuesTotal, null);
  assert.equal(prIncomplete.closingIssuesOverflow, false);
  assert.equal(prIncomplete.omittedClosingIssuesCount, null);

  const mprComplete = normalizeMergedPR({
    number: 7203,
    closingIssuesReferences: { totalCount: 2, nodes: [{ number: 8203 }, { number: 8204 }], pageInfo: { hasNextPage: false } }
  });
  assert.equal(mprComplete.isClosingIssuesComplete, true);
  assert.equal(mprComplete.isClosingIssuesAvailable, true);
  assert.equal(mprComplete.closingIssuesTotal, 2);
  assert.equal(mprComplete.closingIssuesOverflow, false);
  assert.equal(mprComplete.omittedClosingIssuesCount, 0);

  const mprIncomplete = normalizeMergedPR({
    number: 7204,
    closingIssuesReferences: { nodes: [{ number: 8205 }] }
  });
  assert.equal(mprIncomplete.isClosingIssuesComplete, false);
  assert.equal(mprIncomplete.isClosingIssuesAvailable, true);
  assert.equal(mprIncomplete.closingIssuesTotal, null);
  assert.equal(mprIncomplete.closingIssuesOverflow, false);
  assert.equal(mprIncomplete.omittedClosingIssuesCount, null);
});

test('Phase 2E Fix B: Indexed merged-PR search.nodes field error discrimination and nested path safety', () => {
  const mpr0 = {
    number: 7424,
    closingIssuesReferences: { totalCount: 1, nodes: [{ number: 9001 }], pageInfo: { hasNextPage: false } }
  };
  const mpr1 = {
    number: 7425,
    closingIssuesReferences: { totalCount: 1, nodes: [{ number: 9002 }], pageInfo: { hasNextPage: false } }
  };

  // 1. Error path search.nodes.0.closingIssuesReferences affects merged PR index 0
  const fe0 = new Map([
    ['search.nodes.0.closingIssuesReferences', { path: ['search', 'nodes', 0, 'closingIssuesReferences'] }]
  ]);
  const norm0A = normalizeMergedPR(mpr0, fe0, 0);
  const norm1A = normalizeMergedPR(mpr1, fe0, 1);
  assert.equal(norm0A.isClosingIssuesAvailable, false);
  assert.equal(norm0A.isClosingIssuesComplete, false);
  assert.deepEqual(norm0A.confirmedClosingIssueNumbers, []);
  assert.equal(norm1A.isClosingIssuesAvailable, true);
  assert.equal(norm1A.isClosingIssuesComplete, true);
  assert.deepEqual(norm1A.confirmedClosingIssueNumbers, [9002]);

  // 2. Error path search.nodes.1.closingIssuesReferences affects merged PR index 1 only
  const fe1 = new Map([
    ['search.nodes.1.closingIssuesReferences', { path: ['search', 'nodes', 1, 'closingIssuesReferences'] }]
  ]);
  const norm0B = normalizeMergedPR(mpr0, fe1, 0);
  const norm1B = normalizeMergedPR(mpr1, fe1, 1);
  assert.equal(norm0B.isClosingIssuesAvailable, true);
  assert.equal(norm0B.isClosingIssuesComplete, true);
  assert.deepEqual(norm0B.confirmedClosingIssueNumbers, [9001]);
  assert.equal(norm1B.isClosingIssuesAvailable, false);
  assert.equal(norm1B.isClosingIssuesComplete, false);
  assert.deepEqual(norm1B.confirmedClosingIssueNumbers, []);

  // 3. Error on nested search.nodes.1.closingIssuesReferences.nodes.0.number is attributed to PR index 1, not nested index 0
  const feNested = new Map([
    ['search.nodes.1.closingIssuesReferences.nodes.0.number', {
      path: ['search', 'nodes', 1, 'closingIssuesReferences', 'nodes', 0, 'number']
    }]
  ]);
  // Index 0 must NOT match (it's not affected by PR 1's nested error)
  const norm0C = normalizeMergedPR(mpr0, feNested, 0);
  assert.equal(norm0C.isClosingIssuesAvailable, true);
  assert.equal(norm0C.isClosingIssuesComplete, true);
  assert.deepEqual(norm0C.confirmedClosingIssueNumbers, [9001]);
  // Index 1 MUST match (it is PR 1)
  const norm1C = normalizeMergedPR(mpr1, feNested, 1);
  assert.equal(norm1C.isClosingIssuesAvailable, false);
  assert.equal(norm1C.isClosingIssuesComplete, false);
  assert.deepEqual(norm1C.confirmedClosingIssueNumbers, []);

  // 4. PR-level error on search.nodes.1 does not broadly affect unrelated PR nodes
  assert.equal(norm0B.isClosingIssuesAvailable, true);
  assert.equal(norm0C.isClosingIssuesAvailable, true);

  // 5. Existing repository.pullRequests.nodes.<index> behavior remains correct
  const openPR0 = {
    number: 7501,
    closingIssuesReferences: { totalCount: 1, nodes: [{ number: 9101 }], pageInfo: { hasNextPage: false } }
  };
  const openPR1 = {
    number: 7502,
    closingIssuesReferences: { totalCount: 1, nodes: [{ number: 9102 }], pageInfo: { hasNextPage: false } }
  };
  const feOpen = new Map([
    ['repository.pullRequests.nodes.0.closingIssuesReferences', {
      path: ['repository', 'pullRequests', 'nodes', 0, 'closingIssuesReferences']
    }]
  ]);
  const normOpen0 = normalizePullRequest(openPR0, feOpen, 0);
  const normOpen1 = normalizePullRequest(openPR1, feOpen, 1);
  assert.equal(normOpen0.isClosingIssuesAvailable, false);
  assert.equal(normOpen1.isClosingIssuesAvailable, true);

  // 6. Existing alias-based matching remains correct
  const feAlias = new Map([
    ['pr_7424_closingIssuesReferences', { message: 'Error' }]
  ]);
  const normAlias = normalizeMergedPR(mpr0, feAlias, 0);
  assert.equal(normAlias.isClosingIssuesAvailable, false);
  const normOther = normalizeMergedPR(mpr1, feAlias, 1);
  assert.equal(normOther.isClosingIssuesAvailable, true);
});

test('Phase 2G Finding B: Comprehensive Assignee Normalization (all 13 cases)', () => {
  // Case 1: Valid unassigned (totalCount === 0 and empty nodes)
  const c1 = extractAssignees({ number: 201, assignees: { totalCount: 0, nodes: [] } });
  assert.equal(c1.isAvailable, true);
  assert.equal(c1.totalCount, 0);
  assert.deepEqual(c1.assignees, []);
  assert.equal(c1.overflow, false);

  // Case 2: Valid assigned (totalCount === 1, valid nodes)
  const c2 = extractAssignees({ number: 202, assignees: { totalCount: 1, nodes: [{ login: 'alice' }] } });
  assert.equal(c2.isAvailable, true);
  assert.equal(c2.totalCount, 1);
  assert.deepEqual(c2.assignees, ['alice']);
  assert.equal(c2.overflow, false);

  // Case 3: Null assignees connection
  const c3 = extractAssignees({ number: 203, assignees: null });
  assert.equal(c3.isAvailable, false);
  assert.equal(c3.totalCount, null);
  assert.deepEqual(c3.assignees, []);

  // Case 4: Missing assignees property
  const c4 = extractAssignees({ number: 204 });
  assert.equal(c4.isAvailable, false);
  assert.equal(c4.totalCount, null);
  assert.deepEqual(c4.assignees, []);

  // Case 5: Malformed connection (primitive)
  const c5a = extractAssignees({ number: 205, assignees: 'invalid' });
  assert.equal(c5a.isAvailable, false);
  assert.equal(c5a.totalCount, null);
  assert.deepEqual(c5a.assignees, []);

  // Case 5b: Malformed connection (array instead of object)
  const c5b = extractAssignees({ number: 205, assignees: [{ login: 'alice' }] });
  assert.equal(c5b.isAvailable, false);
  assert.equal(c5b.totalCount, null);
  assert.deepEqual(c5b.assignees, []);

  // Case 6: Negative totalCount
  const c6 = extractAssignees({ number: 206, assignees: { totalCount: -1, nodes: [] } });
  assert.equal(c6.isAvailable, false);
  assert.equal(c6.totalCount, null);
  assert.deepEqual(c6.assignees, []);

  // Case 7: Null totalCount
  const c7 = extractAssignees({ number: 207, assignees: { totalCount: null, nodes: [] } });
  assert.equal(c7.isAvailable, false);
  assert.equal(c7.totalCount, null);
  assert.deepEqual(c7.assignees, []);

  // Case 8: Inconsistent totals (totalCount === 0 with nodes.length > 0)
  const c8 = extractAssignees({ number: 208, assignees: { totalCount: 0, nodes: [{ login: 'alice' }] } });
  assert.equal(c8.isAvailable, false);
  assert.equal(c8.totalCount, null);
  assert.deepEqual(c8.assignees, []);

  // Case 9: Inconsistent totals (totalCount < nodes.length)
  const c9 = extractAssignees({ number: 209, assignees: { totalCount: 1, nodes: [{ login: 'alice' }, { login: 'bob' }] } });
  assert.equal(c9.isAvailable, false);
  assert.equal(c9.totalCount, null);
  assert.deepEqual(c9.assignees, []);

  // Case 10: totalCount > 0 but malformed node (null node or missing/empty login)
  const c10 = extractAssignees({ number: 210, assignees: { totalCount: 1, nodes: [null] } });
  assert.equal(c10.isAvailable, false);
  assert.equal(c10.totalCount, 1);
  assert.deepEqual(c10.assignees, []);

  // Case 11: totalCount > 0 but empty nodes array
  const c11 = extractAssignees({ number: 211, assignees: { totalCount: 1, nodes: [] } });
  assert.equal(c11.isAvailable, false);
  assert.equal(c11.totalCount, 1);
  assert.deepEqual(c11.assignees, []);

  // Case 12: Alias-level field error on assignees
  const feAlias = new Map([['issue_212_assignees', { message: 'Forbidden' }]]);
  const c12 = extractAssignees({ number: 212, assignees: { totalCount: 0, nodes: [] } }, feAlias);
  assert.equal(c12.isAvailable, false);
  assert.equal(c12.totalCount, null);

  // Case 13: Indexed field error on repository.issues.nodes.2.assignees
  const feIndexed = new Map([
    ['repository.issues.nodes.2.assignees', { path: ['repository', 'issues', 'nodes', 2, 'assignees'] }]
  ]);
  const c13 = extractAssignees({ number: 213, assignees: { totalCount: 0, nodes: [] } }, feIndexed, 2);
  assert.equal(c13.isAvailable, false);
  assert.equal(c13.totalCount, null);
});

test('Phase 2G Finding C: Comprehensive Closing-Reference Completeness (all 15 cases)', () => {
  // Case 1: Complete 0-ref (totalCount: 0, empty nodes, hasNextPage: false)
  const c1 = extractClosingIssues({
    number: 301,
    closingIssuesReferences: { totalCount: 0, nodes: [], pageInfo: { hasNextPage: false } }
  });
  assert.equal(c1.isComplete, true);
  assert.equal(c1.isAvailable, true);
  assert.deepEqual(c1.numbers, []);
  assert.equal(c1.totalCount, 0);
  assert.equal(c1.overflow, false);
  assert.equal(c1.omittedCount, 0);

  // Case 2: Complete non-empty (totalCount matches valid nodes, hasNextPage: false)
  const c2 = extractClosingIssues({
    number: 302,
    closingIssuesReferences: {
      totalCount: 2,
      nodes: [{ number: 501 }, { number: 502 }],
      pageInfo: { hasNextPage: false }
    }
  });
  assert.equal(c2.isComplete, true);
  assert.equal(c2.isAvailable, true);
  assert.deepEqual(c2.numbers, [501, 502]);
  assert.equal(c2.totalCount, 2);
  assert.equal(c2.overflow, false);
  assert.equal(c2.omittedCount, 0);

  // Case 3: Missing pageInfo -> incomplete
  const c3 = extractClosingIssues({
    number: 303,
    closingIssuesReferences: { totalCount: 1, nodes: [{ number: 503 }] }
  });
  assert.equal(c3.isComplete, false);
  assert.equal(c3.isAvailable, true);
  assert.deepEqual(c3.numbers, [503]);

  // Case 4: Null pageInfo -> incomplete
  const c4 = extractClosingIssues({
    number: 304,
    closingIssuesReferences: { totalCount: 1, nodes: [{ number: 504 }], pageInfo: null }
  });
  assert.equal(c4.isComplete, false);
  assert.equal(c4.isAvailable, true);

  // Case 5: Missing hasNextPage property in pageInfo -> incomplete
  const c5 = extractClosingIssues({
    number: 305,
    closingIssuesReferences: { totalCount: 1, nodes: [{ number: 505 }], pageInfo: { endCursor: 'abc' } }
  });
  assert.equal(c5.isComplete, false);
  assert.equal(c5.isAvailable, true);

  // Case 6: hasNextPage === true -> incomplete and overflow
  const c6 = extractClosingIssues({
    number: 306,
    closingIssuesReferences: { totalCount: 10, nodes: [{ number: 506 }], pageInfo: { hasNextPage: true } }
  });
  assert.equal(c6.isComplete, false);
  assert.equal(c6.isAvailable, true);
  assert.equal(c6.overflow, true);
  assert.equal(c6.omittedCount, 9);

  // Case 7: Null totalCount -> incomplete
  const c7 = extractClosingIssues({
    number: 307,
    closingIssuesReferences: { totalCount: null, nodes: [{ number: 507 }], pageInfo: { hasNextPage: false } }
  });
  assert.equal(c7.isComplete, false);
  assert.equal(c7.isAvailable, true);
  assert.deepEqual(c7.numbers, [507]);
  assert.equal(c7.totalCount, null);

  // Case 8: Malformed totalCount (string) -> incomplete
  const c8 = extractClosingIssues({
    number: 308,
    closingIssuesReferences: { totalCount: '1', nodes: [{ number: 508 }], pageInfo: { hasNextPage: false } }
  });
  assert.equal(c8.isComplete, false);
  assert.equal(c8.isAvailable, true);
  assert.deepEqual(c8.numbers, [508]);
  assert.equal(c8.totalCount, null);

  // Case 9: Negative totalCount -> incomplete
  const c9 = extractClosingIssues({
    number: 309,
    closingIssuesReferences: { totalCount: -1, nodes: [{ number: 509 }], pageInfo: { hasNextPage: false } }
  });
  assert.equal(c9.isComplete, false);
  assert.equal(c9.isAvailable, true);
  assert.equal(c9.totalCount, null);

  // Case 10: Missing nodes -> unavailable and incomplete
  const c10 = extractClosingIssues({
    number: 310,
    closingIssuesReferences: { totalCount: 1, pageInfo: { hasNextPage: false } }
  });
  assert.equal(c10.isComplete, false);
  assert.equal(c10.isAvailable, false);
  assert.deepEqual(c10.numbers, []);

  // Case 11: Null nodes -> unavailable and incomplete
  const c11 = extractClosingIssues({
    number: 311,
    closingIssuesReferences: { totalCount: 1, nodes: null, pageInfo: { hasNextPage: false } }
  });
  assert.equal(c11.isComplete, false);
  assert.equal(c11.isAvailable, false);

  // Case 12: Malformed node among valid nodes -> incomplete, preserves valid numbers
  const c12 = extractClosingIssues({
    number: 312,
    closingIssuesReferences: {
      totalCount: 2,
      nodes: [{ number: 512 }, null],
      pageInfo: { hasNextPage: false }
    }
  });
  assert.equal(c12.isComplete, false);
  assert.equal(c12.isAvailable, true);
  assert.deepEqual(c12.numbers, [512]);

  // Case 13: Inconsistent totals (more nodes than totalCount) -> incomplete
  const c13 = extractClosingIssues({
    number: 313,
    closingIssuesReferences: {
      totalCount: 1,
      nodes: [{ number: 513 }, { number: 514 }],
      pageInfo: { hasNextPage: false }
    }
  });
  assert.equal(c13.isComplete, false);
  assert.equal(c13.isAvailable, true);
  assert.deepEqual(c13.numbers, [513, 514]);

  // Case 14: Fewer returned nodes than totalCount -> incomplete, overflow: true
  const c14 = extractClosingIssues({
    number: 314,
    closingIssuesReferences: {
      totalCount: 5,
      nodes: [{ number: 515 }],
      pageInfo: { hasNextPage: false }
    }
  });
  assert.equal(c14.isComplete, false);
  assert.equal(c14.isAvailable, true);
  assert.equal(c14.overflow, true);
  assert.equal(c14.omittedCount, 4);

  // Case 15: Field error on closingIssues -> unavailable, incomplete, isError: true
  const fe = new Map([
    ['repository.pullRequests.nodes.0.closingIssuesReferences', {
      path: ['repository', 'pullRequests', 'nodes', 0, 'closingIssuesReferences']
    }]
  ]);
  const c15 = extractClosingIssues(
    {
      number: 315,
      closingIssuesReferences: { totalCount: 1, nodes: [{ number: 516 }], pageInfo: { hasNextPage: false } }
    },
    fe,
    0
  );
  assert.equal(c15.isComplete, false);
  assert.equal(c15.isAvailable, false);
  assert.equal(c15.isError, true);
});

test('Phase 2H P2 Finding 3: Timestamp integrity across all normalizers preserves null and handles malformed dates', () => {
  // 1. parseValidISODate tests
  assert.equal(parseValidISODate(null), null);
  assert.equal(parseValidISODate(undefined), null);
  assert.equal(parseValidISODate(''), null);
  assert.equal(parseValidISODate('   '), null);
  assert.equal(parseValidISODate('not-a-date'), null);
  assert.equal(parseValidISODate(12345), null);
  assert.equal(parseValidISODate('2026-11-20T10:00:00Z'), '2026-11-20T10:00:00Z');

  // 2. normalizePullRequest never substitutes current time when createdAt/updatedAt is missing or malformed
  const prMissingDates = normalizePullRequest({
    number: 1001,
    title: 'PR without timestamps'
  });
  assert.equal(prMissingDates.createdAt, null);
  assert.equal(prMissingDates.updatedAt, null);
  assert.equal(prMissingDates.latestCommitAt, null);

  const prMalformedDates = normalizePullRequest({
    number: 1002,
    title: 'PR with malformed timestamps',
    createdAt: 'invalid-created',
    updatedAt: 'invalid-updated',
    commits: {
      nodes: [{ commit: { committedDate: 'invalid-commit' } }]
    }
  });
  assert.equal(prMalformedDates.createdAt, null);
  assert.equal(prMalformedDates.updatedAt, null);
  assert.equal(prMalformedDates.latestCommitAt, null);

  // 3. normalizeIssue never substitutes current time
  const issueMissingDates = normalizeIssue({
    number: 2001,
    title: 'Issue without timestamps'
  });
  assert.equal(issueMissingDates.createdAt, null);
  assert.equal(issueMissingDates.updatedAt, null);
  assert.equal(issueMissingDates.lastCommentAt, null);

  const issueMalformedDates = normalizeIssue({
    number: 2002,
    title: 'Issue with malformed timestamps',
    createdAt: 'bad-created',
    updatedAt: 'bad-updated',
    comments: {
      nodes: [{ createdAt: 'bad-comment' }]
    }
  });
  assert.equal(issueMalformedDates.createdAt, null);
  assert.equal(issueMalformedDates.updatedAt, null);
  assert.equal(issueMalformedDates.lastCommentAt, null);

  // 4. normalizeMergedPR never substitutes current time
  const mergedMissing = normalizeMergedPR({
    number: 3001,
    title: 'Merged PR without mergedAt'
  });
  assert.equal(mergedMissing.mergedAt, null);

  const mergedMalformed = normalizeMergedPR({
    number: 3002,
    title: 'Merged PR with malformed mergedAt',
    mergedAt: 'not-a-valid-merge-time'
  });
  assert.equal(mergedMalformed.mergedAt, null);
});

test('Phase 2H P2 Finding 4: extractReviewRequests and extractReviews handle inconsistent totals, missing nodes, and malformed nodes', () => {
  // ReviewRequests tests
  // totalCount > nodes.length -> overflow: true, isComplete: false, isAvailable: true
  const rrOverflow = extractReviewRequests({
    number: 101,
    reviewRequests: { totalCount: 5, nodes: [{ requestedReviewer: { login: 'u1' } }] }
  });
  assert.equal(rrOverflow.count, 5);
  assert.equal(rrOverflow.overflow, true);
  assert.equal(rrOverflow.isComplete, false);
  assert.equal(rrOverflow.isAvailable, true);

  // totalCount < nodes.length -> inconsistent! isAvailable: false, isComplete: false, isError: true
  const rrInconsistent = extractReviewRequests({
    number: 102,
    reviewRequests: { totalCount: 0, nodes: [{ requestedReviewer: { login: 'u1' } }] }
  });
  assert.equal(rrInconsistent.isAvailable, false);
  assert.equal(rrInconsistent.isComplete, false);
  assert.equal(rrInconsistent.isError, true);

  // missing nodes
  const rrMissingNodes = extractReviewRequests({
    number: 103,
    reviewRequests: { totalCount: 2 }
  });
  assert.equal(rrMissingNodes.isAvailable, false);
  assert.equal(rrMissingNodes.isComplete, false);

  // malformed node in nodes (null node)
  const rrMalformedNode = extractReviewRequests({
    number: 104,
    reviewRequests: { totalCount: 1, nodes: [null] }
  });
  assert.equal(rrMalformedNode.isComplete, false);

  // totalCount > 0 with empty nodes array (ghost / unavailable detail)
  const rrGhost = extractReviewRequests({
    number: 105,
    reviewRequests: { totalCount: 2, nodes: [] }
  });
  assert.equal(rrGhost.isAvailable, false);
  assert.equal(rrGhost.isComplete, false);

  // Reviews tests
  // totalCount > nodes.length -> overflow: true, isComplete: false, isAvailable: true
  const revOverflow = extractReviews({
    number: 201,
    reviews: { totalCount: 3, nodes: [{ submittedAt: '2026-11-20T10:00:00Z', state: 'APPROVED' }] }
  });
  assert.equal(revOverflow.count, 3);
  assert.equal(revOverflow.overflow, true);
  assert.equal(revOverflow.isComplete, false);
  assert.equal(revOverflow.isAvailable, true);

  // totalCount < nodes.length -> inconsistent! isAvailable: false, isComplete: false, isError: true
  const revInconsistent = extractReviews({
    number: 202,
    reviews: { totalCount: 0, nodes: [{ submittedAt: '2026-11-20T10:00:00Z', state: 'APPROVED' }] }
  });
  assert.equal(revInconsistent.isAvailable, false);
  assert.equal(revInconsistent.isComplete, false);
  assert.equal(revInconsistent.isError, true);

  // missing nodes
  const revMissingNodes = extractReviews({
    number: 203,
    reviews: { totalCount: 1 }
  });
  assert.equal(revMissingNodes.isAvailable, false);
  assert.equal(revMissingNodes.isComplete, false);

  // malformed node in nodes (null node)
  const revMalformedNode = extractReviews({
    number: 204,
    reviews: { totalCount: 1, nodes: [null] }
  });
  assert.equal(revMalformedNode.isComplete, false);

  // totalCount > 0 with empty nodes array
  const revGhost = extractReviews({
    number: 205,
    reviews: { totalCount: 1, nodes: [] }
  });
  assert.equal(revGhost.isAvailable, false);
  assert.equal(revGhost.isComplete, false);
});

test('Phase 2H P2 Finding 5: extractClosingIssues treats malformed individual nodes as incomplete while preserving valid partial numbers', () => {
  const result = extractClosingIssues({
    number: 401,
    closingIssuesReferences: {
      totalCount: 3,
      pageInfo: { hasNextPage: false },
      nodes: [
        { number: 5001 },
        null,
        { not_a_number: 'bad' }
      ]
    }
  });

  // Valid partial number 5001 is preserved safely
  assert.deepEqual(result.numbers, [5001]);
  assert.equal(result.isAvailable, true);

  // But completeness MUST be false because malformed nodes exist
  assert.equal(result.isComplete, false);
});

test('Phase 2I Requirement 1: Preserve missing updatedAt as null independently without substituting createdAt', () => {
  // 1. normalizePullRequest:
  // Case A: Valid createdAt + missing updatedAt -> updatedAt: null
  const prValidCreatedMissingUpdated = normalizePullRequest({
    number: 501,
    title: 'Valid createdAt + missing updatedAt',
    createdAt: '2026-11-20T10:00:00Z'
  });
  assert.equal(prValidCreatedMissingUpdated.createdAt, '2026-11-20T10:00:00Z');
  assert.equal(prValidCreatedMissingUpdated.updatedAt, null);

  // Case B: Valid createdAt + malformed updatedAt -> updatedAt: null
  const prValidCreatedMalformedUpdated = normalizePullRequest({
    number: 502,
    title: 'Valid createdAt + malformed updatedAt',
    createdAt: '2026-11-20T10:00:00Z',
    updatedAt: '2026-02-31T00:00:00Z' // malformed calendar date
  });
  assert.equal(prValidCreatedMalformedUpdated.createdAt, '2026-11-20T10:00:00Z');
  assert.equal(prValidCreatedMalformedUpdated.updatedAt, null);

  // Case C: Missing createdAt + valid updatedAt -> createdAt: null, updatedAt preserved
  const prMissingCreatedValidUpdated = normalizePullRequest({
    number: 503,
    title: 'Missing createdAt + valid updatedAt',
    updatedAt: '2026-11-21T15:30:00Z'
  });
  assert.equal(prMissingCreatedValidUpdated.createdAt, null);
  assert.equal(prMissingCreatedValidUpdated.updatedAt, '2026-11-21T15:30:00Z');

  // Case D: Both valid timestamps preserved independently
  const prBothValid = normalizePullRequest({
    number: 504,
    title: 'Both valid timestamps',
    createdAt: '2026-11-18T08:00:00Z',
    updatedAt: '2026-11-20T12:00:00Z'
  });
  assert.equal(prBothValid.createdAt, '2026-11-18T08:00:00Z');
  assert.equal(prBothValid.updatedAt, '2026-11-20T12:00:00Z');

  // 2. normalizeIssue:
  // Case A: Valid createdAt + missing updatedAt -> updatedAt: null
  const issueValidCreatedMissingUpdated = normalizeIssue({
    number: 601,
    title: 'Valid createdAt + missing updatedAt',
    createdAt: '2026-11-20T10:00:00Z'
  });
  assert.equal(issueValidCreatedMissingUpdated.createdAt, '2026-11-20T10:00:00Z');
  assert.equal(issueValidCreatedMissingUpdated.updatedAt, null);

  // Case B: Valid createdAt + malformed updatedAt -> updatedAt: null
  const issueValidCreatedMalformedUpdated = normalizeIssue({
    number: 602,
    title: 'Valid createdAt + malformed updatedAt',
    createdAt: '2026-11-20T10:00:00Z',
    updatedAt: 'not-an-iso-date'
  });
  assert.equal(issueValidCreatedMalformedUpdated.createdAt, '2026-11-20T10:00:00Z');
  assert.equal(issueValidCreatedMalformedUpdated.updatedAt, null);

  // Case C: Missing createdAt + valid updatedAt -> createdAt: null, updatedAt preserved
  const issueMissingCreatedValidUpdated = normalizeIssue({
    number: 603,
    title: 'Missing createdAt + valid updatedAt',
    updatedAt: '2026-11-21T15:30:00Z'
  });
  assert.equal(issueMissingCreatedValidUpdated.createdAt, null);
  assert.equal(issueMissingCreatedValidUpdated.updatedAt, '2026-11-21T15:30:00Z');

  // Case D: Both valid timestamps preserved independently
  const issueBothValid = normalizeIssue({
    number: 604,
    title: 'Both valid timestamps',
    createdAt: '2026-11-18T08:00:00Z',
    updatedAt: '2026-11-20T12:00:00Z'
  });
  assert.equal(issueBothValid.createdAt, '2026-11-18T08:00:00Z');
  assert.equal(issueBothValid.updatedAt, '2026-11-20T12:00:00Z');
});

test('Phase 2I Requirement 3: Review submittedAt integrity and pending review handling', () => {
  // 1. Pending review legitimately has no submittedAt (null) -> complete: true, latestReviewAt: null
  const revPendingNull = extractReviews({
    number: 701,
    reviews: {
      totalCount: 1,
      nodes: [{ state: 'PENDING', submittedAt: null }]
    }
  });
  assert.equal(revPendingNull.isAvailable, true);
  assert.equal(revPendingNull.isComplete, true);
  assert.equal(revPendingNull.latestReviewAt, null);
  assert.equal(revPendingNull.latestApprovalAt, null);

  // 2. Pending review with undefined submittedAt -> complete: true
  const revPendingUndefined = extractReviews({
    number: 702,
    reviews: {
      totalCount: 1,
      nodes: [{ state: 'PENDING' }]
    }
  });
  assert.equal(revPendingUndefined.isAvailable, true);
  assert.equal(revPendingUndefined.isComplete, true);

  // 3. Pending review with non-empty malformed string for submittedAt -> complete: false
  const revPendingMalformed = extractReviews({
    number: 703,
    reviews: {
      totalCount: 1,
      nodes: [{ state: 'PENDING', submittedAt: 'not-a-valid-date' }]
    }
  });
  assert.equal(revPendingMalformed.isAvailable, true);
  assert.equal(revPendingMalformed.isComplete, false);

  // 4. Submitted/non-pending review without submittedAt (null) -> complete: false
  const revSubmittedNull = extractReviews({
    number: 704,
    reviews: {
      totalCount: 1,
      nodes: [{ state: 'CHANGES_REQUESTED', submittedAt: null }]
    }
  });
  assert.equal(revSubmittedNull.isAvailable, true);
  assert.equal(revSubmittedNull.isComplete, false);
  assert.equal(revSubmittedNull.latestReviewAt, null);

  // 5. Submitted/non-pending review with malformed submittedAt -> complete: false
  const revSubmittedMalformed = extractReviews({
    number: 705,
    reviews: {
      totalCount: 1,
      nodes: [{ state: 'APPROVED', submittedAt: '2026-02-31T00:00:00Z' }]
    }
  });
  assert.equal(revSubmittedMalformed.isAvailable, true);
  assert.equal(revSubmittedMalformed.isComplete, false);
  assert.equal(revSubmittedMalformed.latestApprovalAt, null);

  // 6. Safe partial information preserved without fabricating timestamps or claiming completeness
  const revPartial = extractReviews({
    number: 706,
    reviews: {
      totalCount: 2,
      nodes: [
        { state: 'APPROVED', submittedAt: '2026-11-20T10:00:00Z' },
        { state: 'CHANGES_REQUESTED', submittedAt: null }
      ]
    }
  });
  assert.equal(revPartial.isAvailable, true);
  assert.equal(revPartial.isComplete, false); // incomplete because 2nd review has missing submittedAt
  assert.equal(revPartial.latestReviewAt, '2026-11-20T10:00:00Z');
  assert.equal(revPartial.latestApprovalAt, '2026-11-20T10:00:00Z');

  // 7. Legitimate mix: valid submitted approval + legitimate pending review
  const revSubmittedAndPending = extractReviews({
    number: 707,
    reviews: {
      totalCount: 2,
      nodes: [
        { state: 'APPROVED', submittedAt: '2026-11-20T10:00:00Z' },
        { state: 'PENDING', submittedAt: null }
      ]
    }
  });
  assert.equal(revSubmittedAndPending.isAvailable, true);
  assert.equal(revSubmittedAndPending.isComplete, true);
  assert.equal(revSubmittedAndPending.latestReviewAt, '2026-11-20T10:00:00Z');
  assert.equal(revSubmittedAndPending.latestApprovalAt, '2026-11-20T10:00:00Z');
});

test('Phase 2L Finding: RFC 3339 / ISO 8601 numeric timezone offset boundary validation', () => {
  // Positive tests: valid ISO 8601 / RFC 3339 timestamps
  assert.equal(parseValidISODate('2026-11-20T17:41:28Z'), '2026-11-20T17:41:28Z');
  assert.equal(parseValidISODate('2026-11-20T17:41:28.123Z'), '2026-11-20T17:41:28.123Z');
  assert.equal(parseValidISODate('2026-11-20t17:41:28z'), '2026-11-20t17:41:28z');

  // Zero offsets (positive and negative syntax per RFC 3339 §5.6)
  assert.equal(parseValidISODate('2026-11-20T17:41:28+00:00'), '2026-11-20T17:41:28+00:00');
  assert.equal(parseValidISODate('2026-11-20T17:41:28-00:00'), '2026-11-20T17:41:28-00:00');

  // Accepted syntax upper boundary (+23:59 and +23:00) per RFC 3339 §5.6 (hours 00-23, minutes 00-59)
  assert.equal(parseValidISODate('2026-11-20T10:00:00+23:59'), '2026-11-20T10:00:00+23:59');
  assert.equal(parseValidISODate('2026-11-20T10:00:00+23:00'), '2026-11-20T10:00:00+23:00');

  // Accepted syntax lower boundary (-23:59 and -23:00) per RFC 3339 §5.6 (hours 00-23, minutes 00-59)
  assert.equal(parseValidISODate('2026-11-20T10:00:00-23:59'), '2026-11-20T10:00:00-23:59');
  assert.equal(parseValidISODate('2026-11-20T10:00:00-23:00'), '2026-11-20T10:00:00-23:00');

  // Terrestrial civil time offsets within the RFC 3339 range are accepted
  assert.equal(parseValidISODate('2026-11-20T10:00:00+14:00'), '2026-11-20T10:00:00+14:00'); // Kiribati
  assert.equal(parseValidISODate('2026-11-20T10:00:00-12:00'), '2026-11-20T10:00:00-12:00'); // Baker Island
  assert.equal(parseValidISODate('2026-11-20T17:41:28+05:30'), '2026-11-20T17:41:28+05:30'); // India
  assert.equal(parseValidISODate('2026-11-20T17:41:28-08:00'), '2026-11-20T17:41:28-08:00'); // US Pacific
  assert.equal(parseValidISODate('2026-11-20T17:41:28-05:00'), '2026-11-20T17:41:28-05:00'); // US Eastern
  assert.equal(parseValidISODate('2026-11-20T17:41:28-03:30'), '2026-11-20T17:41:28-03:30'); // Newfoundland
  assert.equal(parseValidISODate('2026-11-20T17:41:28+12:45'), '2026-11-20T17:41:28+12:45'); // Chatham Islands
  assert.equal(parseValidISODate('2026-11-20T17:41:28+13:00'), '2026-11-20T17:41:28+13:00'); // Samoa
  assert.equal(parseValidISODate('2026-11-20T10:00:00+14:01'), '2026-11-20T10:00:00+14:01');
  assert.equal(parseValidISODate('2026-11-20T10:00:00+15:00'), '2026-11-20T10:00:00+15:00');
  assert.equal(parseValidISODate('2026-11-20T10:00:00-12:01'), '2026-11-20T10:00:00-12:01');
  assert.equal(parseValidISODate('2026-11-20T10:00:00-13:00'), '2026-11-20T10:00:00-13:00');

  // Date-only ISO format
  assert.equal(parseValidISODate('2026-11-20'), '2026-11-20');
  assert.equal(parseValidISODate('2024-02-29T12:00:00Z'), '2024-02-29T12:00:00Z'); // leap year valid day
  assert.equal(parseValidISODate('2000-02-29T00:00:00Z'), '2000-02-29T00:00:00Z'); // century leap year
  assert.equal(parseValidISODate('2026-01-31'), '2026-01-31');
  assert.equal(parseValidISODate('2026-04-30'), '2026-04-30');
  assert.equal(parseValidISODate('2026-12-31'), '2026-12-31');

  // Negative tests: timezone-less datetime values must be rejected
  assert.equal(parseValidISODate('2026-11-20T17:41:28'), null);
  assert.equal(parseValidISODate('2026-11-20T17:41:28.123'), null);
  assert.equal(parseValidISODate('2026-11-20t17:41:28'), null);

  // Negative tests: compact offsets must be rejected (+0530 vs +05:30)
  assert.equal(parseValidISODate('2026-11-20T17:41:28+0530'), null);
  assert.equal(parseValidISODate('2026-11-20T17:41:28-0800'), null);

  // Negative tests: non-ISO strings parsed by Date.parse
  assert.equal(parseValidISODate('11/20/2026'), null);
  assert.equal(parseValidISODate('Nov 20, 2026'), null);
  assert.equal(parseValidISODate('2026/11/20'), null);
  assert.equal(parseValidISODate('Friday, November 20, 2026'), null);

  // Negative tests: malformed calendar dates (overflowing into next month in Date.parse)
  assert.equal(parseValidISODate('2026-02-31T00:00:00Z'), null);
  assert.equal(parseValidISODate('2026-02-29T00:00:00Z'), null); // non-leap year
  assert.equal(parseValidISODate('2023-02-29T00:00:00Z'), null); // non-leap year
  assert.equal(parseValidISODate('2100-02-29T00:00:00Z'), null); // 2100 not leap year
  assert.equal(parseValidISODate('2026-04-31T00:00:00Z'), null); // April has 30 days
  assert.equal(parseValidISODate('2026-06-31T00:00:00Z'), null); // June has 30 days
  assert.equal(parseValidISODate('2026-09-31T00:00:00Z'), null); // September has 30 days
  assert.equal(parseValidISODate('2026-11-31T00:00:00Z'), null); // November has 30 days

  // Negative tests: out of bound time fields
  assert.equal(parseValidISODate('2026-00-15T00:00:00Z'), null);
  assert.equal(parseValidISODate('2026-13-15T00:00:00Z'), null);
  assert.equal(parseValidISODate('2026-11-00T00:00:00Z'), null);
  assert.equal(parseValidISODate('2026-11-32T00:00:00Z'), null);
  assert.equal(parseValidISODate('2026-11-20T24:00:00Z'), null);
  assert.equal(parseValidISODate('2026-11-20T10:60:00Z'), null);
  assert.equal(parseValidISODate('2026-11-20T10:00:60Z'), null);

  // Negative tests: out of bound timezone offsets beyond RFC 3339 §5.6 syntax bounds (hours 00-23, minutes 00-59)
  // Beyond positive upper boundary (+23:59)
  assert.equal(parseValidISODate('2026-11-20T10:00:00+24:00'), null); // First invalid hour beyond +23
  assert.equal(parseValidISODate('2026-11-20T10:00:00+24:01'), null);
  assert.equal(parseValidISODate('2026-11-20T10:00:00+25:00'), null);

  // Beyond negative lower boundary (-23:59)
  assert.equal(parseValidISODate('2026-11-20T10:00:00-24:00'), null); // First invalid hour beyond -23
  assert.equal(parseValidISODate('2026-11-20T10:00:00-24:01'), null);
  assert.equal(parseValidISODate('2026-11-20T10:00:00-25:00'), null);

  // Invalid minutes in timezone offsets (minute >= 60)
  assert.equal(parseValidISODate('2026-11-20T10:00:00+23:60'), null); // First invalid minute at boundary
  assert.equal(parseValidISODate('2026-11-20T10:00:00-23:60'), null);
  assert.equal(parseValidISODate('2026-11-20T10:00:00+10:60'), null);
  assert.equal(parseValidISODate('2026-11-20T10:00:00+00:60'), null);
  assert.equal(parseValidISODate('2026-11-20T10:00:00+00:65'), null);
  assert.equal(parseValidISODate('2026-11-20T10:00:00-05:60'), null);

  // Negative tests: non-strings, empty, garbage
  assert.equal(parseValidISODate(null), null);
  assert.equal(parseValidISODate(undefined), null);
  assert.equal(parseValidISODate(''), null);
  assert.equal(parseValidISODate('   '), null);
  assert.equal(parseValidISODate(12345), null);
  assert.equal(parseValidISODate({}), null);
  assert.equal(parseValidISODate('not-a-date'), null);
});

test('Phase 2J Finding 1: Comment connection availability and validation across all states', () => {
  // 1. Explicit zero comments
  const zeroComments = normalizeIssue({
    number: 901,
    title: 'Explicit zero comments issue',
    comments: { totalCount: 0, nodes: [] }
  });
  assert.equal(zeroComments.isCommentsAvailable, true);
  assert.equal(zeroComments.commentCount, 0);
  assert.equal(zeroComments.lastCommentAt, null);
  assert.equal(zeroComments.lastCommentAuthor, null);

  // 2. Positive count and valid timestamp
  const validComments = normalizeIssue({
    number: 902,
    title: 'Positive comments with valid timestamp',
    comments: {
      totalCount: 4,
      nodes: [{ createdAt: '2026-11-20T10:00:00Z', author: { login: 'contributorA' } }]
    }
  });
  assert.equal(validComments.isCommentsAvailable, true);
  assert.equal(validComments.commentCount, 4);
  assert.equal(validComments.lastCommentAt, '2026-11-20T10:00:00Z');
  assert.equal(validComments.lastCommentAuthor, 'contributorA');

  // 3. Positive count with unavailable comment details (empty nodes)
  const emptyNodesComments = normalizeIssue({
    number: 903,
    title: 'Positive count with empty nodes',
    comments: { totalCount: 2, nodes: [] }
  });
  assert.equal(emptyNodesComments.isCommentsAvailable, true);
  assert.equal(emptyNodesComments.commentCount, 2);
  assert.equal(emptyNodesComments.lastCommentAt, null);

  // 4. Positive count with null comment createdAt node
  const nullDateComment = normalizeIssue({
    number: 904,
    title: 'Comment node with null createdAt',
    comments: {
      totalCount: 1,
      nodes: [{ createdAt: null, author: { login: 'someone' } }]
    }
  });
  assert.equal(nullDateComment.isCommentsAvailable, true);
  assert.equal(nullDateComment.commentCount, 1);
  assert.equal(nullDateComment.lastCommentAt, null);

  // 5. Positive count with malformed date node
  const malformedDateComment = normalizeIssue({
    number: 905,
    title: 'Comment node with malformed date',
    comments: {
      totalCount: 3,
      nodes: [{ createdAt: '2026-02-31T00:00:00Z' }]
    }
  });
  assert.equal(malformedDateComment.isCommentsAvailable, true);
  assert.equal(malformedDateComment.commentCount, 3);
  assert.equal(malformedDateComment.lastCommentAt, null);

  // 6. Missing comments connection (property absent) -> isCommentsAvailable: false, commentCount: null
  const missingCommentsProp = normalizeIssue({
    number: 906,
    title: 'Missing comments connection'
  });
  assert.equal(missingCommentsProp.isCommentsAvailable, false);
  assert.equal(missingCommentsProp.commentCount, null);
  assert.equal(missingCommentsProp.lastCommentAt, null);

  // 7. Null comments connection -> isCommentsAvailable: false, commentCount: null
  const nullCommentsConn = normalizeIssue({
    number: 907,
    title: 'Null comments connection',
    comments: null
  });
  assert.equal(nullCommentsConn.isCommentsAvailable, false);
  assert.equal(nullCommentsConn.commentCount, null);
  assert.equal(nullCommentsConn.lastCommentAt, null);

  // 8. Missing totalCount in comments object -> isCommentsAvailable: false, commentCount: null
  const missingTotalCount = normalizeIssue({
    number: 908,
    title: 'Comments object without totalCount',
    comments: { nodes: [] }
  });
  assert.equal(missingTotalCount.isCommentsAvailable, false);
  assert.equal(missingTotalCount.commentCount, null);
  assert.equal(missingTotalCount.lastCommentAt, null);

  // 9. Malformed totalCount (non-integer, negative, or string) -> unknown, not zero
  const stringTotalCount = normalizeIssue({
    number: 909,
    title: 'String totalCount',
    comments: { totalCount: 'five', nodes: [] }
  });
  assert.equal(stringTotalCount.isCommentsAvailable, false);
  assert.equal(stringTotalCount.commentCount, null);

  const negativeTotalCount = normalizeIssue({
    number: 910,
    title: 'Negative totalCount',
    comments: { totalCount: -1, nodes: [] }
  });
  assert.equal(negativeTotalCount.isCommentsAvailable, false);
  assert.equal(negativeTotalCount.commentCount, null);

  const floatTotalCount = normalizeIssue({
    number: 911,
    title: 'Float totalCount',
    comments: { totalCount: 3.5, nodes: [] }
  });
  assert.equal(floatTotalCount.isCommentsAvailable, false);
  assert.equal(floatTotalCount.commentCount, null);

  // 10. Field error on comments connection -> isCommentsAvailable: false, commentCount: null
  const fieldErrors = new Map([
    ['issue_912_comments', { path: ['repository', 'issues', 'nodes', 0, 'comments'], message: 'Access denied' }]
  ]);
  const erroredComments = normalizeIssue(
    {
      number: 912,
      title: 'Comments connection error',
      comments: { totalCount: 5, nodes: [] }
    },
    fieldErrors,
    0
  );
  assert.equal(erroredComments.isCommentsAvailable, false);
  assert.equal(erroredComments.commentCount, null);
});

test('Phase 2K Finding 1: Comment field-error matching discrimination and safeguards', () => {
  // 1. Comments-specific alias error (key has comments or path has comments)
  const aliasCommentsError = new Map([
    ['issue_912_comments', { path: ['issue_912', 'comments'], message: 'Field comments error' }]
  ]);
  assert.equal(hasFieldErrorForIssueComments(aliasCommentsError, 912), true);
  assert.equal(hasFieldErrorForIssueComments(aliasCommentsError, 912, 0), true);

  // 2. Comments-specific indexed GraphQL error
  const indexedCommentsError = new Map([
    ['repository.issues.nodes.0.comments', { path: ['repository', 'issues', 'nodes', 0, 'comments'], message: 'Rate limit on comments' }]
  ]);
  assert.equal(hasFieldErrorForIssueComments(indexedCommentsError, 912, 0), true);
  assert.equal(hasFieldErrorForIssueComments(indexedCommentsError, 912, 1), false); // index 1 does not match index 0 error

  // 3. Generic issue alias error affecting title — must NOT match comments
  const titleAliasError = new Map([
    ['issue_912', { path: ['issue_912', 'title'], message: 'Error fetching title' }]
  ]);
  assert.equal(hasFieldErrorForIssueComments(titleAliasError, 912), false);
  assert.equal(hasFieldErrorForIssueComments(titleAliasError, 912, 0), false);

  // Verify normalizeIssue does NOT invalidate comments when title has an error
  const issueWithTitleError = normalizeIssue(
    {
      number: 912,
      title: 'Valid title despite alias error',
      comments: {
        totalCount: 3,
        nodes: [{ createdAt: '2026-11-20T10:00:00Z', author: { login: 'dev1' } }]
      }
    },
    titleAliasError,
    0
  );
  assert.equal(issueWithTitleError.isCommentsAvailable, true);
  assert.equal(issueWithTitleError.commentCount, 3);
  assert.equal(issueWithTitleError.lastCommentAt, '2026-11-20T10:00:00Z');

  // 4. Unrelated issue's comments error — must not contaminate the current issue
  const unrelatedIssueCommentsError = new Map([
    ['issue_999_comments', { path: ['issue_999', 'comments'], message: 'Comments error on 999' }]
  ]);
  assert.equal(hasFieldErrorForIssueComments(unrelatedIssueCommentsError, 912), false);

  const issueUncontaminated = normalizeIssue(
    {
      number: 912,
      title: 'Uncontaminated issue',
      comments: { totalCount: 2, nodes: [{ createdAt: '2026-11-20T12:00:00Z' }] }
    },
    unrelatedIssueCommentsError,
    0
  );
  assert.equal(issueUncontaminated.isCommentsAvailable, true);
  assert.equal(issueUncontaminated.commentCount, 2);

  // 5. Existing issue-number prefix collision protection (issue 14 vs issue 140)
  const prefixCollisionErrors = new Map([
    ['issue_140_comments', { path: ['issue_140', 'comments'], message: 'Error on issue 140 comments' }]
  ]);
  assert.equal(hasFieldErrorForIssueComments(prefixCollisionErrors, 14), false);
  assert.equal(hasFieldErrorForIssueComments(prefixCollisionErrors, 140), true);

  // 6. Genuinely ambiguous comments error (alias path with comments evidence in message/field)
  const ambiguousCommentsError = new Map([
    ['issue_912', { path: ['issue_912'], message: 'Error querying comments connection' }]
  ]);
  assert.equal(hasFieldErrorForIssueComments(ambiguousCommentsError, 912), true);
});
