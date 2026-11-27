'use strict';

const test = require('node:test');
const assert = require('node:assert/strict');
const path = require('node:path');
const fs = require('node:fs');

const {
  OPEN_PRS_QUERY,
  OPEN_ISSUES_QUERY,
  MERGED_PRS_SEARCH_QUERY,
  buildAliasBatchQuery,
  offsetFieldErrors,
  fetchOpenPullRequests,
  fetchOpenIssues,
  fetchMergedPullRequests,
  resolveIssueBatch
} = require('../query');

function loadFixture(name) {
  const file = path.join(__dirname, 'fixtures', name);
  return JSON.parse(fs.readFileSync(file, 'utf8'));
}

test('buildAliasBatchQuery: constructs valid GraphQL field aliases', () => {
  const query = buildAliasBatchQuery([7305, 7334]);
  assert.equal(query.includes('i_7305: issueOrPullRequest(number: 7305)'), true);
  assert.equal(query.includes('i_7334: issueOrPullRequest(number: 7334)'), true);
});

test('fetchOpenPullRequests: paginates and extracts nodes using injected graphql', async () => {
  const fixture = loadFixture('fixture_prs.json');
  const mockGraphql = async (query, vars) => {
    assert.equal(vars.owner, 'rubyforgood');
    assert.equal(vars.name, 'casa');
    return fixture.data;
  };

  const result = await fetchOpenPullRequests({
    graphql: mockGraphql,
    owner: 'rubyforgood',
    name: 'casa',
    maxPages: 2,
    log: { warning: () => {} }
  });

  assert.equal(result.nodes.length, 4);
  assert.equal(result.totalCount, 4);
  assert.equal(result.isCapped, false);
});

test('fetchOpenIssues: paginates and extracts nodes using injected graphql', async () => {
  const fixture = loadFixture('fixture_issues.json');
  const mockGraphql = async () => fixture.data;

  const result = await fetchOpenIssues({
    graphql: mockGraphql,
    owner: 'rubyforgood',
    name: 'casa',
    maxPages: 2,
    log: { warning: () => {} }
  });

  assert.equal(result.nodes.length, 3);
  assert.equal(result.totalCount, 3);
});

test('fetchMergedPullRequests: searches and sorts nodes by mergedAt descending', async () => {
  const fixture = loadFixture('fixture_merged_prs.json');
  const mockGraphql = async (query, vars) => {
    assert.equal(vars.searchQuery.includes('is:pr is:merged merged:>='), true);
    return fixture.data;
  };

  const result = await fetchMergedPullRequests({
    graphql: mockGraphql,
    owner: 'rubyforgood',
    name: 'casa',
    mergedWindowDays: 14,
    log: { warning: () => {} }
  });

  assert.equal(result.nodes.length, 2);
  // Must be sorted by mergedAt descending: 7436 (Nov 20) before 7424 (Nov 19)
  assert.equal(result.nodes[0].number, 7436);
  assert.equal(result.nodes[1].number, 7424);
  assert.equal(new Date(result.nodes[0].mergedAt) > new Date(result.nodes[1].mergedAt), true);
});

test('resolveIssueBatch: returns empty data when candidates list is empty', async () => {
  const mockGraphql = async () => {
    throw new Error('Should not be called');
  };

  const result = await resolveIssueBatch({
    graphql: mockGraphql,
    owner: 'rubyforgood',
    name: 'casa',
    candidateNumbers: []
  });

  assert.deepEqual(result.data, { repository: {} });
  assert.deepEqual(result.errors, []);
});

