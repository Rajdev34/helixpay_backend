/*
# Add pre-application submission fields to merchant_applications

## Purpose
Expands the merchant application form to match a full pre-application submission
flow. Adds business detail fields, owner 1 identity fields, and a complete
owner 2 section so underwriters receive the information they need to begin review.

## Modified Tables
- `merchant_applications`

### New Business Information columns
- `legal_address` (text, nullable) — full legal address of the business
- `dba_name` (text, nullable) — "doing business as" trade name if different from legal name
- `dba_address` (text, nullable) — DBA address if different from legal address
- `federal_tax_id` (text, nullable) — Federal Tax ID / EIN Number
- `business_start_date` (text, nullable) — when the business was established (stored as text for flexibility)

### New Owner 1 columns
- `owner1_ssn_itin` (text, nullable) — Owner 1 SSN or ITIN
- `owner1_personal_phone` (text, nullable) — Owner 1 personal phone number

### New Owner 2 columns
- `owner2_legal_name` (text, nullable) — legal name of second owner (optional)
- `owner2_ownership_pct` (text, nullable) — ownership percentage for owner 2
- `owner2_job_title` (text, nullable) — job title of owner 2
- `owner2_date_of_birth` (text, nullable) — date of birth of owner 2
- `owner2_address` (text, nullable) — residential address of owner 2

## Security
- No policy changes needed. The existing INSERT policy already allows anon/authenticated
  clients to write all columns with `WITH CHECK (true)`.

## Important Notes
1. All new columns are nullable — existing rows remain valid with NULL for the new fields.
2. Sensitive fields (SSN/ITIN, EIN) are stored as plaintext here; encrypt at rest
   or restrict SELECT policies further before handling production PII at scale.
3. This is a purely additive migration — no data is dropped or modified.
*/

ALTER TABLE merchant_applications
  ADD COLUMN IF NOT EXISTS legal_address text;

ALTER TABLE merchant_applications
  ADD COLUMN IF NOT EXISTS dba_name text;

ALTER TABLE merchant_applications
  ADD COLUMN IF NOT EXISTS dba_address text;

ALTER TABLE merchant_applications
  ADD COLUMN IF NOT EXISTS federal_tax_id text;

ALTER TABLE merchant_applications
  ADD COLUMN IF NOT EXISTS business_start_date text;

ALTER TABLE merchant_applications
  ADD COLUMN IF NOT EXISTS owner1_ssn_itin text;

ALTER TABLE merchant_applications
  ADD COLUMN IF NOT EXISTS owner1_personal_phone text;

ALTER TABLE merchant_applications
  ADD COLUMN IF NOT EXISTS owner2_legal_name text;

ALTER TABLE merchant_applications
  ADD COLUMN IF NOT EXISTS owner2_ownership_pct text;

ALTER TABLE merchant_applications
  ADD COLUMN IF NOT EXISTS owner2_job_title text;

ALTER TABLE merchant_applications
  ADD COLUMN IF NOT EXISTS owner2_date_of_birth text;

ALTER TABLE merchant_applications
  ADD COLUMN IF NOT EXISTS owner2_address text;
