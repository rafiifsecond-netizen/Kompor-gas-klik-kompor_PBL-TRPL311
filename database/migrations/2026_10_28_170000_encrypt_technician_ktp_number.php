<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('technician_profiles', function (Blueprint $table): void {
            $table->text('ktp_number')->nullable()->change();
        });
    }

    public function down(): void
    {
        Schema::table('technician_profiles', function (Blueprint $table): void {
            $table->string('ktp_number', 30)->nullable()->change();
        });
    }
};