test('fetchOpenPullRequests: preserves valid earlier-page records when later page has transport failure', async () => {
  let callCount = 0;
  const mockGraphql = async (query, vars) => {
    callCount++;
    if (callCount === 1) {
      return {
        repository: {
          pullRequests: {
            totalCount: 150,
            pageInfo: { hasNextPage: true, endCursor: 'cursor_p1' },
            nodes: [{ number: 1, title: 'PR 1' }, { number: 2, title: 'PR 2' }]
          }
        }
      };
    }
    // Page 2 transport failure (no data)
    throw new Error('ETIMEDOUT: Connection to GitHub failed');
  };

  const logs = [];
  const result = await fetchOpenPullRequests({
    graphql: mockGraphql,
    owner: 'rubyforgood',
    name: 'casa',
    log: { warning: (msg) => logs.push(msg) }
  });

  assert.equal(result.nodes.length, 2);
  assert.equal(result.nodes[0].number, 1);
  assert.equal(result.nodes[1].number, 2);
  assert.equal(result.isPartial, true);
  assert.equal(result.status, 'Partial');
  assert.equal(result.isFailed, false);
  assert.equal(logs.length, 1);
  assert.equal(logs[0].includes('ETIMEDOUT'), true);
});

test('fetchOpenPullRequests: handles second page with partial GraphQL data and errors', async () => {
  let callCount = 0;
  const mockGraphql = async (query, vars) => {
    callCount++;
    if (callCount === 1) {
      return {
        repository: {
          pullRequests: {
            totalCount: 3,
            pageInfo: { hasNextPage: true, endCursor: 'cursor_p1' },
            nodes: [{ number: 101, title: 'PR 101' }]
          }
        }
      };
    }
    // Page 2 error with partial nodes
    const err = new Error('Field error on commits');
    err.data = {
      repository: {
        pullRequests: {
          totalCount: 3,
          pageInfo: { hasNextPage: false, endCursor: null },
          nodes: [{ number: 102, title: 'PR 102' }]
        }
      }
    };
    err.errors = [{ path: ['repository', 'pullRequests', 'nodes', 0, 'commits'], message: 'Timeout' }];
    throw err;
  };

  const result = await fetchOpenPullRequests({
    graphql: mockGraphql,
    owner: 'rubyforgood',
    name: 'casa'
  });

  assert.equal(result.nodes.length, 2);
  assert.equal(result.nodes[0].number, 101);
  assert.equal(result.nodes[1].number, 102);
  assert.equal(result.isPartial, true);
  assert.equal(result.status, 'Partial');
  assert.equal(result.fieldErrors.size, 1);
  assert.equal(result.fieldErrors.has('repository.pullRequests.nodes.1.commits'), true);
});

test('fetchOpenPullRequests: initial-page failure without usable data reports Failed', async () => {
  const mockGraphql = async () => {
    throw new Error('Bad credentials: 401 Unauthorized');
  };

  const logs = [];
  const result = await fetchOpenPullRequests({
    graphql: mockGraphql,
    owner: 'rubyforgood',
    name: 'casa',
    log: { warning: (msg) => logs.push(msg) }
  });

  assert.equal(result.nodes.length, 0);
  assert.equal(result.isFailed, true);
  assert.equal(result.status, 'Failed');
  assert.equal(result.isPartial, false);
});

test('fetchOpenIssues: missing or malformed pageInfo halts pagination and marks Partial', async () => {
  const mockGraphql = async () => {
    return {
      repository: {
        issues: {
          totalCount: 50,
          pageInfo: null, // malformed/null pageInfo
          nodes: [{ number: 501, title: 'Issue 501' }]
        }
      }
    };
  };

  const result = await fetchOpenIssues({
    graphql: mockGraphql,
    owner: 'rubyforgood',
    name: 'casa'
  });

  assert.equal(result.nodes.length, 1);
  assert.equal(result.isPartial, true);
  assert.equal(result.status, 'Partial');
});

