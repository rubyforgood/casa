'use strict';

const test = require('node:test');
const assert = require('node:assert/strict');

const {
  sanitizeTableCell,
  isValidPositiveInt,
  safePRLink,
  safeIssueLink,
  formatTimestampDate,
  formatCommentActivity,
  formatLinkedIssues,
  formatDigest
} = require('../format');
const { normalizeIssue } = require('../normalize');

test('sanitizeTableCell: neutralizes Markdown links and formatting', () => {
  const maliciousLink = '[Click Me](https://evil.example.com)';
  const sanitized = sanitizeTableCell(maliciousLink);
  // Brackets and parentheses must be escaped
  assert.equal(sanitized.includes('['), false);
  assert.equal(sanitized.includes(']'), false);
  assert.equal(sanitized.includes('('), false);
  assert.equal(sanitized.includes(')'), false);
  assert.equal(sanitized, '&#91;Click Me&#93;&#40;https://evil.example.com&#41;');
});

test('sanitizeTableCell: neutralizes HTML tags and script execution', () => {
  const html = '<script>alert("pwned")</script>';
  const sanitized = sanitizeTableCell(html);
  assert.equal(sanitized.includes('<'), false);
  assert.equal(sanitized.includes('>'), false);
  assert.equal(sanitized, '&lt;script&gt;alert&#40;&quot;pwned&quot;&#41;&lt;/script&gt;');
});

test('sanitizeTableCell: escapes ampersand first and neutralizes table delimiters', () => {
  const tableBreak = 'Normal text | Injection | More text & more';
  const sanitized = sanitizeTableCell(tableBreak);
  assert.equal(sanitized.includes('|'), false);
  assert.equal(sanitized.includes('&#124;'), true);
  assert.equal(sanitized.includes('&amp;'), true);
});

test('sanitizeTableCell: strips control characters and bidi override characters', () => {
  // \u202E is Right-to-Left Override (Trojan Source attack)
  const bidiSpoof = 'Safe\u202Eevil\x00text';
  const sanitized = sanitizeTableCell(bidiSpoof);
  assert.equal(sanitized.includes('\u202E'), false);
  assert.equal(sanitized.includes('\x00'), false);
  assert.equal(sanitized, 'Safeeviltext');
});

test('sanitizeTableCell: truncates safely preserving multi-byte Unicode graphemes', () => {
  const complexStr = '👨‍👩‍👧‍👦 Family Hello World Long Message That Needs Truncation';
  const sanitized = sanitizeTableCell(complexStr, 15);
  // Must preserve the 11-byte family emoji as a single grapheme without split surrogate halves
  assert.equal(sanitized.includes('👨‍👩‍👧‍👦'), true);
  assert.equal(sanitized.endsWith('…'), true);
});

test('isValidPositiveInt: validates strictly positive integers within MAX_SAFE_INTEGER', () => {
  // Valid
  assert.equal(isValidPositiveInt(1), true);
  assert.equal(isValidPositiveInt(7305), true);
  assert.equal(isValidPositiveInt('7305'), true);
  assert.equal(isValidPositiveInt(Number.MAX_SAFE_INTEGER), true);
  assert.equal(isValidPositiveInt(String(Number.MAX_SAFE_INTEGER)), true);

  // Invalid: zero and negatives
  assert.equal(isValidPositiveInt(0), false);
  assert.equal(isValidPositiveInt(-5), false);
  assert.equal(isValidPositiveInt('0'), false);
  assert.equal(isValidPositiveInt('-12'), false);

  // Invalid: decimals and non-numeric
  assert.equal(isValidPositiveInt(3.14), false);
  assert.equal(isValidPositiveInt('3.14'), false);
  assert.equal(isValidPositiveInt('abc'), false);
  assert.equal(isValidPositiveInt(null), false);
  assert.equal(isValidPositiveInt(undefined), false);
  assert.equal(isValidPositiveInt({}), false);

  // Invalid: exceeding MAX_SAFE_INTEGER
  assert.equal(isValidPositiveInt(Number.MAX_SAFE_INTEGER + 100), false);
  assert.equal(isValidPositiveInt('9999999999999999999999999999'), false);
});

