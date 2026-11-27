'use strict';

/**
 * GraphQL Query definitions and network retrieval for Contributor Work Queue Digest.
 * Pure dependency injection: expects an authenticated `graphql` client function.
 */

const OPEN_PRS_QUERY = `
query GetOpenPullRequests($owner: String!, $name: String!, $cursor: String) {
  repository(owner: $owner, name: $name) {
    pullRequests(first: 50, states: OPEN, after: $cursor, orderBy: {field: CREATED_AT, direction: DESC}) {
      pageInfo {
        hasNextPage
        endCursor
      }
      totalCount
      nodes {
        number
        title
        url
        isDraft
        headRefName
        createdAt
        updatedAt
        author {
          login
        }
        labels(first: 20) {
          totalCount
          nodes {
            name
          }
        }
        reviewDecision
        reviewRequests(first: 10) {
          totalCount
          nodes {
            requestedReviewer {
              ... on User { login }
              ... on Team { name }
            }
          }
        }
        reviews(last: 10) {
          totalCount
          nodes {
            author { login }
            state
            submittedAt
          }
        }
        commits(last: 1) {
          nodes {
            commit {
              committedDate
              statusCheckRollup {
                state
                contexts(first: 1) {
                  totalCount
                }
              }
              status {
                contexts {
                  id
                }
              }
              checkSuites(first: 1) {
                totalCount
              }
            }
          }
        }
        closingIssuesReferences(first: 10) {
          totalCount
          pageInfo {
            hasNextPage
          }
          nodes {
            number
            title
            state
          }
        }
        body
      }
    }
  }
}
`;

const OPEN_ISSUES_QUERY = `
query GetOpenIssues($owner: String!, $name: String!, $cursor: String) {
  repository(owner: $owner, name: $name) {
    issues(first: 100, states: OPEN, after: $cursor, orderBy: {field: CREATED_AT, direction: DESC}) {
      pageInfo {
        hasNextPage
        endCursor
      }
      totalCount
      nodes {
        number
        title
        url
        createdAt
        updatedAt
        assignees(first: 10) {
          totalCount
          nodes {
            login
          }
        }
        labels(first: 20) {
          totalCount
          nodes {
            name
          }
        }
        comments(last: 1) {
          totalCount
          nodes {
            createdAt
            author {
              login
            }
          }
        }
      }
    }
  }
}
`;

const MERGED_PRS_SEARCH_QUERY = `
query GetMergedPRs($searchQuery: String!, $cursor: String) {
  search(query: $searchQuery, type: ISSUE, first: 50, after: $cursor) {
    issueCount
    pageInfo {
      hasNextPage
      endCursor
    }
    nodes {
      ... on PullRequest {
        number
        title
        url
        mergedAt
        headRefName
        body
        closingIssuesReferences(first: 10) {
          totalCount
          pageInfo {
            hasNextPage
          }
          nodes {
            number
            state
          }
        }
      }
    }
  }
}
`;

function buildAliasBatchQuery(candidateNumbers) {
  const fields = candidateNumbers.map((num) => `
    i_${num}: issueOrPullRequest(number: ${num}) {
      __typename
      ... on Issue {
        number
        state
        title
      }
      ... on PullRequest {
        number
        state
        title
      }
    }
  `).join('\n');

  return `
query BatchResolveIssues($owner: String!, $name: String!) {
  repository(owner: $owner, name: $name) {
    ${fields}
  }
}
`;
}

/**
 * Offsets node index in GraphQL field error paths across pagination pages.
 * Ensures relative index 0 on page 2 becomes global index (0 + pageOffset).
 */
function offsetFieldErrors(errors, pageOffset, connectionName) {
  if (!Array.isArray(errors)) return [];
  return errors.map((fe) => {
    if (!fe || !Array.isArray(fe.path)) return fe;
    const path = [...fe.path];
    for (let i = 0; i < path.length - 2; i++) {
      if (path[i] === connectionName && path[i + 1] === 'nodes') {
        const nodeIdx = path[i + 2];
        if (typeof nodeIdx === 'number') {
          path[i + 2] = nodeIdx + pageOffset;
        } else if (typeof nodeIdx === 'string' && /^\d+$/.test(nodeIdx)) {
          path[i + 2] = String(Number(nodeIdx) + pageOffset);
        }
        break;
      }
    }
    return { ...fe, path };
  });
}

/**
 * Fetch all open pull requests with pagination.
 */
