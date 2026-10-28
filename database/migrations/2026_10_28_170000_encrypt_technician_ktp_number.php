<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Crypt;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('technician_profiles', function (Blueprint $table): void {
            $table->text('ktp_number')->nullable()->change();
        });

        DB::table('technician_profiles')
            ->whereNotNull('ktp_number')
            ->select(['id', 'ktp_number'])
            ->orderBy('id')
            ->each(function (object $profile): void {
                DB::table('technician_profiles')
                    ->where('id', $profile->id)
                    ->update(['ktp_number' => Crypt::encryptString($profile->ktp_number)]);
            });
    }

    public function down(): void
    {
        DB::table('technician_profiles')
            ->whereNotNull('ktp_number')
            ->select(['id', 'ktp_number'])
            ->orderBy('id')
            ->each(function (object $profile): void {
                DB::table('technician_profiles')
                    ->where('id', $profile->id)
                    ->update(['ktp_number' => Crypt::decryptString($profile->ktp_number)]);
            });

        Schema::table('technician_profiles', function (Blueprint $table): void {
            $table->string('ktp_number', 30)->nullable()->change();
        });
    }
};
