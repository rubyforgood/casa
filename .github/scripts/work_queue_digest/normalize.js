'use strict';

/**
 * Normalization layer for Contributor Work Queue Digest.
 * Flattens raw GraphQL nodes into clean, predictable plain objects.
 * Uses only Node.js built-ins.
 */

/**
 * Safely inspects fieldErrors to see if an error applies to a specific PR and field.
 * Disambiguates between PR node indices (ignoring nested commit indices), alias keys,
 * and field names.
 */
function hasFieldErrorForPRField(fieldErrors, prNumber, prIndex, fieldGroup) {
  if (!fieldErrors || fieldErrors.size === 0) return false;

  const numStr = prNumber !== undefined && prNumber !== null ? String(prNumber) : null;
  const numRegex = numStr ? new RegExp(`(?:^|[^0-9])pr_${numStr}(?:[^0-9]|$)`) : null;

  for (const [key, fe] of fieldErrors.entries()) {
    const path = Array.isArray(fe?.path) ? fe.path : (typeof key === 'string' ? key.split('.') : []);

    // 1. Check if the error belongs to this PR node
    let matchesThisPR = false;
    let prPathIndex = -1;

    // Check alias match: pr_<num> or pr_<num>_<field>
    if (numStr) {
      if (key === `pr_${numStr}` || key.startsWith(`pr_${numStr}_`)) {
        matchesThisPR = true;
      } else if (path.some((p) => p === `pr_${numStr}` || (typeof p === 'string' && p.startsWith(`pr_${numStr}_`)))) {
        matchesThisPR = true;
      } else if (numRegex && numRegex.test(key)) {
        matchesThisPR = true;
      }
    }

    // Check indexed path match: repository.pullRequests.nodes.<prIndex>... or search.nodes.<prIndex>...
    if (!matchesThisPR && prIndex !== null && prIndex !== undefined) {
      for (let i = 0; i < path.length - 2; i++) {
        if ((path[i] === 'pullRequests' || path[i] === 'search') && path[i + 1] === 'nodes') {
          const idxVal = path[i + 2];
          if (idxVal === prIndex || idxVal === String(prIndex) || Number(idxVal) === Number(prIndex)) {
            matchesThisPR = true;
            prPathIndex = i + 2;
          }
          break;
        }
      }
    }

    // Check unindexed broad match
    if (!matchesThisPR) {
      if (
        key === `repository.pullRequests.nodes.${fieldGroup}` ||
        key.includes(`pullRequests.nodes.${fieldGroup}`) ||
        key === `search.nodes.${fieldGroup}` ||
        key.includes(`search.nodes.${fieldGroup}`)
      ) {
        matchesThisPR = true;
      }
    }

    if (!matchesThisPR) continue;

    // 2. Check if the error applies to the requested fieldGroup
    let pathFromPR = path;
    if (prPathIndex !== -1) {
      pathFromPR = path.slice(prPathIndex + 1);
      if (pathFromPR.length === 0) {
        return true;
      }
    } else if (numStr && (key === `pr_${numStr}` || (path.length === 1 && path[0] === `pr_${numStr}`))) {
      return true;
    }

    const pathFromPRStr = pathFromPR.join('.').toLowerCase();
    const keyLower = key.toLowerCase();

    switch (fieldGroup) {
      case 'reviewDecision':
        if (keyLower.includes('reviewdecision') || pathFromPRStr.includes('reviewdecision')) return true;
        break;
      case 'reviewRequests':
        if (keyLower.includes('reviewrequests') || pathFromPRStr.includes('reviewrequests')) return true;
        break;
      case 'reviews':
        if (keyLower.includes('reviews') || pathFromPRStr.includes('reviews')) return true;
        break;
      case 'ci':
        if (
          keyLower.includes('statuscheckrollup') ||
          keyLower.includes('checksuites') ||
          keyLower.includes('status') ||
          keyLower.includes('commits') ||
          pathFromPRStr.includes('statuscheckrollup') ||
          pathFromPRStr.includes('checksuites') ||
          pathFromPRStr.includes('status') ||
          pathFromPRStr.includes('commits')
        ) {
          return true;
        }
        break;
      case 'closingIssues':
        if (keyLower.includes('closingissuesreferences') || pathFromPRStr.includes('closingissuesreferences')) return true;
        break;
      default:
        break;
    }
  }

  return false;
}

/**
 * Safely inspects fieldErrors to see if an error applies to a specific Issue and assignees field.
 * Uses exact token boundaries to prevent substring prefix collisions (e.g. issue_14 vs issue_140).
 */