test('fetchOpenIssues: preserves valid earlier-page records when later page has transport failure', async () => {
  let callCount = 0;
  const mockGraphql = async (query, vars) => {
    callCount++;
    if (callCount === 1) {
      return {
        repository: {
          issues: {
            totalCount: 150,
            pageInfo: { hasNextPage: true, endCursor: 'cursor_issue_p1' },
            nodes: [{ number: 501, title: 'Issue 501' }, { number: 502, title: 'Issue 502' }]
          }
        }
      };
    }
    // Page 2 transport failure (no data)
    throw new Error('ECONNRESET: Connection to GitHub reset');
  };

  const logs = [];
  const result = await fetchOpenIssues({
    graphql: mockGraphql,
    owner: 'rubyforgood',
    name: 'casa',
    log: { warning: (msg) => logs.push(msg) }
  });

  assert.equal(result.nodes.length, 2);
  assert.equal(result.nodes[0].number, 501);
  assert.equal(result.nodes[1].number, 502);
  assert.equal(result.isPartial, true);
  assert.equal(result.status, 'Partial');
  assert.equal(result.isFailed, false);
  assert.equal(logs.length, 1);
  assert.equal(logs[0].includes('ECONNRESET'), true);
});

test('Finding #1: MERGED_PRS_SEARCH_QUERY requests totalCount in closingIssuesReferences', () => {
  const query = MERGED_PRS_SEARCH_QUERY;
  assert.equal(query.includes('closingIssuesReferences(first: 10)'), true);
  const closingBlock = query.slice(query.indexOf('closingIssuesReferences(first: 10)'));
  assert.equal(closingBlock.includes('totalCount'), true);
});

test('Finding #4: offsetFieldErrors correctly translates page relative index to global index', () => {
  const page1Errors = [
    { path: ['repository', 'issues', 'nodes', 0, 'assignees'], message: 'Error on page 1 node 0' }
  ];
  const page2Errors = [
    { path: ['repository', 'issues', 'nodes', 0, 'assignees'], message: 'Error on page 2 node 0' }
  ];

  const adjustedP1 = offsetFieldErrors(page1Errors, 0, 'issues');
  const adjustedP2 = offsetFieldErrors(page2Errors, 50, 'issues');

  assert.deepEqual(adjustedP1[0].path, ['repository', 'issues', 'nodes', 0, 'assignees']);
  assert.deepEqual(adjustedP2[0].path, ['repository', 'issues', 'nodes', 50, 'assignees']);
});

test('Finding #4: fetchOpenIssues translates page 2 field errors to global index without overwriting page 1', async () => {
  let callCount = 0;
  const mockGraphql = async () => {
    callCount++;
    if (callCount === 1) {
      return {
        repository: {
          issues: {
            totalCount: 4,
            pageInfo: { hasNextPage: true, endCursor: 'p1_cursor' },
            nodes: [{ number: 101, title: 'Issue 101' }, { number: 102, title: 'Issue 102' }]
          }
        }
      };
    }
    // Page 2 has error on its relative node 0
    const err = new Error('Field error on page 2 node 0');
    err.data = {
      repository: {
        issues: {
          totalCount: 4,
          pageInfo: { hasNextPage: false, endCursor: null },
          nodes: [{ number: 201, title: 'Issue 201' }, { number: 202, title: 'Issue 202' }]
        }
      }
    };
    err.errors = [{ path: ['repository', 'issues', 'nodes', 0, 'assignees'], message: 'Error on issue 201' }];
    throw err;
  };

  const result = await fetchOpenIssues({
    graphql: mockGraphql,
    owner: 'rubyforgood',
    name: 'casa'
  });

  assert.equal(result.nodes.length, 4);
  assert.equal(result.isPartial, true);
  // Page 2 node 0 is global node 2 (since page 1 had 2 nodes)
  assert.equal(result.fieldErrors.has('repository.issues.nodes.2.assignees'), true);
  // Page 1 node 0 is NOT affected
  assert.equal(result.fieldErrors.has('repository.issues.nodes.0.assignees'), false);
});