async function fetchOpenPullRequests({ graphql, owner, name, maxPages = 5, log }) {
  let hasNextPage = true;
  let cursor = null;
  let page = 0;
  let allNodes = [];
  let totalCount = null;
  const fieldErrors = new Map();
  let isPartial = false;
  let isFailed = false;

  while (hasNextPage && page < maxPages) {
    page++;
    let response = null;

    try {
      response = await graphql(OPEN_PRS_QUERY, { owner, name, cursor });
    } catch (err) {
      if (err.data && err.data.repository && err.data.repository.pullRequests) {
        response = err.data;
        if (err.errors && Array.isArray(err.errors)) {
          isPartial = true;
          const adjustedErrors = offsetFieldErrors(err.errors, allNodes.length, 'pullRequests');
          for (const fe of adjustedErrors) {
            const pathKey = Array.isArray(fe.path) ? fe.path.join('.') : 'unknown';
            fieldErrors.set(pathKey, fe);
          }
        }
      } else {
        if (log && log.warning) {
          log.warning(`Open PRs query failed on page ${page}: ${err.message}`);
        }
        if (allNodes.length > 0) {
          // Preserve valid nodes from earlier pages, mark as partial
          isPartial = true;
          hasNextPage = false;
          break;
        } else {
          // Initial page failed without usable data
          isFailed = true;
          return {
            nodes: [],
            totalCount: 0,
            fieldErrors,
            isCapped: false,
            isPartial: false,
            isFailed: true,
            status: 'Failed'
          };
        }
      }
    }

    const prData = response?.repository?.pullRequests;
    if (!prData) {
      if (allNodes.length > 0) isPartial = true;
      else isFailed = true;
      break;
    }

    if (typeof prData.totalCount === 'number') {
      totalCount = prData.totalCount;
    }

    const nodes = (prData.nodes || []).filter(Boolean);
    allNodes = allNodes.concat(nodes);

    // Never infer completion from missing or null pageInfo
    if (!prData.pageInfo || typeof prData.pageInfo.hasNextPage !== 'boolean') {
      isPartial = true;
      hasNextPage = false;
      cursor = null;
    } else {
      hasNextPage = prData.pageInfo.hasNextPage;
      cursor = prData.pageInfo.endCursor || null;
      if (hasNextPage && !cursor) {
        isPartial = true;
        hasNextPage = false;
      }
    }
  }

  const isCapped = hasNextPage && page >= maxPages;
  let status = 'Complete';
  if (isFailed || (allNodes.length === 0 && totalCount === null)) {
    status = 'Failed';
    isFailed = true;
  } else if (isCapped) {
    status = 'Capped';
  } else if (isPartial || (totalCount !== null && allNodes.length < totalCount)) {
    status = 'Partial';
    isPartial = true;
  } else {
    status = 'Complete';
  }

  return {
    nodes: allNodes,
    totalCount: totalCount !== null ? totalCount : allNodes.length,
    fieldErrors,
    isCapped,
    isPartial,
    isFailed,
    status
  };
}

/**
 * Fetch all open issues with pagination.
 */
async function fetchOpenIssues({ graphql, owner, name, maxPages = 5, log }) {
  let hasNextPage = true;
  let cursor = null;
  let page = 0;
  let allNodes = [];
  let totalCount = null;
  const fieldErrors = new Map();
  let isPartial = false;
  let isFailed = false;

  while (hasNextPage && page < maxPages) {
    page++;
    let response = null;

    try {
      response = await graphql(OPEN_ISSUES_QUERY, { owner, name, cursor });
    } catch (err) {
      if (err.data && err.data.repository && err.data.repository.issues) {
        response = err.data;
        if (err.errors && Array.isArray(err.errors)) {
          isPartial = true;
          const adjustedErrors = offsetFieldErrors(err.errors, allNodes.length, 'issues');
          for (const fe of adjustedErrors) {
            const pathKey = Array.isArray(fe.path) ? fe.path.join('.') : 'unknown';
            fieldErrors.set(pathKey, fe);
          }
        }
      } else {
        if (log && log.warning) {
          log.warning(`Open issues query failed on page ${page}: ${err.message}`);
        }
        if (allNodes.length > 0) {
          // Preserve valid nodes from earlier pages, mark as partial
          isPartial = true;
          hasNextPage = false;
          break;
        } else {
          // Initial page failed without usable data
          isFailed = true;
          return {
            nodes: [],
            totalCount: 0,
            fieldErrors,
            isCapped: false,
            isPartial: false,
            isFailed: true,
            status: 'Failed'
          };
        }
      }
    }

    const issueData = response?.repository?.issues;
    if (!issueData) {
      if (allNodes.length > 0) isPartial = true;
      else isFailed = true;
      break;
    }

    if (typeof issueData.totalCount === 'number') {
      totalCount = issueData.totalCount;
    }

    const nodes = (issueData.nodes || []).filter(Boolean);
    allNodes = allNodes.concat(nodes);

    // Never infer completion from missing or null pageInfo
    if (!issueData.pageInfo || typeof issueData.pageInfo.hasNextPage !== 'boolean') {
      isPartial = true;
      hasNextPage = false;
      cursor = null;
    } else {
      hasNextPage = issueData.pageInfo.hasNextPage;
      cursor = issueData.pageInfo.endCursor || null;
      if (hasNextPage && !cursor) {
        isPartial = true;
        hasNextPage = false;
      }
    }
  }

  const isCapped = hasNextPage && page >= maxPages;
  let status = 'Complete';
  if (isFailed || (allNodes.length === 0 && totalCount === null)) {
    status = 'Failed';
    isFailed = true;
  } else if (isCapped) {
    status = 'Capped';
  } else if (isPartial || (totalCount !== null && allNodes.length < totalCount)) {
    status = 'Partial';
    isPartial = true;
  } else {
    status = 'Complete';
  }

  return {
    nodes: allNodes,
    totalCount: totalCount !== null ? totalCount : allNodes.length,
    fieldErrors,
    isCapped,
    isPartial,
    isFailed,
    status
  };
}

