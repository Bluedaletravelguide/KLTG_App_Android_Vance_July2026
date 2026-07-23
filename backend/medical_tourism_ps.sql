-- Table for the Medical Tourism "Plastic Surgery" tab (appMedicalT_ps in
-- functions.php), which had a backend query but no table at all. Column
-- names/types are inferred from the SELECT in functions.php and mirrored
-- from the sibling tables (medical_tourism_hc/dtl/der/oph) by naming
-- convention only — before running this, open one of those sibling tables
-- in phpMyAdmin's "Structure" tab and adjust column types/lengths here to
-- match if they differ from what's assumed below.
CREATE TABLE IF NOT EXISTS medical_tourism_ps (
  id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  medical_tourism_ps_title VARCHAR(255) NOT NULL,
  medical_tourism_ps_location VARCHAR(255),
  medical_tourism_ps_image VARCHAR(255),
  medical_tourism_ps_content TEXT,
  medical_tourism_ps_locationurl VARCHAR(500),
  medical_tourism_ps_hours VARCHAR(255),
  medical_tourism_ps_order INT DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
