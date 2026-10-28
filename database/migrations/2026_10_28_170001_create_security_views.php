<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up(): void
    {
        $createView = DB::getDriverName() === 'sqlite'
            ? 'CREATE VIEW IF NOT EXISTS'
            : 'CREATE OR REPLACE VIEW';

        DB::statement(<<<SQL
            {$createView} v_service_catalog_public AS
            SELECT
                si.id,
                si.service_category_id,
                si.name,
                si.slug,
                si.description,
                si.estimated_minutes,
                si.base_price,
                si.is_active
            FROM service_items si
            WHERE si.is_active = 1
        SQL);

        DB::statement(<<<SQL
            {$createView} v_technician_public AS
            SELECT
                u.id,
                u.name,
                u.avatar_url,
                tp.bio,
                tp.years_of_experience,
                tp.is_verified,
                tp.is_available,
                tp.rating_avg,
                tp.reviews_count,
                tp.jobs_completed_count
            FROM users u
            INNER JOIN technician_profiles tp ON tp.user_id = u.id
            WHERE u.role = 'technician' AND u.is_active = 1
        SQL);

        DB::statement(<<<SQL
            {$createView} v_payment_operational AS
            SELECT
                p.id,
                p.order_id,
                p.customer_id,
                p.payment_number,
                p.payment_method,
                p.amount,
                p.payment_status,
                p.paid_at,
                p.created_at,
                p.updated_at
            FROM payments p
        SQL);

        DB::statement(<<<SQL
            {$createView} v_audit_event_summary AS
            SELECT
                id,
                actor_id,
                actor_role,
                event_name,
                entity_type,
                entity_id,
                platform,
                status,
                created_at
            FROM activity_logs
        SQL);
    }

    public function down(): void
    {
        DB::statement('DROP VIEW IF EXISTS v_audit_event_summary');
        DB::statement('DROP VIEW IF EXISTS v_payment_operational');
        DB::statement('DROP VIEW IF EXISTS v_technician_public');
        DB::statement('DROP VIEW IF EXISTS v_service_catalog_public');
    }
};