test('Phase 2E Fix B: fetchMergedPullRequests offsets search.nodes field errors on later pages and prevents page contamination', async () => {
  let callCount = 0;
  const mockGraphql = async () => {
    callCount++;
    if (callCount === 1) {
      return {
        search: {
          issueCount: 4,
          pageInfo: { hasNextPage: true, endCursor: 'search_p1_cursor' },
          nodes: [
            {
              number: 7401,
              title: 'Merged PR 7401 (Page 1 Node 0)',
              mergedAt: '2026-11-20T10:00:00Z',
              closingIssuesReferences: { totalCount: 1, nodes: [{ number: 6001, state: 'CLOSED' }] }
            },
            {
              number: 7402,
              title: 'Merged PR 7402 (Page 1 Node 1)',
              mergedAt: '2026-11-19T10:00:00Z',
              closingIssuesReferences: { totalCount: 1, nodes: [{ number: 6002, state: 'CLOSED' }] }
            }
          ]
        }
      };
    }
    // Page 2: relative index 0 errored
    const err = new Error('Field error on search page 2 node 0 closing references');
    err.data = {
      search: {
        issueCount: 4,
        pageInfo: { hasNextPage: false, endCursor: null },
        nodes: [
          {
            number: 7403,
            title: 'Merged PR 7403 (Page 2 Node 0)',
            mergedAt: '2026-11-18T10:00:00Z',
            closingIssuesReferences: { totalCount: 1, nodes: [{ number: 6003, state: 'CLOSED' }] }
          },
          {
            number: 7404,
            title: 'Merged PR 7404 (Page 2 Node 1)',
            mergedAt: '2026-11-17T10:00:00Z',
            closingIssuesReferences: { totalCount: 1, nodes: [{ number: 6004, state: 'CLOSED' }] }
          }
        ]
      }
    };
    err.errors = [
      {
        path: ['search', 'nodes', 0, 'closingIssuesReferences', 'nodes', 0, 'number'],
        message: 'Timeout resolving number'
      }
    ];
    throw err;
  };

  const result = await fetchMergedPullRequests({
    graphql: mockGraphql,
    owner: 'rubyforgood',
    name: 'casa',
    maxPages: 2,
    log: { warning: () => {} }
  });

  // Verify retrieval and sorting
  assert.equal(result.nodes.length, 4);
  assert.equal(result.isPartial, true);
  assert.equal(result.status, 'Partial');

  // Verify offset: Page 2 relative index 0 must be global index 2
  assert.equal(result.fieldErrors.has('search.nodes.2.closingIssuesReferences.nodes.0.number'), true);
  assert.equal(result.fieldErrors.has('search.nodes.0.closingIssuesReferences.nodes.0.number'), false);

  // Now verify that when passed to normalizeMergedPR with the pre-sort or raw index,
  // page 2 error does not contaminate page 1 merged PRs
  const { normalizeMergedPR } = require('../normalize');
  const prPage1Node0 = { number: 7401, closingIssuesReferences: { totalCount: 1, pageInfo: { hasNextPage: false }, nodes: [{ number: 6001 }] } };
  const prPage2Node0 = { number: 7403, closingIssuesReferences: { totalCount: 1, pageInfo: { hasNextPage: false }, nodes: [{ number: 6003 }] } };

  // Global index 0 (page 1 node 0)
  const norm0 = normalizeMergedPR(prPage1Node0, result.fieldErrors, 0);
  assert.equal(norm0.isClosingIssuesAvailable, true);
  assert.equal(norm0.isClosingIssuesComplete, true);
  assert.deepEqual(norm0.confirmedClosingIssueNumbers, [6001]);

  // Global index 2 (page 2 node 0)
  const norm2 = normalizeMergedPR(prPage2Node0, result.fieldErrors, 2);
  assert.equal(norm2.isClosingIssuesAvailable, false);
  assert.equal(norm2.isClosingIssuesComplete, false);
  assert.deepEqual(norm2.confirmedClosingIssueNumbers, []);
});