test('safePRLink and safeIssueLink: generate safe parameterized links and reject invalid IDs', () => {
  assert.equal(safePRLink(7334), '[#7334](https://github.com/rubyforgood/casa/pull/7334)');
  assert.equal(safeIssueLink(7305), '[#7305](https://github.com/rubyforgood/casa/issues/7305)');

  assert.equal(safePRLink('invalid'), '[Invalid PR #]');
  assert.equal(safeIssueLink(-1), '[Invalid Issue #]');
  assert.equal(safeIssueLink('999999999999999999999999999'), '[Invalid Issue #]');
});

test('formatDigest: renders cleanly with empty queues', () => {
  const markdown = formatDigest({
    classifiedPRs: [],
    opportunities: { goodFirst: [], helpWanted: [] },
    relationships: { competingPRs: [], potentiallyResolvedIssues: [] },
    metrics: {
      issuesRetrieved: 0,
      issuesExpected: 0,
      prsRetrieved: 0,
      prsExpected: 0,
      mergedRetrieved: 0,
      mergedExpected: 0,
      overflowCount: 0,
      confirmedCount: 0,
      inferredCount: 0,
      unverifiedCount: 0,
      fieldErrorsCount: 0
    }
  });

  assert.equal(typeof markdown, 'string');
  assert.equal(markdown.includes('Data Quality & Ingestion Summary'), true);
  assert.equal(markdown.includes('No pull requests currently have review and CI clear'), true);
  assert.equal(markdown.includes('No unassigned Good First Issues currently available'), true);
  assert.equal(markdown.includes('No multiple open PRs addressing the same issue detected'), true);
});

test('formatDigest: renders honest capped indicators for relationships with closingIssuesOverflow', () => {
  const markdown = formatDigest({
    classifiedPRs: [],
    opportunities: { goodFirst: [], helpWanted: [] },
    relationships: {
      competingPRs: [
        {
          issueNumber: 5001,
          prs: [
            { prNumber: 6001, confidence: 'CONFIRMED', closingIssuesOverflow: true, omittedClosingCount: 5 },
            { prNumber: 6002, confidence: 'HIGH_INFERRED', closingIssuesOverflow: false, omittedClosingCount: 0 }
          ]
        }
      ],
      potentiallyResolvedIssues: [
        {
          issueNumber: 5002,
          mergedPRNumber: 6500,
          mergedAt: '2026-11-20T10:00:00Z',
          confidence: 'CONFIRMED',
          closingIssuesOverflow: true,
          omittedClosingCount: 2
        }
      ]
    },
    metrics: {
      issuesRetrieved: 10,
      issuesExpected: 10,
      issuesStatus: 'Complete',
      prsRetrieved: 5,
      prsExpected: 5,
      prsStatus: 'Complete',
      mergedRetrieved: 2,
      mergedExpected: 2,
      overflowCount: 3,
      confirmedCount: 2,
      inferredCount: 1,
      unverifiedCount: 0,
      fieldErrorsCount: 0
    }
  });

  // Verify competing PR capped indicator [+5 more] is rendered
  assert.equal(markdown.includes('[#6001](https://github.com/rubyforgood/casa/pull/6001) [+5 more]'), true);
  // Verify regular non-capped PR does not have overflow badge
  assert.equal(markdown.includes('[#6002](https://github.com/rubyforgood/casa/pull/6002) (`HIGH_INFERRED`)'), true);
  // Verify potentially resolved capped indicator [+2 more] is rendered
  assert.equal(markdown.includes('[#6500](https://github.com/rubyforgood/casa/pull/6500) [+2 more]'), true);
  // Verify diagnostics summary table displays 3 collections capped
  assert.equal(markdown.includes('⚠️ 3 collection(s) capped'), true);
});