function hasFieldErrorForIssueAssignees(fieldErrors, issueNumber, issueIndex) {
  if (!fieldErrors || fieldErrors.size === 0) return false;

  const numStr = issueNumber !== undefined && issueNumber !== null ? String(issueNumber) : null;
  const numRegex = numStr ? new RegExp(`(?:^|[^0-9])issue_${numStr}(?:[^0-9]|$)`) : null;

  for (const [key, fe] of fieldErrors.entries()) {
    const path = Array.isArray(fe?.path) ? fe.path : key.split('.');

    let matchesThisIssue = false;

    if (numStr) {
      if (key === `issue_${numStr}` || key === `issue_${numStr}_assignees` || (numRegex && numRegex.test(key))) {
        matchesThisIssue = true;
      } else if (path.some((p) => p === `issue_${numStr}` || p === `issue_${numStr}_assignees`)) {
        matchesThisIssue = true;
      }
    }

    if (!matchesThisIssue && issueIndex !== null && issueIndex !== undefined) {
      for (let i = 0; i < path.length - 2; i++) {
        if (path[i] === 'issues' && path[i + 1] === 'nodes') {
          const idxVal = path[i + 2];
          if (idxVal === issueIndex || idxVal === String(issueIndex) || Number(idxVal) === Number(issueIndex)) {
            matchesThisIssue = true;
          }
          break;
        }
      }
    }

    if (!matchesThisIssue) {
      if (key === 'repository.issues.nodes.assignees' || key.includes('issues.nodes.assignees')) {
        matchesThisIssue = true;
      }
    }

    if (!matchesThisIssue) continue;

    const pathStr = path.join('.').toLowerCase();
    const keyLower = key.toLowerCase();
    if (keyLower.includes('assignees') || pathStr.includes('assignees')) {
      return true;
    }
  }

  return false;
}

/**
 * Safely inspects fieldErrors to see if an error applies to a specific Issue and comments field.
 * Uses exact token boundaries to prevent substring prefix collisions.
 */
function hasFieldErrorForIssueComments(fieldErrors, issueNumber, issueIndex) {
  if (!fieldErrors || fieldErrors.size === 0) return false;

  const numStr = issueNumber !== undefined && issueNumber !== null ? String(issueNumber) : null;
  const numRegex = numStr ? new RegExp(`(?:^|[^0-9])issue_${numStr}(?:[^0-9]|$)`) : null;

  for (const [key, fe] of fieldErrors.entries()) {
    const path = Array.isArray(fe?.path) ? fe.path : key.split('.');

    let matchesThisIssue = false;

    if (numStr) {
      if (key === `issue_${numStr}` || key === `issue_${numStr}_comments` || (numRegex && numRegex.test(key))) {
        matchesThisIssue = true;
      } else if (path.some((p) => p === `issue_${numStr}` || p === `issue_${numStr}_comments`)) {
        matchesThisIssue = true;
      }
    }

    if (!matchesThisIssue && issueIndex !== null && issueIndex !== undefined) {
      for (let i = 0; i < path.length - 2; i++) {
        if (path[i] === 'issues' && path[i + 1] === 'nodes') {
          const idxVal = path[i + 2];
          if (idxVal === issueIndex || idxVal === String(issueIndex) || Number(idxVal) === Number(issueIndex)) {
            matchesThisIssue = true;
          }
          break;
        }
      }
    }

    if (!matchesThisIssue) {
      if (key === 'repository.issues.nodes.comments' || key.includes('issues.nodes.comments')) {
        matchesThisIssue = true;
      }
    }

    if (!matchesThisIssue) continue;

    const pathStr = path.join('.').toLowerCase();
    const keyLower = key.toLowerCase();
    const messageLower = typeof fe?.message === 'string' ? fe.message.toLowerCase() : '';
    const fieldLower = typeof fe?.field === 'string' ? fe.field.toLowerCase() : '';

    if (
      keyLower.includes('comments') ||
      pathStr.includes('comments') ||
      fieldLower.includes('comments') ||
      messageLower.includes('comments')
    ) {
      return true;
    }
  }

  return false;
}

/**
 * Safeguard 1: Validates prNode first before inspecting prNumber or properties.
 * Accepts prNumber as an explicit parameter (or falls back safely).
 * Never throws on null, undefined, or malformed inputs.
 */
function extractReviewDecision(prNode, prNumber, fieldErrors = new Map(), index = null) {
  if (!prNode || typeof prNode !== 'object') {
    return { value: null, isAvailable: false, isError: true };
  }

  const num = prNumber !== undefined && prNumber !== null ? prNumber : prNode.number;
  if (hasFieldErrorForPRField(fieldErrors, num, index, 'reviewDecision')) {
    return { value: null, isAvailable: false, isError: true };
  }

  if (!('reviewDecision' in prNode)) {
    return { value: null, isAvailable: false, isError: true };
  }

  return { value: prNode.reviewDecision, isAvailable: true, isError: false };
}

