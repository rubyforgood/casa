'use strict';

const { parseValidISODate } = require('./normalize');

/**
 * Markdown Formatting layer for Contributor Work Queue Digest.
 * Pure string generation with strict plain-text sanitization.
 * Uses only Node.js built-ins.
 */

function sanitizeTableCell(input, maxGraphemes = 80) {
  if (input === null || input === undefined) return '';

  // 1. Unicode normalization
  let str = String(input).normalize('NFC');

  // 2. Strip ASCII & Unicode control characters, and bidi override characters
  str = str.replace(/[\x00-\x1F\x7F-\x9F\u061C\u200E\u200F\u202A-\u202E\u2066-\u2069]/g, '');

  // 3. Normalize whitespace
  str = str.replace(/\s+/g, ' ').trim();

  // 4. Safe grapheme truncation (BEFORE entity escaping)
  // Uses built-in Intl.Segmenter for true grapheme cluster boundaries (e.g. ZWJ emoji, skin tones, combining marks, flags).
  // Fallback uses Unicode property regex matching full grapheme clusters (including regional indicator pairs,
  // emoji modifiers, and combining mark sequences) when Intl.Segmenter is absent.
  const GRAPHEME_FALLBACK_REGEX = /\p{RI}\p{RI}|\p{Extended_Pictographic}(?:\u200D\p{Extended_Pictographic}|\p{Emoji_Modifier}|\p{M})*|[^\p{M}\p{C}](?:\p{M}|\u200D)*|[\s\S]/gu;

  if (typeof Intl !== 'undefined' && typeof Intl.Segmenter === 'function') {
    const segmenter = new Intl.Segmenter(undefined, { granularity: 'grapheme' });
    const segments = Array.from(segmenter.segment(str), (s) => s.segment);
    if (segments.length > maxGraphemes) {
      str = segments.slice(0, maxGraphemes - 1).join('').trim() + '…';
    }
  } else {
    const segments = str.match(GRAPHEME_FALLBACK_REGEX) || [];
    if (segments.length > maxGraphemes) {
      str = segments.slice(0, maxGraphemes - 1).join('').trim() + '…';
    }
  }

  // 5. Escape ampersand FIRST
  str = str.replace(/&/g, '&amp;');

  // 6. Neutralize all Markdown syntax and HTML formatting
  str = str
    .replace(/\\/g, '&#92;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#39;')
    .replace(/\|/g, '&#124;')
    .replace(/\[/g, '&#91;')
    .replace(/\]/g, '&#93;')
    .replace(/\(/g, '&#40;')
    .replace(/\)/g, '&#41;')
    .replace(/\*/g, '&#42;')
    .replace(/_/g, '&#95;')
    .replace(/~/g, '&#126;')
    .replace(/`/g, '&#96;');

  return str;
}

function isValidPositiveInt(val) {
  if (typeof val === 'number') {
    return Number.isInteger(val) && val > 0 && val <= Number.MAX_SAFE_INTEGER;
  }
  if (typeof val === 'string' && /^[1-9]\d*$/.test(val)) {
    const parsed = Number(val);
    return Number.isSafeInteger(parsed) && parsed > 0;
  }
  return false;
}

function safePRLink(prNumber) {
  if (!isValidPositiveInt(prNumber)) return '[Invalid PR #]';
  const num = parseInt(prNumber, 10);
  return `[#${num}](https://github.com/rubyforgood/casa/pull/${num})`;
}

function safeIssueLink(issueNumber) {
  if (!isValidPositiveInt(issueNumber)) return '[Invalid Issue #]';
  const num = parseInt(issueNumber, 10);
  return `[#${num}](https://github.com/rubyforgood/casa/issues/${num})`;
}

function safeAuthorLink(author) {
  const safeName = sanitizeTableCell(author, 40);
  if (!author || author === 'ghost') return 'ghost';
  return `[@${safeName}](https://github.com/${encodeURIComponent(author)})`;
}

function formatTimestampDate(val) {
  if (!val || typeof val !== 'string') return '—';
  const iso = parseValidISODate(val);
  if (!iso) return '—';
  return iso.slice(0, 10);
}

function formatCommentActivity(issue) {
  if (issue && issue.isCommentsAvailable === false) {
    return 'Comment activity unavailable';
  }

  if (typeof issue?.commentCount === 'number') {
    if (issue.commentCount <= 0) {
      return 'No comments';
    }
    const dateStr = formatTimestampDate(issue.lastCommentAt);
    if (dateStr === '—') {
      return 'Comment (date unknown)';
    }
    return `Comment ${dateStr}`;
  }

  // Fallback for manually constructed objects without commentCount or isCommentsAvailable
  if (issue?.lastCommentAt) {
    const dateStr = formatTimestampDate(issue.lastCommentAt);
    if (dateStr === '—') {
      return 'Comment (date unknown)';
    }
    return `Comment ${dateStr}`;
  }

  return 'Comment activity unavailable';
}

function formatLinkedIssues(linkedIssues = [], options = {}) {
  if (!linkedIssues || linkedIssues.length === 0) {
    return 'None';
  }
  return linkedIssues.map((i) => {
    const num = i.number || i.issueNumber;
    const link = safeIssueLink(num);
    const stateTag = (i.isClosed || i.state === 'CLOSED') ? ' (Closed)' : '';
    const unverifiedTag = (i.state === 'UNVERIFIED' || i.status === 'UNVERIFIED') ? ' [?]' : '';
    if (options && options.showConfidence) {
      const isConfirmed = i.confidence === 'CONFIRMED' || i.status === 'CONFIRMED';
      const isUnverified = i.state === 'UNVERIFIED' || i.status === 'UNVERIFIED';
      const confTag = isConfirmed ? ' (Confirmed)' : (isUnverified ? '' : ' (Inferred)');
      return `${link}${stateTag}${unverifiedTag}${confTag}`;
    }
    return `${link}${stateTag}${unverifiedTag}`;
  }).join(', ');
}

/**
 * Renders the Data Quality & Ingestion Summary table with dynamic metrics.
 */
function renderDataQualitySection(metrics) {
  const m = metrics || {};
  const issuesStatus = m.issuesStatus || (m.issuesRetrieved >= m.issuesExpected && m.issuesExpected > 0 ? 'Complete' : '⚠️ Partial');
  const prsStatus = m.prsStatus || (m.prsRetrieved >= m.prsExpected && m.prsExpected > 0 ? 'Complete' : '⚠️ Partial');
  const mergedStatus = m.mergedStatus || (
    m.isMergedFailed
      ? '❌ Failed'
      : m.isMergedCapped
        ? '⚠️ Capped'
        : m.isMergedPartial || (typeof m.mergedExpected === 'number' && m.mergedExpected > 0 && m.mergedRetrieved < m.mergedExpected)
          ? '⚠️ Partial'
          : 'Complete'
  );
  const mergedNotes = m.isMergedFailed
    ? 'Search query failed; section omitted'
    : m.isMergedCapped
      ? 'Reached 100-item ceiling (subset)'
      : mergedStatus.includes('Partial')
        ? 'Search query partial; later pages failed'
        : 'Complete scan (14d window)';
  const overflowStatus = (m.overflowCount || 0) === 0 ? 'Complete' : `⚠️ ${m.overflowCount} collection(s) capped`;
  const fieldErrorsStatus = (m.fieldErrorsCount || 0) === 0 ? 'Clean' : `⚠️ ${m.fieldErrorsCount} error(s) (marked UNKNOWN)`;

  return `
## 🔍 Data Quality & Ingestion Summary

| Metric | Runtime Count | Status | Notes |
| :--- | :--- | :--- | :--- |
| **Open Issues** | ${m.issuesRetrieved || 0} / ${m.issuesExpected || 0} | ${issuesStatus} | Root query |
| **Open Pull Requests** | ${m.prsRetrieved || 0} / ${m.prsExpected || 0} | ${prsStatus} | Root query |
| **Merged PRs (14d)** | ${m.mergedRetrieved || 0} / ${m.mergedExpected || 0} | ${mergedStatus} | ${mergedNotes} |
| **Nested Overflows** | ${m.overflowCount || 0} collection(s) | ${overflowStatus} | Capped items tagged \`[+N more]\` |
| **Issue References** | ${m.confirmedCount || 0} Confirmed, ${m.inferredCount || 0} Inferred, ${m.unverifiedCount || 0} Unverified | Validated | Verified against CASA issues |
| **GraphQL Field Errors** | ${m.fieldErrorsCount || 0} field error(s) | ${fieldErrorsStatus} | Errored fields marked UNKNOWN |
`;
}

/**
 * Formats Section 1: PRs with Review & CI Clear or Maintainer Review.
 */
function renderClearAndReviewQueue(prs) {
  const targetPRs = prs.filter(
    (p) => p.attentionFlags.includes('REVIEW_AND_CI_CLEAR') || p.attentionFlags.includes('MAINTAINER_REVIEW')
  );

  let out = `## 1. 🟢 PRs Ready for Action (Review & CI Clear / Required Review Gate)\n\n`;

  if (targetPRs.length === 0) {
    out += `*No pull requests currently have review and CI clear or are awaiting required review gate clearance.*\n\n`;
    return out;
  }

  out += `| PR | Title | Author | CI State | Review Decision | Attention Flags |\n`;
  out += `| :--- | :--- | :--- | :--- | :--- | :--- |\n`;

  for (const pr of targetPRs) {
    const link = safePRLink(pr.number);
    const title = sanitizeTableCell(pr.title, 50);
    const author = safeAuthorLink(pr.author);
    const flags = pr.attentionFlags.map((f) => `\`${f}\``).join(', ');
    out += `| ${link} | ${title} | ${author} | \`${pr.ciState}\` | \`${pr.githubReviewDecision || 'null'}\` | ${flags} |\n`;
  }

  out += `\n`;
  return out;
}

/**
 * Formats Section 2: PRs Requiring Attention.
 */
function renderAttentionQueue(prs) {
  const targetPRs = prs.filter(
    (p) =>
      p.attentionFlags.includes('CONTRIBUTOR_ACTION') ||
      p.attentionFlags.includes('CI_INTERVENTION') ||
      p.attentionFlags.includes('DEPENDENCY_ATTENTION') ||
      p.workState === 'DRAFT'
  );

  let out = `## 2. 🟡 PRs Requiring Attention (Contributor Action / CI Intervention / Drafts)\n\n`;

  if (targetPRs.length === 0) {
    out += `*No pull requests currently require attention.*\n\n`;
    return out;
  }

  out += `| PR | Title | Author | Work State | CI State | Review Decision | Attention Reasons |\n`;
  out += `| :--- | :--- | :--- | :--- | :--- | :--- | :--- |\n`;

  for (const pr of targetPRs) {
    const link = safePRLink(pr.number);
    const title = sanitizeTableCell(pr.title, 45);
    const author = safeAuthorLink(pr.author);
    const reasons = pr.attentionReasons.map((r) => sanitizeTableCell(r, 40)).join('; ') || 'None';
    out += `| ${link} | ${title} | ${author} | \`${pr.workState}\` | \`${pr.ciState}\` | \`${pr.githubReviewDecision || 'null'}\` | ${reasons} |\n`;
  }

  out += `\n`;
  return out;
}

/**
 * Formats Section 3: Contributor Opportunities.
 */
function renderContributorOpportunities(opportunities) {
  const goodFirst = opportunities?.goodFirst || [];
  const helpWanted = opportunities?.helpWanted || [];

  let out = `## 3. 🎯 Contributor Opportunities (Unassigned Issues)\n\n`;

  out += `### Good First Issues (${goodFirst.length})\n\n`;
  if (goodFirst.length === 0) {
    out += `*No unassigned Good First Issues currently available.*\n\n`;
  } else {
    out += `| Issue | Title | Difficulty | Created | Last GitHub Activity |\n`;
    out += `| :--- | :--- | :--- | :--- | :--- |\n`;
    for (const issue of goodFirst) {
      const link = safeIssueLink(issue.number);
      const title = sanitizeTableCell(issue.title, 50);
      const diff = issue.difficulty ? `\`${issue.difficulty}\`` : '—';
      const created = formatTimestampDate(issue.createdAt);
      const activity = formatCommentActivity(issue);
      out += `| ${link} | ${title} | ${diff} | ${created} | ${activity} |\n`;
    }
    out += `\n`;
  }

  out += `### Other Help Wanted Issues (${helpWanted.length})\n\n`;
  if (helpWanted.length === 0) {
    out += `*No other unassigned Help Wanted issues currently available.*\n\n`;
  } else {
    out += `| Issue | Title | Difficulty | Created | Last GitHub Activity |\n`;
    out += `| :--- | :--- | :--- | :--- | :--- |\n`;
    for (const issue of helpWanted.slice(0, 15)) {
      const link = safeIssueLink(issue.number);
      const title = sanitizeTableCell(issue.title, 50);
      const diff = issue.difficulty ? `\`${issue.difficulty}\`` : '—';
      const created = formatTimestampDate(issue.createdAt);
      const activity = formatCommentActivity(issue);
      out += `| ${link} | ${title} | ${diff} | ${created} | ${activity} |\n`;
    }
    if (helpWanted.length > 15) {
      out += `\n*... and ${helpWanted.length - 15} more Help Wanted issues.*\n`;
    }
    out += `\n`;
  }

  return out;
}

/**
 * Formats Section 4: Issue & PR Cross-Reference Matrix.
 */
function renderCrossReferenceMatrix(relationships, prs, classifiedMergedPRs = []) {
  const competing = relationships?.competingPRs || [];
  const potentiallyResolved = relationships?.potentiallyResolvedIssues || [];

  let out = `## 4. 🔗 Issue & PR Cross-Reference Matrix\n\n`;

  // Competing PRs
  out += `### Competing Pull Requests (${competing.length})\n\n`;
  if (competing.length === 0) {
    out += `*No multiple open PRs addressing the same issue detected.*\n\n`;
  } else {
    out += `| Issue | PRs Addressing Issue |\n`;
    out += `| :--- | :--- |\n`;
    for (const c of competing) {
      const issueLink = safeIssueLink(c.issueNumber);
      const prLinks = c.prs.map((p) => {
        const link = safePRLink(p.prNumber);
        const cap = p.closingIssuesOverflow
          ? ` [+${p.omittedClosingCount || '?'} more]`
          : (p.isClosingIssuesComplete === false ? ' [incomplete]' : '');
        return `${link}${cap} (\`${p.confidence}\`)`;
      }).join(', ');
      out += `| ${issueLink} | ${prLinks} |\n`;
    }
    out += `\n`;
  }

  // Potentially Resolved Issues
  out += `### Candidates for Verification: Open Issues with Merged PRs (${potentiallyResolved.length})\n\n`;
  if (potentiallyResolved.length === 0) {
    out += `*No open issues referenced by recently merged PRs detected.*\n\n`;
  } else {
    out += `| Open Issue | Merged PR | Merged At | Confidence |\n`;
    out += `| :--- | :--- | :--- | :--- |\n`;
    for (const res of potentiallyResolved) {
      const issueLink = safeIssueLink(res.issueNumber);
      const prLink = safePRLink(res.mergedPRNumber);
      const cap = res.closingIssuesOverflow
        ? ` [+${res.omittedClosingCount || '?'} more]`
        : (res.isClosingIssuesComplete === false ? ' [incomplete]' : '');
      const mergedAt = formatTimestampDate(res.mergedAt);
      out += `| ${issueLink} | ${prLink}${cap} | ${mergedAt} | \`${res.confidence}\` |\n`;
    }
    out += `\n`;
  }

  // Recently Merged Pull Requests
  out += `### Recently Merged Pull Requests (${classifiedMergedPRs.length})\n\n`;
  if (classifiedMergedPRs.length === 0) {
    out += `*No pull requests merged in the past 14 days.*\n\n`;
  } else {
    out += `| Merged PR | Title | Merged At | Linked Issues |\n`;
    out += `| :--- | :--- | :--- | :--- |\n`;
    for (const mpr of classifiedMergedPRs) {
      const prLink = safePRLink(mpr.number);
      const cap = mpr.closingIssuesOverflow
        ? ` [+${mpr.omittedClosingIssuesCount || '?'} more]`
        : (mpr.isClosingIssuesComplete === false ? ' [incomplete]' : '');
      const title = sanitizeTableCell(mpr.title, 50);
      const mergedAt = formatTimestampDate(mpr.mergedAt);
      const linked = formatLinkedIssues(mpr.linkedIssues, { showConfidence: true });
      out += `| ${prLink}${cap} | ${title} | ${mergedAt} | ${linked} |\n`;
    }
    out += `\n`;
  }

  return out;
}

/**
 * Top-level Markdown formatter orchestrator.
 */
function formatDigest({
  classifiedPRs = [],
  classifiedMergedPRs = [],
  opportunities = {},
  relationships = {},
  metrics = {}
}) {
  const timestamp = new Date().toISOString().replace('T', ' ').replace(/\..+/, ' UTC');

  let doc = `# 📋 CASA Contributor Work Queue Digest\n\n`;
  doc += `*Generated automatically on ${timestamp}*\n\n`;
  doc += `---\n\n`;

  doc += renderDataQualitySection(metrics);
  doc += `---\n\n`;

  doc += renderClearAndReviewQueue(classifiedPRs);
  doc += `---\n\n`;

  doc += renderAttentionQueue(classifiedPRs);
  doc += `---\n\n`;

  doc += renderContributorOpportunities(opportunities);
  doc += `---\n\n`;

  doc += renderCrossReferenceMatrix(relationships, classifiedPRs, classifiedMergedPRs);
  doc += `---\n\n`;

  doc += `*Digest generated by Contributor Work Queue Digest automation. Read-only operation.*`;

  return doc;
}

module.exports = {
  sanitizeTableCell,
  isValidPositiveInt,
  safePRLink,
  safeIssueLink,
  safeAuthorLink,
  formatTimestampDate,
  formatCommentActivity,
  formatLinkedIssues,
  formatDigest
};
