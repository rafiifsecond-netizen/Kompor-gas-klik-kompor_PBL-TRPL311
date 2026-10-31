-- MySQL dump 10.13  Distrib 8.0.41, for Win64 (x86_64)
--
-- Host: localhost    Database: klikkompor_db
-- ------------------------------------------------------
-- Server version	8.0.41

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `activity_logs`
--

DROP TABLE IF EXISTS `activity_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `activity_logs` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `actor_id` bigint unsigned DEFAULT NULL,
  `actor_role` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'system',
  `event_name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `entity_type` varchar(60) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `entity_id` bigint unsigned DEFAULT NULL,
  `ip_address` varchar(45) COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_agent` text COLLATE utf8mb4_unicode_ci,
  `platform` varchar(30) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'api',
  `old_values` json DEFAULT NULL,
  `new_values` json DEFAULT NULL,
  `status` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'success',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `activity_logs_actor_id_foreign` (`actor_id`),
  KEY `activity_logs_actor_role_index` (`actor_role`),
  KEY `activity_logs_event_name_index` (`event_name`),
  KEY `activity_logs_entity_type_index` (`entity_type`),
  KEY `activity_logs_entity_id_index` (`entity_id`),
  KEY `activity_logs_created_at_index` (`created_at`),
  CONSTRAINT `activity_logs_actor_id_foreign` FOREIGN KEY (`actor_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=124 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `activity_logs`
--