/**
 * Safely parses and validates an ISO 8601 / RFC 3339 date string.
 * Supports date-only ISO strings (YYYY-MM-DD) and timezone-qualified datetimes
 * (YYYY-MM-DDTHH:mm:ss[.sss](Z|+HH:mm|-HH:mm)).
 * Validates calendar date validity (month days, leap years) and validates numeric
 * timezone offset components (hours 00-23, minutes 00-59) per RFC 3339 §5.6 / ISO 8601.
 *
 * Syntax vs. Civil Timezone Availability:
 * RFC 3339 §5.6 defines numeric offsets syntactically as ±HH:mm where time-hour is 00-23
 * and time-minute is 00-59, without restricting timestamps to the currently inhabited
 * terrestrial civil timezone range (UTC-12:00 to UTC+14:00). Timestamp syntax validation
 * accepts all well-formed offsets within 00:00 to 23:59 while strictly rejecting
 * offsets with hours >= 24 or minutes >= 60.
 *
 * Rejects timezone-less datetimes or compact offsets (+HHmm) rather than accepting
 * arbitrary strings merely because Date.parse() can interpret them.
 * Returns the valid string if parsable; null if missing, non-string, or invalid date.
 * Never substitutes current time.
 */
function parseValidISODate(val) {
  if (typeof val !== 'string' || !val) return null;
  const str = val.trim();
  if (!str) return null;

  // Date-only: YYYY-MM-DD
  // Datetime: YYYY-MM-DDTHH:mm:ss[.sss](Z|+HH:mm|-HH:mm)
  // Timezone-less datetimes and compact offsets (e.g. +0530) are rejected.
  const isoRegex = /^(\d{4})-(\d{2})-(\d{2})(?:[Tt](\d{2}):(\d{2}):(\d{2})(?:\.(\d+))?([Zz]|[+-]\d{2}:\d{2}))?$/;
  const match = str.match(isoRegex);
  if (!match) return null;

  const year = parseInt(match[1], 10);
  const month = parseInt(match[2], 10);
  const day = parseInt(match[3], 10);

  if (year < 1000 || month < 1 || month > 12 || day < 1 || day > 31) return null;

  const utcDate = new Date(Date.UTC(year, month - 1, day));
  if (
    utcDate.getUTCFullYear() !== year ||
    utcDate.getUTCMonth() + 1 !== month ||
    utcDate.getUTCDate() !== day
  ) {
    return null;
  }

  if (match[4] !== undefined) {
    const hour = parseInt(match[4], 10);
    const minute = parseInt(match[5], 10);
    const second = parseInt(match[6], 10);
    if (hour > 23 || minute > 59 || second > 59) return null;
  }

  if (match[8] !== undefined && match[8] !== 'Z' && match[8] !== 'z') {
    const tz = match[8];
    const tzHour = parseInt(tz.slice(1, 3), 10);
    const tzMin = parseInt(tz.slice(4, 6), 10);
    // RFC 3339 §5.6 / ISO 8601 numeric offset validation:
    // Offset hour must be 00-23, and offset minute must be 00-59.
    // Offsets with tzHour > 23 or tzMin > 59 are rejected.
    if (tzHour > 23 || tzMin > 59) return null;
  }

  const parsed = Date.parse(str);
  if (Number.isNaN(parsed)) return null;

  return str;
}

/**
 * Safeguard 2: Validates review-request presence and errors.
 * Missing, errored, or unavailable review-request data results in isAvailable: false.
 * Inconsistent totals (totalCount < nodes.length) or malformed nodes prevent claiming completeness.
 */
function extractReviewRequests(prNode, prNumber, fieldErrors = new Map(), index = null) {
  if (!prNode || typeof prNode !== 'object') {
    return { count: null, isAvailable: false, isComplete: false, isError: true, overflow: false };
  }

  const num = prNumber !== undefined && prNumber !== null ? prNumber : prNode.number;
  if (hasFieldErrorForPRField(fieldErrors, num, index, 'reviewRequests')) {
    return { count: null, isAvailable: false, isComplete: false, isError: true, overflow: false };
  }

  const rr = prNode.reviewRequests;
  if (!rr || typeof rr !== 'object') {
    return { count: null, isAvailable: false, isComplete: false, isError: true, overflow: false };
  }

  const totalCount = typeof rr.totalCount === 'number' && Number.isInteger(rr.totalCount) && rr.totalCount >= 0 ? rr.totalCount : null;
  const nodes = Array.isArray(rr.nodes) ? rr.nodes : null;
  if (totalCount === null || nodes === null) {
    return { count: null, isAvailable: false, isComplete: false, isError: true, overflow: false };
  }

  // Inconsistent check: totalCount < nodes.length or (totalCount === 0 with nodes.length > 0)
  if (totalCount < nodes.length || (totalCount === 0 && nodes.length > 0)) {
    return { count: totalCount, isAvailable: false, isComplete: false, isError: true, overflow: false };
  }

  let hasMalformedNode = false;
  for (const n of nodes) {
    if (!n || typeof n !== 'object') {
      hasMalformedNode = true;
    }
  }

  // totalCount > 0 with empty nodes array is unavailable detail
  if (totalCount > 0 && nodes.length === 0) {
    return { count: totalCount, isAvailable: false, isComplete: false, isError: false, overflow: false };
  }

  const overflow = totalCount > nodes.length;
  const isComplete = !overflow && !hasMalformedNode && nodes.length === totalCount;

  return { count: totalCount, isAvailable: true, isComplete, isError: false, overflow };
}