test('Phase 2F Finding C: sanitizeTableCell preserves grapheme clusters across complex Unicode inputs and boundary conditions', () => {
  // 1. Family emoji sequence (👨‍👩‍👧‍👦 is 1 grapheme cluster; must never be split)
  const familyStr = 'Family: 👨‍👩‍👧‍👦 is happy';
  const truncatedFamily = sanitizeTableCell(familyStr, 10);
  assert.equal(truncatedFamily.includes('👨‍👩‍👧‍👦'), true);
  assert.equal(truncatedFamily.endsWith('…'), true);
  assert.equal(truncatedFamily, 'Family: 👨‍👩‍👧‍👦…');

  // 2. Skin-tone-modified emoji (👍🏽 is 1 grapheme cluster; must not split modifier)
  const skinToneStr = 'Status: 👍🏽 approved';
  const truncatedSkinTone = sanitizeTableCell(skinToneStr, 10);
  assert.equal(truncatedSkinTone.includes('👍🏽'), true);
  assert.equal(truncatedSkinTone, 'Status: 👍🏽…');

  // 3. Combining-character sequence (q\u0307 is 1 grapheme cluster: base 'q' with dot above)
  const combiningStr = 'Letter q\u0307 is special';
  const truncatedCombining = sanitizeTableCell(combiningStr, 10);
  assert.equal(truncatedCombining.includes('q\u0307'), true);
  assert.equal(truncatedCombining, 'Letter q\u0307…');

  // 4. Normal ASCII string
  const asciiStr = 'Normal ASCII sentence for testing';
  const truncatedAscii = sanitizeTableCell(asciiStr, 12);
  assert.equal(truncatedAscii, 'Normal ASCI…');

  // 5. String shorter than maximum (no truncation, no ellipsis)
  const shortStr = 'Short string';
  assert.equal(sanitizeTableCell(shortStr, 20), 'Short string');

  // 6. String exactly at maximum (no truncation, no ellipsis)
  const exactStr = '1234567890';
  assert.equal(sanitizeTableCell(exactStr, 10), '1234567890');

  // 7. String exceeding maximum (truncated with ellipsis, length <= max)
  const exceedingStr = '12345678901';
  assert.equal(sanitizeTableCell(exceedingStr, 10), '123456789…');
});

test('Phase 2G Finding E: formatLinkedIssues formatting', () => {
  // Empty inputs
  assert.equal(formatLinkedIssues([]), 'None');
  assert.equal(formatLinkedIssues(null), 'None');
  assert.equal(formatLinkedIssues(undefined), 'None');

  // Single confirmed open issue
  const singleOpen = [{ number: 7305, state: 'OPEN', isClosed: false, status: 'CONFIRMED' }];
  assert.equal(formatLinkedIssues(singleOpen), '[#7305](https://github.com/rubyforgood/casa/issues/7305)');

  // Closed issue
  const singleClosed = [{ number: 7305, state: 'CLOSED', isClosed: true, status: 'CONFIRMED' }];
  assert.equal(formatLinkedIssues(singleClosed), '[#7305](https://github.com/rubyforgood/casa/issues/7305) (Closed)');

  // Unverified issue
  const singleUnverified = [{ number: 7305, state: 'UNVERIFIED', isClosed: false, status: 'UNVERIFIED' }];
  assert.equal(formatLinkedIssues(singleUnverified), '[#7305](https://github.com/rubyforgood/casa/issues/7305) [?]');

  // Multiple mixed issues
  const mixed = [
    { number: 7301, state: 'OPEN', isClosed: false, status: 'CONFIRMED' },
    { number: 7302, state: 'CLOSED', isClosed: true, status: 'INFERRED' },
    { number: 7303, state: 'UNVERIFIED', isClosed: false, status: 'UNVERIFIED' }
  ];
  assert.equal(
    formatLinkedIssues(mixed),
    '[#7301](https://github.com/rubyforgood/casa/issues/7301), [#7302](https://github.com/rubyforgood/casa/issues/7302) (Closed), [#7303](https://github.com/rubyforgood/casa/issues/7303) [?]'
  );
});

