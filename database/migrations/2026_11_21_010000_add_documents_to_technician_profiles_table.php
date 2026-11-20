<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::table('technician_profiles', function (Blueprint $table) {
            if (! Schema::hasColumn('technician_profiles', 'ktp_photo_url')) {
                $table->string('ktp_photo_url')->nullable()->after('ktp_number');
            }
            if (! Schema::hasColumn('technician_profiles', 'application_letter_url')) {
                $table->string('application_letter_url')->nullable()->after('certificate_url');
            }
            if (! Schema::hasColumn('technician_profiles', 'supporting_document_url')) {
                $table->string('supporting_document_url')->nullable()->after('application_letter_url');
            }
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('technician_profiles', function (Blueprint $table) {
            $table->dropColumn(['ktp_photo_url', 'application_letter_url', 'supporting_document_url']);
        });
    }
};