/**
 * Extracts submitted review data.
 * Inconsistent totals or malformed nodes prevent claiming completeness.
 */
function extractReviews(prNode, prNumber, fieldErrors = new Map(), index = null) {
  if (!prNode || typeof prNode !== 'object') {
    return { count: null, latestReviewAt: null, latestApprovalAt: null, isAvailable: false, isComplete: false, isError: true, overflow: false };
  }

  const num = prNumber !== undefined && prNumber !== null ? prNumber : prNode.number;
  if (hasFieldErrorForPRField(fieldErrors, num, index, 'reviews')) {
    return { count: null, latestReviewAt: null, latestApprovalAt: null, isAvailable: false, isComplete: false, isError: true, overflow: false };
  }

  const rev = prNode.reviews;
  if (!rev || typeof rev !== 'object') {
    return { count: null, latestReviewAt: null, latestApprovalAt: null, isAvailable: false, isComplete: false, isError: true, overflow: false };
  }

  const totalCount = typeof rev.totalCount === 'number' && Number.isInteger(rev.totalCount) && rev.totalCount >= 0 ? rev.totalCount : null;
  const nodes = Array.isArray(rev.nodes) ? rev.nodes : null;
  if (totalCount === null || nodes === null) {
    return { count: null, latestReviewAt: null, latestApprovalAt: null, isAvailable: false, isComplete: false, isError: true, overflow: false };
  }

  // Inconsistent check: totalCount < nodes.length or (totalCount === 0 with nodes.length > 0)
  if (totalCount < nodes.length || (totalCount === 0 && nodes.length > 0)) {
    return { count: totalCount, latestReviewAt: null, latestApprovalAt: null, isAvailable: false, isComplete: false, isError: true, overflow: false };
  }

  let hasMalformedNode = false;
  let latestReviewAt = null;
  let latestApprovalAt = null;

  for (const r of nodes) {
    if (!r || typeof r !== 'object') {
      hasMalformedNode = true;
      continue;
    }

    const isPending = r.state === 'PENDING';
    const subAt = parseValidISODate(r.submittedAt);

    if (!subAt) {
      if (isPending) {
        // A PENDING review may legitimately have no submittedAt (null or undefined)
        // However, an explicitly provided non-empty malformed string is malformed
        if (r.submittedAt !== null && r.submittedAt !== undefined && typeof r.submittedAt === 'string' && r.submittedAt.trim() !== '') {
          hasMalformedNode = true;
        }
      } else {
        // A submitted/non-pending review with missing or malformed submittedAt must mark incomplete
        hasMalformedNode = true;
      }
      continue;
    }

    if (!isPending) {
      if (!latestReviewAt || new Date(subAt) > new Date(latestReviewAt)) {
        latestReviewAt = subAt;
      }
    }
    if (r.state === 'APPROVED') {
      if (!latestApprovalAt || new Date(subAt) > new Date(latestApprovalAt)) {
        latestApprovalAt = subAt;
      }
    }
  }

  // totalCount > 0 with empty nodes array is unavailable detail
  if (totalCount > 0 && nodes.length === 0) {
    return { count: totalCount, latestReviewAt: null, latestApprovalAt: null, isAvailable: false, isComplete: false, isError: false, overflow: false };
  }

  const overflow = totalCount > nodes.length;
  const isComplete = !overflow && !hasMalformedNode && nodes.length === totalCount;

  return { count: totalCount, latestReviewAt, latestApprovalAt, isAvailable: true, isComplete, isError: false, overflow };
}

/**
 * Strictly derives CI State according to Phase 2A.6 specification:
 * - PASSING, FAILING, PENDING
 * - NO_CHECKS_CONFIRMED: strictly requires statusCheckRollup === null (or contexts.totalCount === 0),
 *   checkSuites !== null with totalCount === 0, and status === null (or status.contexts empty).
 * - UNKNOWN: missing data, null checkSuites, or field errors.
 */