test('Phase 2G Finding E: Comprehensive Unicode and Plain-Text Sanitization (all 14 categories)', () => {
  // 1. Plain ASCII text
  assert.equal(sanitizeTableCell('Normal test string', 50), 'Normal test string');

  // 2. Short text below boundary
  assert.equal(sanitizeTableCell('Hello', 10), 'Hello');

  // 3. Exact boundary
  assert.equal(sanitizeTableCell('ABCDE', 5), 'ABCDE');

  // 4. Exceeding boundary
  assert.equal(sanitizeTableCell('ABCDEF', 5), 'ABCD…');

  // 5. Complex emoji with ZWJ
  const zwj = '👩‍💻 Tech woman';
  const zwjTrunc = sanitizeTableCell(zwj, 6);
  assert.equal(zwjTrunc.includes('👩‍💻'), true);
  assert.equal(zwjTrunc.endsWith('…'), true);

  // 6. Skin tone modifiers
  const skinTone = '👏🏿 High five';
  const skinTrunc = sanitizeTableCell(skinTone, 6);
  assert.equal(skinTrunc.includes('👏🏿'), true);

  // 7. Combining marks (q\u0307 has no precomposed NFC form)
  const combining = 'Letter q\u0307 is special';
  const combiningTrunc = sanitizeTableCell(combining, 10);
  assert.equal(combiningTrunc.includes('q\u0307'), true);

  // 8. Bidi controls and overrides (\u061C, \u200E, \u200F, \u202A-\u202E, \u2066-\u2069)
  const bidi = 'Prefix\u061C\u200E\u200F\u202A\u202B\u202C\u202D\u202E\u2066\u2067\u2068\u2069Suffix';
  assert.equal(sanitizeTableCell(bidi), 'PrefixSuffix');

  // 9. Control characters (ASCII 0x00-0x1F, 0x7F-0x9F)
  const controls = 'Clean\x00\x07\x1B\x7F\x80\x9FText';
  assert.equal(sanitizeTableCell(controls), 'CleanText');

  // 10. Markdown syntax neutralized
  const md = '[link](url) *bold* _italic_ ~strike~ `code` \\backslash';
  const mdSan = sanitizeTableCell(md);
  assert.equal(mdSan.includes('['), false);
  assert.equal(mdSan.includes(']'), false);
  assert.equal(mdSan.includes('*'), false);
  assert.equal(mdSan.includes('_'), false);
  assert.equal(mdSan.includes('~'), false);
  assert.equal(mdSan.includes('`'), false);
  assert.equal(mdSan.includes('\\'), false);

  // 11. HTML tags and script execution neutralized
  const html = '<script>alert(1)</script><img src="x" onerror="evil()"/>';
  const htmlSan = sanitizeTableCell(html);
  assert.equal(htmlSan.includes('<'), false);
  assert.equal(htmlSan.includes('>'), false);
  assert.equal(htmlSan.includes('"'), false);

  // 12. Table delimiters neutralized
  const table = 'Col 1 | Col 2 | Col 3';
  const tableSan = sanitizeTableCell(table);
  assert.equal(tableSan.includes('|'), false);
  assert.equal(tableSan.includes('&#124;'), true);

  // 13. Ampersand escaped first
  const ampersand = 'AT&T & <tag> & [link]';
  const ampSan = sanitizeTableCell(ampersand);
  assert.equal(ampSan.includes('&amp;'), true);
  // Must NOT double-escape (e.g. no &amp;lt;)
  assert.equal(ampSan.includes('&amp;lt;'), false);
  assert.equal(ampSan.includes('&amp;#91;'), false);

  // 14. Null and undefined
  assert.equal(sanitizeTableCell(null), '');
  assert.equal(sanitizeTableCell(undefined), '');
});

