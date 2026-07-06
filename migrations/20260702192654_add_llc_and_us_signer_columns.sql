/*
# Add LLC and US signer fields to merchant_applications

## Purpose
The application form now requires applicants to confirm they have a registered
LLC (or equivalent US business entity) and a US-based signer. This migration
adds two boolean columns to store those confirmations.

## Modified Tables
- `merchant_applications`
  - `has_llc` (boolean, not null, default false) — applicant confirms they have
    a registered LLC, corporation, or equivalent US business entity
  - `has_us_signer` (boolean, not null, default false) — applicant confirms a
    US-based owner or authorized representative will sign the merchant agreement

## Security
- No changes to existing RLS policies. The INSERT policy already allows
  anon/authenticated inserts with `WITH CHECK (true)`, so the new boolean
  columns are writable by the public form without policy changes.

## Important Notes
1. Both columns default to `false` so existing rows (if any) remain valid.
2. The frontend sends these values from checkbox inputs on the application form.
3. No data is lost — this is a purely additive migration.
*/

ALTER TABLE merchant_applications
  ADD COLUMN IF NOT EXISTS has_llc boolean NOT NULL DEFAULT false;

ALTER TABLE merchant_applications
  ADD COLUMN IF NOT EXISTS has_us_signer boolean NOT NULL DEFAULT false;