function extractCIState(commitNode, prNumber, fieldErrors = new Map(), index = null) {
  if (!commitNode || !commitNode.commit) {
    return { state: 'UNKNOWN', hasConfirmedNoChecks: false, isAvailable: false };
  }

  const num = prNumber !== undefined && prNumber !== null ? prNumber : 'unknown';
  if (hasFieldErrorForPRField(fieldErrors, num, index, 'ci')) {
    return { state: 'UNKNOWN', hasConfirmedNoChecks: false, isAvailable: false };
  }

  const { statusCheckRollup, status, checkSuites } = commitNode.commit;

  // Finding A: NO_CHECKS_CONFIRMED may only be emitted when all required check interfaces
  // were successfully retrieved and explicitly establish that no checks exist.
  // A missing/null connection, GraphQL field error, malformed response, or inaccessible connection
  // must never be interpreted as zero checks. Do not silently map missing statusCheckRollup to NONE or confirmed no-checks.
  const hasZeroSuites = Boolean(checkSuites) &&
    typeof checkSuites === 'object' &&
    typeof checkSuites.totalCount === 'number' &&
    Number.isInteger(checkSuites.totalCount) &&
    checkSuites.totalCount === 0;

  const hasNoStatus = (status === null) || (
    Boolean(status) &&
    typeof status === 'object' &&
    Array.isArray(status.contexts) &&
    status.contexts.length === 0
  );

  const hasEmptyRollupContexts = Boolean(statusCheckRollup) &&
    typeof statusCheckRollup === 'object' &&
    typeof statusCheckRollup.contexts?.totalCount === 'number' &&
    statusCheckRollup.contexts.totalCount === 0 &&
    !statusCheckRollup.state;

  if (hasZeroSuites && hasNoStatus && (hasEmptyRollupContexts || statusCheckRollup === null)) {
    return { state: 'NO_CHECKS_CONFIRMED', hasConfirmedNoChecks: true, isAvailable: true };
  }

  if (!statusCheckRollup || typeof statusCheckRollup !== 'object') {
    return { state: 'UNKNOWN', hasConfirmedNoChecks: false, isAvailable: false };
  }

  // Restore strict distinctions between SUCCESS, FAILURE, ERROR, PENDING, UNKNOWN
  switch (statusCheckRollup.state) {
    case 'SUCCESS':
      return { state: 'SUCCESS', hasConfirmedNoChecks: false, isAvailable: true };
    case 'FAILURE':
      return { state: 'FAILURE', hasConfirmedNoChecks: false, isAvailable: true };
    case 'ERROR':
      return { state: 'ERROR', hasConfirmedNoChecks: false, isAvailable: true };
    case 'PENDING':
    case 'EXPECTED':
      return { state: 'PENDING', hasConfirmedNoChecks: false, isAvailable: true };
    default:
      return { state: 'UNKNOWN', hasConfirmedNoChecks: false, isAvailable: false };
  }
}

/**
 * Safely extracts assignees and validates data completeness.
 * Missing, null, malformed, or errored assignee data must never be treated as empty.
 */
function extractAssignees(issue, fieldErrors = new Map(), index = null) {
  if (!issue || typeof issue !== 'object') {
    return { assignees: [], totalCount: null, isAvailable: false, overflow: false };
  }

  const number = issue.number;
  if (hasFieldErrorForIssueAssignees(fieldErrors, number, index)) {
    return { assignees: [], totalCount: null, isAvailable: false, overflow: false };
  }

  if (!Object.prototype.hasOwnProperty.call(issue, 'assignees')) {
    return { assignees: [], totalCount: null, isAvailable: false, overflow: false };
  }

  const raw = issue.assignees;
  if (raw === null || raw === undefined || typeof raw !== 'object' || Array.isArray(raw)) {
    return { assignees: [], totalCount: null, isAvailable: false, overflow: false };
  }

  const hasValidTotal = typeof raw.totalCount === 'number' && Number.isInteger(raw.totalCount) && raw.totalCount >= 0;
  const totalCount = hasValidTotal ? raw.totalCount : null;
  const nodes = Array.isArray(raw.nodes) ? raw.nodes : null;

  if (totalCount === null || nodes === null) {
    return { assignees: [], totalCount: null, isAvailable: false, overflow: false };
  }

  // Inconsistent check: totalCount === 0 but nodes exist
  if (totalCount === 0 && nodes.length > 0) {
    return { assignees: [], totalCount: null, isAvailable: false, overflow: false };
  }

  // Inconsistent check: totalCount < nodes.length
  if (totalCount < nodes.length) {
    return { assignees: [], totalCount: null, isAvailable: false, overflow: false };
  }

  const assigneesList = [];
  let hasMalformedNode = false;

  for (const a of nodes) {
    if (a && typeof a === 'object' && typeof a.login === 'string' && a.login.trim()) {
      assigneesList.push(a.login.trim());
    } else {
      hasMalformedNode = true;
    }
  }

  // Finding B: When totalCount > 0, null or malformed nodes or empty list renders assignees unavailable
  if (totalCount > 0 && (hasMalformedNode || assigneesList.length === 0)) {
    return { assignees: [], totalCount, isAvailable: false, overflow: false };
  }

  const overflow = totalCount > nodes.length;

  return {
    assignees: assigneesList,
    totalCount,
    isAvailable: true,
    overflow
  };
}

/**
 * Safely extracts comments data and validates connection availability.
 * A missing, null, errored, or malformed comments connection must never
 * be inferred as zero comments.
 */
