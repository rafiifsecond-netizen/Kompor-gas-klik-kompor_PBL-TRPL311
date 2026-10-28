<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\DB;
use RuntimeException;
use Tests\TestCase;

class SecurityTransactionTest extends TestCase
{
    use RefreshDatabase;

    public function test_database_transaction_rolls_back_all_writes_after_failure(): void
    {
        $this->expectException(RuntimeException::class);

        try {
            DB::transaction(function (): void {
                User::factory()->create();
                throw new RuntimeException('forced rollback for security test');
            });
        } finally {
            $this->assertDatabaseCount('users', 0);
        }
    }

    public function test_database_transaction_commits_all_writes_on_success(): void
    {
        DB::transaction(function (): void {
            User::factory()->create();
        });

        $this->assertDatabaseCount('users', 1);
    }
}
