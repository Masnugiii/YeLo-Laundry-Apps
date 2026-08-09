-- Add missing finance permission and assign to finance-enabled roles.
INSERT INTO "permissions" ("id", "code", "name", "module", "description", "is_active", "created_at", "updated_at")
SELECT gen_random_uuid(), 'finance', 'Finance', 'finance', 'Finance module access', true, NOW(), NOW()
WHERE NOT EXISTS (
  SELECT 1 FROM "permissions" WHERE "code" = 'finance'
);

INSERT INTO "role_permissions" ("id", "role_id", "permission_id", "created_at", "updated_at")
SELECT gen_random_uuid(), r."id", p."id", NOW(), NOW()
FROM "roles" r
CROSS JOIN "permissions" p
WHERE p."code" = 'finance'
  AND r."code" IN ('owner', 'cashier', 'cashier_laundry_driver')
  AND NOT EXISTS (
    SELECT 1
    FROM "role_permissions" rp
    WHERE rp."role_id" = r."id"
      AND rp."permission_id" = p."id"
      AND rp."deleted_at" IS NULL
  );