function extractComments(issue, fieldErrors = new Map(), index = null) {
  if (!issue || typeof issue !== 'object') {
    return { count: null, latestCommentAt: null, latestCommentAuthor: null, isAvailable: false };
  }

  const number = issue.number;
  if (hasFieldErrorForIssueComments(fieldErrors, number, index)) {
    return { count: null, latestCommentAt: null, latestCommentAuthor: null, isAvailable: false };
  }

  if (!Object.prototype.hasOwnProperty.call(issue, 'comments')) {
    return { count: null, latestCommentAt: null, latestCommentAuthor: null, isAvailable: false };
  }

  const raw = issue.comments;
  if (raw === null || raw === undefined || typeof raw !== 'object' || Array.isArray(raw)) {
    return { count: null, latestCommentAt: null, latestCommentAuthor: null, isAvailable: false };
  }

  const hasValidTotal = typeof raw.totalCount === 'number' && Number.isInteger(raw.totalCount) && raw.totalCount >= 0;
  if (!hasValidTotal) {
    return { count: null, latestCommentAt: null, latestCommentAuthor: null, isAvailable: false };
  }

  const totalCount = raw.totalCount;
  const nodes = Array.isArray(raw.nodes) ? raw.nodes : [];

  // Inconsistent check: totalCount === 0 but nodes exist
  if (totalCount === 0 && nodes.length > 0) {
    return { count: null, latestCommentAt: null, latestCommentAuthor: null, isAvailable: false };
  }

  // If totalCount is 0, valid zero comments
  if (totalCount === 0) {
    return { count: 0, latestCommentAt: null, latestCommentAuthor: null, isAvailable: true };
  }

  // totalCount > 0: extract latest comment details from nodes[0]
  const lastCommentNode = nodes[0] || null;
  const latestCommentAt = parseValidISODate(lastCommentNode?.createdAt);
  const latestCommentAuthor = typeof lastCommentNode?.author?.login === 'string'
    ? lastCommentNode.author.login.trim()
    : null;

  return {
    count: totalCount,
    latestCommentAt,
    latestCommentAuthor,
    isAvailable: true
  };
}

/**
 * Safely extracts closing issue references and validates completeness and overflow.
 */
function extractClosingIssues(prNode, fieldErrors = new Map(), index = null) {
  if (!prNode || typeof prNode !== 'object') {
    return {
      numbers: [],
      totalCount: null,
      isAvailable: false,
      isComplete: false,
      overflow: false,
      omittedCount: null,
      isError: true
    };
  }

  const number = prNode.number;
  if (hasFieldErrorForPRField(fieldErrors, number, index, 'closingIssues')) {
    return {
      numbers: [],
      totalCount: null,
      isAvailable: false,
      isComplete: false,
      overflow: false,
      omittedCount: null,
      isError: true
    };
  }

  if (!Object.prototype.hasOwnProperty.call(prNode, 'closingIssuesReferences')) {
    return {
      numbers: [],
      totalCount: null,
      isAvailable: false,
      isComplete: false,
      overflow: false,
      omittedCount: null,
      isError: false
    };
  }

  const raw = prNode.closingIssuesReferences;
  if (raw === null || raw === undefined || typeof raw !== 'object' || Array.isArray(raw)) {
    return {
      numbers: [],
      totalCount: null,
      isAvailable: false,
      isComplete: false,
      overflow: false,
      omittedCount: null,
      isError: false
    };
  }

  const hasValidTotalCount = typeof raw.totalCount === 'number' && Number.isInteger(raw.totalCount) && raw.totalCount >= 0;
  const totalCount = hasValidTotalCount ? raw.totalCount : null;
  const nodes = Array.isArray(raw.nodes) ? raw.nodes : null;

  if (nodes === null) {
    return {
      numbers: [],
      totalCount: null,
      isAvailable: false,
      isComplete: false,
      overflow: false,
      omittedCount: null,
      isError: false
    };
  }

  const numbers = [];
  let hasMalformedNode = false;

  for (const n of nodes) {
    if (n && typeof n === 'object' && typeof n.number === 'number' && Number.isInteger(n.number) && n.number > 0) {
      numbers.push(n.number);
    } else {
      hasMalformedNode = true;
    }
  }

  // Finding C: pageInfo verification
  const hasPageInfo = Boolean(raw.pageInfo) && typeof raw.pageInfo === 'object';
  const hasNextPage = hasPageInfo && typeof raw.pageInfo.hasNextPage === 'boolean' ? raw.pageInfo.hasNextPage : null;

  // Inconsistent check: more returned nodes than totalCount
  const hasInconsistentTotals = totalCount !== null && (totalCount < nodes.length || (totalCount === 0 && nodes.length > 0));

  // Completeness requires:
  // - valid non-negative integer totalCount
  // - nodes is array
  // - pageInfo exists with hasNextPage explicitly boolean false
  // - returned valid node count is consistent with totalCount (numbers.length === totalCount && nodes.length === totalCount)
  // - no malformed nodes
  // - no inconsistent totals
  const isComplete =
    hasValidTotalCount &&
    !hasMalformedNode &&
    !hasInconsistentTotals &&
    hasPageInfo &&
    hasNextPage === false &&
    numbers.length === totalCount &&
    nodes.length === totalCount;

  const overflow = totalCount !== null
    ? (totalCount > nodes.length || hasNextPage === true)
    : false;

  const omittedCount = (totalCount !== null && !hasMalformedNode && !hasInconsistentTotals)
    ? (totalCount > numbers.length ? totalCount - numbers.length : 0)
    : null;

  const allNodesMalformed = nodes.length > 0 && numbers.length === 0;
  const isAvailable = !allNodesMalformed && ((totalCount === 0 && nodes.length === 0) || numbers.length > 0);

  return {
    numbers,
    totalCount,
    isAvailable,
    isComplete,
    overflow,
    omittedCount,
    isError: false
  };
}

