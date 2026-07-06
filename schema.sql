-- 1. Create the applications table
CREATE TABLE IF NOT EXISTS merchant_applications (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at timestamptz DEFAULT now(),
  business_name text NOT NULL,
  contact_name text NOT NULL,
  email text NOT NULL,
  phone text NOT NULL,
  website text,
  country text NOT NULL,
  industry text NOT NULL CHECK (
    industry IN ('ecommerce', 'dropshipping', 'saas', 'coaching', 'courses', 'supplements', 'other')
  ),
  monthly_volume text NOT NULL,
  description text,
  status text NOT NULL DEFAULT 'pending' CHECK (
    status IN ('pending', 'reviewing', 'approved', 'declined')
  ),
  
  -- Business details
  legal_address text,
  dba_name text,
  dba_address text,
  federal_tax_id text,
  business_start_date text,
  has_llc boolean NOT NULL DEFAULT false,
  has_us_signer boolean NOT NULL DEFAULT false,
  
  -- Owner 1 Detail
  owner1_ssn_itin text,
  owner1_personal_phone text,
  
  -- Owner 2 Detail (Optional)
  owner2_legal_name text,
  owner2_ownership_pct text,
  owner2_job_title text,
  owner2_date_of_birth text,
  owner2_address text,
  
  -- Processing Details
  payment_method_in_person boolean NOT NULL DEFAULT false,
  payment_method_online boolean NOT NULL DEFAULT false,
  payment_method_phone_invoice boolean NOT NULL DEFAULT false,
  avg_monthly_volume text,
  avg_transaction_size text,
  high_ticket_size text,
  existing_processing text,
  previous_processor text,
  
  -- Document storage path
  document_url text
);

-- 2. Enable Row-Level Security
ALTER TABLE merchant_applications ENABLE ROW LEVEL SECURITY;

-- 3. RLS Policies
-- Allow anyone (public/anon) to submit a new application
CREATE POLICY "anon_insert_applications"
ON merchant_applications FOR INSERT
TO anon, authenticated WITH CHECK (true);

-- Only authenticated admins can read, update or delete applications
CREATE POLICY "auth_select_applications"
ON merchant_applications FOR SELECT
TO authenticated USING (true);

CREATE POLICY "auth_update_applications"
ON merchant_applications FOR UPDATE
TO authenticated USING (true) WITH CHECK (true);

CREATE POLICY "auth_delete_applications"
ON merchant_applications FOR DELETE
TO authenticated USING (true);

-- 4. Database Indexes for performance
CREATE INDEX IF NOT EXISTS idx_merchant_applications_created_at
ON merchant_applications (created_at DESC);

CREATE INDEX IF NOT EXISTS idx_merchant_applications_status
ON merchant_applications (status);



-----------------------------
-- 1. Create the storage bucket
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'merchant-documents',
  'merchant-documents',
  false,
  52428800, -- 50 MB limit
  ARRAY[
    'application/zip',
    'application/x-zip-compressed',
    'application/x-zip',
    'application/octet-stream',
    'multipart/x-zip'
  ]
) ON CONFLICT (id) DO NOTHING;

-- 2. Storage Policies
-- Allow anyone (public/anon) to upload application documents
CREATE POLICY "anon_upload_merchant_docs" ON storage.objects
FOR INSERT TO anon, authenticated
WITH CHECK (bucket_id = 'merchant-documents');

-- Only authenticated admins can download documents
CREATE POLICY "auth_select_merchant_docs" ON storage.objects
FOR SELECT TO authenticated
USING (bucket_id = 'merchant-documents');

-- Only authenticated admins can delete documents
CREATE POLICY "auth_delete_merchant_docs" ON storage.objects
FOR DELETE TO authenticated
USING (bucket_id = 'merchant-documents');