LOCK TABLES `activity_logs` WRITE;
/*!40000 ALTER TABLE `activity_logs` DISABLE KEYS */;
INSERT INTO `activity_logs` VALUES (1,1,'admin','user.account.created','Inisialisasi akun Super Admin sistem','User',1,'127.0.0.1','Symfony','api',NULL,NULL,'success','2026-10-19 05:24:55'),(2,4,'customer','auth.login.success','Login berhasil sebagai customer','User',4,'127.0.0.1','Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1','api',NULL,NULL,'success','2026-10-19 05:54:39'),(3,4,'customer','auth.login.success','Login berhasil sebagai customer','User',4,'127.0.0.1','Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1','api',NULL,NULL,'success','2026-10-19 06:00:43'),(4,4,'customer','auth.login.success','Login berhasil sebagai customer','User',4,'127.0.0.1','Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1','api',NULL,NULL,'success','2026-10-19 06:02:04'),(5,4,'customer','auth.login.success','Login berhasil sebagai customer','User',4,'127.0.0.1','Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1','api',NULL,NULL,'success','2026-10-19 06:30:21'),(6,NULL,'system','auth.login.failed','Percobaan login gagal untuk identifier: dewi@example.com',NULL,NULL,'127.0.0.1','Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1','api',NULL,NULL,'failed','2026-10-24 07:14:52'),(7,NULL,'system','auth.login.failed','Percobaan login gagal untuk identifier: dewi@example.com',NULL,NULL,'127.0.0.1','Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1','api',NULL,NULL,'failed','2026-10-24 07:15:03'),(8,4,'customer','auth.login.success','Login berhasil sebagai customer','User',4,'127.0.0.1','Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1','api',NULL,NULL,'success','2026-10-24 07:15:19'),(9,2,'technician','auth.login.success','Login berhasil sebagai technician','User',2,'127.0.0.1','Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1','api',NULL,NULL,'success','2026-10-24 07:49:06'),(10,NULL,'system','auth.login.failed','Percobaan login gagal untuk identifier: dewi@example.com',NULL,NULL,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36','api',NULL,NULL,'failed','2026-10-26 05:14:25'),(11,4,'customer','auth.login.success','Login berhasil sebagai customer','User',4,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36','api',NULL,NULL,'success','2026-10-26 05:14:45'),(12,4,'customer','auth.login.success','Login berhasil sebagai customer','User',4,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36','api',NULL,NULL,'success','2026-10-26 06:34:00'),(13,4,'customer','order.created','Pelanggan membuat pesanan baru: KP-20261026-V6KP7','Order',3,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36','api',NULL,'{\"id\": 3, \"status\": \"pending\", \"address\": \"Jl. Raplesia No. 10, Kel. Patriot Kec. Lubuk Baja, Kepulauan Riau\", \"discount\": \"0.00\", \"latitude\": null, \"subtotal\": \"75000.00\", \"longitude\": null, \"created_at\": \"2026-10-26T13:34:26.000000Z\", \"stove_type\": null, \"updated_at\": \"2026-10-26T13:34:26.000000Z\", \"customer_id\": 4, \"stove_brand\": null, \"order_number\": \"KP-20261026-V6KP7\", \"scheduled_at\": \"2026-10-27T20:34:25.000000Z\", \"total_amount\": \"90000.00\", \"customer_name\": \"Dewi Lestari\", \"technician_id\": null, \"transport_fee\": \"15000.00\", \"customer_phone\": \"087812345678\", \"payment_method\": \"qris\", \"payment_status\": \"unpaid\", \"problem_description\": \"Pemantik Api Tidak Berfungsi\"}','success','2026-10-26 06:34:26'),(14,2,'technician','auth.login.success','Login berhasil sebagai technician','User',2,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36','api',NULL,NULL,'success','2026-10-26 06:35:22'),(15,2,'technician','auth.login.success','Login berhasil sebagai technician','User',2,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36','api',NULL,NULL,'success','2026-10-26 06:37:45'),(16,4,'customer','auth.login.success','Login berhasil sebagai customer','User',4,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36','api',NULL,NULL,'success','2026-10-26 06:38:26'),(17,4,'customer','auth.login.success','Login berhasil sebagai customer','User',4,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36','api',NULL,NULL,'success','2026-10-26 06:42:00'),(18,2,'technician','auth.login.success','Login berhasil sebagai technician','User',2,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36','api',NULL,NULL,'success','2026-10-26 06:42:14'),(19,2,'technician','auth.login.success','Login berhasil sebagai technician','User',2,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36','api',NULL,NULL,'success','2026-10-26 06:46:37'),(20,4,'customer','auth.login.success','Login berhasil sebagai customer','User',4,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36','api',NULL,NULL,'success','2026-10-26 06:47:03'),(21,4,'customer','auth.login.success','Login berhasil sebagai customer','User',4,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36','api',NULL,NULL,'success','2026-10-26 06:47:54'),(22,2,'technician','auth.login.success','Login berhasil sebagai technician','User',2,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36','api',NULL,NULL,'success','2026-10-26 06:51:24'),(23,4,'customer','auth.login.success','Login berhasil sebagai customer','User',4,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36','api',NULL,NULL,'success','2026-10-26 06:51:42'),(24,4,'customer','auth.login.success','Login berhasil sebagai customer','User',4,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36','api',NULL,NULL,'success','2026-10-26 06:57:00'),(25,NULL,'system','auth.login.failed','Percobaan login gagal untuk identifier: agus.teknisi@klikkompor.com',NULL,NULL,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36','api',NULL,NULL,'failed','2026-10-26 06:58:45'),(26,2,'technician','auth.login.success','Login berhasil sebagai technician','User',2,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36','api',NULL,NULL,'success','2026-10-26 06:58:55'),(27,2,'technician','auth.login.success','Login berhasil sebagai technician','User',2,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36','api',NULL,NULL,'success','2026-10-26 07:03:21'),(28,4,'customer','auth.login.success','Login berhasil sebagai customer','User',4,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36','api',NULL,NULL,'success','2026-10-26 07:03:42'),(29,4,'customer','auth.login.success','Login berhasil sebagai customer','User',4,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36','api',NULL,NULL,'success','2026-10-26 07:05:08'),(30,4,'customer','auth.login.success','Login berhasil sebagai customer','User',4,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36','api',NULL,NULL,'success','2026-10-26 07:09:56'),(31,2,'technician','auth.login.success','Login berhasil sebagai technician','User',2,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36','api',NULL,NULL,'success','2026-10-26 07:10:37'),(32,2,'technician','order.status_transition','Perubahan status pesanan KP-20261026-V6KP7 dari pending ke on_the_way','Order',3,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36','api','{\"status\": \"pending\"}','{\"status\": \"on_the_way\"}','success','2026-10-26 07:10:49'),(33,2,'technician','order.status_transition','Perubahan status pesanan KP-20261026-V6KP7 dari on_the_way ke in_progress','Order',3,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36','api','{\"status\": \"on_the_way\"}','{\"status\": \"in_progress\"}','success','2026-10-26 07:11:02'),(34,2,'technician','order.status_transition','Perubahan status pesanan KP-20261026-V6KP7 dari in_progress ke completed','Order',3,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36','api','{\"status\": \"in_progress\"}','{\"status\": \"completed\"}','success','2026-10-26 07:12:26'),(35,4,'customer','auth.login.success','Login berhasil sebagai customer','User',4,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36','api',NULL,NULL,'success','2026-10-26 07:18:33'),(36,4,'customer','order.created','Pelanggan membuat pesanan baru: KP-20261026-GLBEV','Order',4,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36','api',NULL,'{\"id\": 4, \"status\": \"pending\", \"address\": \"Jl. Raplesia No. 10, Kel. Patriot Kec. Lubuk Baja, Kepulauan Riau\", \"discount\": \"0.00\", \"latitude\": null, \"subtotal\": \"75000.00\", \"longitude\": null, \"created_at\": \"2026-10-26T14:18:57.000000Z\", \"stove_type\": null, \"updated_at\": \"2026-10-26T14:18:57.000000Z\", \"customer_id\": 4, \"stove_brand\": null, \"order_number\": \"KP-20261026-GLBEV\", \"scheduled_at\": \"2026-10-27T21:18:56.000000Z\", \"total_amount\": \"90000.00\", \"customer_name\": \"Dewi Lestari\", \"technician_id\": null, \"transport_fee\": \"15000.00\", \"customer_phone\": \"087812345678\", \"payment_method\": \"qris\", \"payment_status\": \"unpaid\", \"problem_description\": \"Kebocoran Gas / Bau Gas Menyengat\"}','success','2026-10-26 07:18:57'),(37,4,'customer','auth.login.success','Login berhasil sebagai customer','User',4,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36','api',NULL,NULL,'success','2026-10-26 07:24:45'),(38,4,'customer','auth.login.success','Login berhasil sebagai customer','User',4,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36','api',NULL,NULL,'success','2026-10-26 07:25:37'),(39,2,'technician','auth.login.success','Login berhasil sebagai technician','User',2,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36','api',NULL,NULL,'success','2026-10-26 07:25:58'),(40,2,'technician','order.technician_responded','Teknisi Agus Priyanto menerima pesanan KP-20261026-GLBEV','Order',4,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36','api',NULL,NULL,'success','2026-10-26 07:26:17'),(41,2,'technician','order.status_transition','Perubahan status pesanan KP-20261026-GLBEV dari pending ke accepted','Order',4,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36','api','{\"status\": \"pending\"}','{\"status\": \"accepted\"}','success','2026-10-26 07:26:17'),(42,2,'technician','order.status_transition','Perubahan status pesanan KP-20261026-GLBEV dari accepted ke in_progress','Order',4,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36','api','{\"status\": \"accepted\"}','{\"status\": \"in_progress\"}','success','2026-10-26 07:26:36'),(43,2,'technician','order.status_transition','Perubahan status pesanan KP-20261026-GLBEV dari in_progress ke completed','Order',4,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36','api','{\"status\": \"in_progress\"}','{\"status\": \"completed\"}','success','2026-10-26 07:26:51'),(44,4,'customer','auth.login.success','Login berhasil sebagai customer','User',4,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36','api',NULL,NULL,'success','2026-10-26 07:29:27'),(45,2,'technician','auth.login.success','Login berhasil sebagai technician','User',2,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36','api',NULL,NULL,'success','2026-10-26 07:30:10'),(46,4,'customer','order.created','Pelanggan membuat pesanan baru: KP-20261026-7QVKM','Order',5,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36','api',NULL,'{\"id\": 5, \"status\": \"pending\", \"address\": \"Jl. Raplesia No. 10, Kel. Patriot Kec. Lubuk Baja, Kepulauan Riau\", \"discount\": \"0.00\", \"latitude\": null, \"subtotal\": \"75000.00\", \"longitude\": null, \"created_at\": \"2026-10-26T14:30:57.000000Z\", \"stove_type\": null, \"updated_at\": \"2026-10-26T14:30:57.000000Z\", \"customer_id\": 4, \"stove_brand\": null, \"order_number\": \"KP-20261026-7QVKM\", \"scheduled_at\": \"2026-10-27T21:30:56.000000Z\", \"total_amount\": \"90000.00\", \"customer_name\": \"Dewi Lestari\", \"technician_id\": null, \"transport_fee\": \"15000.00\", \"customer_phone\": \"087812345678\", \"payment_method\": \"qris\", \"payment_status\": \"unpaid\", \"problem_description\": \"Pemantik Api Tidak Berfungsi\"}','success','2026-10-26 07:30:57'),(47,2,'technician','order.technician_responded','Teknisi Agus Priyanto menerima pesanan KP-20261026-7QVKM','Order',5,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36','api',NULL,NULL,'success','2026-10-26 07:31:09'),(48,2,'technician','order.status_transition','Perubahan status pesanan KP-20261026-7QVKM dari pending ke accepted','Order',5,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36','api','{\"status\": \"pending\"}','{\"status\": \"accepted\"}','success','2026-10-26 07:31:09'),(49,2,'technician','order.status_transition','Perubahan status pesanan KP-20261026-7QVKM dari accepted ke in_progress','Order',5,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36','api','{\"status\": \"accepted\"}','{\"status\": \"in_progress\"}','success','2026-10-26 07:31:40'),(50,2,'technician','order.status_transition','Perubahan status pesanan KP-20261026-7QVKM dari in_progress ke in_progress','Order',5,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36','api','{\"status\": \"in_progress\"}','{\"status\": \"in_progress\"}','success','2026-10-26 07:31:53'),(51,2,'technician','auth.login.success','Login berhasil sebagai technician','User',2,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36','api',NULL,NULL,'success','2026-10-26 07:37:46'),(52,4,'customer','auth.login.success','Login berhasil sebagai customer','User',4,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36','api',NULL,NULL,'success','2026-10-26 07:37:48'),(53,4,'customer','order.created','Pelanggan membuat pesanan baru: KP-20261026-4QN9C','Order',6,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36','api',NULL,'{\"id\": 6, \"status\": \"pending\", \"address\": \"Jl. Raplesia No. 10, Kel. Patriot Kec. Lubuk Baja, Kepulauan Riau\", \"discount\": \"0.00\", \"latitude\": null, \"subtotal\": \"75000.00\", \"longitude\": null, \"created_at\": \"2026-10-26T14:38:20.000000Z\", \"stove_type\": null, \"updated_at\": \"2026-10-26T14:38:20.000000Z\", \"customer_id\": 4, \"stove_brand\": null, \"order_number\": \"KP-20261026-4QN9C\", \"scheduled_at\": \"2026-10-27T21:38:19.000000Z\", \"total_amount\": \"90000.00\", \"customer_name\": \"Dewi Lestari\", \"technician_id\": null, \"transport_fee\": \"15000.00\", \"customer_phone\": \"087812345678\", \"payment_method\": \"cash\", \"payment_status\": \"unpaid\", \"problem_description\": \"Pemantik Api Tidak Berfungsi\"}','success','2026-10-26 07:38:20'),(54,2,'technician','order.status_transition','Perubahan status pesanan KP-20261026-4QN9C dari pending ke in_progress','Order',6,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36','api','{\"status\": \"pending\"}','{\"status\": \"in_progress\"}','success','2026-10-26 07:38:39'),(55,2,'technician','auth.login.success','Login berhasil sebagai technician','User',2,'127.0.0.1','Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1','api',NULL,NULL,'success','2026-10-26 07:53:59'),(56,2,'technician','order.status_transition','Perubahan status pesanan KP-20261026-4QN9C dari in_progress ke completed','Order',6,'127.0.0.1','Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1','api','{\"status\": \"in_progress\"}','{\"status\": \"completed\"}','success','2026-10-26 07:55:07'),(57,4,'customer','auth.login.success','Login berhasil sebagai customer','User',4,'127.0.0.1','Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1','api',NULL,NULL,'success','2026-10-26 07:56:01'),(58,4,'customer','auth.login.success','Login berhasil sebagai customer','User',4,'127.0.0.1','Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1','api',NULL,NULL,'success','2026-10-26 07:56:33'),(59,4,'customer','auth.logout','User logout dari sesi','User',4,'127.0.0.1','Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1','api',NULL,NULL,'success','2026-10-26 07:57:35'),(60,4,'customer','auth.login.success','Login berhasil sebagai customer','User',4,'127.0.0.1','Mozilla/5.0 (Linux; Android 16; Pixel 10) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Mobile Safari/537.36','api',NULL,NULL,'success','2026-10-26 08:01:22'),(61,2,'technician','auth.login.success','Login berhasil sebagai technician','User',2,'127.0.0.1','Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1','api',NULL,NULL,'success','2026-10-26 09:29:23'),(62,4,'customer','auth.login.success','Login berhasil sebagai customer','User',4,'127.0.0.1','Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1','api',NULL,NULL,'success','2026-10-26 09:31:19'),(63,4,'customer','auth.login.success','Login berhasil sebagai customer','User',4,'127.0.0.1','Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1','api',NULL,NULL,'success','2026-10-26 09:37:04'),(64,4,'customer','auth.login.success','Login berhasil sebagai customer','User',4,'127.0.0.1','Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1','api',NULL,NULL,'success','2026-10-26 09:42:09'),(65,NULL,'system','auth.password.forgot','Permintaan reset kata sandi diajukan','User',4,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36','api',NULL,NULL,'success','2026-10-26 10:13:41'),(66,2,'technician','auth.login.success','Login berhasil sebagai technician','User',2,'127.0.0.1','Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1','api',NULL,NULL,'success','2026-10-26 10:14:53'),(67,4,'customer','auth.login.success','Login berhasil sebagai customer','User',4,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36','api',NULL,NULL,'success','2026-10-26 10:16:07'),(68,2,'technician','auth.login.success','Login berhasil sebagai technician','User',2,'127.0.0.1','Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1','api',NULL,NULL,'success','2026-10-26 10:21:20'),(69,2,'technician','auth.login.success','Login berhasil sebagai technician','User',2,'127.0.0.1','Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1','api',NULL,NULL,'success','2026-10-26 10:35:27'),(70,2,'technician','auth.login.success','Login berhasil sebagai technician','User',2,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36','api',NULL,NULL,'success','2026-10-26 10:37:46'),(71,2,'technician','auth.login.success','Login berhasil sebagai technician','User',2,'127.0.0.1','Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1','api',NULL,NULL,'success','2026-10-26 10:42:12'),(72,2,'technician','auth.login.success','Login berhasil sebagai technician','User',2,'127.0.0.1','Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1','api',NULL,NULL,'success','2026-10-26 10:45:46'),(73,2,'technician','auth.login.success','Login berhasil sebagai technician','User',2,'127.0.0.1','Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1','api',NULL,NULL,'success','2026-10-26 10:52:18'),(74,2,'technician','auth.login.success','Login berhasil sebagai technician','User',2,'127.0.0.1','Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1','api',NULL,NULL,'success','2026-10-26 10:56:20'),(75,2,'technician','auth.login.success','Login berhasil sebagai technician','User',2,'127.0.0.1','Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1','api',NULL,NULL,'success','2026-10-26 11:00:55'),(76,2,'technician','auth.logout','User logout dari sesi','User',2,'127.0.0.1','Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1','api',NULL,NULL,'success','2026-10-26 11:01:09'),(77,2,'technician','auth.login.success','Login berhasil sebagai technician','User',2,'127.0.0.1','Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1','api',NULL,NULL,'success','2026-10-26 11:05:41'),(78,2,'technician','auth.login.success','Login berhasil sebagai technician','User',2,'127.0.0.1','Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1','api',NULL,NULL,'success','2026-10-26 11:09:39'),(79,2,'technician','auth.login.success','Login berhasil sebagai technician','User',2,'127.0.0.1','Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1','api',NULL,NULL,'success','2026-10-26 11:12:12'),(80,2,'technician','auth.login.success','Login berhasil sebagai technician','User',2,'127.0.0.1','Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1','api',NULL,NULL,'success','2026-10-26 11:15:40'),(81,2,'technician','auth.logout','User logout dari sesi','User',2,'127.0.0.1','Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1','api',NULL,NULL,'success','2026-10-26 11:15:53'),(82,2,'technician','auth.login.success','Login berhasil sebagai technician','User',2,'127.0.0.1','Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1','api',NULL,NULL,'success','2026-10-26 11:19:06'),(83,2,'technician','auth.logout','User logout dari sesi','User',2,'127.0.0.1','Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1','api',NULL,NULL,'success','2026-10-26 11:19:53'),(84,4,'customer','auth.login.success','Login berhasil sebagai customer','User',4,'127.0.0.1','Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1','api',NULL,NULL,'success','2026-10-26 11:20:11'),(85,4,'customer','auth.login.success','Login berhasil sebagai customer','User',4,'127.0.0.1','Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1','api',NULL,NULL,'success','2026-10-26 11:24:45'),(86,4,'customer','auth.login.success','Login berhasil sebagai customer','User',4,'127.0.0.1','Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1','api',NULL,NULL,'success','2026-10-26 11:28:30'),(87,4,'customer','auth.login.success','Login berhasil sebagai customer','User',4,'127.0.0.1','Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1','api',NULL,NULL,'success','2026-10-26 11:29:00'),(88,4,'customer','auth.login.success','Login berhasil sebagai customer','User',4,'127.0.0.1','Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1','api',NULL,NULL,'success','2026-10-26 11:30:58'),(89,4,'customer','auth.login.success','Login berhasil sebagai customer','User',4,'127.0.0.1','Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1','api',NULL,NULL,'success','2026-10-26 11:33:36'),(90,4,'customer','auth.login.success','Login berhasil sebagai customer','User',4,'127.0.0.1','Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1','api',NULL,NULL,'success','2026-10-26 11:34:14'),(91,2,'technician','auth.login.success','Login berhasil sebagai technician','User',2,'127.0.0.1','Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1','api',NULL,NULL,'success','2026-10-26 11:56:13'),(92,2,'technician','auth.logout','User logout dari sesi','User',2,'127.0.0.1','Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1','api',NULL,NULL,'success','2026-10-26 11:56:39'),(93,4,'customer','auth.login.success','Login berhasil sebagai customer','User',4,'127.0.0.1','Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1','api',NULL,NULL,'success','2026-10-26 11:56:51'),(94,4,'customer','auth.login.success','Login berhasil sebagai customer','User',4,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36','api',NULL,NULL,'success','2026-10-26 12:01:22'),(95,2,'technician','auth.login.success','Login berhasil sebagai technician','User',2,'127.0.0.1','Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1','api',NULL,NULL,'success','2026-10-26 12:05:28'),(96,2,'technician','auth.logout','User logout dari sesi','User',2,'127.0.0.1','Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1','api',NULL,NULL,'success','2026-10-26 12:05:36'),(97,4,'customer','auth.login.success','Login berhasil sebagai customer','User',4,'127.0.0.1','Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1','api',NULL,NULL,'success','2026-10-26 12:05:47'),(98,4,'customer','auth.login.success','Login berhasil sebagai customer','User',4,'127.0.0.1','Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1','api',NULL,NULL,'success','2026-10-26 12:09:15'),(99,4,'customer','auth.login.success','Login berhasil sebagai customer','User',4,'127.0.0.1','Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1','api',NULL,NULL,'success','2026-10-26 12:18:08'),(100,4,'customer','auth.login.success','Login berhasil sebagai customer','User',4,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36','api',NULL,NULL,'success','2026-10-26 12:24:15'),(101,4,'customer','auth.login.success','Login berhasil sebagai customer','User',4,'127.0.0.1','Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1','api',NULL,NULL,'success','2026-10-26 12:27:33'),(102,4,'customer','auth.login.success','Login berhasil sebagai customer','User',4,'127.0.0.1','Mozilla/5.0 (Linux; Android 16; Pixel 10) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Mobile Safari/537.36','api',NULL,NULL,'success','2026-10-26 12:30:40'),(103,4,'customer','auth.login.success','Login berhasil sebagai customer','User',4,'127.0.0.1','Mozilla/5.0 (Linux; Android 16; Pixel 10) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Mobile Safari/537.36','api',NULL,NULL,'success','2026-10-26 12:32:48'),(104,4,'customer','auth.login.success','Login berhasil sebagai customer','User',4,'127.0.0.1','Mozilla/5.0 (Linux; Android 16; Pixel 10) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Mobile Safari/537.36','api',NULL,NULL,'success','2026-10-26 12:34:48'),(105,4,'customer','auth.login.success','Login berhasil sebagai customer','User',4,'127.0.0.1','Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1','api',NULL,NULL,'success','2026-10-26 12:36:38'),(106,4,'customer','auth.login.success','Login berhasil sebagai customer','User',4,'127.0.0.1','Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1','api',NULL,NULL,'success','2026-10-26 12:39:27'),(107,4,'customer','order.created','Pelanggan membuat pesanan baru: KP-20261026-U3A6H','Order',7,'127.0.0.1','Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1','api',NULL,'{\"id\": 7, \"status\": \"pending\", \"address\": \"Ruko Batam Centre Blok A No. 8, Kel. Teluk Tering, Kec. Batam Kota, Kota Batam, Kepulauan Riau\", \"discount\": \"0.00\", \"latitude\": null, \"subtotal\": \"95000.00\", \"longitude\": null, \"created_at\": \"2026-10-26T19:39:57.000000Z\", \"stove_type\": null, \"updated_at\": \"2026-10-26T19:39:57.000000Z\", \"customer_id\": 4, \"stove_brand\": null, \"order_number\": \"KP-20261026-U3A6H\", \"scheduled_at\": \"2026-10-29T08:00:00.000000Z\", \"total_amount\": \"110000.00\", \"customer_name\": \"Dewi Lestari\", \"technician_id\": null, \"transport_fee\": \"15000.00\", \"customer_phone\": \"087812345678\", \"payment_method\": \"cash\", \"payment_status\": \"unpaid\", \"problem_description\": \"Pemantik tidak berfungsi: dll\"}','success','2026-10-26 12:39:57'),(108,2,'technician','auth.login.success','Login berhasil sebagai technician','User',2,'127.0.0.1','Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1','api',NULL,NULL,'success','2026-10-26 12:40:59'),(109,2,'technician','order.technician_responded','Teknisi Agus Priyanto menerima pesanan KP-20261026-U3A6H','Order',7,'127.0.0.1','Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1','api',NULL,NULL,'success','2026-10-26 12:41:14'),(110,2,'technician','order.status_transition','Perubahan status pesanan KP-20261026-U3A6H dari pending ke accepted','Order',7,'127.0.0.1','Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1','api','{\"status\": \"pending\"}','{\"status\": \"accepted\"}','success','2026-10-26 12:41:14'),(111,2,'technician','order.status_transition','Perubahan status pesanan KP-20261026-U3A6H dari accepted ke in_progress','Order',7,'127.0.0.1','Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1','api','{\"status\": \"accepted\"}','{\"status\": \"in_progress\"}','success','2026-10-26 12:41:46'),(112,2,'technician','order.status_transition','Perubahan status pesanan KP-20261026-U3A6H dari in_progress ke completed','Order',7,'127.0.0.1','Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1','api','{\"status\": \"in_progress\"}','{\"status\": \"completed\"}','success','2026-10-26 12:42:04'),(113,2,'technician','auth.login.success','Login berhasil sebagai technician','User',2,'127.0.0.1','Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1','api',NULL,NULL,'success','2026-10-26 12:44:46'),(114,1,'admin','auth.login.success','Admin login web berhasil','User',1,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36','web_admin',NULL,NULL,'success','2026-10-28 03:07:39'),(115,1,'admin','auth.login.success','Admin login web berhasil','User',1,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','web_admin',NULL,NULL,'success','2026-10-28 06:20:28'),(116,2,'technician','auth.login.success','Login berhasil sebagai technician','User',2,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','api',NULL,NULL,'success','2026-10-28 06:42:09'),(117,4,'customer','auth.login.success','Login berhasil sebagai customer','User',4,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','api',NULL,NULL,'success','2026-10-28 06:47:43'),(118,2,'technician','auth.login.success','Login berhasil sebagai technician','User',2,'127.0.0.1','Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1','api',NULL,NULL,'success','2026-10-28 12:00:02'),(119,2,'technician','auth.logout','User logout dari sesi','User',2,'127.0.0.1','Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1','api',NULL,NULL,'success','2026-10-28 12:01:03'),(120,4,'customer','auth.login.success','Login berhasil sebagai customer','User',4,'127.0.0.1','Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1','api',NULL,NULL,'success','2026-10-28 12:01:20'),(121,2,'technician','auth.login','User berhasil login ke sistem','User',2,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64)','api',NULL,NULL,'success','2026-10-28 21:33:13'),(122,NULL,'guest','auth.failed','Percobaan login gagal: email guest@test.com (password disanitasi)','User',NULL,'192.168.1.15','Mozilla/5.0 (Windows NT 10.0; Win64; x64)','api',NULL,'{\"email\": \"guest@test.com\", \"password\": \"[REDACTED]\"}','failed','2026-10-28 21:38:13'),(123,1,'admin','user.role_changed','Administrator mengubah peran akun pengguna','User',3,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64)','api','{\"role\": \"customer\"}','{\"role\": \"technician\"}','success','2026-10-28 21:48:13');
/*!40000 ALTER TABLE `activity_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `additional_costs`
--

DROP TABLE IF EXISTS `additional_costs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `additional_costs` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `order_id` bigint unsigned NOT NULL,
  `technician_id` bigint unsigned DEFAULT NULL,
  `item_name` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `quantity` int unsigned NOT NULL DEFAULT '1',
  `unit_price` decimal(12,2) NOT NULL,
  `subtotal` decimal(12,2) NOT NULL,
  `photo_url` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `additional_costs_order_id_foreign` (`order_id`),
  KEY `additional_costs_technician_id_foreign` (`technician_id`),
  KEY `additional_costs_status_index` (`status`),
  CONSTRAINT `additional_costs_order_id_foreign` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE,
  CONSTRAINT `additional_costs_technician_id_foreign` FOREIGN KEY (`technician_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `additional_costs`
--

LOCK TABLES `additional_costs` WRITE;
/*!40000 ALTER TABLE `additional_costs` DISABLE KEYS */;
/*!40000 ALTER TABLE `additional_costs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `addresses`
--

DROP TABLE IF EXISTS `addresses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `addresses` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint unsigned NOT NULL,
  `label` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Rumah',
  `recipient_name` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `phone` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `full_address` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `latitude` decimal(10,7) DEFAULT NULL,
  `longitude` decimal(10,7) DEFAULT NULL,
  `notes` text COLLATE utf8mb4_unicode_ci,
  `is_default` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `addresses_user_id_foreign` (`user_id`),
  KEY `addresses_is_default_index` (`is_default`),
  CONSTRAINT `addresses_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `addresses`
--

LOCK TABLES `addresses` WRITE;
/*!40000 ALTER TABLE `addresses` DISABLE KEYS */;
/*!40000 ALTER TABLE `addresses` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cache`
--

DROP TABLE IF EXISTS `cache`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cache` (
  `key` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `value` mediumtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `expiration` bigint NOT NULL,
  PRIMARY KEY (`key`),
  KEY `cache_expiration_index` (`expiration`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cache`
--

LOCK TABLES `cache` WRITE;
/*!40000 ALTER TABLE `cache` DISABLE KEYS */;
INSERT INTO `cache` VALUES ('laravel-cache-5c785c036466adea360111aa28563bfd556b5fba','i:1;',1793214140),('laravel-cache-5c785c036466adea360111aa28563bfd556b5fba:timer','i:1793214140;',1793214140);
/*!40000 ALTER TABLE `cache` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cache_locks`
--

DROP TABLE IF EXISTS `cache_locks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cache_locks` (
  `key` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `owner` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `expiration` bigint NOT NULL,
  PRIMARY KEY (`key`),
  KEY `cache_locks_expiration_index` (`expiration`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cache_locks`
--

LOCK TABLES `cache_locks` WRITE;
/*!40000 ALTER TABLE `cache_locks` DISABLE KEYS */;
/*!40000 ALTER TABLE `cache_locks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `chat_messages`
--

DROP TABLE IF EXISTS `chat_messages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `chat_messages` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `chat_id` bigint unsigned NOT NULL,
  `sender_id` bigint unsigned NOT NULL,
  `message` text COLLATE utf8mb4_unicode_ci,
  `message_type` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'text',
  `attachment_url` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `read_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `chat_messages_chat_id_foreign` (`chat_id`),
  KEY `chat_messages_sender_id_foreign` (`sender_id`),
  CONSTRAINT `chat_messages_chat_id_foreign` FOREIGN KEY (`chat_id`) REFERENCES `chats` (`id`) ON DELETE CASCADE,
  CONSTRAINT `chat_messages_sender_id_foreign` FOREIGN KEY (`sender_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `chat_messages`
--

LOCK TABLES `chat_messages` WRITE;
/*!40000 ALTER TABLE `chat_messages` DISABLE KEYS */;
INSERT INTO `chat_messages` VALUES (2,2,2,'halo','text',NULL,'2026-10-26 10:16:21','2026-10-26 10:15:14','2026-10-26 10:16:21'),(3,2,4,'halo','text',NULL,'2026-10-26 10:16:39','2026-10-26 10:16:27','2026-10-26 10:16:39');
/*!40000 ALTER TABLE `chat_messages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `chats`
--

DROP TABLE IF EXISTS `chats`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `chats` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `order_id` bigint unsigned NOT NULL,
  `customer_id` bigint unsigned NOT NULL,
  `technician_id` bigint unsigned NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `chats_order_id_unique` (`order_id`),
  KEY `chats_customer_id_foreign` (`customer_id`),
  KEY `chats_technician_id_foreign` (`technician_id`),
  CONSTRAINT `chats_customer_id_foreign` FOREIGN KEY (`customer_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `chats_order_id_foreign` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE,
  CONSTRAINT `chats_technician_id_foreign` FOREIGN KEY (`technician_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `chats`
--

LOCK TABLES `chats` WRITE;
/*!40000 ALTER TABLE `chats` DISABLE KEYS */;
INSERT INTO `chats` VALUES (1,3,4,2,'2026-10-26 07:10:48','2026-10-26 07:10:48'),(2,4,4,2,'2026-10-26 07:26:17','2026-10-26 07:26:17'),(5,7,4,2,'2026-10-26 12:41:14','2026-10-26 12:41:14');
/*!40000 ALTER TABLE `chats` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `failed_jobs`
--

DROP TABLE IF EXISTS `failed_jobs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `failed_jobs` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `uuid` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `connection` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `queue` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `payload` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `exception` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `failed_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `failed_jobs_uuid_unique` (`uuid`),
  KEY `failed_jobs_connection_queue_failed_at_index` (`connection`,`queue`,`failed_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `failed_jobs`
--

LOCK TABLES `failed_jobs` WRITE;
/*!40000 ALTER TABLE `failed_jobs` DISABLE KEYS */;
/*!40000 ALTER TABLE `failed_jobs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `job_batches`
--

DROP TABLE IF EXISTS `job_batches`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `job_batches` (
  `id` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `total_jobs` int NOT NULL,
  `pending_jobs` int NOT NULL,
  `failed_jobs` int NOT NULL,
  `failed_job_ids` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `options` mediumtext COLLATE utf8mb4_unicode_ci,
  `cancelled_at` int DEFAULT NULL,
  `created_at` int NOT NULL,
  `finished_at` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `job_batches`
--

LOCK TABLES `job_batches` WRITE;
/*!40000 ALTER TABLE `job_batches` DISABLE KEYS */;
/*!40000 ALTER TABLE `job_batches` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `jobs`
--

DROP TABLE IF EXISTS `jobs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `jobs` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `queue` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `payload` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `attempts` smallint unsigned NOT NULL,
  `reserved_at` int unsigned DEFAULT NULL,
  `available_at` int unsigned NOT NULL,
  `created_at` int unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `jobs_queue_index` (`queue`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `jobs`
--

LOCK TABLES `jobs` WRITE;
/*!40000 ALTER TABLE `jobs` DISABLE KEYS */;
/*!40000 ALTER TABLE `jobs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `migrations`
--

DROP TABLE IF EXISTS `migrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `migrations` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `migration` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `batch` int NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `migrations`
--

LOCK TABLES `migrations` WRITE;
/*!40000 ALTER TABLE `migrations` DISABLE KEYS */;
INSERT INTO `migrations` VALUES (1,'0001_01_01_000000_create_users_table',1),(2,'0001_01_01_000001_create_cache_table',1),(3,'0001_01_01_000002_create_jobs_table',1),(4,'2026_09_24_114810_create_personal_access_tokens_table',1),(5,'2026_09_24_115019_add_klikkompor_fields_to_users_table',1),(6,'2026_09_24_115020_create_technician_profiles_table',1),(7,'2026_09_24_115021_create_service_categories_and_items_table',1),(8,'2026_09_24_115022_create_orders_and_order_items_table',1),(9,'2026_09_24_115023_create_order_status_logs_table',1),(10,'2026_09_24_115024_create_payments_table',1),(11,'2026_09_24_115025_create_reviews_table',1),(12,'2026_09_24_115026_create_activity_logs_table',1),(13,'2026_10_01_161811_create_additional_costs_table',1),(14,'2026_10_01_161811_create_addresses_table',1),(15,'2026_10_01_161829_create_chats_table',1),(16,'2026_10_01_161838_create_chat_messages_table',1),(17,'2026_10_01_161936_create_notifications_table',1),(18,'2026_10_28_170000_encrypt_technician_ktp_number',2),(19,'2026_10_28_170001_create_security_views',2);
/*!40000 ALTER TABLE `migrations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `notifications`
--

DROP TABLE IF EXISTS `notifications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `notifications` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint unsigned NOT NULL,
  `type` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `title` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL,
  `message` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `data` json DEFAULT NULL,
  `read_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `notifications_user_id_foreign` (`user_id`),
  KEY `notifications_type_index` (`type`),
  CONSTRAINT `notifications_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notifications`
--

LOCK TABLES `notifications` WRITE;
/*!40000 ALTER TABLE `notifications` DISABLE KEYS */;
INSERT INTO `notifications` VALUES (1,4,'order_update','Teknisi Menuju Lokasi','Teknisi sedang dalam perjalanan menuju lokasi Anda untuk pesanan #KP-20261026-V6KP7.','{\"order_id\": 3}',NULL,'2026-10-26 07:10:48','2026-10-26 07:10:48'),(2,4,'order_update','Servis Sedang Dikerjakan','Teknisi mulai melakukan servis kompor gas untuk pesanan #KP-20261026-V6KP7.','{\"order_id\": 3}',NULL,'2026-10-26 07:11:02','2026-10-26 07:11:02'),(3,4,'order_update','Servis Telah Selesai','Servis untuk pesanan #KP-20261026-V6KP7 telah selesai. Silakan lakukan pembayaran dan berikan ulasan Anda.','{\"order_id\": 3}',NULL,'2026-10-26 07:12:26','2026-10-26 07:12:26'),(4,4,'order_update','Teknisi Menerima Pesanan','Teknisi Agus Priyanto telah menerima pesanan #KP-20261026-GLBEV.','{\"order_id\": 4}',NULL,'2026-10-26 07:26:17','2026-10-26 07:26:17'),(5,4,'order_update','Servis Sedang Dikerjakan','Teknisi mulai melakukan servis kompor gas untuk pesanan #KP-20261026-GLBEV.','{\"order_id\": 4}',NULL,'2026-10-26 07:26:36','2026-10-26 07:26:36'),(6,4,'order_update','Servis Telah Selesai','Servis untuk pesanan #KP-20261026-GLBEV telah selesai. Silakan lakukan pembayaran dan berikan ulasan Anda.','{\"order_id\": 4}',NULL,'2026-10-26 07:26:51','2026-10-26 07:26:51'),(7,4,'order_update','Teknisi Menerima Pesanan','Teknisi Agus Priyanto telah menerima pesanan #KP-20261026-7QVKM.','{\"order_id\": 5}',NULL,'2026-10-26 07:31:09','2026-10-26 07:31:09'),(8,4,'order_update','Servis Sedang Dikerjakan','Teknisi mulai melakukan servis kompor gas untuk pesanan #KP-20261026-7QVKM.','{\"order_id\": 5}',NULL,'2026-10-26 07:31:40','2026-10-26 07:31:40'),(9,4,'order_update','Servis Sedang Dikerjakan','Teknisi mulai melakukan servis kompor gas untuk pesanan #KP-20261026-7QVKM.','{\"order_id\": 5}',NULL,'2026-10-26 07:31:53','2026-10-26 07:31:53'),(10,4,'order_update','Servis Sedang Dikerjakan','Teknisi mulai melakukan servis kompor gas untuk pesanan #KP-20261026-4QN9C.','{\"order_id\": 6}',NULL,'2026-10-26 07:38:39','2026-10-26 07:38:39'),(11,4,'order_update','Servis Telah Selesai','Servis untuk pesanan #KP-20261026-4QN9C telah selesai. Silakan lakukan pembayaran dan berikan ulasan Anda.','{\"order_id\": 6}',NULL,'2026-10-26 07:55:07','2026-10-26 07:55:07'),(12,2,'chat','Pesan dari Dewi Lestari','halo','{\"chat_id\": 3, \"order_id\": 5, \"message_id\": 1}',NULL,'2026-10-26 07:57:02','2026-10-26 07:57:02'),(13,4,'chat','Pesan dari Agus Priyanto','halo','{\"chat_id\": 2, \"order_id\": 4, \"message_id\": 2}','2026-10-26 12:41:29','2026-10-26 10:15:14','2026-10-26 12:41:29'),(14,2,'chat','Pesan dari Dewi Lestari','halo','{\"chat_id\": 2, \"order_id\": 4, \"message_id\": 3}',NULL,'2026-10-26 10:16:27','2026-10-26 10:16:27'),(15,4,'order_update','Teknisi Menerima Pesanan','Teknisi Agus Priyanto telah menerima pesanan #KP-20261026-U3A6H.','{\"order_id\": 7}','2026-10-26 12:41:25','2026-10-26 12:41:14','2026-10-26 12:41:25'),(16,4,'order_update','Servis Sedang Dikerjakan','Teknisi mulai melakukan servis kompor gas untuk pesanan #KP-20261026-U3A6H.','{\"order_id\": 7}',NULL,'2026-10-26 12:41:46','2026-10-26 12:41:46'),(17,4,'order_update','Servis Telah Selesai','Servis untuk pesanan #KP-20261026-U3A6H telah selesai. Silakan lakukan pembayaran dan berikan ulasan Anda.','{\"order_id\": 7}',NULL,'2026-10-26 12:42:04','2026-10-26 12:42:04');
/*!40000 ALTER TABLE `notifications` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `order_items`
--

DROP TABLE IF EXISTS `order_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `order_items` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `order_id` bigint unsigned NOT NULL,
  `service_item_id` bigint unsigned DEFAULT NULL,
  `service_name` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `unit_price` decimal(12,2) NOT NULL DEFAULT '0.00',
  `quantity` int unsigned NOT NULL DEFAULT '1',
  `total_price` decimal(12,2) NOT NULL DEFAULT '0.00',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `order_items_order_id_foreign` (`order_id`),
  KEY `order_items_service_item_id_foreign` (`service_item_id`),
  CONSTRAINT `order_items_order_id_foreign` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE,
  CONSTRAINT `order_items_service_item_id_foreign` FOREIGN KEY (`service_item_id`) REFERENCES `service_items` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `order_items`
--

LOCK TABLES `order_items` WRITE;
/*!40000 ALTER TABLE `order_items` DISABLE KEYS */;
INSERT INTO `order_items` VALUES (1,1,3,'Servis Kompor Tanam (Api Merah / Mati)',135000.00,1,135000.00,'2026-10-19 05:24:56','2026-10-19 05:24:56'),(3,3,NULL,'Servis Ringan & Pembersihan Spuyer',75000.00,1,75000.00,'2026-10-26 06:34:26','2026-10-26 06:34:26'),(4,4,NULL,'Servis Ringan & Pembersihan Spuyer',75000.00,1,75000.00,'2026-10-26 07:18:57','2026-10-26 07:18:57'),(7,7,2,'Ganti Pemantik Elektrik / Mekanik',95000.00,1,95000.00,'2026-10-26 12:39:57','2026-10-26 12:39:57');
/*!40000 ALTER TABLE `order_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `order_status_logs`
--

DROP TABLE IF EXISTS `order_status_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `order_status_logs` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `order_id` bigint unsigned NOT NULL,
  `actor_id` bigint unsigned DEFAULT NULL,
  `actor_role` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'technician',
  `status_from` varchar(30) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status_to` varchar(30) COLLATE utf8mb4_unicode_ci NOT NULL,
  `note` text COLLATE utf8mb4_unicode_ci,
  `latitude` decimal(10,7) DEFAULT NULL,
  `longitude` decimal(10,7) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `order_status_logs_order_id_foreign` (`order_id`),
  KEY `order_status_logs_actor_id_foreign` (`actor_id`),
  CONSTRAINT `order_status_logs_actor_id_foreign` FOREIGN KEY (`actor_id`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `order_status_logs_order_id_foreign` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `order_status_logs`
--

LOCK TABLES `order_status_logs` WRITE;
/*!40000 ALTER TABLE `order_status_logs` DISABLE KEYS */;
INSERT INTO `order_status_logs` VALUES (1,3,4,'customer',NULL,'pending','Pesanan berhasil dibuat oleh pelanggan.',NULL,NULL,'2026-10-26 06:34:26','2026-10-26 06:34:26'),(2,3,2,'technician','pending','on_the_way',NULL,NULL,NULL,'2026-10-26 07:10:49','2026-10-26 07:10:49'),(3,3,2,'technician','on_the_way','in_progress',NULL,NULL,NULL,'2026-10-26 07:11:02','2026-10-26 07:11:02'),(4,3,2,'technician','in_progress','completed',NULL,NULL,NULL,'2026-10-26 07:12:26','2026-10-26 07:12:26'),(5,4,4,'customer',NULL,'pending','Pesanan berhasil dibuat oleh pelanggan.',NULL,NULL,'2026-10-26 07:18:57','2026-10-26 07:18:57'),(6,4,2,'technician','pending','accepted',NULL,NULL,NULL,'2026-10-26 07:26:17','2026-10-26 07:26:17'),(7,4,2,'technician','accepted','in_progress',NULL,NULL,NULL,'2026-10-26 07:26:36','2026-10-26 07:26:36'),(8,4,2,'technician','in_progress','completed',NULL,NULL,NULL,'2026-10-26 07:26:51','2026-10-26 07:26:51'),(16,7,4,'customer',NULL,'pending','Pesanan berhasil dibuat oleh pelanggan.',NULL,NULL,'2026-10-26 12:39:57','2026-10-26 12:39:57'),(17,7,2,'technician','pending','accepted',NULL,NULL,NULL,'2026-10-26 12:41:14','2026-10-26 12:41:14'),(18,7,2,'technician','accepted','in_progress',NULL,NULL,NULL,'2026-10-26 12:41:46','2026-10-26 12:41:46'),(19,7,2,'technician','in_progress','completed',NULL,NULL,NULL,'2026-10-26 12:42:04','2026-10-26 12:42:04');
/*!40000 ALTER TABLE `order_status_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `orders`
--

DROP TABLE IF EXISTS `orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `orders` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `order_number` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `customer_id` bigint unsigned NOT NULL,
  `technician_id` bigint unsigned DEFAULT NULL,
  `status` varchar(30) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `scheduled_at` datetime NOT NULL,
  `customer_name` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `customer_phone` varchar(30) COLLATE utf8mb4_unicode_ci NOT NULL,
  `address` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `latitude` decimal(10,7) DEFAULT NULL,
  `longitude` decimal(10,7) DEFAULT NULL,
  `stove_brand` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `stove_type` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `problem_description` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `subtotal` decimal(12,2) NOT NULL DEFAULT '0.00',
  `transport_fee` decimal(12,2) NOT NULL DEFAULT '0.00',
  `discount` decimal(12,2) NOT NULL DEFAULT '0.00',
  `total_amount` decimal(12,2) NOT NULL DEFAULT '0.00',
  `payment_method` varchar(30) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'cash',
  `payment_status` varchar(30) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'unpaid',
  `cancellation_reason` text COLLATE utf8mb4_unicode_ci,
  `cancelled_by` bigint unsigned DEFAULT NULL,
  `completed_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `orders_order_number_unique` (`order_number`),
  KEY `orders_customer_id_foreign` (`customer_id`),
  KEY `orders_technician_id_foreign` (`technician_id`),
  KEY `orders_cancelled_by_foreign` (`cancelled_by`),
  KEY `orders_status_index` (`status`),
  KEY `orders_payment_status_index` (`payment_status`),
  CONSTRAINT `orders_cancelled_by_foreign` FOREIGN KEY (`cancelled_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `orders_customer_id_foreign` FOREIGN KEY (`customer_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `orders_technician_id_foreign` FOREIGN KEY (`technician_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=1000 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `orders`
--

LOCK TABLES `orders` WRITE;
/*!40000 ALTER TABLE `orders` DISABLE KEYS */;
INSERT INTO `orders` VALUES (1,'KP-20261019-0001',4,2,'accepted','2026-10-18 10:00:00','Dewi Lestari','087812345678','Apartemen Kalibata City Tower Kemuning Lt. 8, Jakarta Selatan',-6.2570000,106.8540000,'Modena','Kompor Tanam 2 Tungku BH-1725','Api sebelah kanan menyala merah dan pemantiknya mati.',135000.00,20000.00,0.00,155000.00,'qris','paid',NULL,NULL,'2026-10-18 04:30:00','2026-10-19 05:24:56','2026-10-19 05:24:56'),(3,'KP-20261026-V6KP7',4,2,'completed','2026-10-27 20:34:25','Dewi Lestari','087812345678','Jl. Raplesia No. 10, Kel. Patriot Kec. Lubuk Baja, Kepulauan Riau',NULL,NULL,NULL,NULL,'Pemantik Api Tidak Berfungsi',75000.00,15000.00,0.00,90000.00,'qris','unpaid',NULL,NULL,'2026-10-26 07:12:26','2026-10-26 06:34:26','2026-10-26 07:12:26'),(4,'KP-20261026-GLBEV',4,2,'completed','2026-10-27 21:18:56','Dewi Lestari','087812345678','Jl. Raplesia No. 10, Kel. Patriot Kec. Lubuk Baja, Kepulauan Riau',NULL,NULL,NULL,NULL,'Kebocoran Gas / Bau Gas Menyengat',75000.00,15000.00,0.00,90000.00,'qris','unpaid',NULL,NULL,'2026-10-26 07:26:51','2026-10-26 07:18:57','2026-10-26 07:26:51'),(7,'KP-20261026-U3A6H',4,2,'completed','2026-10-29 08:00:00','Dewi Lestari','087812345678','Ruko Batam Centre Blok A No. 8, Kel. Teluk Tering, Kec. Batam Kota, Kota Batam, Kepulauan Riau',NULL,NULL,NULL,NULL,'Pemantik tidak berfungsi: dll',95000.00,15000.00,0.00,110000.00,'cash','unpaid',NULL,NULL,'2026-10-26 12:42:04','2026-10-26 12:39:57','2026-10-26 12:42:04');
/*!40000 ALTER TABLE `orders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `password_reset_tokens`
--

DROP TABLE IF EXISTS `password_reset_tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `password_reset_tokens` (
  `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `token` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `password_reset_tokens`
--

LOCK TABLES `password_reset_tokens` WRITE;
/*!40000 ALTER TABLE `password_reset_tokens` DISABLE KEYS */;
INSERT INTO `password_reset_tokens` VALUES ('dewi@example.com','$2y$12$fTtmJeZ.WiO9sC3F7bw.wObuHMUy20h0V6K4r6IO41QQLSbPreGjm','2026-10-26 10:13:41');
/*!40000 ALTER TABLE `password_reset_tokens` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `payments`
--

DROP TABLE IF EXISTS `payments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `payments` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `order_id` bigint unsigned NOT NULL,
  `customer_id` bigint unsigned NOT NULL,
  `payment_number` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `payment_method` varchar(30) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'cash',
  `amount` decimal(12,2) NOT NULL,
  `payment_status` varchar(30) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `paid_at` timestamp NULL DEFAULT NULL,
  `proof_url` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `transaction_reference` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `payload` json DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `payments_payment_number_unique` (`payment_number`),
  KEY `payments_order_id_foreign` (`order_id`),
  KEY `payments_customer_id_foreign` (`customer_id`),
  KEY `payments_payment_status_index` (`payment_status`),
  CONSTRAINT `payments_customer_id_foreign` FOREIGN KEY (`customer_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `payments_order_id_foreign` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `payments`
--

LOCK TABLES `payments` WRITE;
/*!40000 ALTER TABLE `payments` DISABLE KEYS */;
INSERT INTO `payments` VALUES (1,1,4,'PAY-20261019-0001','qris',155000.00,'paid','2026-10-18 04:35:00',NULL,'QRIS-MgR3LAi3iIMm',NULL,'2026-10-19 05:24:56','2026-10-19 05:24:56');
/*!40000 ALTER TABLE `payments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `personal_access_tokens`
--

DROP TABLE IF EXISTS `personal_access_tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `personal_access_tokens` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `tokenable_type` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tokenable_id` bigint unsigned NOT NULL,
  `name` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `token` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `abilities` text COLLATE utf8mb4_unicode_ci,
  `last_used_at` timestamp NULL DEFAULT NULL,
  `expires_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `personal_access_tokens_token_unique` (`token`),
  KEY `personal_access_tokens_tokenable_type_tokenable_id_index` (`tokenable_type`,`tokenable_id`),
  KEY `personal_access_tokens_expires_at_index` (`expires_at`)
) ENGINE=InnoDB AUTO_INCREMENT=84 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `personal_access_tokens`
--

LOCK TABLES `personal_access_tokens` WRITE;
/*!40000 ALTER TABLE `personal_access_tokens` DISABLE KEYS */;
INSERT INTO `personal_access_tokens` VALUES (1,'App\\Models\\User',4,'auth_token','97f8a3ae113e08ee38c75bdf96b925fbbe753e42de40b7f0d4a1602cd67a1533','[\"*\"]',NULL,NULL,'2026-10-19 05:54:39','2026-10-19 05:54:39'),(2,'App\\Models\\User',4,'auth_token','8d4c09750ad027623253655136d9ac6b8342fec163a72b3a1b31f9a6c877c54f','[\"*\"]',NULL,NULL,'2026-10-19 06:00:43','2026-10-19 06:00:43'),(3,'App\\Models\\User',4,'auth_token','97c5c6476954e280c14fc9d7ee4726c9955c9baaaa7cfee4986c6e6f2b6c7956','[\"*\"]',NULL,NULL,'2026-10-19 06:02:04','2026-10-19 06:02:04'),(4,'App\\Models\\User',4,'auth_token','1580568d990ba7f708204feba349b51ed35420befa6dcfe2a0a97fe31337480a','[\"*\"]',NULL,NULL,'2026-10-19 06:30:21','2026-10-19 06:30:21'),(5,'App\\Models\\User',4,'auth_token','f05dec586958b800b57af53ce6b51e23fb1cca34e3a3f0229f4fda9b6d8d7205','[\"*\"]',NULL,NULL,'2026-10-24 07:15:19','2026-10-24 07:15:19'),(6,'App\\Models\\User',2,'auth_token','080690d85b04dcd965d77ac3f912b3edc233da96bd0132f5146f2a485c5b4e98','[\"*\"]','2026-10-24 07:50:43',NULL,'2026-10-24 07:49:06','2026-10-24 07:50:43'),(7,'App\\Models\\User',4,'auth_token','903a2b2605b8e6f21867c60af78505170ffef265eb1e21490b682dba47302837','[\"*\"]',NULL,NULL,'2026-10-26 05:14:45','2026-10-26 05:14:45'),(8,'App\\Models\\User',4,'auth_token','8aa4ea4d21ea8afd33c2c2cf0bfa70849afdfc8d484961a724e03b8e628a2ad5','[\"*\"]','2026-10-26 06:34:26',NULL,'2026-10-26 06:34:00','2026-10-26 06:34:26'),(9,'App\\Models\\User',2,'auth_token','556155d184971f2b560cf535dd9e69fc74d20f4cf7a9ad5de0e5cf10018333ca','[\"*\"]','2026-10-26 06:35:33',NULL,'2026-10-26 06:35:22','2026-10-26 06:35:33'),(10,'App\\Models\\User',2,'auth_token','cd03c1d404f4e008a337c09a4f3ce39c7da03283dd957255ab4e6239ae494bb0','[\"*\"]','2026-10-26 06:37:55',NULL,'2026-10-26 06:37:45','2026-10-26 06:37:55'),(11,'App\\Models\\User',4,'auth_token','dcdc314244119091ce035098ae075c1d4a0699e0e1bb0e31b7ef681429c4bd61','[\"*\"]','2026-10-26 06:38:50',NULL,'2026-10-26 06:38:26','2026-10-26 06:38:50'),(12,'App\\Models\\User',4,'auth_token','19ebfb6ce01ffffe2a7de9a3c367e410e38981b7378f4e5e3b6e5ee437ae57f2','[\"*\"]','2026-10-26 06:42:19',NULL,'2026-10-26 06:42:00','2026-10-26 06:42:19'),(13,'App\\Models\\User',2,'auth_token','139479109e39cd7313896f6670dafd5fe5fea0f2df1999686f7707755ba4c79d','[\"*\"]','2026-10-26 06:42:23',NULL,'2026-10-26 06:42:14','2026-10-26 06:42:23'),(14,'App\\Models\\User',2,'auth_token','e141a381617c2992cdcbb37e40b32377115b4937af74fdced68803024ee25580','[\"*\"]','2026-10-26 06:47:20',NULL,'2026-10-26 06:46:37','2026-10-26 06:47:20'),(15,'App\\Models\\User',4,'auth_token','7ca7a4dae30526b76ad2fc5565165e1c4ce4dec1bb841e1a2e9b28711d2366fe','[\"*\"]','2026-10-26 06:47:09',NULL,'2026-10-26 06:47:03','2026-10-26 06:47:09'),(16,'App\\Models\\User',4,'auth_token','fa8c9c40b6e8724d13c56482b243d5cfe89155671213b2ff881daaa270090138','[\"*\"]','2026-10-26 06:47:57',NULL,'2026-10-26 06:47:54','2026-10-26 06:47:57'),(17,'App\\Models\\User',2,'auth_token','6106e9071410be2c35653c711e4d67f8c354b409389d38942f6dc206e0701874','[\"*\"]','2026-10-26 06:52:28',NULL,'2026-10-26 06:51:24','2026-10-26 06:52:28'),(18,'App\\Models\\User',4,'auth_token','df09f6c34ae5da67cb7ba96a08e6b854bb6fabc623f9a47a54e5d4dd0cb5781c','[\"*\"]','2026-10-26 06:56:27',NULL,'2026-10-26 06:51:42','2026-10-26 06:56:27'),(19,'App\\Models\\User',4,'auth_token','e906a7ee09c357e05bbe4b2c716d43b73269c175682552136f60f0ddd0bb2ba2','[\"*\"]','2026-10-26 07:02:56',NULL,'2026-10-26 06:57:00','2026-10-26 07:02:56'),(20,'App\\Models\\User',2,'auth_token','eb9ab5e3984ece5505c839899a987cce812636b267aebe646ccbf96e91e348a6','[\"*\"]','2026-10-26 06:59:28',NULL,'2026-10-26 06:58:55','2026-10-26 06:59:28'),(21,'App\\Models\\User',2,'auth_token','883faf6972a060430520dbf2a56987d11cf5183ff91cb26915949d662b5b88c8','[\"*\"]','2026-10-26 07:04:39',NULL,'2026-10-26 07:03:21','2026-10-26 07:04:39'),(22,'App\\Models\\User',4,'auth_token','cb88c55c1bd8badee4d5c5f0a8941ff5146ddd4b6c1433e74824346223d90b89','[\"*\"]','2026-10-26 07:04:29',NULL,'2026-10-26 07:03:42','2026-10-26 07:04:29'),(23,'App\\Models\\User',4,'auth_token','5afbdd26ecabad4f0b937d5e3ef81bc31a3a7e5b27343935b3ee590e33c2dd9d','[\"*\"]','2026-10-26 07:09:28',NULL,'2026-10-26 07:05:08','2026-10-26 07:09:28'),(24,'App\\Models\\User',4,'auth_token','6e45bf0052ae967eb198d0b4971bb39e26bdce6250f88b73c7ce7b1ebfd5e738','[\"*\"]','2026-10-26 07:18:01',NULL,'2026-10-26 07:09:56','2026-10-26 07:18:01'),(25,'App\\Models\\User',2,'auth_token','6da553b61218a3abffff1e793876ba25e9baf73e649288a40dbd505070a7ff6d','[\"*\"]','2026-10-26 07:12:26',NULL,'2026-10-26 07:10:37','2026-10-26 07:12:26'),(26,'App\\Models\\User',4,'auth_token','2330a8163f741ca301a6a76260619bfcbab60808fcb9b0a807d41c73b1bbc0fa','[\"*\"]','2026-10-26 07:24:18',NULL,'2026-10-26 07:18:33','2026-10-26 07:24:18'),(27,'App\\Models\\User',4,'auth_token','85ac9fc4167aadacba1661495200a2d21ff3e00508fa1a1ba559f1e7a9023375','[\"*\"]','2026-10-26 07:24:52',NULL,'2026-10-26 07:24:45','2026-10-26 07:24:52'),(28,'App\\Models\\User',4,'auth_token','d3f5ee095835d1cc85c70b5f58765c035a0e9e0c697d8b30a1bd4da5738bd44b','[\"*\"]','2026-10-26 07:28:52',NULL,'2026-10-26 07:25:37','2026-10-26 07:28:52'),(29,'App\\Models\\User',2,'auth_token','0e325e0d9f7bfbdfcd6dea031d934678dab7f0453af91173e78a1c8b4c702518','[\"*\"]','2026-10-26 07:27:00',NULL,'2026-10-26 07:25:58','2026-10-26 07:27:00'),(30,'App\\Models\\User',4,'auth_token','0284912903a6f1103195d06773305128e19af2a32b920d6dba56e1a9d7f8cc21','[\"*\"]','2026-10-26 07:36:49',NULL,'2026-10-26 07:29:27','2026-10-26 07:36:49'),(31,'App\\Models\\User',2,'auth_token','bd061972fb43fed3f4a84f505bf3c1278ca1e0d4c9cc3a96f189d2ade584ee7d','[\"*\"]','2026-10-26 07:31:53',NULL,'2026-10-26 07:30:10','2026-10-26 07:31:53'),(32,'App\\Models\\User',2,'auth_token','50d1f8477bde37293970485a614461be36b9c9e90515bc029360b4e709b0a87c','[\"*\"]','2026-10-26 07:38:39',NULL,'2026-10-26 07:37:46','2026-10-26 07:38:39'),(33,'App\\Models\\User',4,'auth_token','3f8d24c85aa8c935f242dfdbf50651c59adac282791998fdf624bc9ba904e810','[\"*\"]','2026-10-26 07:38:44',NULL,'2026-10-26 07:37:48','2026-10-26 07:38:44'),(34,'App\\Models\\User',2,'auth_token','a442dbf2d3582130e0af252f2f8ab7065002e648dffdf2168fd05db01135a49a','[\"*\"]','2026-10-26 08:02:21',NULL,'2026-10-26 07:53:59','2026-10-26 08:02:21'),(35,'App\\Models\\User',4,'auth_token','dc584eed73f8fd796fd34d77950348d4787be6bd5ba30d9270c78c2cfb950c30','[\"*\"]','2026-10-26 07:56:18',NULL,'2026-10-26 07:56:01','2026-10-26 07:56:18'),(37,'App\\Models\\User',4,'auth_token','4b5d2415784ca5ae2eebcbd2bdbe372883e0e8751222c4374897c66e8cd7b8e8','[\"*\"]','2026-10-26 08:01:49',NULL,'2026-10-26 08:01:22','2026-10-26 08:01:49'),(38,'App\\Models\\User',2,'auth_token','e44d3197757c4bc463ac31b046ce7478862ab407e109b233eddb167ec84e02b7','[\"*\"]','2026-10-26 09:40:53',NULL,'2026-10-26 09:29:23','2026-10-26 09:40:53'),(39,'App\\Models\\User',4,'auth_token','66a27c841bb1b068dd028bc58752fc51016ec0d5ef9f236628f3876f4596ec1a','[\"*\"]',NULL,NULL,'2026-10-26 09:31:19','2026-10-26 09:31:19'),(40,'App\\Models\\User',4,'auth_token','2211fe4d183b121e80d29cbe810ab94ddaf4722beb1fe08283d246912ff65cd6','[\"*\"]',NULL,NULL,'2026-10-26 09:37:04','2026-10-26 09:37:04'),(41,'App\\Models\\User',4,'auth_token','55dceb4a28a26101843851a3e1c7494a2efe64b4dc6e1e3402517e3a1c1514a7','[\"*\"]','2026-10-26 09:42:13',NULL,'2026-10-26 09:42:09','2026-10-26 09:42:13'),(42,'App\\Models\\User',2,'auth_token','19c76af3617bed95e5f37095d21f15afdbe839d5289689b11fb445efec8b4382','[\"*\"]','2026-10-26 10:16:42',NULL,'2026-10-26 10:14:53','2026-10-26 10:16:42'),(43,'App\\Models\\User',4,'auth_token','7eb0d2c8aec4b66d38fe21b9594a1a8e3b6ea9e1bc3eeec27db229dc0ee4aa00','[\"*\"]','2026-10-26 10:16:27',NULL,'2026-10-26 10:16:06','2026-10-26 10:16:27'),(44,'App\\Models\\User',2,'auth_token','c744da51673adb2548dfa2118c2ba6a9e1d6d852b25290725d636bb9bfd3688a','[\"*\"]','2026-10-26 10:23:07',NULL,'2026-10-26 10:21:20','2026-10-26 10:23:07'),(45,'App\\Models\\User',2,'auth_token','84fd32febfbf0983392e8e4324c78d2a26a4f1b94907c70d069f10400ac15dd0','[\"*\"]','2026-10-26 10:35:28',NULL,'2026-10-26 10:35:27','2026-10-26 10:35:28'),(46,'App\\Models\\User',2,'auth_token','c872bd1d17ab5cc577e8a80e8a132e27abd9a1e25a1f8e34c4c2999f411ab143','[\"*\"]','2026-10-26 10:37:47',NULL,'2026-10-26 10:37:46','2026-10-26 10:37:47'),(47,'App\\Models\\User',2,'auth_token','45e0f8635792359c536e5e4cf338556792aa97f84bb29c9e523dcacf457922c7','[\"*\"]','2026-10-26 10:42:14',NULL,'2026-10-26 10:42:12','2026-10-26 10:42:14'),(48,'App\\Models\\User',2,'auth_token','a6147d04bb2bef533f54aef967701f6c896b15232e2bcf8cc9287ed75519e155','[\"*\"]','2026-10-26 10:45:47',NULL,'2026-10-26 10:45:46','2026-10-26 10:45:47'),(49,'App\\Models\\User',2,'auth_token','332499c00fc55131a9c3b891040ae7d0f800c8cf187d0a6cbf296c695e1287f7','[\"*\"]','2026-10-26 10:52:56',NULL,'2026-10-26 10:52:18','2026-10-26 10:52:56'),(50,'App\\Models\\User',2,'auth_token','6f3ff0472199958d72c8aebe1a93e377746e6613569d31392768d00a412f2f4b','[\"*\"]','2026-10-26 10:57:13',NULL,'2026-10-26 10:56:20','2026-10-26 10:57:13'),(52,'App\\Models\\User',2,'auth_token','e82dd434197cf85fadcf6c627a856f04d85424688fbd469fab8e01651959b08b','[\"*\"]','2026-10-26 11:06:23',NULL,'2026-10-26 11:05:41','2026-10-26 11:06:23'),(53,'App\\Models\\User',2,'auth_token','89fe1f1817874371ac2ef8828d220a63e613b9fd87fdf5173a0da430d1f77641','[\"*\"]','2026-10-26 11:09:41',NULL,'2026-10-26 11:09:39','2026-10-26 11:09:41'),(54,'App\\Models\\User',2,'auth_token','7150e96275f7b3d8fcc6bf53ac61a7e191a707ca8e5e2272ecd9eae708fff07a','[\"*\"]','2026-10-26 11:12:20',NULL,'2026-10-26 11:12:11','2026-10-26 11:12:20'),(57,'App\\Models\\User',4,'auth_token','02493e4df05b957ea6a30d02b3240516e1e136ec0949693c50e67437f79a0c39','[\"*\"]','2026-10-26 11:20:25',NULL,'2026-10-26 11:20:11','2026-10-26 11:20:25'),(58,'App\\Models\\User',4,'auth_token','701096eea37f8606d4569c2235c635d961e3270b8bf1f919b3175fc5b6106490','[\"*\"]',NULL,NULL,'2026-10-26 11:24:45','2026-10-26 11:24:45'),(59,'App\\Models\\User',4,'auth_token','f6d4144c40845b86bf8a80cff89d910446217e9e8717becce564408149f12e0c','[\"*\"]',NULL,NULL,'2026-10-26 11:28:30','2026-10-26 11:28:30'),(60,'App\\Models\\User',4,'auth_token','532a7fa72c1ce8950665dd4e1ce4bed1cb62ff35bc938a76f826366fdc58b574','[\"*\"]',NULL,NULL,'2026-10-26 11:29:00','2026-10-26 11:29:00'),(61,'App\\Models\\User',4,'auth_token','2ba6b79912b285b5cc80aed2a1134d4774ac3c4b00820d3171411df8299d49f7','[\"*\"]',NULL,NULL,'2026-10-26 11:30:58','2026-10-26 11:30:58'),(62,'App\\Models\\User',4,'auth_token','e6a2a1c8293bcfe7d42ecffc09f02f3c2ab78e631ae231dabebf7ec400722e62','[\"*\"]',NULL,NULL,'2026-10-26 11:33:36','2026-10-26 11:33:36'),(63,'App\\Models\\User',4,'auth_token','83dfafb9a025f749f0314dd7bdd481a9aaca2c2b7c33b55dcd4a5b43a845ba9f','[\"*\"]',NULL,NULL,'2026-10-26 11:34:14','2026-10-26 11:34:14'),(65,'App\\Models\\User',4,'auth_token','45354b0e04132acfbcb77a068c2620dd2c8f6d7a558475228554442ba21da63f','[\"*\"]',NULL,NULL,'2026-10-26 11:56:51','2026-10-26 11:56:51'),(66,'App\\Models\\User',4,'auth_token','d925a14b5d8eb23e263dba40f55acb51474caccf09c461f5b9210e7596cfb73d','[\"*\"]',NULL,NULL,'2026-10-26 12:01:22','2026-10-26 12:01:22'),(68,'App\\Models\\User',4,'auth_token','db35688cf73da9adb16af2496f1be5ef9aae4beda83d202e6a2cf543e76ef5d3','[\"*\"]',NULL,NULL,'2026-10-26 12:05:47','2026-10-26 12:05:47'),(69,'App\\Models\\User',4,'auth_token','fd5b2b243ebe996ae06d73e36ca936327642e094aa1068f8656c09142f9541f3','[\"*\"]','2026-10-26 12:09:19',NULL,'2026-10-26 12:09:15','2026-10-26 12:09:19'),(70,'App\\Models\\User',4,'auth_token','a84e25b79225c48161298d5ce3d5f3f541bc24e04e119449e97e93ed09050973','[\"*\"]',NULL,NULL,'2026-10-26 12:18:08','2026-10-26 12:18:08'),(71,'App\\Models\\User',4,'auth_token','dc64d6464da135f77f5445e087a30f2128a0fb77480dffb6c4769b341d0b9f0d','[\"*\"]',NULL,NULL,'2026-10-26 12:24:15','2026-10-26 12:24:15'),(72,'App\\Models\\User',4,'auth_token','208bbe71871e5e751814799cb281d979ca47b5cde76147507196cec62e003438','[\"*\"]','2026-10-26 12:28:40',NULL,'2026-10-26 12:27:33','2026-10-26 12:28:40'),(73,'App\\Models\\User',4,'auth_token','1241b6586b035bbe62b508232b229f1efa0542c0b33621ddf82b771601409c7f','[\"*\"]',NULL,NULL,'2026-10-26 12:30:40','2026-10-26 12:30:40'),(74,'App\\Models\\User',4,'auth_token','a1289bc523ed18b0188490ba2f3e2a91e41df191888852a3fff8ea4bbd3ce153','[\"*\"]',NULL,NULL,'2026-10-26 12:32:48','2026-10-26 12:32:48'),(75,'App\\Models\\User',4,'auth_token','61de0050c50a975b2d3feee1f13890d783eb8a228108e380be5add0ab455b85e','[\"*\"]',NULL,NULL,'2026-10-26 12:34:48','2026-10-26 12:34:48'),(76,'App\\Models\\User',4,'auth_token','1695a78c23d0abce05e1c0373831855eb6ad77c661efc2b556313c5d30a6b2e7','[\"*\"]','2026-10-26 12:37:31',NULL,'2026-10-26 12:36:38','2026-10-26 12:37:31'),(77,'App\\Models\\User',4,'auth_token','0af608f8db891166b8a8a6b3fbb6e76ee4e828f1e3b4c216c8496a60bb52504a','[\"*\"]','2026-10-26 12:42:25',NULL,'2026-10-26 12:39:27','2026-10-26 12:42:25'),(78,'App\\Models\\User',2,'auth_token','23385e4d152aec3dc20eb3e0649a8eda9ecfd657577f02fdfb648d47073dab71','[\"*\"]','2026-10-26 12:43:03',NULL,'2026-10-26 12:40:59','2026-10-26 12:43:03'),(79,'App\\Models\\User',2,'auth_token','c0258548e7dbfdfbe7c7a3d8d6a7841343f5aec27057f1e3db090a7f0f70980c','[\"*\"]','2026-10-26 12:44:55',NULL,'2026-10-26 12:44:46','2026-10-26 12:44:55'),(80,'App\\Models\\User',2,'auth_token','b2d6a1f0f8b6e0945b68cdef008b95549e17892da8964e0933712c89c1484b96','[\"*\"]','2026-10-28 06:45:50',NULL,'2026-10-28 06:42:09','2026-10-28 06:45:50'),(81,'App\\Models\\User',4,'auth_token','8139636f0ed48e8712859068f66ed5d0aaa0336f430b82c4a60524e68c8ddd6b','[\"*\"]','2026-10-28 06:49:49',NULL,'2026-10-28 06:47:43','2026-10-28 06:49:49'),(83,'App\\Models\\User',4,'auth_token','cf8728a17fd196b418e57ff83c3545e893dee17b4f268f605477a85a67c14d36','[\"*\"]','2026-10-28 12:01:35',NULL,'2026-10-28 12:01:20','2026-10-28 12:01:35');
/*!40000 ALTER TABLE `personal_access_tokens` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `reviews`
--

DROP TABLE IF EXISTS `reviews`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `reviews` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `order_id` bigint unsigned NOT NULL,
  `customer_id` bigint unsigned NOT NULL,
  `technician_id` bigint unsigned NOT NULL,
  `rating` tinyint unsigned NOT NULL,
  `comment` text COLLATE utf8mb4_unicode_ci,
  `photos` json DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `reviews_order_id_unique` (`order_id`),
  KEY `reviews_customer_id_foreign` (`customer_id`),
  KEY `reviews_technician_id_foreign` (`technician_id`),
  CONSTRAINT `reviews_customer_id_foreign` FOREIGN KEY (`customer_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `reviews_order_id_foreign` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE,
  CONSTRAINT `reviews_technician_id_foreign` FOREIGN KEY (`technician_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `reviews`
--

LOCK TABLES `reviews` WRITE;
/*!40000 ALTER TABLE `reviews` DISABLE KEYS */;
INSERT INTO `reviews` VALUES (1,1,4,2,5,'Pelayanan Pak Agus sangat memuaskan! Kompor tanam Modena saya yang tadinya apinya merah sekarang biru bersih kembali. Datang tepat waktu dan sopan.',NULL,'2026-10-19 05:24:56','2026-10-19 05:24:56');
/*!40000 ALTER TABLE `reviews` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `service_categories`
--

DROP TABLE IF EXISTS `service_categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `service_categories` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `slug` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `icon` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `sort_order` int unsigned NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `service_categories_slug_unique` (`slug`),
  KEY `service_categories_is_active_index` (`is_active`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `service_categories`
--

LOCK TABLES `service_categories` WRITE;
/*!40000 ALTER TABLE `service_categories` DISABLE KEYS */;
INSERT INTO `service_categories` VALUES (1,'Uji Gagal T09','kompor-gas-standar','Perbaikan dan perawatan kompor gas portabel atau meja (Rinnai, Quantum, Miyako, dll)','flame',1,1,'2026-10-19 05:24:55','2026-10-19 05:24:55'),(2,'Kompor Tanam (Built-in Hob)','kompor-tanam-builtin-hob','Servis kompor gas tanam premium (Modena, Electrolux, Ariston, Bosch, Teka)','layout-grid',1,2,'2026-10-19 05:24:55','2026-10-19 05:24:55'),(3,'Freestanding Cooker (Kompor + Oven Gas)','freestanding-cooker','Perawatan kompor berdiri dengan oven terintegrasi untuk dapur rumah & resto.','server',1,3,'2026-10-19 05:24:55','2026-10-19 05:24:55');
/*!40000 ALTER TABLE `service_categories` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `service_items`
--

DROP TABLE IF EXISTS `service_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `service_items` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `service_category_id` bigint unsigned NOT NULL,
  `name` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `slug` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `estimated_minutes` int unsigned NOT NULL DEFAULT '60',
  `base_price` decimal(12,2) NOT NULL DEFAULT '0.00',
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `service_items_slug_unique` (`slug`),
  KEY `service_items_service_category_id_foreign` (`service_category_id`),
  KEY `service_items_is_active_index` (`is_active`),
  CONSTRAINT `service_items_service_category_id_foreign` FOREIGN KEY (`service_category_id`) REFERENCES `service_categories` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `service_items`
--

LOCK TABLES `service_items` WRITE;
/*!40000 ALTER TABLE `service_items` DISABLE KEYS */;
INSERT INTO `service_items` VALUES (2,1,'Ganti Pemantik Elektrik / Mekanik','ganti-pemantik-mekanik','Penggantian modul pemantik atau knob mekanik yang patah/macet.',60,95000.00,1,'2026-10-19 05:24:55','2026-10-19 05:24:55'),(3,2,'Servis Kompor Tanam (Api Merah / Mati)','servis-kompor-tanam-api-merah','Pembersihan saluran udara, kalibrasi thermocouple pengaman gas, perbaikan burner api.',75,135000.00,1,'2026-10-19 05:24:55','2026-10-19 05:24:55'),(4,2,'Perbaikan Kebocoran Gas & Pipa Tanam','perbaikan-kebocoran-gas-kompor-tanam','Pemeriksaan kebocoran dengan gas detector, penggantian seal gasket tahan panas, pengencangan clamp.',90,175000.00,1,'2026-10-19 05:24:55','2026-10-19 05:24:55'),(5,3,'Servis Total Tungku & Oven Gas','servis-total-tungku-oven-gas','Servis api oven atas-bawah, pembersihan burner 4-5 tungku, cek sirkulasi pengapian.',120,250000.00,1,'2026-10-19 05:24:55','2026-10-19 05:24:55');
/*!40000 ALTER TABLE `service_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sessions`
--

DROP TABLE IF EXISTS `sessions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sessions` (
  `id` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_id` bigint unsigned DEFAULT NULL,
  `ip_address` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `user_agent` text COLLATE utf8mb4_unicode_ci,
  `payload` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `last_activity` int NOT NULL,
  PRIMARY KEY (`id`),
  KEY `sessions_user_id_index` (`user_id`),
  KEY `sessions_last_activity_index` (`last_activity`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sessions`
--

LOCK TABLES `sessions` WRITE;
/*!40000 ALTER TABLE `sessions` DISABLE KEYS */;
INSERT INTO `sessions` VALUES ('0x67o5m20Aj7gxn0DO5i8r0iGkUM4QCDQj5vsS5H',1,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36','eyJfdG9rZW4iOiJka2dtN2x1UUt5dXE5QzVpUlI4cXVUQm5uWGIzenhCbjh3R01NNVp0IiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHA6XC9cLzEyNy4wLjAuMTo4MDAwXC9hZG1pblwvZGFzaGJvYXJkIiwicm91dGUiOiJhZG1pbi5kYXNoYm9hcmQifSwiX2ZsYXNoIjp7Im9sZCI6W10sIm5ldyI6W119LCJsb2dpbl93ZWJfNTliYTM2YWRkYzJiMmY5NDAxNTgwZjAxNGM3ZjU4ZWE0ZTMwOTg5ZCI6MSwicGFzc3dvcmRfaGFzaF93ZWIiOiJmYzg5NjZjNDllNjBiMDBmMDBmYmQ0MmVlMDg0OGNlMjI4MzkxNTU5ZWI2NThmNjUwYmRmN2M3ODkxNjQxYjY5In0=',1793182060),('3PzB3INZOzrrGfoJhF37vSqunYxe6N3yFBvxGfbk',1,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','eyJfdG9rZW4iOiI4QjZUa2NvVkQ5Y3NJMWVUZDBZVzNLNVdIZzBMRjBxQ3NCajRLY1VGIiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHA6XC9cLzEyNy4wLjAuMTo4MDAwXC9hZG1pblwvcGF5bWVudHMiLCJyb3V0ZSI6ImFkbWluLnBheW1lbnRzIn0sIl9mbGFzaCI6eyJvbGQiOltdLCJuZXciOltdfSwibG9naW5fd2ViXzU5YmEzNmFkZGMyYjJmOTQwMTU4MGYwMTRjN2Y1OGVhNGUzMDk4OWQiOjEsInBhc3N3b3JkX2hhc2hfd2ViIjoiZmM4OTY2YzQ5ZTYwYjAwZjAwZmJkNDJlZTA4NDhjZTIyODM5MTU1OWViNjU4ZjY1MGJkZjdjNzg5MTY0MWI2OSJ9',1793194094),('URVulo7Lm4m6lkpgAtL18vPXELVS5UPFMqJdLB2v',1,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36','eyJfdG9rZW4iOiJ4M1RCdU43RGV1c0tOUmZOa3dIbDVobVJacFlrU3I0VTUwZFlnVTJuIiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHA6XC9cLzEyNy4wLjAuMTo4MDAwXC9hZG1pblwvdGVjaG5pY2lhbnMiLCJyb3V0ZSI6ImFkbWluLnRlY2huaWNpYW5zIn0sIl9mbGFzaCI6eyJvbGQiOltdLCJuZXciOltdfSwibG9naW5fd2ViXzU5YmEzNmFkZGMyYjJmOTQwMTU4MGYwMTRjN2Y1OGVhNGUzMDk4OWQiOjEsInBhc3N3b3JkX2hhc2hfd2ViIjoiZmM4OTY2YzQ5ZTYwYjAwZjAwZmJkNDJlZTA4NDhjZTIyODM5MTU1OWViNjU4ZjY1MGJkZjdjNzg5MTY0MWI2OSJ9',1793055782),('vqeLqm63eiEUY5tp9eplaudkCezGsrM9BXhZtqp4',1,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36','eyJfdG9rZW4iOiJVUlRjRmVrbUtXaGczdG10Vkhlckh5QnNpbXZwNGYyeHV1SmNuSFNGIiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHA6XC9cLzEyNy4wLjAuMTo4MDAwXC9hZG1pblwvY3VzdG9tZXJzIiwicm91dGUiOiJhZG1pbi5jdXN0b21lcnMifSwiX2ZsYXNoIjp7Im9sZCI6W10sIm5ldyI6W119LCJsb2dpbl93ZWJfNTliYTM2YWRkYzJiMmY5NDAxNTgwZjAxNGM3ZjU4ZWE0ZTMwOTg5ZCI6MSwicGFzc3dvcmRfaGFzaF93ZWIiOiJmYzg5NjZjNDllNjBiMDBmMDBmYmQ0MmVlMDg0OGNlMjI4MzkxNTU5ZWI2NThmNjUwYmRmN2M3ODkxNjQxYjY5In0=',1793032734),('YgquX92EPrLpSmwREGuZB9s5uKOVqMtx6uGVv8Yu',NULL,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Code/1.143.1 Chrome/150.0.7871.250 Electron/43.7.7 Safari/537.36','eyJfdG9rZW4iOiJsQmc2cmhUUmVHeExSOEx4WVpVU1dwaUczbk9Fem9tRndIN20wdmdTIiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHA6XC9cLzEyNy4wLjAuMTo4MDAwIiwicm91dGUiOm51bGx9LCJfZmxhc2giOnsib2xkIjpbXSwibmV3IjpbXX19',1793181990);
/*!40000 ALTER TABLE `sessions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `technician_profiles`
--

DROP TABLE IF EXISTS `technician_profiles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `technician_profiles` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint unsigned NOT NULL,
  `bio` text COLLATE utf8mb4_unicode_ci,
  `years_of_experience` int unsigned NOT NULL DEFAULT '0',
  `skills` json DEFAULT NULL,
  `ktp_number` text COLLATE utf8mb4_unicode_ci,
  `certificate_url` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `is_verified` tinyint(1) NOT NULL DEFAULT '0',
  `verified_at` timestamp NULL DEFAULT NULL,
  `verified_by` bigint unsigned DEFAULT NULL,
  `is_available` tinyint(1) NOT NULL DEFAULT '1',
  `current_latitude` decimal(10,7) DEFAULT NULL,
  `current_longitude` decimal(10,7) DEFAULT NULL,
  `last_location_updated_at` timestamp NULL DEFAULT NULL,
  `rating_avg` decimal(3,2) NOT NULL DEFAULT '0.00',
  `reviews_count` int unsigned NOT NULL DEFAULT '0',
  `jobs_completed_count` int unsigned NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `technician_profiles_user_id_unique` (`user_id`),
  KEY `technician_profiles_verified_by_foreign` (`verified_by`),
  KEY `technician_profiles_is_verified_index` (`is_verified`),
  KEY `technician_profiles_is_available_index` (`is_available`),
  CONSTRAINT `technician_profiles_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `technician_profiles_verified_by_foreign` FOREIGN KEY (`verified_by`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `technician_profiles`
--

LOCK TABLES `technician_profiles` WRITE;
/*!40000 ALTER TABLE `technician_profiles` DISABLE KEYS */;
INSERT INTO `technician_profiles` VALUES (1,2,'Spesialis kompor gas tanam Modena, Rinnai, dan Electrolux. Berpengalaman lebih dari 8 tahun.',8,'[\"Kompor Gas Tanam\", \"Freestanding Cooker\", \"Ganti Pemantik\", \"Uji Kebocoran Gas\"]','eyJpdiI6IlQrY3hZMjlsdlh2Q0E4NGJmU1Nib3c9PSIsInZhbHVlIjoiMVBOQ0tKMk9tRGIwemluSnFVZ0V6YlRSVTYvRVR0djZ5bWd6VnFWb3hVST0iLCJtYWMiOiI4NzFhNzVlNTg0Mjc1YzBmYzY0ZDRkYTM5YmRiNTgzYzFjMzVmNTk4Yjg5N2FlOWViODQ1NmMwYmJjZmI1ZTU1IiwidGFnIjoiIn0=',NULL,1,'2026-10-19 05:24:55',1,1,1.1082680,104.0581740,'2026-10-28 12:00:56',4.90,48,56,'2026-10-19 05:24:55','2026-10-28 12:00:56'),(2,3,'Teknisi handal untuk segala merk kompor gas standar dan freestanding cooker. Cepat dan bergaransi.',5,'[\"Kompor Gas Standar\", \"Pembersihan Spuyer\", \"Freestanding Cooker\"]','eyJpdiI6IlVuL1JVQkxSVDBEV0Q0aXpxNVMzVXc9PSIsInZhbHVlIjoiN1FQdDVHZitJUEltMkt0ajlBRW1ONC93a1JHVGJqRHJxcms4NVI5ajVhND0iLCJtYWMiOiJkN2IzZTcxNzFkYjUzZGZmZmIyZmM2Njc0ZDczM2E5NjhiNDU5NzI3ZTUwNDQ2OWY0NWVjY2U5ZDIwOTA3NjY1IiwidGFnIjoiIn0=',NULL,1,'2026-10-19 05:24:56',1,1,-6.2905000,106.7972000,'2026-10-19 05:24:56',4.80,32,35,'2026-10-19 05:24:56','2026-10-19 05:24:56');
/*!40000 ALTER TABLE `technician_profiles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `technician_services`
--

DROP TABLE IF EXISTS `technician_services`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `technician_services` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `technician_profile_id` bigint unsigned NOT NULL,
  `service_item_id` bigint unsigned NOT NULL,
  `custom_price` decimal(12,2) DEFAULT NULL,
  `is_offered` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `technician_services_technician_profile_id_service_item_id_unique` (`technician_profile_id`,`service_item_id`),
  KEY `technician_services_service_item_id_foreign` (`service_item_id`),
  CONSTRAINT `technician_services_service_item_id_foreign` FOREIGN KEY (`service_item_id`) REFERENCES `service_items` (`id`) ON DELETE CASCADE,
  CONSTRAINT `technician_services_technician_profile_id_foreign` FOREIGN KEY (`technician_profile_id`) REFERENCES `technician_profiles` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `technician_services`
--

LOCK TABLES `technician_services` WRITE;
/*!40000 ALTER TABLE `technician_services` DISABLE KEYS */;
INSERT INTO `technician_services` VALUES (2,1,3,135000.00,1,'2026-10-19 05:24:55','2026-10-19 05:24:55'),(3,1,4,175000.00,1,'2026-10-19 05:24:55','2026-10-19 05:24:55'),(5,2,5,240000.00,1,'2026-10-19 05:24:56','2026-10-19 05:24:56');
/*!40000 ALTER TABLE `technician_services` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `phone` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `role` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'customer',
  `avatar_url` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `address` text COLLATE utf8mb4_unicode_ci,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `email_verified_at` timestamp NULL DEFAULT NULL,
  `password` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `remember_token` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `users_email_unique` (`email`),
  UNIQUE KEY `users_phone_unique` (`phone`),
  KEY `users_role_index` (`role`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'Admin KlikKompor','rafiifsecond@gmail.com','081100000001','admin',NULL,NULL,1,NULL,'$2y$12$djBnQai//qM43L6UJDnNFuQtgnrL6oKigTSErdpWbLtyKFD0uf3wu',NULL,'2026-10-19 05:24:55','2026-10-26 04:12:13'),(2,'Agus Priyanto','agus.teknisi@klikkompor.com','081234567890','technician',NULL,'Jl. Tebet Timur Dalam No. 14, Jakarta Selatan',1,NULL,'$2y$12$2hzZAnIEIQ71fjnN9ojYBOM6v2ZiFNemekGibHAYX2eQwb8IoOm9G',NULL,'2026-10-19 05:24:55','2026-10-19 05:24:55'),(3,'Bambang Sugiarto','bambang.teknisi@klikkompor.com','081398765432','technician',NULL,'Jl. Fatmawati Raya No. 45, Jakarta Selatan',1,NULL,'$2y$12$AiK7OJgZg2pEmHeijYExj.hMoVCrGcQSfKKPBHf14AKUl0lsQDGw.',NULL,'2026-10-19 05:24:56','2026-10-19 05:24:56'),(4,'Dewi Lestari','dewi@example.com','087812345678','customer',NULL,'Apartemen Kalibata City Tower Kemuning Lt. 8, Jakarta Selatan',1,NULL,'$2y$12$eqpUoexB8FtfI0Az2wiy6O1l4Y2/JS7dbpvCyqcgBi9VFjcjsqaDy',NULL,'2026-10-19 05:24:56','2026-10-19 05:24:56'),(5,'Rian Hidayat','rian@example.com','085799887766','customer',NULL,'Jl. Kemang Timur No. 21, Jakarta Selatan',1,NULL,'$2y$12$inyhyR32YmxxC6BxwEII6uA0KD/oyeUZu5I7eJXoBxa3/KpULi77C',NULL,'2026-10-19 05:24:56','2026-10-19 05:24:56');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary view structure for view `v_audit_event_summary`
--

DROP TABLE IF EXISTS `v_audit_event_summary`;
/*!50001 DROP VIEW IF EXISTS `v_audit_event_summary`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_audit_event_summary` AS SELECT 
 1 AS `id`,
 1 AS `actor_id`,
 1 AS `actor_role`,
 1 AS `event_name`,
 1 AS `entity_type`,
 1 AS `entity_id`,
 1 AS `platform`,
 1 AS `status`,
 1 AS `created_at`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `v_payment_operational`
--

DROP TABLE IF EXISTS `v_payment_operational`;
/*!50001 DROP VIEW IF EXISTS `v_payment_operational`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_payment_operational` AS SELECT 
 1 AS `id`,
 1 AS `order_id`,
 1 AS `customer_id`,
 1 AS `payment_number`,
 1 AS `payment_method`,
 1 AS `amount`,
 1 AS `payment_status`,
 1 AS `paid_at`,
 1 AS `created_at`,
 1 AS `updated_at`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `v_service_catalog_public`
--

DROP TABLE IF EXISTS `v_service_catalog_public`;
/*!50001 DROP VIEW IF EXISTS `v_service_catalog_public`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_service_catalog_public` AS SELECT 
 1 AS `id`,
 1 AS `service_category_id`,
 1 AS `name`,
 1 AS `slug`,
 1 AS `description`,
 1 AS `estimated_minutes`,
 1 AS `base_price`,
 1 AS `is_active`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `v_technician_public`
--

DROP TABLE IF EXISTS `v_technician_public`;
/*!50001 DROP VIEW IF EXISTS `v_technician_public`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_technician_public` AS SELECT 
 1 AS `id`,
 1 AS `name`,
 1 AS `avatar_url`,
 1 AS `bio`,
 1 AS `years_of_experience`,
 1 AS `is_verified`,
 1 AS `is_available`,
 1 AS `rating_avg`,
 1 AS `reviews_count`,
 1 AS `jobs_completed_count`*/;
SET character_set_client = @saved_cs_client;

--
-- Dumping events for database 'klikkompor_db'
--

--
-- Dumping routines for database 'klikkompor_db'
--

--
-- Final view structure for view `v_audit_event_summary`
--

/*!50001 DROP VIEW IF EXISTS `v_audit_event_summary`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_unicode_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_audit_event_summary` AS select `activity_logs`.`id` AS `id`,`activity_logs`.`actor_id` AS `actor_id`,`activity_logs`.`actor_role` AS `actor_role`,`activity_logs`.`event_name` AS `event_name`,`activity_logs`.`entity_type` AS `entity_type`,`activity_logs`.`entity_id` AS `entity_id`,`activity_logs`.`platform` AS `platform`,`activity_logs`.`status` AS `status`,`activity_logs`.`created_at` AS `created_at` from `activity_logs` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_payment_operational`
--

/*!50001 DROP VIEW IF EXISTS `v_payment_operational`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_unicode_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_payment_operational` AS select `p`.`id` AS `id`,`p`.`order_id` AS `order_id`,`p`.`customer_id` AS `customer_id`,`p`.`payment_number` AS `payment_number`,`p`.`payment_method` AS `payment_method`,`p`.`amount` AS `amount`,`p`.`payment_status` AS `payment_status`,`p`.`paid_at` AS `paid_at`,`p`.`created_at` AS `created_at`,`p`.`updated_at` AS `updated_at` from `payments` `p` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_service_catalog_public`
--

/*!50001 DROP VIEW IF EXISTS `v_service_catalog_public`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_unicode_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_service_catalog_public` AS select `si`.`id` AS `id`,`si`.`service_category_id` AS `service_category_id`,`si`.`name` AS `name`,`si`.`slug` AS `slug`,`si`.`description` AS `description`,`si`.`estimated_minutes` AS `estimated_minutes`,`si`.`base_price` AS `base_price`,`si`.`is_active` AS `is_active` from `service_items` `si` where (`si`.`is_active` = 1) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_technician_public`
--

/*!50001 DROP VIEW IF EXISTS `v_technician_public`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_unicode_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_technician_public` AS select `u`.`id` AS `id`,`u`.`name` AS `name`,`u`.`avatar_url` AS `avatar_url`,`tp`.`bio` AS `bio`,`tp`.`years_of_experience` AS `years_of_experience`,`tp`.`is_verified` AS `is_verified`,`tp`.`is_available` AS `is_available`,`tp`.`rating_avg` AS `rating_avg`,`tp`.`reviews_count` AS `reviews_count`,`tp`.`jobs_completed_count` AS `jobs_completed_count` from (`users` `u` join `technician_profiles` `tp` on((`tp`.`user_id` = `u`.`id`))) where ((`u`.`role` = 'technician') and (`u`.`is_active` = 1)) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-10-29  4:56:47