/**
 * Fetch merged pull requests within a date-scoped window.
 */
async function fetchMergedPullRequests({ graphql, owner, name, mergedWindowDays = 14, maxPages = 2, log }) {
  const sinceDate = new Date(Date.now() - mergedWindowDays * 24 * 60 * 60 * 1000);
  const dateStr = sinceDate.toISOString().slice(0, 10);
  const searchQuery = `repo:${owner}/${name} is:pr is:merged merged:>=${dateStr}`;

  let hasNextPage = true;
  let cursor = null;
  let page = 0;
  let allNodes = [];
  let totalCount = 0;
  const fieldErrors = new Map();
  let isPartial = false;
  let isFailed = false;

  while (hasNextPage && page < maxPages) {
    page++;
    let response;
    try {
      response = await graphql(MERGED_PRS_SEARCH_QUERY, { searchQuery, cursor });
    } catch (err) {
      if (err.data && err.data.search) {
        response = err.data;
        if (err.errors) {
          isPartial = true;
          const adjustedErrors = offsetFieldErrors(err.errors, allNodes.length, 'search');
          for (const fe of adjustedErrors) {
            const pathKey = Array.isArray(fe.path) ? fe.path.join('.') : 'unknown';
            fieldErrors.set(pathKey, fe);
          }
        }
      } else {
        if (log && log.warning) {
          log.warning(`Merged PR search failed: ${err.message}`);
        }
        if (allNodes.length > 0) {
          isPartial = true;
          hasNextPage = false;
          break;
        } else {
          isFailed = true;
          return { nodes: [], totalCount: 0, fieldErrors, isCapped: false, isPartial: false, isFailed: true, status: 'Failed' };
        }
      }
    }

    const searchData = response?.search;
    if (!searchData) {
      if (allNodes.length > 0) isPartial = true;
      else isFailed = true;
      break;
    }

    totalCount = searchData.issueCount || 0;
    const nodes = (searchData.nodes || []).filter(Boolean);
    allNodes = allNodes.concat(nodes);

    if (!searchData.pageInfo || typeof searchData.pageInfo.hasNextPage !== 'boolean') {
      isPartial = true;
      hasNextPage = false;
      cursor = null;
    } else {
      hasNextPage = searchData.pageInfo.hasNextPage;
      cursor = searchData.pageInfo.endCursor || null;
      if (hasNextPage && !cursor) {
        isPartial = true;
        hasNextPage = false;
      }
    }
  }

  // Sort retrieved merged PRs in memory by mergedAt descending
  allNodes.sort((a, b) => new Date(b.mergedAt) - new Date(a.mergedAt));

  const isCapped = hasNextPage && page >= maxPages;
  let status = 'Complete';
  if (isFailed) status = 'Failed';
  else if (isCapped) status = 'Capped';
  else if (isPartial || (totalCount > 0 && allNodes.length < totalCount)) status = 'Partial';
  else status = 'Complete';

  return { nodes: allNodes, totalCount, fieldErrors, isCapped, isPartial, isFailed, status };
}

/**
 * Batch resolve unknown candidate issue numbers using issueOrPullRequest aliases.
 */
async function resolveIssueBatch({ graphql, owner, name, candidateNumbers, batchSize = 25, log }) {
  if (!candidateNumbers || candidateNumbers.length === 0) {
    return { data: { repository: {} }, errors: [] };
  }

  const combinedData = { repository: {} };
  const allErrors = [];

  for (let i = 0; i < candidateNumbers.length; i += batchSize) {
    const chunk = candidateNumbers.slice(i, i + batchSize);
    const query = buildAliasBatchQuery(chunk);

    try {
      const response = await graphql(query, { owner, name });
      if (response && response.repository) {
        Object.assign(combinedData.repository, response.repository);
      }
    } catch (err) {
      if (err.data && err.data.repository) {
        Object.assign(combinedData.repository, err.data.repository);
      }
      if (err.errors && Array.isArray(err.errors)) {
        allErrors.push(...err.errors);
      } else if (!err.data) {
        if (log && log.warning) {
          log.warning(`Batch alias query failed: ${err.message}`);
        }
      }
    }
  }

  return { data: combinedData, errors: allErrors };
}

module.exports = {
  OPEN_PRS_QUERY,
  OPEN_ISSUES_QUERY,
  MERGED_PRS_SEARCH_QUERY,
  buildAliasBatchQuery,
  offsetFieldErrors,
  fetchOpenPullRequests,
  fetchOpenIssues,
  fetchMergedPullRequests,
  resolveIssueBatch
};