/**
 * Normalizes open pull requests.
 */
function normalizePullRequest(pr, fieldErrors = new Map(), index = null) {
  const number = pr.number;
  const title = pr.title || '';
  const url = pr.url || `https://github.com/rubyforgood/casa/pull/${number}`;
  const author = pr.author?.login || 'ghost';
  const isDraft = Boolean(pr.isDraft);
  const headRefName = pr.headRefName || '';
  const createdAt = parseValidISODate(pr.createdAt);
  const updatedAt = parseValidISODate(pr.updatedAt);
  const body = pr.body || '';

  // Labels
  const rawLabels = pr.labels || {};
  const labelsTotal = rawLabels.totalCount || 0;
  const labelsNodes = Array.isArray(rawLabels.nodes) ? rawLabels.nodes : [];
  const labels = labelsNodes.map((l) => l.name).filter(Boolean);
  const labelsOverflow = labelsTotal > labels.length;

  // Review Decision & Requests
  const reviewDecisionData = extractReviewDecision(pr, number, fieldErrors, index);
  const reviewRequestsData = extractReviewRequests(pr, number, fieldErrors, index);
  const reviewsData = extractReviews(pr, number, fieldErrors, index);

  // Commit & CI
  const commitNode = pr.commits?.nodes?.[0] || null;
  const latestCommitAt = parseValidISODate(commitNode?.commit?.committedDate);
  const ciData = extractCIState(commitNode, number, fieldErrors, index);

  // Closing issue references with overflow calculation
  const closingData = extractClosingIssues(pr, fieldErrors, index);

  return {
    number,
    title,
    url,
    author,
    isDraft,
    headRefName,
    createdAt,
    updatedAt,
    body,
    labels,
    labelsOverflow,
    githubReviewDecision: reviewDecisionData.value,
    isReviewDecisionAvailable: reviewDecisionData.isAvailable,
    reviewRequestsCount: reviewRequestsData.count,
    isReviewRequestsAvailable: reviewRequestsData.isAvailable,
    isReviewRequestsComplete: reviewRequestsData.isComplete,
    reviewRequestsOverflow: reviewRequestsData.overflow,
    reviewsCount: reviewsData.count,
    isReviewsAvailable: reviewsData.isAvailable,
    isReviewsComplete: reviewsData.isComplete,
    reviewsOverflow: reviewsData.overflow,
    latestReviewAt: reviewsData.latestReviewAt,
    latestApprovalAt: reviewsData.latestApprovalAt,
    latestCommitAt,
    ciState: ciData.state,
    isCIAvailable: ciData.isAvailable,
    hasConfirmedNoChecks: ciData.hasConfirmedNoChecks,
    confirmedClosingIssueNumbers: closingData.numbers,
    isClosingIssuesAvailable: closingData.isAvailable,
    isClosingIssuesComplete: closingData.isComplete,
    closingIssuesTotal: closingData.totalCount,
    closingIssuesOverflow: closingData.overflow,
    omittedClosingIssuesCount: closingData.omittedCount
  };
}

/**
 * Normalizes open issues.
 */
