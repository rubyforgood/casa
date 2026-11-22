'use strict';

const test = require('node:test');
const assert = require('node:assert/strict');
const path = require('node:path');
const fs = require('node:fs');

const { processBatchResult } = require('../normalize');

function loadFixture(name) {
  const file = path.join(__dirname, 'fixtures', name);
  return JSON.parse(fs.readFileSync(file, 'utf8'));
}

test('batch_resolve: handles mixed success, PR rejection, and explicit NOT_FOUND error', () => {
  const fixture = loadFixture('fixture_error_not_found.json');
  const candidateNumbers = [7305, 7334, 999999];

  const results = processBatchResult(fixture, candidateNumbers);

  // 7305 is an Issue -> OPEN
  assert.equal(results.has(7305), true);
  const issue7305 = results.get(7305);
  assert.equal(issue7305.isIssue, true);
  assert.equal(issue7305.isPR, false);
  assert.equal(issue7305.state, 'OPEN');
  assert.equal(issue7305.title, 'Delete dead read_more.js');

  // 7334 is a PullRequest -> discarded as an issue link
  assert.equal(results.has(7334), true);
  const pr7334 = results.get(7334);
  assert.equal(pr7334.isIssue, false);
  assert.equal(pr7334.isPR, true);

  // 999999 has an explicit NOT_FOUND error -> NOT_FOUND
  assert.equal(results.has(999999), true);
  const notFound = results.get(999999);
  assert.equal(notFound.isIssue, false);
  assert.equal(notFound.state, 'NOT_FOUND');
});

test('batch_resolve: unrelated alias-level error produces UNVERIFIED (never NOT_FOUND)', () => {
  const fixture = loadFixture('fixture_error_unrelated.json');
  const candidateNumbers = [7305, 8888];

  const results = processBatchResult(fixture, candidateNumbers);

  // 8888 had a FORBIDDEN error -> UNVERIFIED
  assert.equal(results.has(8888), true);
  const unverified = results.get(8888);
  assert.equal(unverified.isIssue, false);
  assert.equal(unverified.state, 'UNVERIFIED');
});

test('batch_resolve: nested field-level error on state produces UNVERIFIED', () => {
  const fixture = loadFixture('fixture_error_nested_field.json');
  const candidateNumbers = [7305];

  const results = processBatchResult(fixture, candidateNumbers);

  // 7305 exists, but state had a field error -> UNVERIFIED
  assert.equal(results.has(7305), true);
  const item = results.get(7305);
  assert.equal(item.isIssue, true);
  assert.equal(item.state, 'UNVERIFIED');
});

test('batch_resolve: malformed response produces UNVERIFIED for all candidates', () => {
  const fixture = loadFixture('fixture_error_malformed.json');
  const candidateNumbers = [1111, 2222];

  const results = processBatchResult(fixture, candidateNumbers);

  assert.equal(results.get(1111).state, 'UNVERIFIED');
  assert.equal(results.get(2222).state, 'UNVERIFIED');
});
