'use strict';

const test = require('node:test');
const assert = require('node:assert/strict');
const path = require('node:path');
const fs = require('node:fs');

const { runDigest } = require('../index');

function loadFixture(name) {
  const file = path.join(__dirname, 'fixtures', name);
  return JSON.parse(fs.readFileSync(file, 'utf8'));
}

test('runDigest: orchestrates full pipeline with mock runtime and outputs to summary', async () => {
  const issuesFixture = loadFixture('fixture_issues.json');
  const prsFixture = loadFixture('fixture_prs.json');
  const mergedFixture = loadFixture('fixture_merged_prs.json');

  const mockGraphql = async (query, vars) => {
    if (query.includes('query OpenIssues')) {
      return issuesFixture.data;
    }
    if (query.includes('query OpenPullRequests')) {
      return prsFixture.data;
    }
    if (query.includes('query MergedPullRequests')) {
      return mergedFixture.data;
    }
    if (query.includes('issueOrPullRequest')) {
      return {
        repository: {
          issue_7305: {
            __typename: 'Issue',
            number: 7305,
            state: 'CLOSED'
          }
        }
      };
    }
    return {};
  };

  let summaryBuffer = '';
  let writeCalled = false;
  const mockSummary = {
    addRaw: (text) => {
      summaryBuffer += text;
      return mockSummary;
    },
    write: async () => {
      writeCalled = true;
    }
  };

  const logs = [];
  const mockLog = {
    info: (msg) => logs.push(msg),
    warning: (msg) => logs.push(msg),
    error: (msg) => logs.push(msg)
  };

  const result = await runDigest({
    graphql: mockGraphql,
    summary: mockSummary,
    log: mockLog,
    owner: 'rubyforgood',
    name: 'casa'
  });

  assert.equal(writeCalled, true);
  assert.equal(typeof result.markdown, 'string');
  assert.equal(result.markdown.includes('CASA Contributor Work Queue Digest'), true);
  assert.equal(result.markdown.includes('Data Quality & Ingestion Summary'), true);
  assert.equal(result.markdown.includes('Review & CI Clear'), true);
  assert.equal(result.markdown.includes('PRs Requiring Attention'), true);
  assert.equal(result.markdown.includes('Contributor Opportunities'), true);
  assert.equal(result.markdown.includes('Issue & PR Cross-Reference Matrix'), true);
  assert.equal(summaryBuffer, result.markdown);
});

test('runDigest: throws error when graphql or summary is missing', async () => {
  await assert.rejects(
    async () => runDigest({ summary: { addRaw: () => {}, write: () => {} } }),
    { message: /Missing required dependency: graphql function/ }
  );

  await assert.rejects(
    async () => runDigest({ graphql: async () => {} }),
    { message: /Missing required dependency: summary interface/ }
  );
});

test('Finding #3: runDigest correctly reports Partial status and does not claim Complete scan when merged PR query has later-page failure', async () => {
  let mergedCallCount = 0;
  const mockGraphql = async (query, vars) => {
    if (query.includes('query GetOpenIssues')) {
      return { repository: { issues: { totalCount: 1, pageInfo: { hasNextPage: false }, nodes: [{ number: 501, title: 'Open Issue' }] } } };
    }
    if (query.includes('query GetOpenPullRequests')) {
      return { repository: { pullRequests: { totalCount: 1, pageInfo: { hasNextPage: false }, nodes: [{ number: 601, title: 'Open PR' }] } } };
    }
    if (query.includes('query GetMergedPRs')) {
      mergedCallCount++;
      if (mergedCallCount === 1) {
        return {
          search: {
            issueCount: 2,
            pageInfo: { hasNextPage: true, endCursor: 'merged_cursor_p1' },
            nodes: [{
              number: 701,
              title: 'Merged PR 701 on Page 1',
              mergedAt: '2026-11-20T10:00:00Z',
              closingIssuesReferences: { totalCount: 1, nodes: [{ number: 501, state: 'CLOSED' }] }
            }]
          }
        };
      }
      // Page 2 transport failure
      throw new Error('ETIMEDOUT: GitHub API timed out on page 2');
    }
    return { repository: {} };
  };

  let summaryBuffer = '';
  const mockSummary = {
    addRaw: (text) => { summaryBuffer += text; return mockSummary; },
    write: async () => {}
  };

  const logs = [];
  const mockLog = {
    info: (msg) => logs.push(msg),
    warning: (msg) => logs.push(msg),
    error: (msg) => logs.push(msg)
  };

  const result = await runDigest({
    graphql: mockGraphql,
    summary: mockSummary,
    log: mockLog,
    owner: 'rubyforgood',
    name: 'casa'
  });

  // Verify earlier records were preserved
  assert.equal(result.metrics.mergedRetrieved, 1);
  assert.equal(result.metrics.mergedExpected, 2);
  assert.equal(result.metrics.isMergedPartial, true);

  // Verify markdown table renders honest Partial status
  assert.equal(result.markdown.includes('| **Merged PRs (14d)** | 1 / 2 | ⚠️ Partial | Search query partial; later pages failed |'), true);

  // Crucial requirement: MUST NOT claim 'Complete scan (14d window)'
  assert.equal(result.markdown.includes('Complete scan (14d window)'), false);
});