test('Phase 2H P1 Finding 1: formatDigest integration test with populated classifiedMergedPRs', () => {
  const classifiedMergedPRs = [
    {
      number: 7424,
      title: 'Fix Postgres outage & handle errors',
      mergedAt: '2026-11-19T23:48:29Z',
      closingIssuesOverflow: false,
      isClosingIssuesComplete: true,
      omittedClosingIssuesCount: 0,
      linkedIssues: [
        { number: 7401, state: 'CLOSED', isClosed: true, confidence: 'CONFIRMED', status: 'CONFIRMED' },
        { number: 7402, state: 'OPEN', isClosed: false, confidence: 'HIGH_INFERRED', status: 'INFERRED' },
        { number: 7403, state: 'UNVERIFIED', isClosed: false, confidence: 'LOW_MENTION', status: 'UNVERIFIED' }
      ]
    },
    {
      number: 7436,
      title: 'Follow-up with overflow closing references',
      mergedAt: '2026-11-20T17:41:28Z',
      closingIssuesOverflow: true,
      isClosingIssuesComplete: false,
      omittedClosingIssuesCount: 3,
      linkedIssues: [
        { number: 7412, state: 'OPEN', isClosed: false, confidence: 'CONFIRMED', status: 'CONFIRMED' }
      ]
    }
  ];

  const digest = formatDigest({
    classifiedPRs: [],
    classifiedMergedPRs,
    opportunities: { goodFirst: [], helpWanted: [] },
    relationships: { competingPRs: [], potentiallyResolvedIssues: [] },
    metrics: {}
  });

  // 1. Integration check: Recently Merged Pull Requests subsection is rendered
  assert.equal(digest.includes('### Recently Merged Pull Requests (2)'), true);

  // 2. Contains both merged PR links
  assert.equal(digest.includes('[#7424](https://github.com/rubyforgood/casa/pull/7424)'), true);
  assert.equal(digest.includes('[#7436](https://github.com/rubyforgood/casa/pull/7436) [+3 more]'), true);

  // 3. Sanitized titles and formatted dates
  assert.equal(digest.includes('Fix Postgres outage &amp; handle errors'), true);
  assert.equal(digest.includes('2026-11-19'), true);
  assert.equal(digest.includes('2026-11-20'), true);

  // 4. Linked issue relationships rendered with correct distinctions:
  // - Confirmed closing issue: shows (Confirmed) and (Closed) if closed
  assert.equal(digest.includes('[#7401](https://github.com/rubyforgood/casa/issues/7401) (Closed) (Confirmed)'), true);
  // - Inferred issue: shows (Inferred) and NOT confirmed
  assert.equal(digest.includes('[#7402](https://github.com/rubyforgood/casa/issues/7402) (Inferred)'), true);
  // - Unverified reference: retains [?]
  assert.equal(digest.includes('[#7403](https://github.com/rubyforgood/casa/issues/7403) [?]'), true);

  // 5. Never presents inferred reference as confirmed closing relationship
  assert.equal(digest.includes('[#7402](https://github.com/rubyforgood/casa/issues/7402) (Confirmed)'), false);

  // 6. Does not claim merged PR automatically proves open issue is resolved
  assert.equal(digest.includes('Closed Issue #7402'), false);
  assert.equal(digest.includes('Resolved Issue #7402'), false);
});

test('Phase 2H P2 Finding 3: formatDigest and helpers gracefully handle missing and malformed timestamps', () => {
  // formatTimestampDate helper tests
  assert.equal(formatTimestampDate(null), '—');
  assert.equal(formatTimestampDate(undefined), '—');
  assert.equal(formatTimestampDate(''), '—');
  assert.equal(formatTimestampDate('invalid-date'), '—');
  assert.equal(formatTimestampDate('2026-11-20T17:41:28Z'), '2026-11-20');

  // In digest with null / malformed timestamps
  const digest = formatDigest({
    opportunities: {
      goodFirst: [
        {
          number: 9001,
          title: 'Missing date issue',
          difficulty: 'Easy',
          createdAt: null,
          lastCommentAt: 'not-a-valid-date'
        }
      ],
      helpWanted: []
    },
    classifiedMergedPRs: [
      {
        number: 9002,
        title: 'Missing mergedAt PR',
        mergedAt: null,
        closingIssuesOverflow: false,
        isClosingIssuesComplete: true,
        omittedClosingIssuesCount: 0,
        linkedIssues: []
      }
    ],
    relationships: {
      competingPRs: [],
      potentiallyResolvedIssues: [
        {
          issueNumber: 9003,
          mergedPRNumber: 9002,
          mergedAt: 'garbage-date',
          confidence: 'CONFIRMED'
        }
      ]
    }
  });

  // Verify missing and malformed dates are represented as '—' without inventing freshness
  assert.equal(digest.includes('| [#9001](https://github.com/rubyforgood/casa/issues/9001) | Missing date issue | `Easy` | — | Comment (date unknown) |'), true);
  assert.equal(digest.includes('| [#9002](https://github.com/rubyforgood/casa/pull/9002) | Missing mergedAt PR | — | None |'), true);
  assert.equal(digest.includes('| [#9003](https://github.com/rubyforgood/casa/issues/9003) | [#9002](https://github.com/rubyforgood/casa/pull/9002) | — | `CONFIRMED` |'), true);
});

