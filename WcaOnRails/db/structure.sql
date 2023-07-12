
/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
DROP TABLE IF EXISTS `Competitions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Competitions` (
  `id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `cityName` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `countryId` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `information` mediumtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `venue` varchar(240) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `venueAddress` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `venueDetails` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `external_website` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `cellName` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `showAtAll` tinyint(1) NOT NULL DEFAULT '0',
  `latitude` int DEFAULT NULL,
  `longitude` int DEFAULT NULL,
  `contact` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `remarks` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `registration_open` datetime DEFAULT NULL,
  `registration_close` datetime DEFAULT NULL,
  `use_wca_registration` tinyint(1) NOT NULL DEFAULT '1',
  `guests_enabled` tinyint(1) NOT NULL DEFAULT '1',
  `results_posted_at` datetime DEFAULT NULL,
  `results_nag_sent_at` datetime DEFAULT NULL,
  `generate_website` tinyint(1) DEFAULT NULL,
  `announced_at` datetime DEFAULT NULL,
  `base_entry_fee_lowest_denomination` int DEFAULT NULL,
  `currency_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'USD',
  `connected_stripe_account_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `enable_donations` tinyint(1) DEFAULT NULL,
  `competitor_limit_enabled` tinyint(1) DEFAULT NULL,
  `competitor_limit` int DEFAULT NULL,
  `competitor_limit_reason` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `extra_registration_requirements` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `on_the_spot_registration` tinyint(1) DEFAULT NULL,
  `on_the_spot_entry_fee_lowest_denomination` int DEFAULT NULL,
  `refund_policy_percent` int DEFAULT NULL,
  `refund_policy_limit_date` datetime DEFAULT NULL,
  `guests_entry_fee_lowest_denomination` int DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `results_submitted_at` datetime DEFAULT NULL,
  `early_puzzle_submission` tinyint(1) DEFAULT NULL,
  `early_puzzle_submission_reason` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `qualification_results` tinyint(1) DEFAULT NULL,
  `qualification_results_reason` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `name_reason` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `external_registration_page` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `confirmed_at` datetime DEFAULT NULL,
  `event_restrictions` tinyint(1) DEFAULT NULL,
  `event_restrictions_reason` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `registration_reminder_sent_at` datetime DEFAULT NULL,
  `announced_by` int DEFAULT NULL,
  `results_posted_by` int DEFAULT NULL,
  `main_event_id` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `cancelled_at` datetime DEFAULT NULL,
  `cancelled_by` int DEFAULT NULL,
  `waiting_list_deadline_date` datetime DEFAULT NULL,
  `event_change_deadline_date` datetime DEFAULT NULL,
  `guest_entry_status` int NOT NULL DEFAULT '0',
  `allow_registration_edits` tinyint(1) NOT NULL DEFAULT '0',
  `allow_registration_self_delete_after_acceptance` tinyint(1) NOT NULL DEFAULT '0',
  `competition_series_id` int DEFAULT NULL,
  `use_wca_live_for_scoretaking` tinyint(1) NOT NULL DEFAULT '0',
  `allow_registration_without_qualification` tinyint(1) DEFAULT '0',
  `guests_per_registration_limit` int DEFAULT NULL,
  `events_per_registration_limit` int DEFAULT NULL,
  `force_comment_in_registration` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_Competitions_on_countryId` (`countryId`),
  KEY `index_Competitions_on_start_date` (`start_date`),
  KEY `index_Competitions_on_end_date` (`end_date`),
  KEY `index_Competitions_on_cancelled_at` (`cancelled_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `CompetitionsMedia`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `CompetitionsMedia` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `competitionId` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `type` varchar(15) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `text` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `uri` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `submitterName` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `submitterComment` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `submitterEmail` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `timestampSubmitted` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `timestampDecided` timestamp NULL DEFAULT NULL,
  `status` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=11880 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `ConciseAverageResults`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ConciseAverageResults` (
  `id` int NOT NULL DEFAULT '0',
  `average` int NOT NULL DEFAULT '0',
  `valueAndId` bigint DEFAULT NULL,
  `personId` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `eventId` varchar(6) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `countryId` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `continentId` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `year` smallint unsigned NOT NULL DEFAULT '0',
  `month` smallint unsigned NOT NULL DEFAULT '0',
  `day` smallint unsigned NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `ConciseSingleResults`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ConciseSingleResults` (
  `id` int NOT NULL DEFAULT '0',
  `best` int NOT NULL DEFAULT '0',
  `valueAndId` bigint DEFAULT NULL,
  `personId` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `eventId` varchar(6) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `countryId` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `continentId` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `year` smallint unsigned NOT NULL DEFAULT '0',
  `month` smallint unsigned NOT NULL DEFAULT '0',
  `day` smallint unsigned NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `Continents`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Continents` (
  `id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `recordName` char(3) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `latitude` int NOT NULL DEFAULT '0',
  `longitude` int NOT NULL DEFAULT '0',
  `zoom` tinyint NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `Countries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Countries` (
  `id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `continentId` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `iso2` char(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `iso2` (`iso2`),
  KEY `fk_continents` (`continentId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `Events`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Events` (
  `id` varchar(6) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `name` varchar(54) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `rank` int NOT NULL DEFAULT '0',
  `format` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `cellName` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci PACK_KEYS=0;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `Formats`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Formats` (
  `id` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `sort_by` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `sort_by_second` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `expected_solve_count` int NOT NULL,
  `trim_fastest_n` int NOT NULL,
  `trim_slowest_n` int NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `InboxPersons`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `InboxPersons` (
  `id` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `wcaId` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `name` varchar(80) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `countryId` char(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `gender` varchar(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT '',
  `dob` date NOT NULL,
  `competitionId` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  UNIQUE KEY `index_InboxPersons_on_competitionId_and_id` (`competitionId`,`id`),
  KEY `InboxPersons_fk_country` (`countryId`),
  KEY `InboxPersons_id` (`wcaId`),
  KEY `InboxPersons_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `InboxResults`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `InboxResults` (
  `personId` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `pos` smallint NOT NULL DEFAULT '0',
  `competitionId` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `eventId` varchar(6) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `roundTypeId` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `formatId` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `value1` int NOT NULL DEFAULT '0',
  `value2` int NOT NULL DEFAULT '0',
  `value3` int NOT NULL DEFAULT '0',
  `value4` int NOT NULL DEFAULT '0',
  `value5` int NOT NULL DEFAULT '0',
  `best` int NOT NULL DEFAULT '0',
  `average` int NOT NULL DEFAULT '0',
  `id` bigint NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`id`),
  KEY `InboxResults_fk_tournament` (`competitionId`),
  KEY `InboxResults_fk_event` (`eventId`),
  KEY `InboxResults_fk_format` (`formatId`),
  KEY `InboxResults_fk_round` (`roundTypeId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci PACK_KEYS=0;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `Persons`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Persons` (
  `id` int NOT NULL AUTO_INCREMENT,
  `wca_id` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `subId` tinyint NOT NULL DEFAULT '1',
  `name` varchar(80) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `countryId` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `gender` varchar(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT '',
  `dob` date DEFAULT NULL,
  `comments` varchar(40) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `incorrect_wca_id_claim_count` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_Persons_on_wca_id_and_subId` (`wca_id`,`subId`),
  KEY `Persons_fk_country` (`countryId`),
  KEY `Persons_id` (`wca_id`),
  KEY `Persons_name` (`name`),
  FULLTEXT KEY `index_Persons_on_name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=195497 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `RanksAverage`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `RanksAverage` (
  `id` int NOT NULL AUTO_INCREMENT,
  `personId` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `eventId` varchar(6) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `best` int NOT NULL DEFAULT '0',
  `worldRank` int NOT NULL DEFAULT '0',
  `continentRank` int NOT NULL DEFAULT '0',
  `countryRank` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `fk_persons` (`personId`),
  KEY `fk_events` (`eventId`)
) ENGINE=InnoDB AUTO_INCREMENT=924393568 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `RanksSingle`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `RanksSingle` (
  `id` int NOT NULL AUTO_INCREMENT,
  `personId` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `eventId` varchar(6) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `best` int NOT NULL DEFAULT '0',
  `worldRank` int NOT NULL DEFAULT '0',
  `continentRank` int NOT NULL DEFAULT '0',
  `countryRank` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `fk_persons` (`personId`),
  KEY `fk_events` (`eventId`)
) ENGINE=InnoDB AUTO_INCREMENT=1083455037 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `Results`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Results` (
  `id` int NOT NULL AUTO_INCREMENT,
  `pos` smallint NOT NULL DEFAULT '0',
  `personId` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `personName` varchar(80) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `countryId` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `competitionId` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `eventId` varchar(6) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `roundTypeId` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `formatId` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `value1` int NOT NULL DEFAULT '0',
  `value2` int NOT NULL DEFAULT '0',
  `value3` int NOT NULL DEFAULT '0',
  `value4` int NOT NULL DEFAULT '0',
  `value5` int NOT NULL DEFAULT '0',
  `best` int NOT NULL DEFAULT '0',
  `average` int NOT NULL DEFAULT '0',
  `regionalSingleRecord` char(3) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `regionalAverageRecord` char(3) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `Results_fk_tournament` (`competitionId`),
  KEY `Results_fk_event` (`eventId`),
  KEY `Results_fk_format` (`formatId`),
  KEY `Results_fk_round` (`roundTypeId`),
  KEY `Results_eventAndAverage` (`eventId`,`average`),
  KEY `Results_eventAndBest` (`eventId`,`best`),
  KEY `Results_regionalAverageRecordCheckSpeedup` (`eventId`,`competitionId`,`roundTypeId`,`countryId`,`average`),
  KEY `Results_regionalSingleRecordCheckSpeedup` (`eventId`,`competitionId`,`roundTypeId`,`countryId`,`best`),
  KEY `Results_fk_competitor` (`personId`),
  KEY `index_Results_on_competitionId_and_updated_at` (`competitionId`,`updated_at`),
  KEY `_tmp_index_Results_on_countryId` (`countryId`),
  KEY `index_Results_on_eventId_and_value1` (`eventId`,`value1`),
  KEY `index_Results_on_eventId_and_value2` (`eventId`,`value2`),
  KEY `index_Results_on_eventId_and_value3` (`eventId`,`value3`),
  KEY `index_Results_on_eventId_and_value4` (`eventId`,`value4`),
  KEY `index_Results_on_eventId_and_value5` (`eventId`,`value5`),
  KEY `index_Results_on_regionalSingleRecord_and_eventId` (`regionalSingleRecord`,`eventId`),
  KEY `index_Results_on_regionalAverageRecord_and_eventId` (`regionalAverageRecord`,`eventId`)
) ENGINE=InnoDB AUTO_INCREMENT=4957161 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci PACK_KEYS=1;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `RoundTypes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `RoundTypes` (
  `id` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `rank` int NOT NULL DEFAULT '0',
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `cellName` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `final` tinyint(1) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `Scrambles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Scrambles` (
  `scrambleId` int unsigned NOT NULL AUTO_INCREMENT,
  `competitionId` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `eventId` varchar(6) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `roundTypeId` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `groupId` varchar(3) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `isExtra` tinyint(1) NOT NULL,
  `scrambleNum` int NOT NULL,
  `scramble` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`scrambleId`),
  KEY `competitionId` (`competitionId`,`eventId`)
) ENGINE=InnoDB AUTO_INCREMENT=2722317 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `active_storage_attachments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `active_storage_attachments` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `record_type` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `record_id` bigint NOT NULL,
  `blob_id` bigint NOT NULL,
  `created_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_active_storage_attachments_uniqueness` (`record_type`,`record_id`,`name`,`blob_id`),
  KEY `index_active_storage_attachments_on_blob_id` (`blob_id`),
  CONSTRAINT `fk_rails_c3b3935057` FOREIGN KEY (`blob_id`) REFERENCES `active_storage_blobs` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `active_storage_blobs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `active_storage_blobs` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `key` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `filename` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `content_type` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `metadata` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `byte_size` bigint NOT NULL,
  `checksum` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `service_name` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_active_storage_blobs_on_key` (`key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `active_storage_variant_records`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `active_storage_variant_records` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `blob_id` bigint NOT NULL,
  `variation_digest` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_active_storage_variant_records_uniqueness` (`blob_id`,`variation_digest`),
  CONSTRAINT `fk_rails_993965df05` FOREIGN KEY (`blob_id`) REFERENCES `active_storage_blobs` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `ar_internal_metadata`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ar_internal_metadata` (
  `key` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `value` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `archive_phpbb3_forums`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `archive_phpbb3_forums` (
  `forum_id` mediumint unsigned NOT NULL AUTO_INCREMENT,
  `parent_id` mediumint unsigned NOT NULL DEFAULT '0',
  `left_id` mediumint unsigned NOT NULL DEFAULT '0',
  `right_id` mediumint unsigned NOT NULL DEFAULT '0',
  `forum_parents` mediumtext CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `forum_name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL DEFAULT '',
  `forum_desc` text CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `forum_desc_bitfield` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL DEFAULT '',
  `forum_desc_options` int unsigned NOT NULL DEFAULT '7',
  `forum_desc_uid` varchar(8) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL DEFAULT '',
  `forum_link` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL DEFAULT '',
  `forum_password` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL DEFAULT '',
  `forum_style` mediumint unsigned NOT NULL DEFAULT '0',
  `forum_image` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL DEFAULT '',
  `forum_rules` text CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `forum_rules_link` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL DEFAULT '',
  `forum_rules_bitfield` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL DEFAULT '',
  `forum_rules_options` int unsigned NOT NULL DEFAULT '7',
  `forum_rules_uid` varchar(8) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL DEFAULT '',
  `forum_topics_per_page` tinyint NOT NULL DEFAULT '0',
  `forum_type` tinyint NOT NULL DEFAULT '0',
  `forum_status` tinyint NOT NULL DEFAULT '0',
  `forum_last_post_id` mediumint unsigned NOT NULL DEFAULT '0',
  `forum_last_poster_id` mediumint unsigned NOT NULL DEFAULT '0',
  `forum_last_post_subject` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL DEFAULT '',
  `forum_last_post_time` int unsigned NOT NULL DEFAULT '0',
  `forum_last_poster_name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL DEFAULT '',
  `forum_last_poster_colour` varchar(6) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL DEFAULT '',
  `forum_flags` tinyint NOT NULL DEFAULT '32',
  `display_on_index` tinyint unsigned NOT NULL DEFAULT '1',
  `enable_indexing` tinyint unsigned NOT NULL DEFAULT '1',
  `enable_icons` tinyint unsigned NOT NULL DEFAULT '1',
  `enable_prune` tinyint unsigned NOT NULL DEFAULT '0',
  `prune_next` int unsigned NOT NULL DEFAULT '0',
  `prune_days` mediumint unsigned NOT NULL DEFAULT '0',
  `prune_viewed` mediumint unsigned NOT NULL DEFAULT '0',
  `prune_freq` mediumint unsigned NOT NULL DEFAULT '0',
  `display_subforum_list` tinyint unsigned NOT NULL DEFAULT '1',
  `forum_options` int unsigned NOT NULL DEFAULT '0',
  `forum_posts_approved` mediumint unsigned NOT NULL DEFAULT '0',
  `forum_posts_unapproved` mediumint unsigned NOT NULL DEFAULT '0',
  `forum_posts_softdeleted` mediumint unsigned NOT NULL DEFAULT '0',
  `forum_topics_approved` mediumint unsigned NOT NULL DEFAULT '0',
  `forum_topics_unapproved` mediumint unsigned NOT NULL DEFAULT '0',
  `forum_topics_softdeleted` mediumint unsigned NOT NULL DEFAULT '0',
  `enable_shadow_prune` tinyint unsigned NOT NULL DEFAULT '0',
  `prune_shadow_days` mediumint unsigned NOT NULL DEFAULT '7',
  `prune_shadow_freq` mediumint unsigned NOT NULL DEFAULT '1',
  `prune_shadow_next` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`forum_id`),
  KEY `left_right_id` (`left_id`,`right_id`),
  KEY `forum_lastpost_id` (`forum_last_post_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `archive_phpbb3_posts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `archive_phpbb3_posts` (
  `post_id` mediumint unsigned NOT NULL AUTO_INCREMENT,
  `topic_id` mediumint unsigned NOT NULL DEFAULT '0',
  `forum_id` mediumint unsigned NOT NULL DEFAULT '0',
  `poster_id` mediumint unsigned NOT NULL DEFAULT '0',
  `icon_id` mediumint unsigned NOT NULL DEFAULT '0',
  `poster_ip` varchar(40) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL DEFAULT '',
  `post_time` int unsigned NOT NULL DEFAULT '0',
  `post_reported` tinyint unsigned NOT NULL DEFAULT '0',
  `enable_bbcode` tinyint unsigned NOT NULL DEFAULT '1',
  `enable_smilies` tinyint unsigned NOT NULL DEFAULT '1',
  `enable_magic_url` tinyint unsigned NOT NULL DEFAULT '1',
  `enable_sig` tinyint unsigned NOT NULL DEFAULT '1',
  `post_username` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL DEFAULT '',
  `post_subject` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL DEFAULT '',
  `post_text` mediumtext CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `post_checksum` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL DEFAULT '',
  `post_attachment` tinyint unsigned NOT NULL DEFAULT '0',
  `bbcode_bitfield` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL DEFAULT '',
  `bbcode_uid` varchar(8) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL DEFAULT '',
  `post_postcount` tinyint unsigned NOT NULL DEFAULT '1',
  `post_edit_time` int unsigned NOT NULL DEFAULT '0',
  `post_edit_reason` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL DEFAULT '',
  `post_edit_user` mediumint unsigned NOT NULL DEFAULT '0',
  `post_edit_count` smallint unsigned NOT NULL DEFAULT '0',
  `post_edit_locked` tinyint unsigned NOT NULL DEFAULT '0',
  `post_visibility` tinyint NOT NULL DEFAULT '0',
  `post_delete_time` int unsigned NOT NULL DEFAULT '0',
  `post_delete_reason` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL DEFAULT '',
  `post_delete_user` mediumint unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`post_id`),
  KEY `forum_id` (`forum_id`),
  KEY `topic_id` (`topic_id`),
  KEY `poster_ip` (`poster_ip`),
  KEY `poster_id` (`poster_id`),
  KEY `tid_post_time` (`topic_id`,`post_time`),
  KEY `post_username` (`post_username`),
  KEY `post_visibility` (`post_visibility`),
  FULLTEXT KEY `post_subject` (`post_subject`),
  FULLTEXT KEY `post_content` (`post_text`,`post_subject`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `archive_phpbb3_topics`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `archive_phpbb3_topics` (
  `topic_id` mediumint unsigned NOT NULL AUTO_INCREMENT,
  `forum_id` mediumint unsigned NOT NULL DEFAULT '0',
  `icon_id` mediumint unsigned NOT NULL DEFAULT '0',
  `topic_attachment` tinyint unsigned NOT NULL DEFAULT '0',
  `topic_reported` tinyint unsigned NOT NULL DEFAULT '0',
  `topic_title` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL DEFAULT '',
  `topic_poster` mediumint unsigned NOT NULL DEFAULT '0',
  `topic_time` int unsigned NOT NULL DEFAULT '0',
  `topic_time_limit` int unsigned NOT NULL DEFAULT '0',
  `topic_views` mediumint unsigned NOT NULL DEFAULT '0',
  `topic_status` tinyint NOT NULL DEFAULT '0',
  `topic_type` tinyint NOT NULL DEFAULT '0',
  `topic_first_post_id` mediumint unsigned NOT NULL DEFAULT '0',
  `topic_first_poster_name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL DEFAULT '',
  `topic_first_poster_colour` varchar(6) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL DEFAULT '',
  `topic_last_post_id` mediumint unsigned NOT NULL DEFAULT '0',
  `topic_last_poster_id` mediumint unsigned NOT NULL DEFAULT '0',
  `topic_last_poster_name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL DEFAULT '',
  `topic_last_poster_colour` varchar(6) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL DEFAULT '',
  `topic_last_post_subject` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL DEFAULT '',
  `topic_last_post_time` int unsigned NOT NULL DEFAULT '0',
  `topic_last_view_time` int unsigned NOT NULL DEFAULT '0',
  `topic_moved_id` mediumint unsigned NOT NULL DEFAULT '0',
  `topic_bumped` tinyint unsigned NOT NULL DEFAULT '0',
  `topic_bumper` mediumint unsigned NOT NULL DEFAULT '0',
  `poll_title` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL DEFAULT '',
  `poll_start` int unsigned NOT NULL DEFAULT '0',
  `poll_length` int unsigned NOT NULL DEFAULT '0',
  `poll_max_options` tinyint NOT NULL DEFAULT '1',
  `poll_last_vote` int unsigned NOT NULL DEFAULT '0',
  `poll_vote_change` tinyint unsigned NOT NULL DEFAULT '0',
  `poll_vote_name` tinyint(1) NOT NULL DEFAULT '0',
  `topic_visibility` tinyint NOT NULL DEFAULT '0',
  `topic_delete_time` int unsigned NOT NULL DEFAULT '0',
  `topic_delete_reason` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL DEFAULT '',
  `topic_delete_user` mediumint unsigned NOT NULL DEFAULT '0',
  `topic_posts_approved` mediumint unsigned NOT NULL DEFAULT '0',
  `topic_posts_unapproved` mediumint unsigned NOT NULL DEFAULT '0',
  `topic_posts_softdeleted` mediumint unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`topic_id`),
  KEY `forum_id` (`forum_id`),
  KEY `forum_id_type` (`forum_id`,`topic_type`),
  KEY `last_post_time` (`topic_last_post_time`),
  KEY `fid_time_moved` (`forum_id`,`topic_last_post_time`,`topic_moved_id`),
  KEY `topic_visibility` (`topic_visibility`),
  KEY `forum_vis_last` (`forum_id`,`topic_visibility`,`topic_last_post_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `archive_phpbb3_users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `archive_phpbb3_users` (
  `user_id` mediumint unsigned NOT NULL AUTO_INCREMENT,
  `user_type` tinyint NOT NULL DEFAULT '0',
  `group_id` mediumint unsigned NOT NULL DEFAULT '3',
  `user_permissions` mediumtext CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `user_perm_from` mediumint unsigned NOT NULL DEFAULT '0',
  `user_ip` varchar(40) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL DEFAULT '',
  `user_regdate` int unsigned NOT NULL DEFAULT '0',
  `username` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL DEFAULT '',
  `username_clean` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL DEFAULT '',
  `user_password` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL DEFAULT '',
  `user_passchg` int unsigned NOT NULL DEFAULT '0',
  `user_email` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL DEFAULT '',
  `user_email_hash` bigint NOT NULL DEFAULT '0',
  `user_birthday` varchar(10) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL DEFAULT '',
  `user_lastvisit` int unsigned NOT NULL DEFAULT '0',
  `user_lastmark` int unsigned NOT NULL DEFAULT '0',
  `user_lastpost_time` int unsigned NOT NULL DEFAULT '0',
  `user_lastpage` varchar(200) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL DEFAULT '',
  `user_last_confirm_key` varchar(10) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL DEFAULT '',
  `user_last_search` int unsigned NOT NULL DEFAULT '0',
  `user_warnings` tinyint NOT NULL DEFAULT '0',
  `user_last_warning` int unsigned NOT NULL DEFAULT '0',
  `user_login_attempts` tinyint NOT NULL DEFAULT '0',
  `user_inactive_reason` tinyint NOT NULL DEFAULT '0',
  `user_inactive_time` int unsigned NOT NULL DEFAULT '0',
  `user_posts` mediumint unsigned NOT NULL DEFAULT '0',
  `user_lang` varchar(30) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL DEFAULT '',
  `user_timezone` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL DEFAULT '',
  `user_dateformat` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL DEFAULT 'd M Y H:i',
  `user_style` mediumint unsigned NOT NULL DEFAULT '0',
  `user_rank` mediumint unsigned NOT NULL DEFAULT '0',
  `user_colour` varchar(6) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL DEFAULT '',
  `user_new_privmsg` int NOT NULL DEFAULT '0',
  `user_unread_privmsg` int NOT NULL DEFAULT '0',
  `user_last_privmsg` int unsigned NOT NULL DEFAULT '0',
  `user_message_rules` tinyint unsigned NOT NULL DEFAULT '0',
  `user_full_folder` int NOT NULL DEFAULT '-3',
  `user_emailtime` int unsigned NOT NULL DEFAULT '0',
  `user_topic_show_days` smallint unsigned NOT NULL DEFAULT '0',
  `user_topic_sortby_type` varchar(1) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL DEFAULT 't',
  `user_topic_sortby_dir` varchar(1) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL DEFAULT 'd',
  `user_post_show_days` smallint unsigned NOT NULL DEFAULT '0',
  `user_post_sortby_type` varchar(1) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL DEFAULT 't',
  `user_post_sortby_dir` varchar(1) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL DEFAULT 'a',
  `user_notify` tinyint unsigned NOT NULL DEFAULT '0',
  `user_notify_pm` tinyint unsigned NOT NULL DEFAULT '1',
  `user_notify_type` tinyint NOT NULL DEFAULT '0',
  `user_allow_pm` tinyint unsigned NOT NULL DEFAULT '1',
  `user_allow_viewonline` tinyint unsigned NOT NULL DEFAULT '1',
  `user_allow_viewemail` tinyint unsigned NOT NULL DEFAULT '1',
  `user_allow_massemail` tinyint unsigned NOT NULL DEFAULT '1',
  `user_options` int unsigned NOT NULL DEFAULT '230271',
  `user_avatar` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL DEFAULT '',
  `user_avatar_type` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL DEFAULT '',
  `user_avatar_width` smallint unsigned NOT NULL DEFAULT '0',
  `user_avatar_height` smallint unsigned NOT NULL DEFAULT '0',
  `user_sig` mediumtext CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `user_sig_bbcode_uid` varchar(8) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL DEFAULT '',
  `user_sig_bbcode_bitfield` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL DEFAULT '',
  `user_jabber` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL DEFAULT '',
  `user_actkey` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL DEFAULT '',
  `user_newpasswd` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL DEFAULT '',
  `user_form_salt` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL DEFAULT '',
  `user_new` tinyint unsigned NOT NULL DEFAULT '1',
  `user_reminded` tinyint NOT NULL DEFAULT '0',
  `user_reminded_time` int unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `username_clean` (`username_clean`),
  KEY `user_birthday` (`user_birthday`),
  KEY `user_email_hash` (`user_email_hash`),
  KEY `user_type` (`user_type`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `archive_registrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `archive_registrations` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `competitionId` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `name` varchar(80) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `personId` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `countryId` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `gender` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `birthYear` smallint unsigned NOT NULL DEFAULT '0',
  `birthMonth` tinyint unsigned NOT NULL DEFAULT '0',
  `birthDay` tinyint unsigned NOT NULL DEFAULT '0',
  `email` varchar(80) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `guests_old` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `comments` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `ip` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `user_id` int DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `guests` int NOT NULL DEFAULT '0',
  `accepted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_registrations_on_competitionId_and_user_id` (`competitionId`,`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `assignments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `assignments` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `registration_id` bigint DEFAULT NULL,
  `schedule_activity_id` bigint DEFAULT NULL,
  `station_number` int DEFAULT NULL,
  `assignment_code` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_assignments_on_registration_id` (`registration_id`),
  KEY `index_assignments_on_schedule_activity_id` (`schedule_activity_id`)
) ENGINE=InnoDB AUTO_INCREMENT=7900722 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `bookmarked_competitions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `bookmarked_competitions` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `competition_id` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_id` int NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_bookmarked_competitions_on_competition_id` (`competition_id`),
  KEY `index_bookmarked_competitions_on_user_id` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=110427 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `cached_results`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cached_results` (
  `key_params` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `payload` json DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`key_params`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `championships`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `championships` (
  `id` int NOT NULL AUTO_INCREMENT,
  `competition_id` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `championship_type` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_championships_on_competition_id_and_championship_type` (`competition_id`,`championship_type`),
  KEY `index_championships_on_championship_type` (`championship_type`)
) ENGINE=InnoDB AUTO_INCREMENT=638 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `competition_delegates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `competition_delegates` (
  `id` int NOT NULL AUTO_INCREMENT,
  `competition_id` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `delegate_id` int DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `receive_registration_emails` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_competition_delegates_on_competition_id_and_delegate_id` (`competition_id`,`delegate_id`),
  KEY `index_competition_delegates_on_competition_id` (`competition_id`),
  KEY `index_competition_delegates_on_delegate_id` (`delegate_id`)
) ENGINE=InnoDB AUTO_INCREMENT=22087 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `competition_events`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `competition_events` (
  `id` int NOT NULL AUTO_INCREMENT,
  `competition_id` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `event_id` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `fee_lowest_denomination` int NOT NULL DEFAULT '0',
  `qualification` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_competition_events_on_competition_id_and_event_id` (`competition_id`,`event_id`),
  KEY `fk_rails_ba6cfdafb1` (`event_id`)
) ENGINE=InnoDB AUTO_INCREMENT=97781 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `competition_organizers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `competition_organizers` (
  `id` int NOT NULL AUTO_INCREMENT,
  `competition_id` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `organizer_id` int DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `receive_registration_emails` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_competition_organizers_on_competition_id_and_organizer_id` (`competition_id`,`organizer_id`),
  KEY `index_competition_organizers_on_competition_id` (`competition_id`),
  KEY `index_competition_organizers_on_organizer_id` (`organizer_id`)
) ENGINE=InnoDB AUTO_INCREMENT=23259 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `competition_series`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `competition_series` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `wcif_id` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `short_name` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=114 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `competition_tabs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `competition_tabs` (
  `id` int NOT NULL AUTO_INCREMENT,
  `competition_id` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `display_order` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_competition_tabs_on_display_order_and_competition_id` (`display_order`,`competition_id`)
) ENGINE=InnoDB AUTO_INCREMENT=29814 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `competition_venues`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `competition_venues` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `competition_id` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `wcif_id` int NOT NULL,
  `name` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `latitude_microdegrees` int NOT NULL,
  `longitude_microdegrees` int NOT NULL,
  `timezone_id` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `country_iso2` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_competition_venues_on_competition_id_and_wcif_id` (`competition_id`,`wcif_id`),
  KEY `index_competition_venues_on_competition_id` (`competition_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5632 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `completed_jobs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `completed_jobs` (
  `id` int NOT NULL AUTO_INCREMENT,
  `priority` int NOT NULL DEFAULT '0',
  `attempts` int NOT NULL DEFAULT '0',
  `handler` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `run_at` datetime DEFAULT NULL,
  `queue` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `completed_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `country_bands`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `country_bands` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `number` int NOT NULL,
  `iso2` varchar(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_country_bands_on_iso2` (`iso2`),
  KEY `index_country_bands_on_number` (`number`)
) ENGINE=InnoDB AUTO_INCREMENT=124 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `delayed_jobs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `delayed_jobs` (
  `id` int NOT NULL AUTO_INCREMENT,
  `priority` int NOT NULL DEFAULT '0',
  `attempts` int NOT NULL DEFAULT '0',
  `handler` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `last_error` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `run_at` datetime DEFAULT NULL,
  `locked_at` datetime DEFAULT NULL,
  `failed_at` datetime DEFAULT NULL,
  `locked_by` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `queue` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `delayed_jobs_priority` (`priority`,`run_at`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `delegate_reports`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `delegate_reports` (
  `id` int NOT NULL AUTO_INCREMENT,
  `competition_id` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `equipment` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `venue` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `organization` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `schedule_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `incidents` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `remarks` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `discussion_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `posted_by_user_id` int DEFAULT NULL,
  `posted_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `nag_sent_at` datetime DEFAULT NULL,
  `wrc_feedback_requested` tinyint(1) NOT NULL DEFAULT '0',
  `wrc_incidents` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `wdc_feedback_requested` tinyint(1) NOT NULL DEFAULT '0',
  `wdc_incidents` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `wrc_primary_user_id` int DEFAULT NULL,
  `wrc_secondary_user_id` int DEFAULT NULL,
  `reminder_sent_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_delegate_reports_on_competition_id` (`competition_id`)
) ENGINE=InnoDB AUTO_INCREMENT=11362 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `eligible_country_iso2s_for_championship`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `eligible_country_iso2s_for_championship` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `championship_type` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `eligible_country_iso2` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_eligible_iso2s_for_championship_on_type_and_country_iso2` (`championship_type`,`eligible_country_iso2`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `incident_competitions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `incident_competitions` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `incident_id` bigint NOT NULL,
  `competition_id` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `comments` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_incident_competitions_on_incident_id_and_competition_id` (`incident_id`,`competition_id`),
  KEY `index_incident_competitions_on_incident_id` (`incident_id`)
) ENGINE=InnoDB AUTO_INCREMENT=138 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `incident_tags`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `incident_tags` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `incident_id` bigint NOT NULL,
  `tag` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_incident_tags_on_incident_id_and_tag` (`incident_id`,`tag`),
  KEY `index_incident_tags_on_incident_id` (`incident_id`),
  KEY `index_incident_tags_on_tag` (`tag`)
) ENGINE=InnoDB AUTO_INCREMENT=163 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `incidents`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `incidents` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `title` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `private_description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `private_wrc_decision` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `public_summary` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `resolved_at` datetime DEFAULT NULL,
  `digest_worthy` tinyint(1) DEFAULT '0',
  `digest_sent_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=86 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `jwt_denylist`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `jwt_denylist` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `jti` varchar(191) COLLATE utf8mb3_unicode_ci NOT NULL,
  `exp` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_jwt_denylist_on_jti` (`jti`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `linkings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `linkings` (
  `wca_id` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `wca_ids` mediumtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  UNIQUE KEY `index_linkings_on_wca_id` (`wca_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `locations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `locations` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `latitude_microdegrees` int DEFAULT NULL,
  `longitude_microdegrees` int DEFAULT NULL,
  `notification_radius_km` int DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `oauth_access_grants`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `oauth_access_grants` (
  `id` int NOT NULL AUTO_INCREMENT,
  `resource_owner_id` int NOT NULL,
  `application_id` int NOT NULL,
  `token` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `expires_in` int NOT NULL,
  `redirect_uri` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `created_at` datetime NOT NULL,
  `revoked_at` datetime DEFAULT NULL,
  `scopes` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_oauth_access_grants_on_token` (`token`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `oauth_access_tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `oauth_access_tokens` (
  `id` int NOT NULL AUTO_INCREMENT,
  `resource_owner_id` int DEFAULT NULL,
  `application_id` int DEFAULT NULL,
  `token` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `refresh_token` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `expires_in` int DEFAULT NULL,
  `revoked_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `scopes` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_oauth_access_tokens_on_token` (`token`),
  UNIQUE KEY `index_oauth_access_tokens_on_refresh_token` (`refresh_token`),
  KEY `index_oauth_access_tokens_on_resource_owner_id` (`resource_owner_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `oauth_applications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `oauth_applications` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `uid` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `secret` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `redirect_uri` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `scopes` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `owner_id` int DEFAULT NULL,
  `owner_type` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `dangerously_allow_any_redirect_uri` tinyint(1) NOT NULL DEFAULT '0',
  `confidential` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_oauth_applications_on_uid` (`uid`),
  KEY `index_oauth_applications_on_owner_id_and_owner_type` (`owner_id`,`owner_type`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `poll_options`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `poll_options` (
  `id` int NOT NULL AUTO_INCREMENT,
  `description` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `poll_id` int NOT NULL,
  PRIMARY KEY (`id`),
  KEY `poll_id` (`poll_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `polls`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `polls` (
  `id` int NOT NULL AUTO_INCREMENT,
  `question` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `multiple` tinyint(1) NOT NULL,
  `deadline` datetime NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `comment` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `confirmed_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `post_tags`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `post_tags` (
  `id` int NOT NULL AUTO_INCREMENT,
  `post_id` int NOT NULL,
  `tag` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_post_tags_on_post_id_and_tag` (`post_id`,`tag`),
  KEY `index_post_tags_on_post_id` (`post_id`),
  KEY `index_post_tags_on_tag` (`tag`)
) ENGINE=InnoDB AUTO_INCREMENT=22452 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `posts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `posts` (
  `id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `body` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `slug` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `sticky` tinyint(1) NOT NULL DEFAULT '0',
  `author_id` int DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `show_on_homepage` tinyint(1) NOT NULL DEFAULT '1',
  `unstick_at` date DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_posts_on_slug` (`slug`),
  KEY `index_posts_on_world_readable_and_sticky_and_created_at` (`sticky`,`created_at`),
  KEY `index_posts_on_world_readable_and_created_at` (`created_at`),
  KEY `idx_show_wr_sticky_created_at` (`show_on_homepage`,`sticky`,`created_at`)
) ENGINE=InnoDB AUTO_INCREMENT=14104 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `preferred_formats`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `preferred_formats` (
  `event_id` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `format_id` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `ranking` int NOT NULL,
  UNIQUE KEY `index_preferred_formats_on_event_id_and_format_id` (`event_id`,`format_id`),
  KEY `fk_rails_c3e0098ed3` (`format_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `regional_organizations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `regional_organizations` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `country` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `website` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `email` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `address` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `directors_and_officers` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `area_description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `past_and_current_activities` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `future_plans` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `extra_information` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  PRIMARY KEY (`id`),
  KEY `index_regional_organizations_on_name` (`name`),
  KEY `index_regional_organizations_on_country` (`country`)
) ENGINE=InnoDB AUTO_INCREMENT=48 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `registration_competition_events`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `registration_competition_events` (
  `id` int NOT NULL AUTO_INCREMENT,
  `registration_id` int DEFAULT NULL,
  `competition_event_id` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_registration_competition_events_on_reg_id_and_comp_event_id` (`registration_id`,`competition_event_id`),
  KEY `index_reg_events_reg_id_comp_event_id` (`registration_id`,`competition_event_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3637966 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `registration_payments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `registration_payments` (
  `id` int NOT NULL AUTO_INCREMENT,
  `registration_id` int DEFAULT NULL,
  `amount_lowest_denomination` int DEFAULT NULL,
  `currency_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `receipt_id` bigint DEFAULT NULL,
  `receipt_type` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `stripe_charge_id` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `refunded_registration_payment_id` int DEFAULT NULL,
  `user_id` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_registration_payments_on_stripe_charge_id` (`stripe_charge_id`),
  KEY `idx_reg_payments_on_refunded_registration_payment_id` (`refunded_registration_payment_id`),
  KEY `index_registration_payments_on_receipt` (`receipt_type`,`receipt_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `registrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `registrations` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `competition_id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `comments` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `ip` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `user_id` int DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `guests` int NOT NULL DEFAULT '0',
  `accepted_at` datetime DEFAULT NULL,
  `accepted_by` int DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `deleted_by` int DEFAULT NULL,
  `roles` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `is_competing` tinyint(1) DEFAULT '1',
  `administrative_notes` text COLLATE utf8mb4_unicode_ci,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_registrations_on_competition_id_and_user_id` (`competition_id`,`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=680338 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `rounds`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `rounds` (
  `id` int NOT NULL AUTO_INCREMENT,
  `competition_event_id` int NOT NULL,
  `format_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `number` int NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `time_limit` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `cutoff` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `advancement_condition` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `scramble_set_count` int NOT NULL DEFAULT '1',
  `round_results` mediumtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `total_number_of_rounds` int NOT NULL,
  `old_type` varchar(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_rounds_on_competition_event_id_and_number` (`competition_event_id`,`number`)
) ENGINE=InnoDB AUTO_INCREMENT=810778 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `sanity_check_categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sanity_check_categories` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_sanity_check_categories_on_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `sanity_check_exclusions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sanity_check_exclusions` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `sanity_check_id` bigint NOT NULL,
  `exclusion` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `comments` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  PRIMARY KEY (`id`),
  KEY `fk_rails_c9112973d2` (`sanity_check_id`),
  CONSTRAINT `fk_rails_c9112973d2` FOREIGN KEY (`sanity_check_id`) REFERENCES `sanity_checks` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `sanity_checks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sanity_checks` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `sanity_check_category_id` bigint NOT NULL,
  `topic` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `comments` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `query` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_sanity_checks_on_topic` (`topic`),
  KEY `fk_rails_fddad5fbb5` (`sanity_check_category_id`),
  CONSTRAINT `fk_rails_fddad5fbb5` FOREIGN KEY (`sanity_check_category_id`) REFERENCES `sanity_check_categories` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `schedule_activities`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `schedule_activities` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `holder_type` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `holder_id` bigint NOT NULL,
  `wcif_id` int NOT NULL,
  `name` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `activity_code` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `start_time` datetime NOT NULL,
  `end_time` datetime NOT NULL,
  `scramble_set_id` int DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_activities_on_their_id_within_holder` (`holder_type`,`holder_id`,`wcif_id`),
  KEY `index_schedule_activities_on_holder_type_and_holder_id` (`holder_type`,`holder_id`)
) ENGINE=InnoDB AUTO_INCREMENT=328882 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `schema_migrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `schema_migrations` (
  `version` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  UNIQUE KEY `unique_schema_migrations` (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `starburst_announcement_views`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `starburst_announcement_views` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` int DEFAULT NULL,
  `announcement_id` int DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `starburst_announcement_view_index` (`user_id`,`announcement_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `starburst_announcements`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `starburst_announcements` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `title` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `body` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `start_delivering_at` datetime DEFAULT NULL,
  `stop_delivering_at` datetime DEFAULT NULL,
  `limit_to_users` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `category` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `stripe_payment_intents`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `stripe_payment_intents` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `holder_type` varchar(191) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `holder_id` bigint DEFAULT NULL,
  `stripe_transaction_id` bigint DEFAULT NULL,
  `client_secret` text COLLATE utf8mb3_unicode_ci,
  `error_details` text COLLATE utf8mb3_unicode_ci,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `user_id` int DEFAULT NULL,
  `confirmed_at` datetime(6) DEFAULT NULL,
  `confirmed_by_type` varchar(191) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `confirmed_by_id` bigint DEFAULT NULL,
  `canceled_at` datetime(6) DEFAULT NULL,
  `canceled_by_type` varchar(191) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `canceled_by_id` bigint DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_stripe_payment_intents_on_holder` (`holder_type`,`holder_id`),
  KEY `index_stripe_payment_intents_on_stripe_transaction_id` (`stripe_transaction_id`),
  KEY `index_stripe_payment_intents_on_user_id` (`user_id`),
  KEY `index_stripe_payment_intents_on_confirmed_by` (`confirmed_by_type`,`confirmed_by_id`),
  KEY `index_stripe_payment_intents_on_canceled_by` (`canceled_by_type`,`canceled_by_id`),
  CONSTRAINT `fk_rails_2dbc373c0c` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_rails_81f3af31de` FOREIGN KEY (`stripe_transaction_id`) REFERENCES `stripe_transactions` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `stripe_transactions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `stripe_transactions` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `api_type` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `stripe_id` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `parameters` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `amount_stripe_denomination` int DEFAULT NULL,
  `currency_code` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `error` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `account_id` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `parent_transaction_id` bigint DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_stripe_transactions_on_status` (`status`),
  KEY `fk_rails_6ad225b020` (`parent_transaction_id`),
  CONSTRAINT `fk_rails_6ad225b020` FOREIGN KEY (`parent_transaction_id`) REFERENCES `stripe_transactions` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `stripe_webhook_events`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `stripe_webhook_events` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `stripe_id` varchar(191) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `event_type` varchar(191) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `account_id` varchar(191) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `handled` tinyint(1) DEFAULT NULL,
  `stripe_transaction_id` bigint DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_stripe_webhook_events_on_stripe_transaction_id` (`stripe_transaction_id`),
  CONSTRAINT `fk_rails_44a72b44fd` FOREIGN KEY (`stripe_transaction_id`) REFERENCES `stripe_transactions` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `team_members`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `team_members` (
  `id` int NOT NULL AUTO_INCREMENT,
  `team_id` int NOT NULL,
  `user_id` int NOT NULL,
  `start_date` date NOT NULL,
  `end_date` date DEFAULT NULL,
  `team_leader` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `team_senior_member` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=628 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `teams`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `teams` (
  `id` int NOT NULL AUTO_INCREMENT,
  `friendly_id` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `email` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `hidden` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `index_teams_on_friendly_id` (`friendly_id`)
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `timestamps`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `timestamps` (
  `name` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `date` datetime DEFAULT NULL,
  UNIQUE KEY `index_timestamps_on_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `uploaded_jsons`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `uploaded_jsons` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `competition_id` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `json_str` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  PRIMARY KEY (`id`),
  KEY `index_uploaded_jsons_on_competition_id` (`competition_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `user_preferred_events`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_preferred_events` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int DEFAULT NULL,
  `event_id` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_user_preferred_events_on_user_id_and_event_id` (`user_id`,`event_id`)
) ENGINE=InnoDB AUTO_INCREMENT=295276 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `users` (
  `id` int NOT NULL AUTO_INCREMENT,
  `email` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `encrypted_password` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `reset_password_token` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `reset_password_sent_at` datetime DEFAULT NULL,
  `remember_created_at` datetime DEFAULT NULL,
  `sign_in_count` int NOT NULL DEFAULT '0',
  `current_sign_in_at` datetime DEFAULT NULL,
  `last_sign_in_at` datetime DEFAULT NULL,
  `current_sign_in_ip` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `last_sign_in_ip` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `confirmation_token` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `confirmed_at` datetime DEFAULT NULL,
  `confirmation_sent_at` datetime DEFAULT NULL,
  `unconfirmed_email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `delegate_status` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `senior_delegate_id` int DEFAULT NULL,
  `region` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `wca_id` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `avatar` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `pending_avatar` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `saved_avatar_crop_x` int DEFAULT NULL,
  `saved_avatar_crop_y` int DEFAULT NULL,
  `saved_avatar_crop_w` int DEFAULT NULL,
  `saved_avatar_crop_h` int DEFAULT NULL,
  `saved_pending_avatar_crop_x` int DEFAULT NULL,
  `saved_pending_avatar_crop_y` int DEFAULT NULL,
  `saved_pending_avatar_crop_w` int DEFAULT NULL,
  `saved_pending_avatar_crop_h` int DEFAULT NULL,
  `unconfirmed_wca_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `delegate_id_to_handle_wca_id_claim` int DEFAULT NULL,
  `dob` date DEFAULT NULL,
  `gender` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `country_iso2` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `results_notifications_enabled` tinyint(1) DEFAULT '0',
  `preferred_locale` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `competition_notifications_enabled` tinyint(1) DEFAULT NULL,
  `receive_delegate_reports` tinyint(1) NOT NULL DEFAULT '0',
  `dummy_account` tinyint(1) NOT NULL DEFAULT '0',
  `consumed_timestep` int DEFAULT NULL,
  `otp_required_for_login` tinyint(1) DEFAULT '0',
  `otp_backup_codes` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `session_validity_token` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `cookies_acknowledged` tinyint(1) NOT NULL DEFAULT '0',
  `registration_notifications_enabled` tinyint(1) DEFAULT '0',
  `otp_secret` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_users_on_email` (`email`),
  UNIQUE KEY `index_users_on_reset_password_token` (`reset_password_token`),
  UNIQUE KEY `index_users_on_wca_id` (`wca_id`),
  KEY `index_users_on_senior_delegate_id` (`senior_delegate_id`),
  KEY `index_users_on_delegate_id_to_handle_wca_id_claim` (`delegate_id_to_handle_wca_id_claim`)
) ENGINE=InnoDB AUTO_INCREMENT=355530 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `venue_rooms`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `venue_rooms` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `competition_venue_id` bigint NOT NULL,
  `wcif_id` int NOT NULL,
  `name` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `color` varchar(7) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_venue_rooms_on_competition_venue_id_and_wcif_id` (`competition_venue_id`,`wcif_id`),
  KEY `index_venue_rooms_on_competition_venue_id` (`competition_venue_id`)
) ENGINE=InnoDB AUTO_INCREMENT=6927 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `vote_options`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `vote_options` (
  `id` int NOT NULL AUTO_INCREMENT,
  `vote_id` int NOT NULL,
  `poll_option_id` int NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `votes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `votes` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `comment` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `poll_id` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_votes_on_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `wcif_extensions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `wcif_extensions` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `extendable_type` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `extendable_id` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `extension_id` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `spec_url` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `data` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_wcif_extensions_on_extendable_type_and_extendable_id` (`extendable_type`,`extendable_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

INSERT INTO `schema_migrations` (version) VALUES
('20150501004846'),
('20150504022234'),
('20150504163657'),
('20150520080634'),
('20150521000833'),
('20150521001340'),
('20150521005227'),
('20150521225109'),
('20150526035517'),
('20150601061358'),
('20150601224750'),
('20150602044759'),
('20150602062127'),
('20150602233220'),
('20150603015039'),
('20150718020058'),
('20150718020123'),
('20150806172310'),
('20150812014543'),
('20150819064257'),
('20150821164902'),
('20150826003626'),
('20150831195312'),
('20150903083847'),
('20150904062512'),
('20150908183742'),
('20150924011143'),
('20150924011919'),
('20150924155057'),
('20151001191340'),
('20151008211834'),
('20151014220307'),
('20151116195414'),
('20151117183214'),
('20151119063335'),
('20151119072940'),
('20151207230222'),
('20151209003851'),
('20151213232440'),
('20151214000352'),
('20151215193124'),
('20151217001125'),
('20151217054555'),
('20151217062612'),
('20151222013017'),
('20151230174411'),
('20160109070723'),
('20160120071503'),
('20160128023834'),
('20160218135313'),
('20160218234447'),
('20160223204831'),
('20160224013453'),
('20160303144700'),
('20160305170821'),
('20160406192349'),
('20160407005537'),
('20160407210623'),
('20160504170758'),
('20160504230105'),
('20160505231300'),
('20160513162613'),
('20160514124545'),
('20160514141051'),
('20160517140653'),
('20160518020433'),
('20160518045741'),
('20160520230353'),
('20160528071910'),
('20160531124049'),
('20160602105428'),
('20160610191605'),
('20160616183719'),
('20160627215744'),
('20160701034833'),
('20160705120632'),
('20160705121551'),
('20160727000015'),
('20160731181145'),
('20160811013347'),
('20160825124202'),
('20160831212003'),
('20160901120254'),
('20160902230822'),
('20160914122252'),
('20160930213354'),
('20161011005956'),
('20161018220122'),
('20161026201019'),
('20161031215932'),
('20161108081416'),
('20161108210423'),
('20161117085757'),
('20161118141833'),
('20161122014040'),
('20161122162029'),
('20161201211133'),
('20161206204738'),
('20161212200704'),
('20161221205552'),
('20161226223701'),
('20161227202950'),
('20170121202850'),
('20170212005142'),
('20170215221832'),
('20170223153915'),
('20170228140556'),
('20170320222511'),
('20170402223714'),
('20170404184332'),
('20170406170418'),
('20170417072301'),
('20170418171035'),
('20170421204700'),
('20170426145811'),
('20170502232234'),
('20170503205810'),
('20170510071858'),
('20170516002944'),
('20170517192919'),
('20170517194354'),
('20170517213035'),
('20170518011526'),
('20170523034604'),
('20170523185221'),
('20170524221221'),
('20170524224533'),
('20170624115851'),
('20170629134754'),
('20170726133627'),
('20170801010739'),
('20170812120421'),
('20170816115449'),
('20170816143703'),
('20170818141716'),
('20170818164058'),
('20170820023104'),
('20170823170616'),
('20170823203113'),
('20170824082448'),
('20170824133352'),
('20170830140540'),
('20170831170616'),
('20170916165728'),
('20171006182851'),
('20171113154922'),
('20171119143749'),
('20171122010954'),
('20171122220857'),
('20171124184454'),
('20171219000023'),
('20171219200237'),
('20171219204656'),
('20171221184910'),
('20171222100000'),
('20171222182940'),
('20180104132335'),
('20180107142301'),
('20180120132926'),
('20180201005000'),
('20180205000001'),
('20180205000002'),
('20180205000003'),
('20180206211650'),
('20180403194359'),
('20180526084857'),
('20180528130810'),
('20180621093155'),
('20180623171213'),
('20180629112054'),
('20180701160042'),
('20180703172949'),
('20180705231137'),
('20180708214503'),
('20180709220826'),
('20180710165401'),
('20180711124055'),
('20180729000001'),
('20180730182509'),
('20180731204733'),
('20180822165331'),
('20180825114051'),
('20180825115701'),
('20180831075355'),
('20180831164420'),
('20180908195553'),
('20180911140010'),
('20180912042457'),
('20181020004209'),
('20181021185003'),
('20181022031135'),
('20181109172930'),
('20181122233823'),
('20181208145408'),
('20181209171137'),
('20181222224850'),
('20181226115357'),
('20190105215446'),
('20190112130723'),
('20190113180945'),
('20190117112257'),
('20190124180224'),
('20190208175255'),
('20190216102110'),
('20190221194112'),
('20190514234342'),
('20190601105825'),
('20190601231550'),
('20190622173635'),
('20190716065618'),
('20190728084145'),
('20190803202212'),
('20190806173355'),
('20190814232833'),
('20190816001639'),
('20190816004605'),
('20190817170648'),
('20190817193315'),
('20190818102517'),
('20190825095512'),
('20190826005902'),
('20190916133253'),
('20191005203556'),
('20191013211511'),
('20191107212356'),
('20200125180554'),
('20200206012756'),
('20200304044931'),
('20200319193625'),
('20200331082313'),
('20200415151734'),
('20200419133415'),
('20200502095048'),
('20200522095030'),
('20200522125145'),
('20200607140007'),
('20200627195628'),
('20200725152218'),
('20201020193829'),
('20210129181657'),
('20210221190945'),
('20210301002636'),
('20210325202019'),
('20210501213332'),
('20210506205912'),
('20210521195423'),
('20210727081850'),
('20210802065056'),
('20211031152615'),
('20211031152616'),
('20211031152617'),
('20211031154101'),
('20211210100657'),
('20220223163446'),
('20220223163447'),
('20220511025003'),
('20220516124717'),
('20220619200832'),
('20220623121810'),
('20220627195217'),
('20220630233246'),
('20220706232200'),
('20220725045202'),
('20220725045819'),
('20220804193822'),
('20220822232936'),
('20220916132536'),
('20221121111430'),
('20221123090104'),
('20221123121220'),
('20221224215048'),
('20230119115432'),
('20230204111111'),
('20230303093411'),
('20230311165116'),
('20230311183558'),
('20230312182740'),
('20230315170143'),
('20230515103948'),
('20230517135741'),
('20230520171858'),
('20230520173123'),
('20230606180813'),
('20230701100417');


