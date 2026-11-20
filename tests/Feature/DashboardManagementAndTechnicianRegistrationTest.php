<?php

namespace Tests\Feature;

use App\Models\Banner;
use App\Models\TechnicianProfile;
use App\Models\User;
use App\Models\Notification;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Storage;
use Tests\TestCase;

class DashboardManagementAndTechnicianRegistrationTest extends TestCase
{
    use RefreshDatabase;

    protected User $admin;
    protected User $customer;

    protected function setUp(): void
    {
        parent::setUp();

        Storage::fake('public');

        $this->admin = User::factory()->create([
            'role' => 'admin',
            'name' => 'Admin KlikKompor',
            'email' => 'admin@klikkompor.com',
            'is_active' => true,
        ]);

        $this->customer = User::factory()->create([
            'role' => 'customer',
            'name' => 'Customer Budi',
            'email' => 'customer@test.com',
            'is_active' => true,
        ]);
    }

    /*
    |--------------------------------------------------------------------------
    | BAGIAN A: PENGELOLAAN DASHBOARD & BANNER OLEH ADMIN
    |--------------------------------------------------------------------------
    */

    public function test_admin_can_add_banner_with_image_upload()
    {
        $file = UploadedFile::fake()->image('promo_banner.jpg', 800, 400);

        $response = $this->actingAs($this->admin, 'sanctum')
            ->postJson('/api/v1/admin/banners', [
                'title' => 'Promo Diskon Servis 20%',
                'description' => 'Servis kompor gas hemat awal bulan',
                'badge_text' => 'PROMO',
                'sort_order' => 1,
                'image' => $file,
            ]);

        $response->assertStatus(201);
        $bannerId = $response->json('data.id');

        $this->assertDatabaseHas('banners', [
            'id' => $bannerId,
            'title' => 'Promo Diskon Servis 20%',
            'badge_text' => 'PROMO',
            'is_active' => true,
        ]);

        $banner = Banner::find($bannerId);
        $this->assertNotNull($banner->image_url);

        // Verify file stored in public disk
        $relative = str_replace('/storage/', '', $banner->image_url);
        Storage::disk('public')->assertExists($relative);
    }

    public function test_admin_can_edit_and_replace_banner_image()
    {
        $oldFile = UploadedFile::fake()->image('old_banner.jpg', 800, 400);
        $oldPath = $oldFile->store('banners', 'public');

        $banner = Banner::create([
            'title' => 'Banner Lama',
            'description' => 'Deskripsi lama',
            'image_url' => '/storage/'.$oldPath,
            'is_active' => true,
            'sort_order' => 0,
        ]);

        Storage::disk('public')->assertExists($oldPath);

        $newFile = UploadedFile::fake()->image('new_banner.webp', 800, 400);

        $response = $this->actingAs($this->admin, 'sanctum')
            ->putJson("/api/v1/admin/banners/{$banner->id}", [
                'title' => 'Banner Baru Terupdate',
                'description' => 'Deskripsi baru',
                'sort_order' => 5,
                'image' => $newFile,
            ]);

        $response->assertOk();

        $banner->refresh();
        $this->assertEquals('Banner Baru Terupdate', $banner->title);
        $this->assertEquals(5, $banner->sort_order);

        // Old file deleted, new file exists
        Storage::disk('public')->assertMissing($oldPath);
        $newRelative = str_replace('/storage/', '', $banner->image_url);
        Storage::disk('public')->assertExists($newRelative);
    }

    public function test_admin_can_toggle_banner_active_status()
    {
        $banner = Banner::create([
            'title' => 'Banner Info',
            'image_url' => '/storage/banners/sample.jpg',
            'is_active' => true,
        ]);

        $response = $this->actingAs($this->admin, 'sanctum')
            ->patchJson("/api/v1/admin/banners/{$banner->id}/toggle-active");

        $response->assertOk();
        $this->assertFalse($banner->fresh()->is_active);

        // Toggle back to active
        $this->actingAs($this->admin, 'sanctum')
            ->patchJson("/api/v1/admin/banners/{$banner->id}/toggle-active");
        $this->assertTrue($banner->fresh()->is_active);
    }