test('Phase 2H P2 Finding 5: end-to-end formatter renders incomplete closing reference indicators', () => {
  const digest = formatDigest({
    classifiedMergedPRs: [
      {
        number: 7701,
        title: 'PR with incomplete closing references',
        mergedAt: '2026-11-20T10:00:00Z',
        closingIssuesOverflow: false,
        isClosingIssuesComplete: false,
        omittedClosingIssuesCount: 0,
        linkedIssues: [{ number: 8801, state: 'OPEN', confidence: 'CONFIRMED', status: 'CONFIRMED' }]
      }
    ],
    relationships: {
      competingPRs: [
        {
          issueNumber: 8802,
          prs: [
            {
              prNumber: 7702,
              confidence: 'CONFIRMED',
              closingIssuesOverflow: false,
              isClosingIssuesComplete: false,
              omittedClosingCount: 0
            }
          ]
        }
      ],
      potentiallyResolvedIssues: [
        {
          issueNumber: 8803,
          mergedPRNumber: 7703,
          mergedAt: '2026-11-20T10:00:00Z',
          confidence: 'CONFIRMED',
          closingIssuesOverflow: false,
          isClosingIssuesComplete: false,
          omittedClosingCount: 0
        }
      ]
    }
  });

  // Must retain [incomplete] indicator across all three relationship displays
  assert.equal(digest.includes('[#7701](https://github.com/rubyforgood/casa/pull/7701) [incomplete]'), true);
  assert.equal(digest.includes('[#7702](https://github.com/rubyforgood/casa/pull/7702) [incomplete] (`CONFIRMED`)'), true);
  assert.equal(digest.includes('[#7703](https://github.com/rubyforgood/casa/pull/7703) [incomplete]'), true);
});

test('Phase 2H P3 Finding 6: sanitizeTableCell preserves regional-indicator flags and grapheme clusters when Intl.Segmenter is unavailable', () => {
  const usFlag = '🇺🇸 US Flag';
  const gbFlag = '🇬🇧 UK Flag';

  // 1. With standard Intl.Segmenter available
  assert.equal(sanitizeTableCell(usFlag, 5).includes('🇺🇸'), true);
  assert.equal(sanitizeTableCell(gbFlag, 5).includes('🇬🇧'), true);

  // 2. Simulate environment without Intl.Segmenter
  const originalSegmenter = Intl.Segmenter;
  try {
    delete Intl.Segmenter;

    // Regional indicator flags must not be split into lone surrogate code points
    const flagTrunc = sanitizeTableCell('🇺🇸 Long Text Exceeding Boundary', 5);
    assert.equal(flagTrunc.includes('🇺🇸'), true);
    assert.equal(flagTrunc.endsWith('…'), true);

    // ZWJ sequence must remain intact
    const zwj = '👨‍👩‍👧‍👦 Family';
    const zwjTrunc = sanitizeTableCell(zwj, 5);
    assert.equal(zwjTrunc.includes('👨‍👩‍👧‍👦'), true);

    // Combining characters must remain intact
    const combining = 'q\u0307 Combining mark';
    const combTrunc = sanitizeTableCell(combining, 5);
    assert.equal(combTrunc.includes('q\u0307'), true);
  } finally {
    Intl.Segmenter = originalSegmenter;
  }
});

