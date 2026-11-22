'use strict';

/**
 * Top-level orchestrator for Contributor Work Queue Digest.
 * Injected with actions runtime interfaces (graphql, summary, log).
 * Uses only Node.js built-ins.
 */

const {
  fetchOpenPullRequests,
  fetchOpenIssues,
  fetchMergedPullRequests,
  resolveIssueBatch
} = require('./query');

const {
  normalizeData,
  processBatchResult
} = require('./normalize');

const {
  classifyBacklog,
  extractCandidateReferences
} = require('./classify');

const {
  formatDigest
} = require('./format');

async function runDigest({
  graphql,
  summary,
  log = console,
  owner = 'rubyforgood',
  name = 'casa',
  mergedWindowDays = 14
}) {
  if (!graphql) {
    throw new Error('Missing required dependency: graphql function');
  }
  if (!summary || typeof summary.addRaw !== 'function') {
    throw new Error('Missing required dependency: summary interface');
  }

  log.info(`Starting Contributor Work Queue Digest for ${owner}/${name}...`);

  const combinedFieldErrors = new Map();

  // 1. Fetch raw data
  const prsResult = await fetchOpenPullRequests({ graphql, owner, name, log });
  for (const [k, v] of prsResult.fieldErrors.entries()) combinedFieldErrors.set(k, v);

  const issuesResult = await fetchOpenIssues({ graphql, owner, name, log });
  for (const [k, v] of issuesResult.fieldErrors.entries()) combinedFieldErrors.set(k, v);

  const mergedResult = await fetchMergedPullRequests({ graphql, owner, name, mergedWindowDays, log });
  for (const [k, v] of mergedResult.fieldErrors.entries()) combinedFieldErrors.set(k, v);

  // 2. Normalize
  const { normalizedIssues, normalizedPRs, normalizedMergedPRs } = normalizeData({
    rawIssues: issuesResult.nodes,
    rawPRs: prsResult.nodes,
    rawMergedPRs: mergedResult.nodes,
    fieldErrors: combinedFieldErrors
  });

  const openIssuesMap = new Map(normalizedIssues.map((i) => [i.number, i]));
  const openPRsMap = new Map(normalizedPRs.map((p) => [p.number, p]));

  // 3. Collect candidate issue numbers needing resolution (not in open issues and not open PRs)
  const candidateNumbersSet = new Set();
  for (const pr of normalizedPRs) {
    const refs = extractCandidateReferences(pr);
    for (const r of refs) {
      if (!openIssuesMap.has(r.issueNumber) && !openPRsMap.has(r.issueNumber)) {
        candidateNumbersSet.add(r.issueNumber);
      }
    }
  }
  for (const mpr of normalizedMergedPRs) {
    const refs = extractCandidateReferences(mpr);
    for (const r of refs) {
      if (!openIssuesMap.has(r.issueNumber) && !openPRsMap.has(r.issueNumber)) {
        candidateNumbersSet.add(r.issueNumber);
      }
    }
  }

  const candidateNumbers = Array.from(candidateNumbersSet);

  // 4. Batch resolve unknown candidate numbers
  let resolvedBatchMap = new Map();
  if (candidateNumbers.length > 0) {
    log.info(`Resolving ${candidateNumbers.length} unknown referenced issue numbers...`);
    const batchResponse = await resolveIssueBatch({ graphql, owner, name, candidateNumbers, log });
    resolvedBatchMap = processBatchResult(batchResponse, candidateNumbers);
  }

  // 5. Calculate Data Quality Metrics
  let overflowCount = 0;
  for (const pr of normalizedPRs) {
    if (pr.labelsOverflow) overflowCount++;
    if (pr.reviewRequestsOverflow) overflowCount++;
    if (pr.reviewsOverflow) overflowCount++;
    if (pr.closingIssuesOverflow) overflowCount++;
  }
  for (const issue of normalizedIssues) {
    if (issue.labelsOverflow) overflowCount++;
    if (issue.assigneesOverflow) overflowCount++;
  }
  for (const mpr of normalizedMergedPRs) {
    if (mpr.closingIssuesOverflow) overflowCount++;
  }

  let confirmedCount = 0;
  let inferredCount = 0;
  let unverifiedCount = 0;

  for (const pr of normalizedPRs) {
    const refs = extractCandidateReferences(pr);
    for (const r of refs) {
      if (r.confidence === 'CONFIRMED') confirmedCount++;
      else if (r.confidence === 'HIGH_INFERRED' || r.confidence === 'LOW_MENTION') {
        const resolved = resolvedBatchMap.get(r.issueNumber);
        if (openIssuesMap.has(r.issueNumber) || (resolved && resolved.isIssue && resolved.state !== 'UNVERIFIED')) {
          inferredCount++;
        } else {
          unverifiedCount++;
        }
      }
    }
  }

  const deriveStatusDisplay = (res) => {
    if (!res) return '⚠️ Partial';
    if (res.status === 'Failed' || res.isFailed) return '❌ Failed';
    if (res.status === 'Capped' || res.isCapped) return '⚠️ Capped';
    if (res.status === 'Partial' || res.isPartial || (typeof res.totalCount === 'number' && res.totalCount > 0 && res.nodes.length < res.totalCount)) {
      return '⚠️ Partial';
    }
    return 'Complete';
  };

  const metrics = {
    issuesExpected: issuesResult.totalCount,
    issuesRetrieved: issuesResult.nodes.length,
    issuesStatus: deriveStatusDisplay(issuesResult),
    prsExpected: prsResult.totalCount,
    prsRetrieved: prsResult.nodes.length,
    prsStatus: deriveStatusDisplay(prsResult),
    mergedExpected: mergedResult.totalCount,
    mergedRetrieved: mergedResult.nodes.length,
    mergedStatus: deriveStatusDisplay(mergedResult),
    isMergedCapped: mergedResult.isCapped,
    isMergedFailed: mergedResult.isFailed,
    isMergedPartial: mergedResult.isPartial,
    overflowCount,
    confirmedCount,
    inferredCount,
    unverifiedCount,
    fieldErrorsCount: combinedFieldErrors.size
  };

  // 6. Classify
  const classification = classifyBacklog({
    normalizedIssues,
    normalizedPRs,
    normalizedMergedPRs,
    resolvedBatchMap,
    metrics
  });

  // 7. Format
  const markdown = formatDigest({
    classifiedPRs: classification.classifiedPRs,
    classifiedMergedPRs: classification.classifiedMergedPRs,
    opportunities: classification.opportunities,
    relationships: classification.relationships,
    metrics
  });

  // 8. Write output to step summary
  summary.addRaw(markdown);
  await summary.write();

  log.info(`Contributor Work Queue Digest successfully published to step summary (${markdown.length} characters).`);
  return { markdown, metrics };
}

module.exports = {
  runDigest
};