    public function test_admin_can_delete_banner_and_file_is_safely_removed()
    {
        $file = UploadedFile::fake()->image('to_delete.png');
        $path = $file->store('banners', 'public');

        $banner = Banner::create([
            'title' => 'Banner Akan Dihapus',
            'image_url' => '/storage/'.$path,
            'is_active' => true,
        ]);

        Storage::disk('public')->assertExists($path);

        $response = $this->actingAs($this->admin, 'sanctum')
            ->deleteJson("/api/v1/admin/banners/{$banner->id}");

        $response->assertOk();
        $this->assertDatabaseMissing('banners', ['id' => $banner->id]);
        Storage::disk('public')->assertMissing($path);
    }

    public function test_public_dashboard_endpoint_only_returns_active_banners()
    {
        // Active banner
        Banner::create([
            'title' => 'Banner Aktif 1',
            'image_url' => '/storage/banners/active1.jpg',
            'is_active' => true,
            'sort_order' => 1,
        ]);

        // Inactive banner
        Banner::create([
            'title' => 'Banner Nonaktif',
            'image_url' => '/storage/banners/inactive.jpg',
            'is_active' => false,
            'sort_order' => 2,
        ]);

        $response = $this->getJson('/api/v1/dashboard/banners');
        $response->assertOk();

        $data = $response->json('data');
        $this->assertCount(1, $data);
        $this->assertEquals('Banner Aktif 1', $data[0]['title']);
    }

    public function test_non_admin_cannot_manage_banners()
    {
        $response = $this->actingAs($this->customer, 'sanctum')
            ->postJson('/api/v1/admin/banners', [
                'title' => 'Banner Ilegal',
                'image' => UploadedFile::fake()->image('illegal.jpg'),
            ]);

        $response->assertStatus(403);
    }

    /*
    |--------------------------------------------------------------------------
    | BAGIAN B: PENDAFTARAN & PERSETUJUAN AKUN TEKNISI
    |--------------------------------------------------------------------------
    */

    public function test_prospective_technician_can_register_and_starts_as_pending()
    {
        $cert = UploadedFile::fake()->create('sertifikat.pdf', 500, 'application/pdf');
        $ktpPhoto = UploadedFile::fake()->image('ktp.jpg');
        $lamaran = UploadedFile::fake()->create('lamaran.pdf', 400, 'application/pdf');

        $payload = [
            'name' => 'Doni Teknisi',
            'email' => 'doni.tech@example.com',
            'phone' => '081299887766',
            'password' => 'password123',
            'password_confirmation' => 'password123',
            'role' => 'technician',
            'address' => 'Jl. Merdeka No. 45',
            'bio' => 'Spesialis perbaikan kompor gas kaca & tanam',
            'years_of_experience' => 4,
            'skills' => ['Kompor Gas Standar', 'Kompor Tanam', 'Kalibrasi Spuyer'],
            'ktp_number' => '3201123456780001',
            'certificate' => $cert,
            'ktp_photo' => $ktpPhoto,
            'application_letter' => $lamaran,
        ];

        $response = $this->postJson('/api/v1/auth/register', $payload);
        $response->assertStatus(201);

        $user = User::where('email', 'doni.tech@example.com')->first();
        $this->assertNotNull($user);
        $this->assertEquals('technician', $user->role);
        $this->assertTrue(Hash::check('password123', $user->password));

        $profile = $user->technicianProfile;
        $this->assertNotNull($profile);
        $this->assertEquals('pending', $profile->status);
        $this->assertFalse($profile->is_verified);
        $this->assertFalse($profile->is_available);
        $this->assertNotNull($profile->certificate_url);
        $this->assertNotNull($profile->ktp_photo_url);
        $this->assertNotNull($profile->application_letter_url);
    }

    public function test_user_cannot_register_as_admin()
    {
        $payload = [
            'name' => 'Hacker Admin',
            'email' => 'hacker@example.com',
            'phone' => '089999999999',
            'password' => 'password123',
            'password_confirmation' => 'password123',
            'role' => 'admin',
        ];

        $response = $this->postJson('/api/v1/auth/register', $payload);
        $response->assertStatus(422);
    }

