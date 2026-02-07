USE HR_Enterprise_Project;
GO

-- 1) Confirm tables exist
SELECT TABLE_SCHEMA, TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE='BASE TABLE'
ORDER BY TABLE_SCHEMA, TABLE_NAME;
GO

-- 2) Confirm key foreign keys (CASCADE settings)
SELECT
  fk.name,
  OBJECT_NAME(fk.parent_object_id) AS child_table,
  fk.delete_referential_action_desc AS on_delete,
  OBJECT_NAME(fk.referenced_object_id) AS parent_table
FROM sys.foreign_keys fk
WHERE fk.name IN ('fk_es_emp','fk_es_skill','fk_et_course','fk_et_emp')
ORDER BY fk.name;
GO