function normalizeIssue(issue, fieldErrors = new Map(), index = null) {
  const number = issue.number;
  const title = issue.title || '';
  const url = issue.url || `https://github.com/rubyforgood/casa/issues/${number}`;
  const createdAt = parseValidISODate(issue.createdAt);
  const updatedAt = parseValidISODate(issue.updatedAt);

  // Labels
  const rawLabels = issue.labels || {};
  const labelsTotal = rawLabels.totalCount || 0;
  const labelsNodes = Array.isArray(rawLabels.nodes) ? rawLabels.nodes : [];
  const labels = labelsNodes.map((l) => l.name).filter(Boolean);
  const labelsOverflow = labelsTotal > labels.length;

  // Assignees with safe completeness checks
  const assigneesData = extractAssignees(issue, fieldErrors, index);

  // Comments with connection availability checks
  const commentsData = extractComments(issue, fieldErrors, index);

  // Convenience flags
  const isGoodFirstIssue = labels.some((l) => l.toLowerCase() === 'good first issue');
  const isHelpWanted = labels.some((l) => l.toLowerCase() === 'help wanted');

  let difficulty = null;
  for (const l of labels) {
    const lower = l.toLowerCase();
    if (lower.includes('difficulty: easy') || lower === 'easy') difficulty = 'Easy';
    else if (lower.includes('difficulty: intermediate') || lower === 'intermediate') difficulty = 'Intermediate';
    else if (lower.includes('difficulty: advanced') || lower === 'advanced') difficulty = 'Advanced';
  }

  return {
    number,
    title,
    url,
    createdAt,
    updatedAt,
    labels,
    labelsOverflow,
    assignees: assigneesData.assignees,
    isAssigneesAvailable: assigneesData.isAvailable,
    assigneesTotal: assigneesData.totalCount,
    assigneesOverflow: assigneesData.overflow,
    isCommentsAvailable: commentsData.isAvailable,
    commentCount: commentsData.count,
    lastCommentAt: commentsData.latestCommentAt,
    lastCommentAuthor: commentsData.latestCommentAuthor,
    isGoodFirstIssue,
    isHelpWanted,
    difficulty
  };
}

/**
 * Normalizes merged pull requests.
 */
function normalizeMergedPR(pr, fieldErrors = new Map(), index = null) {
  const number = pr.number;
  const title = pr.title || '';
  const url = pr.url || `https://github.com/rubyforgood/casa/pull/${number}`;
  const mergedAt = parseValidISODate(pr.mergedAt);
  const headRefName = pr.headRefName || '';
  const body = pr.body || '';

  const closingData = extractClosingIssues(pr, fieldErrors, index);

  return {
    number,
    title,
    url,
    mergedAt,
    headRefName,
    body,
    confirmedClosingIssueNumbers: closingData.numbers,
    isClosingIssuesAvailable: closingData.isAvailable,
    isClosingIssuesComplete: closingData.isComplete,
    closingIssuesTotal: closingData.totalCount,
    closingIssuesOverflow: closingData.overflow,
    omittedClosingIssuesCount: closingData.omittedCount
  };
}

/**
 * Processes batch alias validation results with strict error discrimination.
 * Inspects alias-level and nested field-level errors.
 */
function processBatchResult(response, candidateNumbers) {
  const results = new Map();

  const repo = response?.data?.repository || {};
  const errors = Array.isArray(response?.errors) ? response.errors : [];

  for (const num of candidateNumbers) {
    const alias = `i_${num}`;
    const item = repo[alias];

    // Finding D: Exact alias matching without prefix collisions
    // Matches errors specifically targeting this exact alias (e.g. ['repository', 'i_14'])
    const aliasErrors = errors.filter((err) => {
      if (!err || !Array.isArray(err.path)) return false;
      return err.path.length >= 2 && err.path[0] === 'repository' && err.path[1] === alias;
    });

    const notFoundError = aliasErrors.find((e) => e.type === 'NOT_FOUND');
    const stateError = aliasErrors.find((e) => e.path && e.path[2] === 'state');

    if (item && typeof item === 'object') {
      if (item.__typename === 'PullRequest') {
        // Discard: It is a PR, not an Issue
        results.set(num, { isIssue: false, isPR: true, state: item.state || 'OPEN' });
      } else if (item.__typename === 'Issue') {
        // If state field had an error, state is UNVERIFIED
        if (stateError || !item.state) {
          results.set(num, { isIssue: true, isPR: false, state: 'UNVERIFIED', title: item.title || '' });
        } else {
          results.set(num, { isIssue: true, isPR: false, state: item.state, title: item.title || '' });
        }
      } else {
        results.set(num, { isIssue: false, isPR: false, state: 'UNVERIFIED' });
      }
    } else if (notFoundError) {
      results.set(num, { isIssue: false, isPR: false, state: 'NOT_FOUND' });
    } else {
      // Unrelated error, alias error, or missing data -> UNVERIFIED
      results.set(num, { isIssue: false, isPR: false, state: 'UNVERIFIED' });
    }
  }

  return results;
}

/**
 * Top-level normalization orchestrator.
 */
function normalizeData({ rawIssues = [], rawPRs = [], rawMergedPRs = [], fieldErrors = new Map() }) {
  const normalizedIssues = rawIssues.map((i, idx) => normalizeIssue(i, fieldErrors, idx));
  const normalizedPRs = rawPRs.map((p, idx) => normalizePullRequest(p, fieldErrors, idx));
  const normalizedMergedPRs = rawMergedPRs.map((m, idx) => normalizeMergedPR(m, fieldErrors, idx));

  return {
    normalizedIssues,
    normalizedPRs,
    normalizedMergedPRs
  };
}

module.exports = {
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
  normalizeMergedPR,
  processBatchResult,
  normalizeData
};