    public function test_pending_technician_is_forbidden_from_technician_features()
    {
        $techUser = User::factory()->create([
            'role' => 'technician',
            'email' => 'pending.tech@example.com',
            'is_active' => true,
        ]);

        TechnicianProfile::create([
            'user_id' => $techUser->id,
            'status' => 'pending',
            'is_verified' => false,
            'is_available' => false,
        ]);

        // Attempting to access technician-protected endpoint
        $response = $this->actingAs($techUser, 'sanctum')
            ->patchJson('/api/v1/technician/availability', ['is_available' => true]);

        $response->assertStatus(403);
        $this->assertEquals('pending', $response->json('registration_status'));
    }

    public function test_admin_can_approve_technician_registration()
    {
        $techUser = User::factory()->create([
            'role' => 'technician',
            'name' => 'Fajar Teknisi',
            'email' => 'fajar@example.com',
            'is_active' => true,
        ]);

        $profile = TechnicianProfile::create([
            'user_id' => $techUser->id,
            'status' => 'pending',
            'is_verified' => false,
            'is_available' => false,
        ]);

        $response = $this->actingAs($this->admin, 'sanctum')
            ->postJson("/api/v1/admin/technicians/{$techUser->id}/approve");

        $response->assertOk();

        $profile->refresh();
        $this->assertEquals('approved', $profile->status);
        $this->assertTrue($profile->is_verified);
        $this->assertTrue($profile->is_available);
        $this->assertNotNull($profile->verified_at);
        $this->assertEquals($this->admin->id, $profile->verified_by);

        // Notification created for technician
        $this->assertDatabaseHas('notifications', [
            'user_id' => $techUser->id,
            'type' => 'account_approved',
        ]);

        // Approved technician can now access technician endpoints
        $accessResponse = $this->actingAs($techUser, 'sanctum')
            ->patchJson('/api/v1/technician/availability', ['is_available' => true]);

        $accessResponse->assertOk();
    }

    public function test_approval_is_idempotent_and_prevents_duplicate_accounts()
    {
        $techUser = User::factory()->create([
            'role' => 'technician',
            'name' => 'Idem Teknisi',
            'email' => 'idem@example.com',
            'is_active' => true,
        ]);

        TechnicianProfile::create([
            'user_id' => $techUser->id,
            'status' => 'approved',
            'is_verified' => true,
            'is_available' => true,
        ]);

        // Approve again
        $response = $this->actingAs($this->admin, 'sanctum')
            ->postJson("/api/v1/admin/technicians/{$techUser->id}/approve");

        $response->assertOk();
        $this->assertStringContainsString('sudah disetujui sebelumnya', $response->json('message'));
        $this->assertEquals(1, User::where('email', 'idem@example.com')->count());
    }

    public function test_admin_can_reject_technician_registration_with_reason()
    {
        $techUser = User::factory()->create([
            'role' => 'technician',
            'name' => 'Gagal Teknisi',
            'email' => 'gagal@example.com',
            'is_active' => true,
        ]);

        $profile = TechnicianProfile::create([
            'user_id' => $techUser->id,
            'status' => 'pending',
            'is_verified' => false,
            'is_available' => false,
        ]);

        $response = $this->actingAs($this->admin, 'sanctum')
            ->postJson("/api/v1/admin/technicians/{$techUser->id}/reject", [
                'rejection_reason' => 'Nomor KTP tidak sesuai dengan berkas kartu identitas yang dilampirkan.',
            ]);

        $response->assertOk();

        $profile->refresh();
        $this->assertEquals('rejected', $profile->status);
        $this->assertFalse($profile->is_verified);
        $this->assertStringContainsString('Nomor KTP', $profile->rejection_reason);

        // Notification created with rejection reason
        $this->assertDatabaseHas('notifications', [
            'user_id' => $techUser->id,
            'type' => 'account_rejected',
        ]);

        // Login fails with rejection message
        $loginResponse = $this->postJson('/api/v1/auth/login', [
            'identifier' => 'gagal@example.com',
            'password' => 'password', // User factory default
        ]);

        $loginResponse->assertStatus(403);
        $this->assertStringContainsString('Pendaftaran teknisi ditolak', $loginResponse->json('message'));
    }
}
