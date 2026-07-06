/*
# Add processing information fields and document storage to merchant_applications

## Purpose
Expands the application form with a "Processing Information" section and
a file upload capability so applicants can submit their supporting documents
in a single zip file alongside the application data.

## Modified Tables
- `merchant_applications`

### New Processing Information columns
- `payment_method_in_person` (boolean, default false) — applicant accepts in-person payments
- `payment_method_online` (boolean, default false) — applicant accepts online payments
- `payment_method_phone_invoice` (boolean, default false) — applicant accepts over-the-phone/invoice payments
- `avg_monthly_volume` (text, nullable) — average monthly processing volume dollar amount
- `avg_transaction_size` (text, nullable) — typical average transaction size
- `high_ticket_size` (text, nullable) — highest typical transaction size
- `existing_processing` (text, nullable) — whether applicant has existing processing and for how long
- `previous_processor` (text, nullable) — name of previous or current processor

### New Document Upload column
- `document_url` (text, nullable) — Supabase Storage path to the uploaded zip file of required documents

## New Storage Bucket
- `merchant-documents` — private bucket for storing applicant document zip files
  - Max file size: 50 MB
  - Allowed MIME types: zip and generic binary (since browsers report zip MIME types inconsistently)

## Storage Policies
- INSERT: anon + authenticated may upload to `merchant-documents` (public form submission)
- SELECT: authenticated only (protects sensitive applicant documents)

## Security
- No changes to existing table RLS policies needed.
- Storage INSERT policy allows anon uploads so the public form can attach documents.
- Storage SELECT is restricted to authenticated (admin) users to protect PII documents.

## Important Notes
1. All new columns are nullable — existing rows remain valid.
2. This is a purely additive migration — no data is dropped or modified.
3. The storage bucket is created idempotently via ON CONFLICT DO NOTHING.
*/

-- New processing info columns
ALTER TABLE merchant_applications
  ADD COLUMN IF NOT EXISTS payment_method_in_person boolean NOT NULL DEFAULT false;

ALTER TABLE merchant_applications
  ADD COLUMN IF NOT EXISTS payment_method_online boolean NOT NULL DEFAULT false;

ALTER TABLE merchant_applications
  ADD COLUMN IF NOT EXISTS payment_method_phone_invoice boolean NOT NULL DEFAULT false;

ALTER TABLE merchant_applications
  ADD COLUMN IF NOT EXISTS avg_monthly_volume text;

ALTER TABLE merchant_applications
  ADD COLUMN IF NOT EXISTS avg_transaction_size text;

ALTER TABLE merchant_applications
  ADD COLUMN IF NOT EXISTS high_ticket_size text;

ALTER TABLE merchant_applications
  ADD COLUMN IF NOT EXISTS existing_processing text;

ALTER TABLE merchant_applications
  ADD COLUMN IF NOT EXISTS previous_processor text;

ALTER TABLE merchant_applications
  ADD COLUMN IF NOT EXISTS document_url text;

-- Storage bucket for applicant documents
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'merchant-documents',
  'merchant-documents',
  false,
  52428800,
  ARRAY[
    'application/zip',
    'application/x-zip-compressed',
    'application/x-zip',
    'application/octet-stream',
    'multipart/x-zip'
  ]
) ON CONFLICT (id) DO NOTHING;

-- Storage policies
DROP POLICY IF EXISTS "anon_upload_merchant_docs" ON storage.objects;
CREATE POLICY "anon_upload_merchant_docs" ON storage.objects
FOR INSERT TO anon, authenticated
WITH CHECK (bucket_id = 'merchant-documents');

DROP POLICY IF EXISTS "auth_select_merchant_docs" ON storage.objects;
CREATE POLICY "auth_select_merchant_docs" ON storage.objects
FOR SELECT TO authenticated
USING (bucket_id = 'merchant-documents');

DROP POLICY IF EXISTS "auth_delete_merchant_docs" ON storage.objects;
CREATE POLICY "auth_delete_merchant_docs" ON storage.objects
FOR DELETE TO authenticated
USING (bucket_id = 'merchant-documents');