test('Phase 2J Finding 1: Correct comment connection availability and activity rendering', () => {
  // 1. Explicit zero comments -> "No comments"
  const issueZeroComments = normalizeIssue({
    number: 801,
    title: 'Zero comments issue',
    comments: { totalCount: 0, nodes: [] }
  });
  assert.equal(issueZeroComments.isCommentsAvailable, true);
  assert.equal(issueZeroComments.commentCount, 0);
  assert.equal(issueZeroComments.lastCommentAt, null);
  assert.equal(formatCommentActivity(issueZeroComments), 'No comments');

  // 2. Positive totalCount with valid latest timestamp -> "Comment YYYY-MM-DD"
  const issueValidCommentDate = normalizeIssue({
    number: 803,
    title: 'Valid comment timestamp issue',
    comments: {
      totalCount: 1,
      nodes: [{ createdAt: '2026-11-20T10:00:00Z', author: { login: 'contributor1' } }]
    }
  });
  assert.equal(issueValidCommentDate.isCommentsAvailable, true);
  assert.equal(issueValidCommentDate.commentCount, 1);
  assert.equal(issueValidCommentDate.lastCommentAt, '2026-11-20T10:00:00Z');
  assert.equal(formatCommentActivity(issueValidCommentDate), 'Comment 2026-11-20');

  const issueMultipleComments = normalizeIssue({
    number: 804,
    title: 'Multiple comments with latest timestamp',
    comments: {
      totalCount: 7,
      nodes: [{ createdAt: '2026-11-22T08:30:00Z', author: { login: 'maintainer1' } }]
    }
  });
  assert.equal(issueMultipleComments.isCommentsAvailable, true);
  assert.equal(issueMultipleComments.commentCount, 7);
  assert.equal(issueMultipleComments.lastCommentAt, '2026-11-22T08:30:00Z');
  assert.equal(formatCommentActivity(issueMultipleComments), 'Comment 2026-11-22');

  // 3. Positive totalCount with unavailable or invalid timestamp -> "Comment (date unknown)"
  // Case A: totalCount > 0 but nodes array is empty (detail unavailable)
  const issueMissingNodeDetail = normalizeIssue({
    number: 805,
    title: 'Positive count with empty nodes',
    comments: { totalCount: 3, nodes: [] }
  });
  assert.equal(issueMissingNodeDetail.isCommentsAvailable, true);
  assert.equal(issueMissingNodeDetail.commentCount, 3);
  assert.equal(issueMissingNodeDetail.lastCommentAt, null);
  assert.equal(formatCommentActivity(issueMissingNodeDetail), 'Comment (date unknown)');

  // Case B: totalCount > 0 and node createdAt is null
  const issueNullCommentDate = normalizeIssue({
    number: 806,
    title: 'Comment node with null createdAt',
    comments: {
      totalCount: 2,
      nodes: [{ createdAt: null }]
    }
  });
  assert.equal(issueNullCommentDate.isCommentsAvailable, true);
  assert.equal(issueNullCommentDate.commentCount, 2);
  assert.equal(issueNullCommentDate.lastCommentAt, null);
  assert.equal(formatCommentActivity(issueNullCommentDate), 'Comment (date unknown)');

  // Case C: totalCount > 0 and node createdAt is malformed calendar date (e.g. Feb 31)
  const issueMalformedCommentDate = normalizeIssue({
    number: 807,
    title: 'Comment node with malformed calendar date',
    comments: {
      totalCount: 1,
      nodes: [{ createdAt: '2026-02-31T00:00:00Z' }]
    }
  });
  assert.equal(issueMalformedCommentDate.isCommentsAvailable, true);
  assert.equal(issueMalformedCommentDate.commentCount, 1);
  assert.equal(issueMalformedCommentDate.lastCommentAt, null);
  assert.equal(formatCommentActivity(issueMalformedCommentDate), 'Comment (date unknown)');

  // Case D: totalCount > 0 and node createdAt is non-ISO date string
  const issueNonIsoCommentDate = normalizeIssue({
    number: 808,
    title: 'Comment node with non-ISO date string',
    comments: {
      totalCount: 1,
      nodes: [{ createdAt: '11/20/2026' }]
    }
  });
  assert.equal(issueNonIsoCommentDate.isCommentsAvailable, true);
  assert.equal(issueNonIsoCommentDate.commentCount, 1);
  assert.equal(issueNonIsoCommentDate.lastCommentAt, null);
  assert.equal(formatCommentActivity(issueNonIsoCommentDate), 'Comment (date unknown)');

  // 4. Missing comments connection -> "Comment activity unavailable"
  const issueMissingCommentsProp = normalizeIssue({
    number: 802,
    title: 'No comments property'
  });
  assert.equal(issueMissingCommentsProp.isCommentsAvailable, false);
  assert.equal(issueMissingCommentsProp.commentCount, null);
  assert.equal(issueMissingCommentsProp.lastCommentAt, null);
  assert.equal(formatCommentActivity(issueMissingCommentsProp), 'Comment activity unavailable');

  // 5. Null comments connection -> "Comment activity unavailable"
  const issueNullComments = normalizeIssue({
    number: 809,
    title: 'Null comments connection',
    comments: null
  });
  assert.equal(issueNullComments.isCommentsAvailable, false);
  assert.equal(issueNullComments.commentCount, null);
  assert.equal(formatCommentActivity(issueNullComments), 'Comment activity unavailable');

  // 6. Missing totalCount in comments connection -> "Comment activity unavailable"
  const issueMissingTotalCount = normalizeIssue({
    number: 810,
    title: 'Missing totalCount',
    comments: { nodes: [] }
  });
  assert.equal(issueMissingTotalCount.isCommentsAvailable, false);
  assert.equal(issueMissingTotalCount.commentCount, null);
  assert.equal(formatCommentActivity(issueMissingTotalCount), 'Comment activity unavailable');

  // 7. Malformed totalCount in comments connection -> unknown, not zero -> "Comment activity unavailable"
  const issueMalformedTotalCount = normalizeIssue({
    number: 811,
    title: 'Malformed totalCount',
    comments: { totalCount: 'not-a-number' }
  });
  assert.equal(issueMalformedTotalCount.isCommentsAvailable, false);
  assert.equal(issueMalformedTotalCount.commentCount, null);
  assert.equal(formatCommentActivity(issueMalformedTotalCount), 'Comment activity unavailable');

  // 8. Never infer zero comments from a missing connection
  assert.notEqual(formatCommentActivity(issueMissingCommentsProp), 'No comments');
  assert.notEqual(formatCommentActivity(issueNullComments), 'No comments');
  assert.notEqual(formatCommentActivity(issueMissingTotalCount), 'No comments');
  assert.notEqual(formatCommentActivity(issueMalformedTotalCount), 'No comments');

  // 9. End-to-end integration test in formatDigest with opportunities table
  const digest = formatDigest({
    opportunities: {
      goodFirst: [
        issueZeroComments,
        issueValidCommentDate,
        issueMissingNodeDetail
      ],
      helpWanted: [
        issueMalformedCommentDate,
        issueMissingCommentsProp,
        issueNullComments,
        issueMalformedTotalCount
      ]
    }
  });

  // Verify Good First table rows
  assert.equal(digest.includes('| [#801](https://github.com/rubyforgood/casa/issues/801) | Zero comments issue | — | — | No comments |'), true);
  assert.equal(digest.includes('| [#803](https://github.com/rubyforgood/casa/issues/803) | Valid comment timestamp issue | — | — | Comment 2026-11-20 |'), true);
  assert.equal(digest.includes('| [#805](https://github.com/rubyforgood/casa/issues/805) | Positive count with empty nodes | — | — | Comment (date unknown) |'), true);

  // Verify Help Wanted table rows
  assert.equal(digest.includes('| [#807](https://github.com/rubyforgood/casa/issues/807) | Comment node with malformed calendar date | — | — | Comment (date unknown) |'), true);
  assert.equal(digest.includes('| [#802](https://github.com/rubyforgood/casa/issues/802) | No comments property | — | — | Comment activity unavailable |'), true);
  assert.equal(digest.includes('| [#809](https://github.com/rubyforgood/casa/issues/809) | Null comments connection | — | — | Comment activity unavailable |'), true);
  assert.equal(digest.includes('| [#811](https://github.com/rubyforgood/casa/issues/811) | Malformed totalCount | — | — | Comment activity unavailable |'), true);
});
