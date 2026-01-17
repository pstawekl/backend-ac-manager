-- MySQL dump 10.13  Distrib 8.0.35, for Linux (x86_64)
--
-- Host: localhost    Database: m1204_acmanager
-- ------------------------------------------------------
-- Server version	8.0.35-0ubuntu0.23.04.1

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
-- Table structure for table `auth_group`
--

DROP TABLE IF EXISTS `auth_group`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `auth_group` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(150) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auth_group`
--

LOCK TABLES `auth_group` WRITE;
/*!40000 ALTER TABLE `auth_group` DISABLE KEYS */;
/*!40000 ALTER TABLE `auth_group` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `auth_group_permissions`
--

DROP TABLE IF EXISTS `auth_group_permissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `auth_group_permissions` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `group_id` int NOT NULL,
  `permission_id` int NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `auth_group_permissions_group_id_permission_id_0cd325b0_uniq` (`group_id`,`permission_id`),
  KEY `auth_group_permissio_permission_id_84c5c92e_fk_auth_perm` (`permission_id`),
  CONSTRAINT `auth_group_permissio_permission_id_84c5c92e_fk_auth_perm` FOREIGN KEY (`permission_id`) REFERENCES `auth_permission` (`id`),
  CONSTRAINT `auth_group_permissions_group_id_b120cbf9_fk_auth_group_id` FOREIGN KEY (`group_id`) REFERENCES `auth_group` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auth_group_permissions`
--

LOCK TABLES `auth_group_permissions` WRITE;
/*!40000 ALTER TABLE `auth_group_permissions` DISABLE KEYS */;
/*!40000 ALTER TABLE `auth_group_permissions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `auth_permission`
--

DROP TABLE IF EXISTS `auth_permission`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `auth_permission` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `content_type_id` int NOT NULL,
  `codename` varchar(100) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `auth_permission_content_type_id_codename_01ab375a_uniq` (`content_type_id`,`codename`),
  CONSTRAINT `auth_permission_content_type_id_2f476e4b_fk_django_co` FOREIGN KEY (`content_type_id`) REFERENCES `django_content_type` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=129 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auth_permission`
--

LOCK TABLES `auth_permission` WRITE;
/*!40000 ALTER TABLE `auth_permission` DISABLE KEYS */;
INSERT INTO `auth_permission` VALUES (1,'Can add log entry',1,'add_logentry'),(2,'Can change log entry',1,'change_logentry'),(3,'Can delete log entry',1,'delete_logentry'),(4,'Can view log entry',1,'view_logentry'),(5,'Can add permission',2,'add_permission'),(6,'Can change permission',2,'change_permission'),(7,'Can delete permission',2,'delete_permission'),(8,'Can view permission',2,'view_permission'),(9,'Can add group',3,'add_group'),(10,'Can change group',3,'change_group'),(11,'Can delete group',3,'delete_group'),(12,'Can view group',3,'view_group'),(13,'Can add user',4,'add_user'),(14,'Can change user',4,'change_user'),(15,'Can delete user',4,'delete_user'),(16,'Can view user',4,'view_user'),(17,'Can add content type',5,'add_contenttype'),(18,'Can change content type',5,'change_contenttype'),(19,'Can delete content type',5,'delete_contenttype'),(20,'Can view content type',5,'view_contenttype'),(21,'Can add session',6,'add_session'),(22,'Can change session',6,'change_session'),(23,'Can delete session',6,'delete_session'),(24,'Can view session',6,'view_session'),(25,'Can add ac user',7,'add_acuser'),(26,'Can change ac user',7,'change_acuser'),(27,'Can delete ac user',7,'delete_acuser'),(28,'Can view ac user',7,'view_acuser'),(29,'Can add device multi split',8,'add_devicemultisplit'),(30,'Can change device multi split',8,'change_devicemultisplit'),(31,'Can delete device multi split',8,'delete_devicemultisplit'),(32,'Can view device multi split',8,'view_devicemultisplit'),(33,'Can add device split',9,'add_devicesplit'),(34,'Can change device split',9,'change_devicesplit'),(35,'Can delete device split',9,'delete_devicesplit'),(36,'Can view device split',9,'view_devicesplit'),(37,'Can add group',10,'add_group'),(38,'Can change group',10,'change_group'),(39,'Can delete group',10,'delete_group'),(40,'Can view group',10,'view_group'),(41,'Can add instalacja',11,'add_instalacja'),(42,'Can change instalacja',11,'change_instalacja'),(43,'Can delete instalacja',11,'delete_instalacja'),(44,'Can view instalacja',11,'view_instalacja'),(45,'Can add tag',12,'add_tag'),(46,'Can change tag',12,'change_tag'),(47,'Can delete tag',12,'delete_tag'),(48,'Can view tag',12,'view_tag'),(49,'Can add user data',13,'add_userdata'),(50,'Can change user data',13,'change_userdata'),(51,'Can delete user data',13,'delete_userdata'),(52,'Can view user data',13,'view_userdata'),(53,'Can add ulotka',14,'add_ulotka'),(54,'Can change ulotka',14,'change_ulotka'),(55,'Can delete ulotka',14,'delete_ulotka'),(56,'Can view ulotka',14,'view_ulotka'),(57,'Can add task',15,'add_task'),(58,'Can change task',15,'change_task'),(59,'Can delete task',15,'delete_task'),(60,'Can view task',15,'view_task'),(61,'Can add szkolenie',16,'add_szkolenie'),(62,'Can change szkolenie',16,'change_szkolenie'),(63,'Can delete szkolenie',16,'delete_szkolenie'),(64,'Can view szkolenie',16,'view_szkolenie'),(65,'Can add serwis',17,'add_serwis'),(66,'Can change serwis',17,'change_serwis'),(67,'Can delete serwis',17,'delete_serwis'),(68,'Can view serwis',17,'view_serwis'),(69,'Can add rabat',18,'add_rabat'),(70,'Can change rabat',18,'change_rabat'),(71,'Can delete rabat',18,'delete_rabat'),(72,'Can view rabat',18,'view_rabat'),(73,'Can add photo',19,'add_photo'),(74,'Can change photo',19,'change_photo'),(75,'Can delete photo',19,'delete_photo'),(76,'Can view photo',19,'view_photo'),(77,'Can add narzut',20,'add_narzut'),(78,'Can change narzut',20,'change_narzut'),(79,'Can delete narzut',20,'delete_narzut'),(80,'Can view narzut',20,'view_narzut'),(81,'Can add montaz',21,'add_montaz'),(82,'Can change montaz',21,'change_montaz'),(83,'Can delete montaz',21,'delete_montaz'),(84,'Can view montaz',21,'view_montaz'),(85,'Can add katalog',22,'add_katalog'),(86,'Can change katalog',22,'change_katalog'),(87,'Can delete katalog',22,'delete_katalog'),(88,'Can view katalog',22,'view_katalog'),(89,'Can add inspekcja',23,'add_inspekcja'),(90,'Can change inspekcja',23,'change_inspekcja'),(91,'Can delete inspekcja',23,'delete_inspekcja'),(92,'Can view inspekcja',23,'view_inspekcja'),(93,'Can add certificate',24,'add_certificate'),(94,'Can change certificate',24,'change_certificate'),(95,'Can delete certificate',24,'delete_certificate'),(96,'Can view certificate',24,'view_certificate'),(97,'Can add cennik',25,'add_cennik'),(98,'Can change cennik',25,'change_cennik'),(99,'Can delete cennik',25,'delete_cennik'),(100,'Can view cennik',25,'view_cennik'),(101,'Can add Token',26,'add_token'),(102,'Can change Token',26,'change_token'),(103,'Can delete Token',26,'delete_token'),(104,'Can view Token',26,'view_token'),(105,'Can add token',27,'add_tokenproxy'),(106,'Can change token',27,'change_tokenproxy'),(107,'Can delete token',27,'delete_tokenproxy'),(108,'Can view token',27,'view_tokenproxy'),(109,'Can add oferta',28,'add_oferta'),(110,'Can change oferta',28,'change_oferta'),(111,'Can delete oferta',28,'delete_oferta'),(112,'Can view oferta',28,'view_oferta'),(113,'Can add szablon',29,'add_szablon'),(114,'Can change szablon',29,'change_szablon'),(115,'Can delete szablon',29,'delete_szablon'),(116,'Can view szablon',29,'view_szablon'),(117,'Can add zadanie',30,'add_zadanie'),(118,'Can change zadanie',30,'change_zadanie'),(119,'Can delete zadanie',30,'delete_zadanie'),(120,'Can view zadanie',30,'view_zadanie'),(121,'Can add invoice settings',31,'add_invoicesettings'),(122,'Can change invoice settings',31,'change_invoicesettings'),(123,'Can delete invoice settings',31,'delete_invoicesettings'),(124,'Can view invoice settings',31,'view_invoicesettings'),(125,'Can add faktury',32,'add_faktury'),(126,'Can change faktury',32,'change_faktury'),(127,'Can delete faktury',32,'delete_faktury'),(128,'Can view faktury',32,'view_faktury');
/*!40000 ALTER TABLE `auth_permission` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `auth_user`
--

DROP TABLE IF EXISTS `auth_user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `auth_user` (
  `id` int NOT NULL AUTO_INCREMENT,
  `password` varchar(128) NOT NULL,
  `last_login` datetime(6) DEFAULT NULL,
  `is_superuser` tinyint(1) NOT NULL,
  `username` varchar(150) NOT NULL,
  `first_name` varchar(150) NOT NULL,
  `last_name` varchar(150) NOT NULL,
  `email` varchar(254) NOT NULL,
  `is_staff` tinyint(1) NOT NULL,
  `is_active` tinyint(1) NOT NULL,
  `date_joined` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auth_user`
--

LOCK TABLES `auth_user` WRITE;
/*!40000 ALTER TABLE `auth_user` DISABLE KEYS */;
/*!40000 ALTER TABLE `auth_user` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `auth_user_groups`
--

DROP TABLE IF EXISTS `auth_user_groups`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `auth_user_groups` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `group_id` int NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `auth_user_groups_user_id_group_id_94350c0c_uniq` (`user_id`,`group_id`),
  KEY `auth_user_groups_group_id_97559544_fk_auth_group_id` (`group_id`),
  CONSTRAINT `auth_user_groups_group_id_97559544_fk_auth_group_id` FOREIGN KEY (`group_id`) REFERENCES `auth_group` (`id`),
  CONSTRAINT `auth_user_groups_user_id_6a12ed8b_fk_auth_user_id` FOREIGN KEY (`user_id`) REFERENCES `auth_user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auth_user_groups`
--

LOCK TABLES `auth_user_groups` WRITE;
/*!40000 ALTER TABLE `auth_user_groups` DISABLE KEYS */;
/*!40000 ALTER TABLE `auth_user_groups` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `auth_user_user_permissions`
--

DROP TABLE IF EXISTS `auth_user_user_permissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `auth_user_user_permissions` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `permission_id` int NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `auth_user_user_permissions_user_id_permission_id_14a6b632_uniq` (`user_id`,`permission_id`),
  KEY `auth_user_user_permi_permission_id_1fbb5f2c_fk_auth_perm` (`permission_id`),
  CONSTRAINT `auth_user_user_permi_permission_id_1fbb5f2c_fk_auth_perm` FOREIGN KEY (`permission_id`) REFERENCES `auth_permission` (`id`),
  CONSTRAINT `auth_user_user_permissions_user_id_a95ead1b_fk_auth_user_id` FOREIGN KEY (`user_id`) REFERENCES `auth_user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auth_user_user_permissions`
--

LOCK TABLES `auth_user_user_permissions` WRITE;
/*!40000 ALTER TABLE `auth_user_user_permissions` DISABLE KEYS */;
/*!40000 ALTER TABLE `auth_user_user_permissions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `authtoken_token`
--

DROP TABLE IF EXISTS `authtoken_token`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `authtoken_token` (
  `key` varchar(40) NOT NULL,
  `created` datetime(6) NOT NULL,
  `user_id` int NOT NULL,
  PRIMARY KEY (`key`),
  UNIQUE KEY `user_id` (`user_id`),
  CONSTRAINT `authtoken_token_user_id_35299eff_fk_auth_user_id` FOREIGN KEY (`user_id`) REFERENCES `auth_user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `authtoken_token`
--

LOCK TABLES `authtoken_token` WRITE;
/*!40000 ALTER TABLE `authtoken_token` DISABLE KEYS */;
/*!40000 ALTER TABLE `authtoken_token` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `django_admin_log`
--

DROP TABLE IF EXISTS `django_admin_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `django_admin_log` (
  `id` int NOT NULL AUTO_INCREMENT,
  `action_time` datetime(6) NOT NULL,
  `object_id` longtext,
  `object_repr` varchar(200) NOT NULL,
  `action_flag` smallint unsigned NOT NULL,
  `change_message` longtext NOT NULL,
  `content_type_id` int DEFAULT NULL,
  `user_id` int NOT NULL,
  PRIMARY KEY (`id`),
  KEY `django_admin_log_content_type_id_c4bce8eb_fk_django_co` (`content_type_id`),
  KEY `django_admin_log_user_id_c564eba6_fk_auth_user_id` (`user_id`),
  CONSTRAINT `django_admin_log_content_type_id_c4bce8eb_fk_django_co` FOREIGN KEY (`content_type_id`) REFERENCES `django_content_type` (`id`),
  CONSTRAINT `django_admin_log_user_id_c564eba6_fk_auth_user_id` FOREIGN KEY (`user_id`) REFERENCES `auth_user` (`id`),
  CONSTRAINT `django_admin_log_chk_1` CHECK ((`action_flag` >= 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `django_admin_log`
--

LOCK TABLES `django_admin_log` WRITE;
/*!40000 ALTER TABLE `django_admin_log` DISABLE KEYS */;
/*!40000 ALTER TABLE `django_admin_log` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `django_content_type`
--

DROP TABLE IF EXISTS `django_content_type`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `django_content_type` (
  `id` int NOT NULL AUTO_INCREMENT,
  `app_label` varchar(100) NOT NULL,
  `model` varchar(100) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `django_content_type_app_label_model_76bd3d3b_uniq` (`app_label`,`model`)
) ENGINE=InnoDB AUTO_INCREMENT=33 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `django_content_type`
--

LOCK TABLES `django_content_type` WRITE;
/*!40000 ALTER TABLE `django_content_type` DISABLE KEYS */;
INSERT INTO `django_content_type` VALUES (1,'admin','logentry'),(3,'auth','group'),(2,'auth','permission'),(4,'auth','user'),(26,'authtoken','token'),(27,'authtoken','tokenproxy'),(5,'contenttypes','contenttype'),(7,'klima','acuser'),(25,'klima','cennik'),(24,'klima','certificate'),(8,'klima','devicemultisplit'),(9,'klima','devicesplit'),(32,'klima','faktury'),(10,'klima','group'),(23,'klima','inspekcja'),(11,'klima','instalacja'),(31,'klima','invoicesettings'),(22,'klima','katalog'),(21,'klima','montaz'),(20,'klima','narzut'),(28,'klima','oferta'),(19,'klima','photo'),(18,'klima','rabat'),(17,'klima','serwis'),(29,'klima','szablon'),(16,'klima','szkolenie'),(12,'klima','tag'),(15,'klima','task'),(14,'klima','ulotka'),(13,'klima','userdata'),(30,'klima','zadanie'),(6,'sessions','session');
/*!40000 ALTER TABLE `django_content_type` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `django_migrations`
--

DROP TABLE IF EXISTS `django_migrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `django_migrations` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `app` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `applied` datetime(6) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=47 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `django_migrations`
--

LOCK TABLES `django_migrations` WRITE;
/*!40000 ALTER TABLE `django_migrations` DISABLE KEYS */;
INSERT INTO `django_migrations` VALUES (1,'contenttypes','0001_initial','2023-09-20 06:26:36.326839'),(2,'auth','0001_initial','2023-09-20 06:26:36.741358'),(3,'admin','0001_initial','2023-09-20 06:26:36.849317'),(4,'admin','0002_logentry_remove_auto_add','2023-09-20 06:26:36.866028'),(5,'admin','0003_logentry_add_action_flag_choices','2023-09-20 06:26:36.878093'),(6,'contenttypes','0002_remove_content_type_name','2023-09-20 06:26:36.950005'),(7,'auth','0002_alter_permission_name_max_length','2023-09-20 06:26:37.013892'),(8,'auth','0003_alter_user_email_max_length','2023-09-20 06:26:37.045993'),(9,'auth','0004_alter_user_username_opts','2023-09-20 06:26:37.056704'),(10,'auth','0005_alter_user_last_login_null','2023-09-20 06:26:37.098051'),(11,'auth','0006_require_contenttypes_0002','2023-09-20 06:26:37.103031'),(12,'auth','0007_alter_validators_add_error_messages','2023-09-20 06:26:37.125015'),(13,'auth','0008_alter_user_username_max_length','2023-09-20 06:26:37.182328'),(14,'auth','0009_alter_user_last_name_max_length','2023-09-20 06:26:37.231374'),(15,'auth','0010_alter_group_name_max_length','2023-09-20 06:26:37.256056'),(16,'auth','0011_update_proxy_permissions','2023-09-20 06:26:37.267970'),(17,'auth','0012_alter_user_first_name_max_length','2023-09-20 06:26:37.313914'),(18,'authtoken','0001_initial','2023-09-20 06:26:37.367708'),(19,'authtoken','0002_auto_20160226_1747','2023-09-20 06:26:37.403061'),(20,'authtoken','0003_tokenproxy','2023-09-20 06:26:37.407496'),(21,'klima','0001_initial','2023-09-20 06:26:38.791385'),(22,'sessions','0001_initial','2023-09-20 06:26:38.825255'),(23,'klima','0002_rename_gloscnosc_devicemultisplit_glosnosc_and_more','2023-09-20 07:19:34.188178'),(24,'klima','0003_rename_klasa_energetyczna_chlodznie_devicemultisplit_klasa_energetyczna_chlodzenie_and_more','2023-09-20 07:20:42.120980'),(25,'klima','0004_alter_inspekcja_instalacja_and_more','2023-09-26 14:53:04.474737'),(26,'klima','0005_serwis_czyszczenie_filtrow_jedn_wew_and_more','2023-09-26 15:34:08.676161'),(27,'klima','0006_oferta','2023-09-29 08:54:03.813047'),(28,'klima','0007_rename_kod_producenta_devicemultisplit_nazwa_modelu_producenta','2023-09-29 11:07:56.719733'),(29,'klima','0008_rename_brand_rabat_name','2023-09-29 12:45:19.091143'),(30,'klima','0009_oferta_narzut_oferta_rabat','2023-09-29 13:05:46.868848'),(31,'klima','0010_alter_userdata_kod_pocztowy_alter_userdata_miasto_and_more','2023-10-06 12:07:51.171375'),(32,'klima','0011_szablon','2023-10-20 10:11:48.057707'),(33,'klima','0012_remove_szablon_rabaty_szablon_owner','2023-10-20 11:35:36.801265'),(34,'klima','0013_userdata_mieszkanie','2023-10-26 09:57:55.866407'),(35,'klima','0014_rename_name_rabat_producent','2023-10-26 10:35:00.438093'),(36,'klima','0015_zadanie','2023-10-26 11:02:10.116578'),(37,'klima','0016_zadanie_instalacja_alter_zadanie_grupa','2023-10-26 11:25:34.662055'),(38,'klima','0017_alter_narzut_options_narzut_order','2023-11-16 09:41:51.514717'),(39,'klima','0018_remove_montaz_device_multisplit_and_more','2023-11-20 14:36:29.083481'),(40,'klima','0019_invoicesettings','2023-11-22 09:40:49.613422'),(41,'klima','0020_alter_invoicesettings_day_format_and_more','2023-11-22 10:19:41.803586'),(42,'klima','0021_invoicesettings_iban','2023-11-22 10:36:00.552130'),(43,'klima','0022_faktury','2023-11-22 11:34:50.182570'),(44,'klima','0023_faktury_id_fakturowni','2023-11-22 12:07:32.471693'),(45,'klima','0024_faktury_numer_faktury','2023-11-23 09:07:52.126397'),(46,'klima','0025_faktury_status','2023-11-23 10:11:35.214730');
/*!40000 ALTER TABLE `django_migrations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `django_session`
--

DROP TABLE IF EXISTS `django_session`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `django_session` (
  `session_key` varchar(40) NOT NULL,
  `session_data` longtext NOT NULL,
  `expire_date` datetime(6) NOT NULL,
  PRIMARY KEY (`session_key`),
  KEY `django_session_expire_date_a5c62663` (`expire_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `django_session`
--

LOCK TABLES `django_session` WRITE;
/*!40000 ALTER TABLE `django_session` DISABLE KEYS */;
/*!40000 ALTER TABLE `django_session` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `klima_acuser`
--

DROP TABLE IF EXISTS `klima_acuser`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `klima_acuser` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `first_name` varchar(255) NOT NULL,
  `last_name` varchar(255) NOT NULL,
  `email` varchar(254) NOT NULL,
  `password` varchar(128) NOT NULL,
  `url` varchar(200) NOT NULL,
  `user_type` varchar(10) NOT NULL,
  `hash_value` varchar(128) NOT NULL,
  `group_id` bigint DEFAULT NULL,
  `parent_id` bigint DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`),
  KEY `klima_acuser_group_id_dc18c234_fk_klima_group_id` (`group_id`),
  KEY `klima_acuser_parent_id_614c4962_fk_klima_acuser_id` (`parent_id`),
  CONSTRAINT `klima_acuser_group_id_dc18c234_fk_klima_group_id` FOREIGN KEY (`group_id`) REFERENCES `klima_group` (`id`),
  CONSTRAINT `klima_acuser_parent_id_614c4962_fk_klima_acuser_id` FOREIGN KEY (`parent_id`) REFERENCES `klima_acuser` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=52 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `klima_acuser`
--

LOCK TABLES `klima_acuser` WRITE;
/*!40000 ALTER TABLE `klima_acuser` DISABLE KEYS */;
INSERT INTO `klima_acuser` VALUES (3,'admin','admin','konrad@gmail.com','pbkdf2_sha256$600000$GfQIk6MHH9rk8KxBJxZMWn$1UxvyIQW0NqKt4CBSmGFqTGGfXFmic8VLlqSTqOjrTs=','http://51.68.143.33/static/default_user.png','admin','eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjozLCJleHAiOjE3MDI1MDMxMzJ9.eLV3jbP01qP_xhkoeMCeplcD9OG1y6gXj0L-UrTZ5Pg',NULL,NULL),(4,'admin','admin','aplikacjaklima.technik@gmail.com','pbkdf2_sha256$600000$K2ioFyKnAyXGaadXWsckIC$PtoBp2+w4r9VaoXWx9AIzWDducYXeVqJR0L3FxCK3kI=','http://51.68.143.33/static/default_user.png','admin','eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjo0LCJleHAiOjE2OTU3OTYzMDB9.fPrA_bsFhmUwsJiTBHROyMF86uGkMiIDeyIR6_tJf38',NULL,NULL),(5,'Jmk','Bhk','Gvfhj@mn.ml','aaa','http://51.68.143.33/static/default_user.png','klient','eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjo1LCJleHAiOjE2OTU4MTc5MTl9.6-5qy6_0Yfb0navwZxGbAIAV7DL7bAIy7B7IDE8_MRI',NULL,NULL),(6,'Jan','Janowski','Jan@janowski.com','aaa','http://51.68.143.33/static/default_user.png','klient','eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjo2LCJleHAiOjE2OTU5NDI3NTV9.D5FvMz6qTLndIq2spKfoqLGftrDIkDHJR3zkuUb_raQ',NULL,NULL),(7,'Tomek','Tomaszowski','tomek@tomek.com','aaa','http://51.68.143.33/static/default_user.png','monter','eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjo3LCJleHAiOjE2OTY4Nzc2NDZ9.Mb9K1W02sJnvtheQxH5D9oTlnKrnL6zRCCsUDvgD308',NULL,3),(8,'Janek','Janek','Janek@janek.com','aaa','http://51.68.143.33/static/default_user.png','klient','eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjo4LCJleHAiOjE2OTY4ODA4Njh9.xAUccyTtzQpTey_33u93Ujf1obeo7hzXGeRrXEwMePQ',NULL,NULL),(9,'Bhghnhg','Gggjjh','Testowy@gmail.com','aaa','http://51.68.143.33/static/default_user.png','klient','eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjo5LCJleHAiOjE2OTY5MzA2MzZ9.ZdsUlLEQHO4FeSimDQRxehbf2BNa24LEwUVZfXNQ2vU',NULL,NULL),(10,'aaa','Testtt','Testowanie@gmail.com','aaa','http://51.68.143.33/static/default_user.png','klient','eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoxMCwiZXhwIjoxNjk2OTM3ODI2fQ.tZQJyJiU5XWLssBUbbijpj_Ng9dlcUwJ3vqMKcg_6w8',NULL,NULL),(11,'Andrzej','Kowalski','akowalski@gmail.com','aaa','http://51.68.143.33/static/default_user.png','klient','eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoxMSwiZXhwIjoxNjk2OTM5MjMxfQ.K5olNR-Y7lDdGyC54VIqNvrGPP87YoYK5FERp-BfL2M',NULL,NULL),(16,'Nowy','User','Cmsnsjja@gmail.com','pbkdf2_sha256$600000$sw3pCuSXVhja7Ca8MR2tyM$7bbwYyt3C7Q0LyH19FQZzVXhbJTmzQhz3qmzAsGEKYI=','http://51.68.143.33/static/default_user.png','klient','eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoxNiwiZXhwIjoxNjk2OTQ4NTM0fQ.AFKX9Dxo6_u6RHI5btjjCaH7c0pRScS_6Ez7SYnFcCc',NULL,NULL),(17,'Mateusz','Testowy','Dhshabhzbzh@gmail.com','pbkdf2_sha256$600000$cDZzCvxoh9ov0MLzfxbjb0$rVGayyGPKCLf8SfY1TST/t+f9beyZpd1B7CePyOLqYI=','http://51.68.143.33/static/default_user.png','klient','eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoxNywiZXhwIjoxNjk2OTQ5MTExfQ.gdZ2SMHHLYjXITKUV1DGtbSbF_unZ5UenVAt0dBTA3M',NULL,NULL),(18,'Dhhsjabba','Shhzjajan','Bdhahsbsbba@gmail.com','pbkdf2_sha256$600000$sEvVFpj7g7ttHcpQM2RmBR$p2dztE3eFcH5cjmoMUTzQlAUNWJtBH8N/FhHp4W3RhQ=','http://51.68.143.33/static/default_user.png','klient','eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoxOCwiZXhwIjoxNjk2OTQ5NDAzfQ.5VeUtjfHUYs40imFpgFyK4iPm-MwCt4AGQLB5m3fdY0',NULL,NULL),(19,'Ejhdhajsjns','Hdhajajja','bdhahzbabNa@gmail.com','pbkdf2_sha256$600000$QIBeYLaeswsYIFUTi7BnIl$s5bk2EplwNeGYVVwdvh/UTjjklTSBQLxCetdbKeXCMI=','http://51.68.143.33/static/default_user.png','klient','eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoxOSwiZXhwIjoxNjk2OTQ5NTE4fQ.nyDxFlq3KI6Qx6i67oMx7rg3kwBlAeYzf7RsulLAV5w',NULL,NULL),(20,'Jdjajjajsb','HzhsjJab','fhhsjajcjhaja@gmail.com','pbkdf2_sha256$600000$XLO9zcY3YkjHSVJr47ZSpF$mkSjrjQUe3GHCKLoj3xQHwEP2zKdUS7jHfPY8iuSFio=','http://51.68.143.33/static/default_user.png','klient','eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoyMCwiZXhwIjoxNjk2OTQ5NzUyfQ.tMvtgXMOSlj2ZCtwUw77CZhsYGK5jltA1lHt-ok1pUI',NULL,NULL),(22,'Testtt','Testtt','testownia@gmail.com','pbkdf2_sha256$600000$XopKxHcQ0tAaYc1xd03qEG$dtTnqUAfv6TG7TW9rKfw1l7CLIh/MO/hZwaUaZLQggo=','http://51.68.143.33/static/default_user.png','klient','eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoyMiwiZXhwIjoxNjk3MTk4OTIwfQ.UQrxwFBA2WVnULwfiTAUwi4mRNXdfLRIk53p3_J1AUw',NULL,NULL),(23,'Pofjjshs','Xbajjs','Gdhxjagag@gmail.com','pbkdf2_sha256$600000$5uqRLCarZQ9tISTOcQdQ4U$/OW/hAlYiycVqvVoSQWgmBGX5/HwwAKy908TdtDKzrU=','http://51.68.143.33/static/default_user.png','klient','eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoyMywiZXhwIjoxNjk3MTk5OTg2fQ.aappTTxQ8vntuMOhuNghgp2847RM6X4hMsZmtfHTShM',NULL,NULL),(24,'Jdjfjaja','Cjjajsjs','Hxhajhcjs@gmail.com','pbkdf2_sha256$600000$RX8xufCNHZkbhs4IZfCo5m$CnTzp0ARLi3qG5brycpsbkUJvYNvQEx8rjj+Dn1d21s=','http://51.68.143.33/static/default_user.png','klient','eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoyNCwiZXhwIjoxNjk3MjAwMTAwfQ.Or-jZAo1OX0BxzDdbNRVfw_IymPLPANHJvdGZq80nrQ',NULL,NULL),(25,'Hhhhh','Bbbbb','Test@test.pl','pbkdf2_sha256$600000$HQfDauEeL8BtSi16eFO8HX$ihMGhIrW1505aH0yMopKW1T+I9BVOZ4rLLUma1s2azI=','http://51.68.143.33/static/default_user.png','klient','eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoyNSwiZXhwIjoxNjk3MjI0NTE4fQ.eV4QMil40oi6O0jE3uUHLAEe91QQWWmK2iYV4TYGxPo',NULL,NULL),(26,'Alex','Dżordż','alex@gmail.com','pbkdf2_sha256$600000$ePW0oYGnoYupki1H0L9O1l$TMoEWyBWgrCwoJIGv37ewinwlhFTCe6ITZG12NMuiB0=','http://51.68.143.33/static/default_user.png','klient','eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoyNiwiZXhwIjoxNjk3Mjc4MDEwfQ.0E0Cy31Tyt6541N3XkYj3XGMIaWvCgYC8VNYrDWVfT8',NULL,NULL),(27,'Zdzisiek','Rychly','zdrych@gmail.com','pbkdf2_sha256$600000$UF4qHDTpbz4hj9InpWQjTH$YCDzQZR/bgWGNhUgNus3JWcGCa3iddBWR9kEYkgS7HQ=','http://51.68.143.33/static/default_user.png','klient','eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoyNywiZXhwIjoxNjk3MzA3Mzc3fQ.V8Avy77A7nuSu8Vq2oac2KWbgIZLr2B2awuUTum6_Ak',NULL,NULL),(29,'Jan','Janowski','Jan@jan.co','aaa','http://51.68.143.33/static/default_user.png','monter','eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoyOSwiZXhwIjoxNjk5MzEzNTAwfQ.7Cv-AHrbc4UCYtdzm2yl4KSZzXnaxzmOjZYX3DuyTUc',NULL,3),(43,'Krzysztof','Testowy','krzystestowy@mail.com','pbkdf2_sha256$600000$r6kmaJHnSPB0ihywUOHgZ2$s7qiwAWZADtgaSmH4PumhV50mIvC0d+jc/EAZrKH4Lc=','http://51.68.143.33/static/default_user.png','klient','eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjo0MywiZXhwIjoxNzAxMTY0ODIyfQ.DajxwXF0GR7fxYRaYnaqfnq1GydOYpH76dDBTc52Nt8',NULL,NULL),(44,'Mateusz','Testowy','testowymati@gmail.com','pbkdf2_sha256$600000$BES2tLuqYcWhegDZC2JP05$rkl+YK6JQySkbOyfSz5iQAhsTkPSRwST3G2FkjpZFwU=','http://51.68.143.33/static/default_user.png','klient','eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjo0NCwiZXhwIjoxNzAxMjYxMTQ5fQ.lGfZ2ELJfZ-71F5ocuT0ZKezT6tgBft-QIV5TY4N0RU',NULL,NULL),(45,'Mateusz','Testowy','testowymati123@gmail.com','pbkdf2_sha256$600000$jrBQDtgltxMO6A27MDrQVt$2GR8Rxz0PdVtqES6WJ1PAcQqbrE16Ox4Lh+gJabPLzk=','http://51.68.143.33/static/default_user.png','klient','eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjo0NSwiZXhwIjoxNzAxMjYxNDg1fQ.wpShnBxlAXFsih1Vx9kQ_8EGZWQTT8aItbCWXTmly1Y',NULL,NULL),(46,'Ahmed','Nazarov','Ahmedcieokradnje@gmail.com','aaa','http://51.68.143.33/static/default_user.png','monter','eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjo0NiwiZXhwIjoxNzAxMzM2MDc2fQ.04WDfMzKVHJnsb-j9tnt0KLHeS633QlBhhIxV2mr5UA',NULL,3),(47,'Fs','Hj','Hsjej@gmail.com','pbkdf2_sha256$600000$UWUw9jqvshjyCzfSbni7ND$PW99ZzBWY5Mq/Edvk1Oak5TdGSL1HQdVmn3JLYtYr9s=','http://51.68.143.33/static/default_user.png','klient','eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjo0NywiZXhwIjoxNzAxMzM2NDQ5fQ.5j_qJKo89bpMLZTA4PFqDnjkTl2-emMjS3mZJTE-CCU',NULL,NULL),(48,'Shbdnans','Dnnsnan','Dnnsnsj@mail.com','aaa','http://51.68.143.33/static/default_user.png','monter','eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjo0OCwiZXhwIjoxNzAxMzU1NTkwfQ.yCe89yWB4xejqkXh5BoVF1tTm8Wni6O6ryaG21fK-EQ',2,3),(49,'Test','Testowy','fhsjjrjsjaj@gmail.com','aaa','http://51.68.143.33/static/default_user.png','monter','eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjo0OSwiZXhwIjoxNzAxNDI1NzE4fQ.Obif9U6VRW6Dhgf_lW1s_6eBDDx0IduPH3xwv8icDcg',3,3),(50,'Krzysztof','Kowalski','krzysztof@kowalski.com','pbkdf2_sha256$600000$hAmudJQwRnMAbzuEn5RoAn$s3VV/YCKshjH1VFp7h4vOJTs+uc+Yv48pfiFuzmVEhU=','http://51.68.143.33/static/default_user.png','klient','eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjo1MCwiZXhwIjoxNzAxNzIzOTkwfQ.bMJr3GiKvPC2VYWcUfjf_ns3I0onKMwYGFVJLeJVI50',NULL,NULL),(51,'Jacek','Winnik','Jacek@winnik.com','pbkdf2_sha256$600000$2QPjq8VtCmUcW8h7Tq3SOt$ZeUGfx1aN0WlY3er+dvExZDKblaJ9QUWUS1Uaj51Uds=','http://51.68.143.33/static/default_user.png','klient','eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjo1MSwiZXhwIjoxNzAxNzI0MTI2fQ.CDXXzfNKA6UFlvOLw7dZbD1GhAo4yhwSuXTV24LsYmo',NULL,NULL);
/*!40000 ALTER TABLE `klima_acuser` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `klima_acuser_monter`
--

DROP TABLE IF EXISTS `klima_acuser_monter`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `klima_acuser_monter` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `from_acuser_id` bigint NOT NULL,
  `to_acuser_id` bigint NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `klima_acuser_monter_from_acuser_id_to_acuser_id_cefa5dec_uniq` (`from_acuser_id`,`to_acuser_id`),
  KEY `klima_acuser_monter_to_acuser_id_2db08743_fk_klima_acuser_id` (`to_acuser_id`),
  CONSTRAINT `klima_acuser_monter_from_acuser_id_f637a926_fk_klima_acuser_id` FOREIGN KEY (`from_acuser_id`) REFERENCES `klima_acuser` (`id`),
  CONSTRAINT `klima_acuser_monter_to_acuser_id_2db08743_fk_klima_acuser_id` FOREIGN KEY (`to_acuser_id`) REFERENCES `klima_acuser` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=26 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `klima_acuser_monter`
--

LOCK TABLES `klima_acuser_monter` WRITE;
/*!40000 ALTER TABLE `klima_acuser_monter` DISABLE KEYS */;
INSERT INTO `klima_acuser_monter` VALUES (2,6,3),(6,11,3),(25,51,3);
/*!40000 ALTER TABLE `klima_acuser_monter` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `klima_cennik`
--

DROP TABLE IF EXISTS `klima_cennik`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `klima_cennik` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `file` varchar(100) NOT NULL,
  `created_date` datetime(6) NOT NULL,
  `is_active` tinyint(1) NOT NULL,
  `ac_user_id` bigint NOT NULL,
  PRIMARY KEY (`id`),
  KEY `klima_cennik_ac_user_id_bdc66b7d_fk_klima_acuser_id` (`ac_user_id`),
  CONSTRAINT `klima_cennik_ac_user_id_bdc66b7d_fk_klima_acuser_id` FOREIGN KEY (`ac_user_id`) REFERENCES `klima_acuser` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `klima_cennik`
--

LOCK TABLES `klima_cennik` WRITE;
/*!40000 ALTER TABLE `klima_cennik` DISABLE KEYS */;
INSERT INTO `klima_cennik` VALUES (3,'Cennik','documents/cenniki/3/sample_L3RIrb3_r6fSbwp.pdf','2023-09-21 10:54:17.570892',1,3),(5,'Cennik 2 test','documents/cenniki/3/sample_y5g947w.pdf','2023-11-14 09:27:56.305304',1,3);
/*!40000 ALTER TABLE `klima_cennik` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `klima_certificate`
--

DROP TABLE IF EXISTS `klima_certificate`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `klima_certificate` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `file` varchar(100) NOT NULL,
  `created_date` datetime(6) NOT NULL,
  `set_date` datetime(6) NOT NULL,
  `ac_user_id` bigint NOT NULL,
  PRIMARY KEY (`id`),
  KEY `klima_certificate_ac_user_id_13cf1626_fk_klima_acuser_id` (`ac_user_id`),
  CONSTRAINT `klima_certificate_ac_user_id_13cf1626_fk_klima_acuser_id` FOREIGN KEY (`ac_user_id`) REFERENCES `klima_acuser` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `klima_certificate`
--

LOCK TABLES `klima_certificate` WRITE;
/*!40000 ALTER TABLE `klima_certificate` DISABLE KEYS */;
INSERT INTO `klima_certificate` VALUES (3,'Testowy','documents/certificates/3/sample_y5g947w.pdf','2023-10-05 11:27:09.712873','2023-10-03 12:26:56.994000',3);
/*!40000 ALTER TABLE `klima_certificate` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `klima_devicemultisplit`
--

DROP TABLE IF EXISTS `klima_devicemultisplit`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `klima_devicemultisplit` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `data` datetime(6) DEFAULT NULL,
  `producent` varchar(255) DEFAULT NULL,
  `rodzaj` varchar(255) DEFAULT NULL,
  `maks_ilosc_jedn_wew` int DEFAULT NULL,
  `typ_jedn_zew` varchar(255) DEFAULT NULL,
  `typ_jedn_wew` varchar(255) DEFAULT NULL,
  `moc_chlodnicza` decimal(8,2) DEFAULT NULL,
  `moc_grzewcza` decimal(8,2) DEFAULT NULL,
  `model_nazwa` varchar(255) DEFAULT NULL,
  `nazwa_modelu_producenta` varchar(255) DEFAULT NULL,
  `nazwa_jedn_wew` varchar(255) DEFAULT NULL,
  `nazwa_jedn_zew` varchar(255) DEFAULT NULL,
  `cena_katalogowa_netto` decimal(8,2) DEFAULT NULL,
  `kolor` varchar(255) DEFAULT NULL,
  `glosnosc` decimal(8,2) DEFAULT NULL,
  `wielkosc_wew` decimal(8,2) DEFAULT NULL,
  `wielkosc_zew` decimal(8,2) DEFAULT NULL,
  `klasa_energetyczna_chlodzenie` varchar(255) DEFAULT NULL,
  `klasa_energetyczna_grzanie` varchar(255) DEFAULT NULL,
  `sterowanie_wifi` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=500 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `klima_devicemultisplit`
--

LOCK TABLES `klima_devicemultisplit` WRITE;
/*!40000 ALTER TABLE `klima_devicemultisplit` DISABLE KEYS */;
INSERT INTO `klima_devicemultisplit` VALUES (1,'2023-03-01 00:00:00.000000','AUX','agregat',2,'zewnętrzna','',4.10,4.80,'','AUX-M2-14LCLH','','AUX-M2-14LCLH',4290.00,'',NULL,NULL,NULL,NULL,NULL,0),(2,'2023-03-02 00:00:00.000000','AUX','agregat',2,'zewnętrzna','',5.30,5.60,'','AUX-M2-18LCLH','','AUX-M2-18LCLH',4990.00,'',NULL,NULL,NULL,NULL,NULL,0),(3,'2023-03-03 00:00:00.000000','AUX','agregat',2,'zewnętrzna','',6.20,6.60,'','AUX-M3-21LCLH','','AUX-M3-21LCLH',6090.00,'',NULL,NULL,NULL,NULL,NULL,0),(4,'2023-03-04 00:00:00.000000','AUX','agregat',3,'zewnętrzna','',7.90,8.20,'','AUX-M3-27LCLH','','AUX-M3-27LCLH',6690.00,'',NULL,NULL,NULL,NULL,NULL,0),(5,'2023-03-05 00:00:00.000000','AUX','agregat',4,'zewnętrzna','',10.50,11.00,'','AUX-M4-36LCLH','','AUX-M4-36LCLH',9890.00,'',NULL,NULL,NULL,NULL,NULL,0),(6,'2023-03-06 00:00:00.000000','AUX','agregat',5,'zewnętrzna','',12.00,13.00,'','AUX-M5-42LCLH','','AUX-M5-42LCLH',10690.00,'',NULL,NULL,NULL,NULL,NULL,0),(7,'2023-03-07 00:00:00.000000','AUX','wewnęrzna',0,'wewnęrzna','naścienny',2.05,2.15,'Freedom','AUX-07FH/I','AUX-07FH/I','',1150.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(8,'2023-03-08 00:00:00.000000','AUX','wewnęrzna',0,'wewnęrzna','naścienny',2.58,2.70,'Freedom','AUX-09FH/I','AUX-09FH/I','',1250.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(9,'2023-03-09 00:00:00.000000','AUX','wewnęrzna',0,'wewnęrzna','naścienny',3.50,3.50,'Freedom','AUX-12FH/I','AUX-12FH/I','',1350.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(10,'2023-03-10 00:00:00.000000','AUX','wewnęrzna',0,'wewnęrzna','naścienny',5.00,5.37,'Freedom','AUX-18FH/I','AUX-18FH/I','',1500.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(11,'2023-03-11 00:00:00.000000','AUX','wewnęrzna',0,'wewnęrzna','naścienny',6.50,6.50,'Freedom','AUX-24FH/I','AUX-24FH/I','',1600.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(12,'2023-03-12 00:00:00.000000','AUX','wewnęrzna',0,'wewnęrzna','naścienny',2.05,2.15,'J-Smart','AUX-07JO/I','AUX-07JO/I','',1390.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(13,'2023-03-13 00:00:00.000000','AUX','wewnęrzna',0,'wewnęrzna','naścienny',2.58,2.70,'J-Smart','AUX-09JO/I','AUX-09JO/I','',1490.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(14,'2023-03-14 00:00:00.000000','AUX','wewnęrzna',0,'wewnęrzna','naścienny',3.50,3.50,'J-Smart','AUX-12JO/I','AUX-12JO/I','',1590.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(15,'2023-03-15 00:00:00.000000','AUX','wewnęrzna',0,'wewnęrzna','naścienny',5.27,5.37,'J-Smart','AUX-18JO/I','AUX-18JO/I','',1790.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(16,'2023-03-16 00:00:00.000000','AUX','wewnęrzna',0,'wewnęrzna','naścienny',7.03,7.05,'J-Smart','AUX-24JO/I','AUX-24JO/I','',2090.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(17,'2023-03-17 00:00:00.000000','AUX','wewnęrzna',0,'wewnęrzna','naścienny',2.05,2.15,'J-Smart Art','AUX-07JB/I','AUX-07JB/I','',1550.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(18,'2023-03-18 00:00:00.000000','AUX','wewnęrzna',0,'wewnęrzna','naścienny',2.58,2.70,'J-Smart Art','AUX-09JB/I','AUX-09JB/I','',1650.00,'czarny',NULL,NULL,NULL,NULL,NULL,0),(19,'2023-03-19 00:00:00.000000','AUX','wewnęrzna',0,'wewnęrzna','naścienny',3.50,3.50,'J-Smart Art','AUX-12JB/I','AUX-12JB/I','',1750.00,'czarny',NULL,NULL,NULL,NULL,NULL,0),(20,'2023-03-20 00:00:00.000000','AUX','wewnęrzna',0,'wewnęrzna','naścienny',5.27,5.37,'J-Smart Art','AUX-18JB/I','AUX-18JB/I','',1890.00,'czarny',NULL,NULL,NULL,NULL,NULL,0),(21,'2023-03-21 00:00:00.000000','AUX','wewnęrzna',0,'wewnęrzna','naścienny',7.03,7.05,'J-Smart Art','AUX-24JB/I','AUX-24JB/I','',2190.00,'czarny',NULL,NULL,NULL,NULL,NULL,0),(22,'2023-03-22 00:00:00.000000','AUX','wewnęrzna',0,'wewnęrzna','przypodłogowy',2.80,3.00,'Przypodlogowy MF','AUX-M-F09/I','AUX-M-F09/I','',2190.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(23,'2023-03-23 00:00:00.000000','AUX','wewnęrzna',0,'wewnęrzna','przypodłogowy',3.60,3.90,'Przypodlogowy MF','AUX-M-F12/I','AUX-M-F12/I','',2290.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(24,'2023-03-24 00:00:00.000000','AUX','wewnęrzna',0,'wewnęrzna','przypodłogowy',5.30,5.80,'Przypodlogowy MF','AUX-M-F18/I','AUX-M-F18/I','',2390.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(25,'2023-03-25 00:00:00.000000','AUX','wewnęrzna',0,'wewnęrzna','kasetonowy',2.80,3.00,'Kasetonowy MC','AUX-M-C09/I','AUX-M-C09/I','',2390.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(26,'2023-03-26 00:00:00.000000','AUX','wewnęrzna',0,'wewnęrzna','kasetonowy',3.60,3.90,'Kasetonowy MC','AUX-M-C12/I','AUX-M-C12/I','',2490.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(27,'2023-03-27 00:00:00.000000','AUX','wewnęrzna',0,'wewnęrzna','kasetonowy',5.00,5.60,'Kasetonowy MC','AUX-M-C18/I','AUX-M-C18/I','',2590.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(28,'2023-03-28 00:00:00.000000','AUX','wewnęrzna',0,'wewnęrzna','kanałowy',2.20,2.50,'Kanałowy MD','AUX-M-D07/I','AUX-M-D07/I','',1690.00,'',NULL,NULL,NULL,NULL,NULL,0),(29,'2023-03-29 00:00:00.000000','AUX','wewnęrzna',0,'wewnęrzna','kanałowy',2.60,2.90,'Kanałowy MD','AUX-M-D09/I','AUX-M-D09/I','',1790.00,'',NULL,NULL,NULL,NULL,NULL,0),(30,'2023-03-30 00:00:00.000000','AUX','wewnęrzna',0,'wewnęrzna','kanałowy',3.60,4.00,'Kanałowy MD','AUX-M-D12/I','AUX-M-D12/I','',1890.00,'',NULL,NULL,NULL,NULL,NULL,0),(31,'2023-03-31 00:00:00.000000','AUX','wewnęrzna',0,'wewnęrzna','kanałowy',5.10,5.80,'Kanałowy MD','AUX-M-D18/I','AUX-M-D18/I','',2090.00,'',NULL,NULL,NULL,NULL,NULL,0),(32,'2023-04-01 00:00:00.000000','AUX','wewnęrzna',0,'wewnęrzna','konsola',2.60,2.80,'Konsola MK','AUX-M-K09/I','AUX-M-K09/I','',1790.00,'',NULL,NULL,NULL,NULL,NULL,0),(33,'2023-04-02 00:00:00.000000','AUX','wewnęrzna',0,'wewnęrzna','konsola',3.50,3.80,'Konsola MK','AUX-M-K12/I','AUX-M-K12/I','',1890.00,'',NULL,NULL,NULL,NULL,NULL,0),(34,'2023-04-03 00:00:00.000000','AUX','wewnęrzna',0,'wewnęrzna','konsola',4.10,4.50,'Konsola MK','AUX-M-K18/I','AUX-M-K18/I','',1990.00,'',NULL,NULL,NULL,NULL,NULL,0),(35,'2023-04-05 00:00:00.000000','LG','agregat',2,'zewnętrzna','',4.10,4.70,'Agregat Multi','MU2R15','','MU2R15',5980.00,'',NULL,NULL,NULL,NULL,NULL,0),(36,'2023-04-06 00:00:00.000000','LG','agregat',2,'zewnętrzna','',4.70,5.30,'Agregat Multi','MU2R17','','MU2R17',6720.00,'',NULL,NULL,NULL,NULL,NULL,0),(37,'2023-04-07 00:00:00.000000','LG','agregat',3,'zewnętrzna','',5.30,6.30,'Agregat Multi','MU3R19','','MU3R19',7530.00,'',NULL,NULL,NULL,NULL,NULL,0),(38,'2023-04-08 00:00:00.000000','LG','agregat',3,'zewnętrzna','',6.20,7.00,'Agregat Multi','MU3R21','','MU3R21',8600.00,'',NULL,NULL,NULL,NULL,NULL,0),(39,'2023-04-09 00:00:00.000000','LG','agregat',4,'zewnętrzna','',7.00,8.10,'Agregat Multi','MU4R25','','MU4R25',9260.00,'',NULL,NULL,NULL,NULL,NULL,0),(40,'2023-04-10 00:00:00.000000','LG','agregat',4,'zewnętrzna','',7.90,9.10,'Agregat Multi','MU4R27','','MU4R27',9990.00,'',NULL,NULL,NULL,NULL,NULL,0),(41,'2023-04-11 00:00:00.000000','LG','agregat',5,'zewnętrzna','',8.80,10.10,'Agregat Multi','MU5R30','','MU5R30',10730.00,'',NULL,NULL,NULL,NULL,NULL,0),(42,'2023-04-12 00:00:00.000000','LG','agregat',5,'zewnętrzna','',11.20,12.50,'Agregat Multi','MU5M40','','MU5M40',12860.00,'',NULL,NULL,NULL,NULL,NULL,0),(43,'2023-04-13 00:00:00.000000','LG','agregat',7,'zewnętrzna','',12.10,12.50,'Agregat Multi FDX','FM41AH','','FM41AH',12700.00,'',NULL,NULL,NULL,NULL,NULL,0),(44,'2023-04-14 00:00:00.000000','LG','agregat',8,'zewnętrzna','',14.00,16.00,'Agregat Multi FDX','FM49AH','','FM49AH',14500.00,'',NULL,NULL,NULL,NULL,NULL,0),(45,'2023-04-15 00:00:00.000000','LG','agregat',9,'zewnętrzna','',15.50,17.40,'Agregat Multi FDX','FM57AH','','FM57AH',17280.00,'',NULL,NULL,NULL,NULL,NULL,0),(46,'2023-04-16 00:00:00.000000','LG','wewnętrzna',0,'wewnęrzna','naścienny',2.60,2.90,'ArtCool Gallery','MA09R','MA09R.NF1','',2950.00,'',NULL,NULL,NULL,NULL,NULL,0),(47,'2023-04-17 00:00:00.000000','LG','wewnętrzna',0,'wewnęrzna','naścienny',3.50,3.90,'ArtCool Gallery','MA12R','MA12R.NF1','',3200.00,'',NULL,NULL,NULL,NULL,NULL,0),(48,'2023-04-18 00:00:00.000000','LG','wewnętrzna',0,'wewnęrzna','naścienny',2.50,3.20,'ArtCool Beige','AB09BK','AB09BK.NSJ','',2400.00,'',NULL,NULL,NULL,NULL,NULL,0),(49,'2023-04-19 00:00:00.000000','LG','wewnętrzna',0,'wewnęrzna','naścienny',3.50,3.80,'ArtCool Beige','AB12BK','AB12BK.NSJ','',2620.00,'beżowy',NULL,NULL,NULL,NULL,NULL,0),(50,'2023-04-20 00:00:00.000000','LG','wewnętrzna',0,'wewnęrzna','naścienny',5.00,5.80,'ArtCool Beige','AB18BK','AB18BK.NSJ','',3550.00,'beżowy',NULL,NULL,NULL,NULL,NULL,0),(51,'2023-04-21 00:00:00.000000','LG','wewnętrzna',0,'wewnęrzna','naścienny',6.60,7.50,'ArtCool Beige','AB24BK','AB24BK.NSJ','',4170.00,'beżowy',NULL,NULL,NULL,NULL,NULL,0),(52,'2023-04-22 00:00:00.000000','LG','wewnętrzna',0,'wewnęrzna','naścienny',2.10,2.30,'ArtCool Mirror','AM07BK','AM07BK.NSJ','',2050.00,'czarny',NULL,NULL,NULL,NULL,NULL,0),(53,'2023-04-23 00:00:00.000000','LG','wewnętrzna',0,'wewnęrzna','naścienny',2.50,3.20,'ArtCool Mirror','AM09BK','AM09BK.NSJ','',2290.00,'czarny',NULL,NULL,NULL,NULL,NULL,0),(54,'2023-04-24 00:00:00.000000','LG','wewnętrzna',0,'wewnęrzna','naścienny',3.50,3.80,'ArtCool Mirror','AM12BK','AM12BK.NSJ','',2500.00,'czarny',NULL,NULL,NULL,NULL,NULL,0),(55,'2023-04-25 00:00:00.000000','LG','wewnętrzna',0,'wewnęrzna','naścienny',5.00,5.80,'ArtCool Mirror','AM18BK','AM18BK.NSJ','',3380.00,'czarny',NULL,NULL,NULL,NULL,NULL,0),(56,'2023-04-26 00:00:00.000000','LG','wewnętrzna',0,'wewnęrzna','naścienny',6.60,7.50,'ArtCool Mirror','AM24BK','AM24BK.NSJ','',3970.00,'czarny',NULL,NULL,NULL,NULL,NULL,0),(57,'2023-04-27 00:00:00.000000','LG','wewnętrzna',0,'wewnęrzna','naścienny',2.50,3.30,'DualCool','AP09RK','AP09RK.NSJ','',2130.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(58,'2023-04-28 00:00:00.000000','LG','wewnętrzna',0,'wewnęrzna','naścienny',3.50,4.00,'DualCool','AP12RK','AP12RK.NSJ','',2350.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(59,'2023-04-29 00:00:00.000000','LG','wewnętrzna',0,'wewnęrzna','naścienny',2.10,2.30,'Deluxe','DM07RK','DM07RK.NSJ','',1800.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(60,'2023-04-30 00:00:00.000000','LG','wewnętrzna',0,'wewnęrzna','naścienny',2.50,3.20,'Deluxe','DM09RK','DM09RK.NSJ','',1890.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(61,'2023-05-01 00:00:00.000000','LG','wewnętrzna',0,'wewnęrzna','naścienny',3.50,3.80,'Deluxe','DM12RK','DM12RK.NSJ','',1990.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(62,'2023-05-02 00:00:00.000000','LG','wewnętrzna',0,'wewnęrzna','naścienny',5.00,5.80,'Deluxe','DM18RK','DM18RK.NSJ','',2580.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(63,'2023-05-03 00:00:00.000000','LG','wewnętrzna',0,'wewnęrzna','naścienny',6.60,7.50,'Deluxe','DM24RK','DM24RK.NSJ','',3280.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(64,'2023-05-04 00:00:00.000000','LG','wewnętrzna',0,'wewnęrzna','naścienny',1.50,1.60,'Standard Plus','PM05SK','PM05SK.NSA','',1400.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(65,'2023-05-05 00:00:00.000000','LG','wewnętrzna',0,'wewnęrzna','naścienny',2.10,2.30,'Standard Plus','PM07SK','PM07SK.NSA','',1400.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(66,'2023-05-06 00:00:00.000000','LG','wewnętrzna',0,'wewnęrzna','naścienny',2.50,3.20,'Standard Plus','PC09SK','PC09SK.NS','',1610.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(67,'2023-05-07 00:00:00.000000','LG','wewnętrzna',0,'wewnęrzna','naścienny',3.50,3.80,'Standard Plus','PC12SK','PC12SK.NS','',1700.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(68,'2023-05-08 00:00:00.000000','LG','wewnętrzna',0,'wewnęrzna','naścienny',4.20,5.40,'Standard Plus','PC15SK','PC15SK.NS','',1720.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(69,'2023-05-09 00:00:00.000000','LG','wewnętrzna',0,'wewnęrzna','naścienny',5.00,5.80,'Standard Plus','PC18SK','PC18SK.NS','',2090.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(70,'2023-05-10 00:00:00.000000','LG','wewnętrzna',0,'wewnęrzna','naścienny',6.60,7.50,'Standard Plus','PC24SK','PC24SK.NS','',2480.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(71,'2023-05-11 00:00:00.000000','LG','wewnętrzna',0,'wewnęrzna','naścienny',2.10,2.30,'Standard 2','MS07ET','MS07ET.NSA','',1230.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(72,'2023-05-12 00:00:00.000000','LG','wewnętrzna',0,'wewnęrzna','naścienny',2.50,3.20,'Standard 2','S09ET','S09ET.NSJ','',1320.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(73,'2023-05-13 00:00:00.000000','LG','wewnętrzna',0,'wewnęrzna','naścienny',3.50,3.80,'Standard 2','S12ET','S12ET.NSJ','',1420.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(74,'2023-05-14 00:00:00.000000','LG','wewnętrzna',0,'wewnęrzna','naścienny',5.00,5.80,'Standard 2','S18ET','S18ET.NSJ','',2120.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(75,'2023-05-15 00:00:00.000000','LG','wewnętrzna',0,'wewnęrzna','naścienny',6.60,7.50,'Standard 2','S24ET','S24ET.NSJ','',2590.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(76,'2023-05-16 00:00:00.000000','LG','wewnętrzna',0,'wewnęrzna','kaseton 1 stronny',2.60,2.90,'Kaseton 1 stronny','MT09R','MT09R.NU1','',3390.00,'',NULL,NULL,NULL,NULL,NULL,0),(77,'2023-05-17 00:00:00.000000','LG','wewnętrzna',0,'wewnęrzna','kaseton 1 stronny',3.50,3.90,'Kaseton 1 stronny','MT12R','MT12R.NU1','',3560.00,'',NULL,NULL,NULL,NULL,NULL,0),(78,'2023-05-18 00:00:00.000000','LG','wewnętrzna',0,'wewnęrzna','kaseton 4 stronny',1.50,1.60,'Kaseton 4 stronny','MT06R','MT06R.NR0','',2700.00,'',NULL,NULL,NULL,NULL,NULL,0),(79,'2023-05-19 00:00:00.000000','LG','wewnętrzna',0,'wewnęrzna','kaseton 4 stronny',2.10,2.30,'Kaseton 4 stronny','MT08R','MT08R.NR0','',2860.00,'',NULL,NULL,NULL,NULL,NULL,0),(80,'2023-05-20 00:00:00.000000','LG','wewnętrzna',0,'wewnęrzna','kaseton 4 stronny',2.60,2.90,'Kaseton 4 stronny','CT09F','CT09F.NR0','',2860.00,'',NULL,NULL,NULL,NULL,NULL,0),(81,'2023-05-21 00:00:00.000000','LG','wewnętrzna',0,'wewnęrzna','kaseton 4 stronny',3.50,3.90,'Kaseton 4 stronny','CT12F','CT12F.NR0','',3190.00,'',NULL,NULL,NULL,NULL,NULL,0),(82,'2023-05-22 00:00:00.000000','LG','wewnętrzna',0,'wewnęrzna','kaseton 4 stronny',5.30,5.80,'Kaseton 4 stronny','CT18F','CT18F.NR0','',3350.00,'',NULL,NULL,NULL,NULL,NULL,0),(83,'2023-05-23 00:00:00.000000','LG','wewnętrzna',0,'wewnęrzna','kaseton 4 stronny',6.70,7.50,'Kaseton 4 stronny','CT24F','CT24F.NR0','',3530.00,'',NULL,NULL,NULL,NULL,NULL,0),(84,'2023-05-24 00:00:00.000000','LG','wewnętrzna',0,'wewnęrzna','Kanałowy niskiego sprężu',2.60,2.90,'Kanałowy niskiego sprężu','CL09F','CL09F.N50','',2540.00,'',NULL,NULL,NULL,NULL,NULL,0),(85,'2023-05-25 00:00:00.000000','LG','wewnętrzna',0,'wewnęrzna','Kanałowy niskiego sprężu',3.50,3.90,'Kanałowy niskiego sprężu','CL12F','CL12F.N50','',2870.00,'',NULL,NULL,NULL,NULL,NULL,0),(86,'2023-05-26 00:00:00.000000','LG','wewnętrzna',0,'wewnęrzna','Kanałowy niskiego sprężu',5.30,5.80,'Kanałowy niskiego sprężu','CL18F','CL18F.N50','',2950.00,'',NULL,NULL,NULL,NULL,NULL,0),(87,'2023-05-27 00:00:00.000000','LG','wewnętrzna',0,'wewnęrzna','Kanałowy niskiego sprężu',7.00,7.70,'Kanałowy niskiego sprężu','CL24F','CL24F.N50','',3110.00,'',NULL,NULL,NULL,NULL,NULL,0),(88,'2023-05-28 00:00:00.000000','LG','wewnętrzna',0,'wewnęrzna','Kanałowy Średniego sprężu',5.30,5.80,'Kanałowy Średniego sprężu','CM18F','CM18F.N10','',2780.00,'',NULL,NULL,NULL,NULL,NULL,0),(89,'2023-05-29 00:00:00.000000','LG','wewnętrzna',0,'wewnęrzna','Kanałowy Średniego sprężu',7.00,7.70,'Kanałowy Średniego sprężu','CM24F','CM24F.N10','',2950.00,'',NULL,NULL,NULL,NULL,NULL,0),(90,'2023-05-30 00:00:00.000000','LG','wewnętrzna',0,'wewnęrzna','Konsola',2.60,2.90,'Konsola','CQ09','CQ09.NA0','',2620.00,'',NULL,NULL,NULL,NULL,NULL,0),(91,'2023-05-31 00:00:00.000000','LG','wewnętrzna',0,'wewnęrzna','Konsola',3.50,3.90,'Konsola','CQ12','CQ12.NA0','',3110.00,'',NULL,NULL,NULL,NULL,NULL,0),(92,'2023-06-01 00:00:00.000000','LG','wewnętrzna',0,'wewnęrzna','Konsola',5.30,5.80,'Konsola','CQ18','CQ18.NA0','',3600.00,'',NULL,NULL,NULL,NULL,NULL,0),(93,'2023-06-03 00:00:00.000000','Gree','agregat',2,'zewnętrzna','',4.10,4.40,'Agregat Multi','FM14O','','FM14O',4790.00,'',NULL,NULL,NULL,NULL,NULL,0),(94,'2023-06-04 00:00:00.000000','Gree','agregat',2,'zewnętrzna','',5.30,5.65,'Agregat Multi','FM18O','','FM18O',5290.00,'',NULL,NULL,NULL,NULL,NULL,0),(95,'2023-06-05 00:00:00.000000','Gree','agregat',3,'zewnętrzna','',6.10,6.50,'Agregat Multi','FM21O','','FM21O',5690.00,'',NULL,NULL,NULL,NULL,NULL,0),(96,'2023-06-06 00:00:00.000000','Gree','agregat',3,'zewnętrzna','',7.10,8.60,'Agregat Multi','FM24O','','FM24O',7090.00,'',NULL,NULL,NULL,NULL,NULL,0),(97,'2023-06-07 00:00:00.000000','Gree','agregat',4,'zewnętrzna','',8.00,9.50,'Agregat Multi','FM28O','','FM28O',7690.00,'',NULL,NULL,NULL,NULL,NULL,0),(98,'2023-06-08 00:00:00.000000','Gree','agregat',4,'zewnętrzna','',10.60,12.00,'Agregat Multi','FM36O','','FM36O',10590.00,'',NULL,NULL,NULL,NULL,NULL,0),(99,'2023-06-09 00:00:00.000000','Gree','agregat',5,'zewnętrzna','',12.10,13.00,'Agregat Multi','FM42O','','FM42O',11490.00,'',NULL,NULL,NULL,NULL,NULL,0),(100,'2023-06-10 00:00:00.000000','Gree','wewnętrzna',0,'wewnęrzna','naścienny',2.20,2.40,'Lomo Luxury Plus','LL07I','LL07I','',1250.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(101,'2023-06-11 00:00:00.000000','Gree','wewnętrzna',0,'wewnęrzna','naścienny',2.70,3.00,'Lomo Luxury Plus','LLP09I','LLP09I','',1350.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(102,'2023-06-12 00:00:00.000000','Gree','wewnętrzna',0,'wewnęrzna','naścienny',3.50,3.80,'Lomo Luxury Plus','LLP12I','LLP12I','',1450.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(103,'2023-06-13 00:00:00.000000','Gree','wewnętrzna',0,'wewnęrzna','naścienny',5.20,5.60,'Lomo Luxury Plus','LLP18I','LLP18I','',1550.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(104,'2023-06-14 00:00:00.000000','Gree','wewnętrzna',0,'wewnęrzna','naścienny',7.10,7.80,'Lomo Luxury Plus','LLP24I','LLP24I','',1650.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(105,'2023-06-15 00:00:00.000000','Gree','wewnętrzna',0,'wewnęrzna','naścienny',2.50,2.80,'Pular','PU09I','PU09I','',1350.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(106,'2023-06-16 00:00:00.000000','Gree','wewnętrzna',0,'wewnęrzna','naścienny',3.20,3.40,'Pular','PU12I','PU12I','',1450.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(107,'2023-06-17 00:00:00.000000','Gree','wewnętrzna',0,'wewnęrzna','naścienny',4.60,5.20,'Pular','PU18I','PU18I','',1550.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(108,'2023-06-18 00:00:00.000000','Gree','wewnętrzna',0,'wewnęrzna','naścienny',6.20,6.50,'Pular','PU24I','PU24I','',1650.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(109,'2023-06-19 00:00:00.000000','Gree','wewnętrzna',0,'wewnęrzna','naścienny',2.70,3.00,'Fairy White','FA09WI','FA09WI','',1550.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(110,'2023-06-20 00:00:00.000000','Gree','wewnętrzna',0,'wewnęrzna','naścienny',3.50,3.80,'Fairy White','FA12WI','FA12WI','',1650.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(111,'2023-06-21 00:00:00.000000','Gree','wewnętrzna',0,'wewnęrzna','naścienny',5.30,5.60,'Fairy White','FA18WI','FA18WI','',1790.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(112,'2023-06-22 00:00:00.000000','Gree','wewnętrzna',0,'wewnęrzna','naścienny',7.10,7.80,'Fairy White','FA24WI','FA24WI','',1890.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(113,'2023-06-23 00:00:00.000000','Gree','wewnętrzna',0,'wewnęrzna','naścienny',2.70,3.00,'Fairy Silver','FA09SI','FA09SI','',1500.00,'silver',NULL,NULL,NULL,NULL,NULL,0),(114,'2023-06-24 00:00:00.000000','Gree','wewnętrzna',0,'wewnęrzna','naścienny',3.50,3.80,'Fairy Silver','FA12SI','FA12SI','',1600.00,'silver',NULL,NULL,NULL,NULL,NULL,0),(115,'2023-06-25 00:00:00.000000','Gree','wewnętrzna',0,'wewnęrzna','naścienny',5.30,5.60,'Fairy Silver','FA18SI','FA18SI','',1700.00,'silver',NULL,NULL,NULL,NULL,NULL,0),(116,'2023-06-26 00:00:00.000000','Gree','wewnętrzna',0,'wewnęrzna','naścienny',7.10,7.80,'Fairy Silver','FA24SI','FA24SI','',1800.00,'silver',NULL,NULL,NULL,NULL,NULL,0),(117,'2023-06-27 00:00:00.000000','Gree','wewnętrzna',0,'wewnęrzna','naścienny',2.70,3.00,'Fairy Dark','FA09DI','FA09DI','',1500.00,'czarny',NULL,NULL,NULL,NULL,NULL,0),(118,'2023-06-28 00:00:00.000000','Gree','wewnętrzna',0,'wewnęrzna','naścienny',3.50,3.80,'Fairy Dark','FA12DI','FA12DI','',1600.00,'czarny',NULL,NULL,NULL,NULL,NULL,0),(119,'2023-06-29 00:00:00.000000','Gree','wewnętrzna',0,'wewnęrzna','naścienny',5.30,5.60,'Fairy Dark','FA18DI','FA18DI','',1700.00,'czarny',NULL,NULL,NULL,NULL,NULL,0),(120,'2023-06-30 00:00:00.000000','Gree','wewnętrzna',0,'wewnęrzna','naścienny',7.10,7.80,'Fairy Dark','FA24DI','FA24DI','',1800.00,'czarny',NULL,NULL,NULL,NULL,NULL,0),(121,'2023-07-01 00:00:00.000000','Gree','wewnętrzna',0,'wewnęrzna','naścienny',2.70,3.20,'G-Tech Silver','GT09SI','GT09SI','',1900.00,'silver',NULL,NULL,NULL,NULL,NULL,0),(122,'2023-07-02 00:00:00.000000','Gree','wewnętrzna',0,'wewnęrzna','naścienny',3.50,3.80,'G-Tech Silver','GT12SI','GT12SI','',2000.00,'silver',NULL,NULL,NULL,NULL,NULL,0),(123,'2023-07-03 00:00:00.000000','Gree','wewnętrzna',0,'wewnęrzna','naścienny',2.70,3.20,'G-Tech Rose Gold','GT09RI','GT09RI','',1900.00,'różowy',NULL,NULL,NULL,NULL,NULL,0),(124,'2023-07-04 00:00:00.000000','Gree','wewnętrzna',0,'wewnęrzna','naścienny',3.50,3.80,'G-Tech Rose Gold','GT12RI','GT12RI','',2000.00,'różowy',NULL,NULL,NULL,NULL,NULL,0),(125,'2023-07-05 00:00:00.000000','Gree','wewnętrzna',0,'wewnęrzna','naścienny',2.70,2.90,'Amber Standard White','AS09WI','AS09WI','',1750.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(126,'2023-07-06 00:00:00.000000','Gree','wewnętrzna',0,'wewnęrzna','naścienny',3.50,3.80,'Amber Standard White','AS12WI','AS12WI','',1850.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(127,'2023-07-07 00:00:00.000000','Gree','wewnętrzna',0,'wewnęrzna','naścienny',5.30,5.60,'Amber Standard White','AS18WI','AS18WI','',2150.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(128,'2023-07-08 00:00:00.000000','Gree','wewnętrzna',0,'wewnęrzna','naścienny',7.00,7.20,'Amber Standard White','AS24WI','AS24WI','',2450.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(129,'2023-07-09 00:00:00.000000','Gree','wewnętrzna',0,'wewnęrzna','naścienny',2.70,2.90,'Amber Standard Silver','AS09WI','AS09WI','',1750.00,'silver',NULL,NULL,NULL,NULL,NULL,0),(130,'2023-07-10 00:00:00.000000','Gree','wewnętrzna',0,'wewnęrzna','naścienny',3.50,3.80,'Amber Standard Silver','AS12WI','AS12WI','',1850.00,'silver',NULL,NULL,NULL,NULL,NULL,0),(131,'2023-07-11 00:00:00.000000','Gree','wewnętrzna',0,'wewnęrzna','naścienny',5.30,5.60,'Amber Standard Silver','AS18WI','AS18WI','',2150.00,'silver',NULL,NULL,NULL,NULL,NULL,0),(132,'2023-07-12 00:00:00.000000','Gree','wewnętrzna',0,'wewnęrzna','naścienny',7.00,7.20,'Amber Standard Silver','AS24WI','AS24WI','',2450.00,'silver',NULL,NULL,NULL,NULL,NULL,0),(133,'2023-07-13 00:00:00.000000','Gree','wewnętrzna',0,'wewnęrzna','naścienny',2.70,2.90,'Amber Standard Full Black','AS09WI','AS09WI','',1750.00,'czarny full',NULL,NULL,NULL,NULL,NULL,0),(134,'2023-07-14 00:00:00.000000','Gree','wewnętrzna',0,'wewnęrzna','naścienny',3.50,3.80,'Amber Standard Full Black','AS12WI','AS12WI','',1850.00,'czarny full',NULL,NULL,NULL,NULL,NULL,0),(135,'2023-07-15 00:00:00.000000','Gree','wewnętrzna',0,'wewnęrzna','naścienny',5.30,5.60,'Amber Standard Full Black','AS18WI','AS18WI','',2150.00,'czarny full',NULL,NULL,NULL,NULL,NULL,0),(136,'2023-07-16 00:00:00.000000','Gree','wewnętrzna',0,'wewnęrzna','naścienny',7.00,7.20,'Amber Standard Full Black','AS24WI','AS24WI','',2450.00,'czarny full',NULL,NULL,NULL,NULL,NULL,0),(137,'2023-07-17 00:00:00.000000','Gree','wewnętrzna',0,'wewnęrzna','naścienny',2.70,2.90,'Amber Standard Black','AS09WI','AS09WI','',1400.00,'czarny',NULL,NULL,NULL,NULL,NULL,0),(138,'2023-07-18 00:00:00.000000','Gree','wewnętrzna',0,'wewnęrzna','naścienny',3.50,3.80,'Amber Standard Black','AS12WI','AS12WI','',1500.00,'czarny',NULL,NULL,NULL,NULL,NULL,0),(139,'2023-07-19 00:00:00.000000','Gree','wewnętrzna',0,'wewnęrzna','naścienny',5.30,5.60,'Amber Standard Black','AS18WI','AS18WI','',1600.00,'czarny',NULL,NULL,NULL,NULL,NULL,0),(140,'2023-07-20 00:00:00.000000','Gree','wewnętrzna',0,'wewnęrzna','naścienny',7.00,7.20,'Amber Standard Black','AS24WI','AS24WI','',1800.00,'czarny',NULL,NULL,NULL,NULL,NULL,0),(141,'2023-07-21 00:00:00.000000','Gree','wewnętrzna',0,'wewnęrzna','naścienny',2.70,3.20,'U-Crown Silver','UC09SI','UC09SI','',2190.00,'silver',NULL,NULL,NULL,NULL,NULL,0),(142,'2023-07-22 00:00:00.000000','Gree','wewnętrzna',0,'wewnęrzna','naścienny',3.50,4.00,'U-Crown Silver','UC12SI','UC12SI','',2290.00,'silver',NULL,NULL,NULL,NULL,NULL,0),(143,'2023-07-23 00:00:00.000000','Gree','wewnętrzna',0,'wewnęrzna','naścienny',5.30,5.30,'U-Crown Silver','UC18SI','UC18SI','',2590.00,'silver',NULL,NULL,NULL,NULL,NULL,0),(144,'2023-07-24 00:00:00.000000','Gree','wewnętrzna',0,'wewnęrzna','naścienny',2.70,3.20,'U_Crown Champagne','UC09CI','UC09CI','',2190.00,'champagne',NULL,NULL,NULL,NULL,NULL,0),(145,'2023-07-25 00:00:00.000000','Gree','wewnętrzna',0,'wewnęrzna','naścienny',3.50,4.00,'U_Crown Champagne','UC12CI','UC12CI','',2290.00,'champagne',NULL,NULL,NULL,NULL,NULL,0),(146,'2023-07-26 00:00:00.000000','Gree','wewnętrzna',0,'wewnęrzna','naścienny',5.30,5.30,'U_Crown Champagne','UC18CI','UC18CI','',2590.00,'champagne',NULL,NULL,NULL,NULL,NULL,0),(147,'2023-07-27 00:00:00.000000','Gree','wewnętrzna',0,'wewnęrzna','naścienny',2.70,3.60,'Soyal','SO09I','SO09I','',2690.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(148,'2023-07-28 00:00:00.000000','Gree','wewnętrzna',0,'wewnęrzna','naścienny',3.50,4.20,'Soyal','SO12I','SO12I','',2890.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(149,'2023-07-29 00:00:00.000000','Gree','wewnętrzna',0,'wewnęrzna','naścienny',5.30,5.60,'Soyal','SO18I','SO18I','',3390.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(150,'2023-07-30 00:00:00.000000','Gree','wewnętrzna',0,'wewnęrzna','naścienny',2.70,2.80,'Konsola','CFM09I','CFM09I','',1790.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(151,'2023-07-31 00:00:00.000000','Gree','wewnętrzna',0,'wewnęrzna','naścienny',3.50,3.80,'Konsola','CFM12I','CFM12I','',1890.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(152,'2023-08-01 00:00:00.000000','Gree','wewnętrzna',0,'wewnęrzna','naścienny',5.20,5.30,'Konsola','CFM18I','CFM18I','',1990.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(153,'2023-08-02 00:00:00.000000','Gree','wewnętrzna',0,'wewnęrzna','kaseton',3.50,4.00,'kaseton','KFM12I','KFM12I','',2490.00,'',NULL,NULL,NULL,NULL,NULL,0),(154,'2023-08-03 00:00:00.000000','Gree','wewnętrzna',0,'wewnęrzna','kaseton',5.00,5.50,'kaseton','KFM118I','KFM118I','',2690.00,'',NULL,NULL,NULL,NULL,NULL,0),(155,'2023-08-04 00:00:00.000000','Gree','wewnętrzna',0,'wewnęrzna','kaseton',7.00,8.00,'kaseton','KFM24I','KFM24I','',3390.00,'',NULL,NULL,NULL,NULL,NULL,0),(156,'2023-08-05 00:00:00.000000','Gree','wewnętrzna',0,'wewnęrzna','kanałowy',2.70,2.80,'kanałowy','DFM09I','DFM09I','',1750.00,'',NULL,NULL,NULL,NULL,NULL,0),(157,'2023-08-06 00:00:00.000000','Gree','wewnętrzna',0,'wewnęrzna','kanałowy',3.50,4.00,'kanałowy','DFM12I','DFM12I','',1850.00,'',NULL,NULL,NULL,NULL,NULL,0),(158,'2023-08-07 00:00:00.000000','Gree','wewnętrzna',0,'wewnęrzna','kanałowy',5.00,5.50,'kanałowy','DFM18I','DFM18I','',2250.00,'',NULL,NULL,NULL,NULL,NULL,0),(159,'2023-08-08 00:00:00.000000','Gree','wewnętrzna',0,'wewnęrzna','kanałowy',6.00,6.60,'kanałowy','DFM21I','DFM21I','',2300.00,'',NULL,NULL,NULL,NULL,NULL,0),(160,'2023-08-09 00:00:00.000000','Gree','wewnętrzna',0,'wewnęrzna','kanałowy',7.00,8.00,'kanałowy','DFM24I','DFM24I','',2550.00,'',NULL,NULL,NULL,NULL,NULL,0),(161,'2023-08-10 00:00:00.000000','Gree','wewnętrzna',0,'wewnęrzna','przypodłogowy-przysufitowy',2.60,2.70,'przypodłogowy-przysufitowy','FCFM09I','FCFM09I','',2200.00,'',NULL,NULL,NULL,NULL,NULL,0),(162,'2023-08-11 00:00:00.000000','Gree','wewnętrzna',0,'wewnęrzna','przypodłogowy-przysufitowy',3.50,4.00,'przypodłogowy-przysufitowy','FCFM12I','FCFM12I','',2300.00,'',NULL,NULL,NULL,NULL,NULL,0),(163,'2023-08-12 00:00:00.000000','Gree','wewnętrzna',0,'wewnęrzna','przypodłogowy-przysufitowy',4.50,5.00,'przypodłogowy-przysufitowy','FCFM18I','FCFM18I','',2400.00,'',NULL,NULL,NULL,NULL,NULL,0),(164,'2023-08-13 00:00:00.000000','Gree','wewnętrzna',0,'wewnęrzna','przypodłogowy-przysufitowy',7.10,8.00,'przypodłogowy-przysufitowy','FCFM24I','FCFM24I','',3000.00,'',NULL,NULL,NULL,NULL,NULL,0),(165,'2023-08-15 00:00:00.000000','Ande','agregat',2,'zewnętrzna','',4.10,4.10,'Agregat Multi','AND-AM2-H14/4DR3','','AND-AM2-H14/4DR3',4250.00,'',NULL,NULL,NULL,NULL,NULL,0),(166,'2023-08-16 00:00:00.000000','Ande','agregat',2,'zewnętrzna','',5.30,5.30,'Agregat Multi','AND-AM2-H18/4DR3','','AND-AM2-H18/4DR3',4640.00,'',NULL,NULL,NULL,NULL,NULL,0),(167,'2023-08-17 00:00:00.000000','Ande','agregat',3,'zewnętrzna','',6.20,6.20,'Agregat Multi','AND-AM3-H21/4DR3','','AND-AM3-H21/4DR3',5440.00,'',NULL,NULL,NULL,NULL,NULL,0),(168,'2023-08-18 00:00:00.000000','Ande','agregat',3,'zewnętrzna','',7.90,7.90,'Agregat Multi','AND-AM3-H27/4DR3','','AND-AM3-H27/4DR3',5940.00,'',NULL,NULL,NULL,NULL,NULL,0),(169,'2023-08-19 00:00:00.000000','Ande','agregat',4,'zewnętrzna','',10.50,10.50,'Agregat Multi','AND-AM4-H36/4DR3','','AND-AM4-H36/4DR3',9650.00,'',NULL,NULL,NULL,NULL,NULL,0),(170,'2023-08-20 00:00:00.000000','Ande','agregat',5,'zewnętrzna','',12.00,12.00,'Agregat Multi','AND-AM5-H42/4DR3','','AND-AM5-H42/4DR3',10450.00,'',NULL,NULL,NULL,NULL,NULL,0),(171,'2023-08-21 00:00:00.000000','Ande','wewnętrzna',0,'wewnęrzna','naścienny',2.00,2.00,'Basic+','AND-AMWM-H07(FA)','AND-AMWM-H07(FA)','',1100.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(172,'2023-08-22 00:00:00.000000','Ande','wewnętrzna',0,'wewnęrzna','naścienny',2.50,2.50,'Basic+','AND-AMWM-H09(FA)','AND-AMWM-H09(FA)','',1200.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(173,'2023-08-23 00:00:00.000000','Ande','wewnętrzna',0,'wewnęrzna','naścienny',3.50,3.50,'Basic+','AND-AMWM-H12(FA)','AND-AMWM-H12(FA)','',1350.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(174,'2023-08-24 00:00:00.000000','Ande','wewnętrzna',0,'wewnęrzna','naścienny',5.20,5.20,'Basic+','AND-AMWM-H18(FA)','AND-AMWM-H18(FA)','',1500.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(175,'2023-08-25 00:00:00.000000','Ande','wewnętrzna',0,'wewnęrzna','naścienny',7.00,7.00,'Basic+','AND-AMWM-H24(FA)','AND-AMWM-H24(FA)','',1600.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(176,'2023-08-26 00:00:00.000000','Ande','wewnętrzna',0,'wewnęrzna','naścienny',2.00,2.00,'Jupiter+','AND-AMWM-H07(JA)','AND-AMWM-H07(JA)','',1350.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(177,'2023-08-27 00:00:00.000000','Ande','wewnętrzna',0,'wewnęrzna','naścienny',2.50,2.50,'Jupiter+','AND-AMWM-H09(JA)','AND-AMWM-H09(JA)','',1450.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(178,'2023-08-28 00:00:00.000000','Ande','wewnętrzna',0,'wewnęrzna','naścienny',3.50,3.50,'Jupiter+','AND-AMWM-H12(JA)','AND-AMWM-H12(JA)','',1550.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(179,'2023-08-29 00:00:00.000000','Ande','wewnętrzna',0,'wewnęrzna','naścienny',5.20,5.20,'Jupiter+','AND-AMWM-H18(JA)','AND-AMWM-H18(JA)','',1750.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(180,'2023-08-30 00:00:00.000000','Ande','wewnętrzna',0,'wewnęrzna','naścienny',7.00,7.00,'Jupiter+','AND-AMWM-H24(JA)','AND-AMWM-H24(JA)','',2050.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(181,'2023-08-31 00:00:00.000000','Ande','wewnętrzna',0,'wewnęrzna','kaseton',2.80,2.80,'kaseton','AND-AMCA-H09-3B','AND-AMCA-H09-3B','',1940.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(182,'2023-09-01 00:00:00.000000','Ande','wewnętrzna',0,'wewnęrzna','kaseton',3.60,3.60,'kaseton','AND-AMCA-H12-3B','AND-AMCA-H12-3B','',2040.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(183,'2023-09-02 00:00:00.000000','Ande','wewnętrzna',0,'wewnęrzna','kaseton',5.00,5.00,'kaseton','AND-AMCA-H18-3B','AND-AMCA-H18-3B','',2140.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(184,'2023-09-04 00:00:00.000000','Rotenso','agregat',2,'zewnętrzna','',4.10,4.80,'Agregat Multi','H40Xm2','','Hiro 4,1',4649.00,'',NULL,NULL,NULL,NULL,NULL,0),(185,'2023-09-05 00:00:00.000000','Rotenso','agregat',2,'zewnętrzna','',5.30,6.20,'Agregat Multi','H50Xm2','','Hiro 5,3',4799.00,'',NULL,NULL,NULL,NULL,NULL,0),(186,'2023-09-06 00:00:00.000000','Rotenso','agregat',3,'zewnętrzna','',6.20,6.60,'Agregat Multi','H60Xm3','','Hiro 6,2',6899.00,'',NULL,NULL,NULL,NULL,NULL,0),(187,'2023-09-07 00:00:00.000000','Rotenso','agregat',3,'zewnętrzna','',7.90,8.20,'Agregat Multi','H70Xm3','','Hiro 7,6',7199.00,'',NULL,NULL,NULL,NULL,NULL,0),(188,'2023-09-08 00:00:00.000000','Rotenso','agregat',4,'zewnętrzna','',8.80,9.10,'Agregat Multi','H80Xm4','','Hiro 8,8',7999.00,'',NULL,NULL,NULL,NULL,NULL,0),(189,'2023-09-09 00:00:00.000000','Rotenso','agregat',4,'zewnętrzna','',10.90,12.00,'Agregat Multi','H100Xm4','','Hiro 10,9',11299.00,'',NULL,NULL,NULL,NULL,NULL,0),(190,'2023-09-10 00:00:00.000000','Rotenso','agregat',5,'zewnętrzna','',12.30,13.30,'Agregat Multi','H120Xm5','','Hiro 12,3',11999.00,'',NULL,NULL,NULL,NULL,NULL,0),(191,'2023-09-11 00:00:00.000000','Rotenso','wewnętrzna',0,'wewnętrzna','konsola',3.50,3.80,'konsola','Aneru 3,5','A35Xi','',1127.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(192,'2023-09-12 00:00:00.000000','Rotenso','wewnętrzna',0,'wewnętrzna','konsola',5.00,5.30,'konsola','Aneru 5,3','A50Xi','',1237.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(193,'2023-09-13 00:00:00.000000','Rotenso','wewnętrzna',0,'wewnętrzna','kanałowy',2.10,2.30,'kanałowy','Nevo 2,1','N21Xi','',1949.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(194,'2023-09-14 00:00:00.000000','Rotenso','wewnętrzna',0,'wewnętrzna','kanałowy',2.60,2.90,'kanałowy','Nevo 2,6','N26Xi','',2049.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(195,'2023-09-15 00:00:00.000000','Rotenso','wewnętrzna',0,'wewnętrzna','kanałowy',3.50,3.80,'kanałowy','Nevo 3,5','N35Xi','',2199.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(196,'2023-09-16 00:00:00.000000','Rotenso','wewnętrzna',0,'wewnętrzna','kanałowy',5.30,5.90,'kanałowy','Nevo 5,3','N50Xi','',2299.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(197,'2023-09-17 00:00:00.000000','Rotenso','wewnętrzna',0,'wewnętrzna','kanałowy',7.00,7.60,'kanałowy','Nevo 7,0','N70Xi','',2899.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(198,'2023-09-18 00:00:00.000000','Rotenso','wewnętrzna',0,'wewnętrzna','przypodłogowo-podsufitowy',5.30,5.60,'przypodłogowo-podsufitowy ','Jato 5,3','J50Xi','',2299.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(199,'2023-09-19 00:00:00.000000','Rotenso','wewnętrzna',0,'wewnętrzna','przypodłogowo-podsufitowy',7.00,7.60,'przypodłogowo-podsufitowy ','Jato 7,0','J70Xi','',3699.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(200,'2023-09-20 00:00:00.000000','Rotenso','wewnętrzna',0,'wewnętrzna','kaseton',2.10,2.30,'kaseton','Tenji 2,1','T21Xi','',1799.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(201,'2023-09-21 00:00:00.000000','Rotenso','wewnętrzna',0,'wewnętrzna','kaseton',2.60,2.90,'kaseton','Tenji 2,6','T26Xi','',1899.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(202,'2023-09-22 00:00:00.000000','Rotenso','wewnętrzna',0,'wewnętrzna','kaseton',3.50,4.40,'kaseton','Tenji 3,5','T35Xi','',2199.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(203,'2023-09-23 00:00:00.000000','Rotenso','wewnętrzna',0,'wewnętrzna','kaseton',5.30,5.60,'kaseton','Tenji 5,3','T50Xi','',2399.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(204,'2023-09-24 00:00:00.000000','Rotenso','wewnętrzna',0,'wewnętrzna','kaseton',7.00,7.60,'kaseton','Tenji 7,0','T70Xi','',3199.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(205,'2023-09-25 00:00:00.000000','Rotenso','wewnętrzna',0,'wewnętrzna','kaseton',2.10,2.30,'kaseton standard','Tenji 2,1','T21Wm','',1390.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(206,'2023-09-26 00:00:00.000000','Rotenso','wewnętrzna',0,'wewnętrzna','kaseton',2.60,2.90,'kaseton standard','Tenji 2,6','T26Wm','',1499.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(207,'2023-09-27 00:00:00.000000','Rotenso','wewnętrzna',0,'wewnętrzna','kaseton',3.50,4.40,'kaseton standard','Tenji 3,5','T35Wm','',1599.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(208,'2023-09-28 00:00:00.000000','Rotenso','wewnętrzna',0,'wewnętrzna','naścienny',2.10,2.60,'Imoto','Imoto 2,1','I21Xi','',1149.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(209,'2023-09-29 00:00:00.000000','Rotenso','wewnętrzna',0,'wewnętrzna','naścienny',2.60,2.90,'Imoto','Imoto 2,6','I26Xi','',1199.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(210,'2023-09-30 00:00:00.000000','Rotenso','wewnętrzna',0,'wewnętrzna','naścienny',3.50,3.80,'Imoto','Imoto 3,5','I35Xi','',1249.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(211,'2023-10-01 00:00:00.000000','Rotenso','wewnętrzna',0,'wewnętrzna','naścienny',5.30,5.60,'Imoto','Imoto 5,3','I50Xi','',1699.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(212,'2023-10-02 00:00:00.000000','Rotenso','wewnętrzna',0,'wewnętrzna','naścienny',7.30,7.50,'Imoto','Imoto 7,3','I70Xi','',2199.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(213,'2023-10-03 00:00:00.000000','Rotenso','wewnętrzna',0,'wewnętrzna','naścienny',2.70,3.10,'Revio','Revio 2,7','RO26Xi','',1449.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(214,'2023-10-04 00:00:00.000000','Rotenso','wewnętrzna',0,'wewnętrzna','naścienny',3.50,4.30,'Revio','Revio 3,5','RO35Xi','',1500.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(215,'2023-10-05 00:00:00.000000','Rotenso','wewnętrzna',0,'wewnętrzna','naścienny',5.30,5.60,'Revio','Revio 5,7','RO50Xi','',2250.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(216,'2023-10-06 00:00:00.000000','Rotenso','wewnętrzna',0,'wewnętrzna','naścienny',7.30,7.60,'Revio','Revio 7,3','RO70Xi','',2850.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(217,'2023-10-07 00:00:00.000000','Rotenso','wewnętrzna',0,'wewnętrzna','naścienny',2.60,2.90,'Versu Gold','Versu Gold 2,6','VG26Xi','',1649.00,'gold',NULL,NULL,NULL,NULL,NULL,0),(218,'2023-10-08 00:00:00.000000','Rotenso','wewnętrzna',0,'wewnętrzna','naścienny',3.50,3.80,'Versu Gold','Versu Gold 3,5','VG35Xi','',1749.00,'gold',NULL,NULL,NULL,NULL,NULL,0),(219,'2023-10-09 00:00:00.000000','Rotenso','wewnętrzna',0,'wewnętrzna','naścienny',2.60,2.90,'Versu Silver','Versu Silver 2,6','VS26Xi','',1649.00,'silver',NULL,NULL,NULL,NULL,NULL,0),(220,'2023-10-10 00:00:00.000000','Rotenso','wewnętrzna',0,'wewnętrzna','naścienny',3.50,3.80,'Versu Silver','Versu Silver 3,5','VS35Xi','',1749.00,'silver',NULL,NULL,NULL,NULL,NULL,0),(221,'2023-10-11 00:00:00.000000','Rotenso','wewnętrzna',0,'wewnętrzna','naścienny',2.60,2.90,'Versu Mirror','Versu Mirror 2,6','VM26Xi','',1649.00,'czarny',NULL,NULL,NULL,NULL,NULL,0),(222,'2023-10-12 00:00:00.000000','Rotenso','wewnętrzna',0,'wewnętrzna','naścienny',3.50,3.80,'Versu Mirror','Versu Mirror 3,5','VM35Xi','',1749.00,'czarny',NULL,NULL,NULL,NULL,NULL,0),(223,'2023-10-13 00:00:00.000000','Rotenso','wewnętrzna',0,'wewnętrzna','naścienny',2.60,2.70,'Versu Pure','Versu Pure 2,6','VP26Xi','',1649.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(224,'2023-10-14 00:00:00.000000','Rotenso','wewnętrzna',0,'wewnętrzna','naścienny',3.50,4.10,'Versu Pure','Versu Pure 3,5','VP35Xi','',1799.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(225,'2023-10-15 00:00:00.000000','Rotenso','wewnętrzna',0,'wewnętrzna','naścienny',2.60,2.70,'Versu Cloth Stone','Versu Cloth Stone 2,6','VCS26Xi','',2049.00,'stone',NULL,NULL,NULL,NULL,NULL,0),(226,'2023-10-16 00:00:00.000000','Rotenso','wewnętrzna',0,'wewnętrzna','naścienny',3.50,4.10,'Versu Cloth Stone','Versu Cloth Stone 3,5','VCS35Xi','',2199.00,'stone',NULL,NULL,NULL,NULL,NULL,0),(227,'2023-10-17 00:00:00.000000','Rotenso','wewnętrzna',0,'wewnętrzna','naścienny',2.60,2.70,'Versu Cloth Caramel','Versu Cloth Caramel 2,6','VCC26Xi','',2049.00,'caramel',NULL,NULL,NULL,NULL,NULL,0),(228,'2023-10-18 00:00:00.000000','Rotenso','wewnętrzna',0,'wewnętrzna','naścienny',3.50,4.10,'Versu Cloth Caramel','Versu Cloth Caramel 3,5','VCC35Xi','',2199.00,'caramel',NULL,NULL,NULL,NULL,NULL,0),(229,'2023-10-19 00:00:00.000000','Rotenso','wewnętrzna',0,'wewnętrzna','naścienny',3.50,3.90,'Mirai','Mirai 3,5','M35Xi','',2349.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(230,'2023-10-21 00:00:00.000000','Samsung','agregat',2,'zewnętrzna','',4.00,4.20,'Agregat Multi','AJ040TXJ2KG/EU','','AJ040TXJ2KG/EU',6979.00,'',NULL,NULL,NULL,NULL,NULL,0),(231,'2023-10-22 00:00:00.000000','Samsung','agregat',2,'zewnętrzna','',5.00,5.60,'Agregat Multi','AJ050TXJ2KG/EU','','AJ050TXJ2KG/EU',8129.00,'',NULL,NULL,NULL,NULL,NULL,0),(232,'2023-10-23 00:00:00.000000','Samsung','agregat',3,'zewnętrzna','',5.20,6.30,'Agregat Multi','AJ052TXJ3KG/EU','','AJ052TXJ3KG/EU',8639.00,'',NULL,NULL,NULL,NULL,NULL,0),(233,'2023-10-24 00:00:00.000000','Samsung','agregat',3,'zewnętrzna','',6.80,8.00,'Agregat Multi','AJ068TXJ3KG/EU','','AJ068TXJ3KG/EU',10089.00,'',NULL,NULL,NULL,NULL,NULL,0),(234,'2023-10-25 00:00:00.000000','Samsung','agregat',4,'zewnętrzna','',8.00,9.30,'Agregat Multi','AJ080TXJ4KG/EU','','AJ080TXJ4KG/EU',13339.00,'',NULL,NULL,NULL,NULL,NULL,0),(235,'2023-10-26 00:00:00.000000','Samsung','agregat',5,'zewnętrzna','',10.00,12.00,'Agregat Multi','AJ100TXJ5KG/EU','','AJ100TXJ5KG/EU',16599.00,'',NULL,NULL,NULL,NULL,NULL,0),(236,'2023-10-27 00:00:00.000000','Samsung','wewnętrzna',0,'wewnętrzna','naścienny',2.00,2.20,'Cebu','Cebu','AR07TXFYAWKNEU','',1459.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(237,'2023-10-28 00:00:00.000000','Samsung','wewnętrzna',0,'wewnętrzna','naścienny',2.50,3.20,'Cebu','Cebu','AR09TXFYAWKNEU','',1599.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(238,'2023-10-29 00:00:00.000000','Samsung','wewnętrzna',0,'wewnętrzna','naścienny',3.50,3.50,'Cebu','Cebu','AR12TXFYAWKNEU','',1789.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(239,'2023-10-30 00:00:00.000000','Samsung','wewnętrzna',0,'wewnętrzna','naścienny',5.00,6.00,'Cebu','Cebu','AR18TXFYAWKNEU','',2749.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(240,'2023-10-31 00:00:00.000000','Samsung','wewnętrzna',0,'wewnętrzna','naścienny',6.50,7.40,'Cebu','Cebu','AR24TXFYAWKNEU','',3619.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(241,'2023-11-01 00:00:00.000000','Samsung','wewnętrzna',0,'wewnętrzna','naścienny',2.00,2.20,'WindFree Comfort','WindFree Comfort','AR09TXFCAWKNEU','',1809.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(242,'2023-11-02 00:00:00.000000','Samsung','wewnętrzna',0,'wewnętrzna','naścienny',2.50,3.20,'WindFree Comfort','WindFree Comfort','AR09TXFCAWKNEU','',1989.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(243,'2023-11-03 00:00:00.000000','Samsung','wewnętrzna',0,'wewnętrzna','naścienny',3.50,3.50,'WindFree Comfort','WindFree Comfort','AR12TXFCAWKNEU','',2199.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(244,'2023-11-04 00:00:00.000000','Samsung','wewnętrzna',0,'wewnętrzna','naścienny',5.00,6.00,'WindFree Comfort','WindFree Comfort','AR18TXFCAWKNEU','',3389.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(245,'2023-11-05 00:00:00.000000','Samsung','wewnętrzna',0,'wewnętrzna','naścienny',6.50,7.40,'WindFree Comfort','WindFree Comfort','AR24TXFCAWKNEU','',4479.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(246,'2023-11-06 00:00:00.000000','Samsung','wewnętrzna',0,'wewnętrzna','naścienny',2.00,2.20,'WindFree AVANT','WindFree AVANT','AR07TXEAAWKNEU','',2449.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(247,'2023-11-07 00:00:00.000000','Samsung','wewnętrzna',0,'wewnętrzna','naścienny',2.50,3.20,'WindFree AVANT','WindFree AVANT','AR09TXEAAWKNEU','',2689.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(248,'2023-11-08 00:00:00.000000','Samsung','wewnętrzna',0,'wewnętrzna','naścienny',3.50,4.00,'WindFree AVANT','WindFree AVANT','AR12TXEAAWKNEU','',2979.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(249,'2023-11-09 00:00:00.000000','Samsung','wewnętrzna',0,'wewnętrzna','naścienny',5.00,6.00,'WindFree AVANT','WindFree AVANT','AR18TXEAAWKNEU','',4599.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(250,'2023-11-10 00:00:00.000000','Samsung','wewnętrzna',0,'wewnętrzna','naścienny',6.50,7.40,'WindFree AVANT','WindFree AVANT','AR24TXEAAWKNEU','',6069.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(251,'2023-11-11 00:00:00.000000','Samsung','wewnętrzna',0,'wewnętrzna','naścienny',2.00,2.20,'WindFree Elite','WindFree Elite','AR07TXCAAWKNEU','',2689.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(252,'2023-11-12 00:00:00.000000','Samsung','wewnętrzna',0,'wewnętrzna','naścienny',2.50,3.20,'WindFree Elite','WindFree Elite','AR09TXCAAWKNEU','',2959.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(253,'2023-11-13 00:00:00.000000','Samsung','wewnętrzna',0,'wewnętrzna','naścienny',3.50,4.00,'WindFree Elite','WindFree Elite','AR12TXCAAWKNEU','',3279.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(254,'2023-11-14 00:00:00.000000','Samsung','wewnętrzna',0,'wewnętrzna','kaseton',1.60,2.00,'Kaseton WindFree','Kaseton WindFree','AJ016TNNDKG/EU','',4458.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(255,'2023-11-15 00:00:00.000000','Samsung','wewnętrzna',0,'wewnętrzna','kaseton',2.00,2.20,'Kaseton WindFree','Kaseton WindFree','AJ020TNNDKG/EU','',4618.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(256,'2023-11-16 00:00:00.000000','Samsung','wewnętrzna',0,'wewnętrzna','kaseton',2.60,2.90,'Kaseton WindFree','Kaseton WindFree','AJ026TNNDKG/EU','',4768.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(257,'2023-11-17 00:00:00.000000','Samsung','wewnętrzna',0,'wewnętrzna','kaseton',3.50,3.80,'Kaseton WindFree','Kaseton WindFree','AJ035TNNDKG/EU','',5028.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(258,'2023-11-18 00:00:00.000000','Samsung','wewnętrzna',0,'wewnętrzna','kaseton',5.20,5.60,'Kaseton WindFree','Kaseton WindFree','AJ052TNNDKG/EU','',5388.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(259,'2023-11-19 00:00:00.000000','Samsung','wewnętrzna',0,'wewnętrzna','kaseton',2.60,2.90,'Kaseton 1 kierunkowy','Kaseton 1 kierunkowy','AJ026TN1DKG/EU','',4568.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(260,'2023-11-20 00:00:00.000000','Samsung','wewnętrzna',0,'wewnętrzna','kaseton',3.50,3.80,'Kaseton 1 kierunkowy','Kaseton 1 kierunkowy','AJ035TN1DKG/EU','',4978.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(261,'2023-11-21 00:00:00.000000','Samsung','wewnętrzna',0,'wewnętrzna','kanałowy',2.60,2.90,'Kanałowy Slim','Kanałowy Slim','AJ026TNLDEG/EU','',3779.00,'',NULL,NULL,NULL,NULL,NULL,0),(262,'2023-11-22 00:00:00.000000','Samsung','wewnętrzna',0,'wewnętrzna','kanałowy',3.50,3.80,'Kanałowy Slim','Kanałowy Slim','AJ035TNLDEG/EU','',4079.00,'',NULL,NULL,NULL,NULL,NULL,0),(263,'2023-11-23 00:00:00.000000','Samsung','wewnętrzna',0,'wewnętrzna','kanałowy',2.60,2.90,'Kanałowy Slim','Kanałowy Slim','AJ026TNLPEG/EU','',3939.00,'',NULL,NULL,NULL,NULL,NULL,0),(264,'2023-11-24 00:00:00.000000','Samsung','wewnętrzna',0,'wewnętrzna','kanałowy',3.50,3.80,'Kanałowy Slim','Kanałowy Slim','AJ035TNLPEG/EU','',4229.00,'',NULL,NULL,NULL,NULL,NULL,0),(265,'2023-11-25 00:00:00.000000','Samsung','wewnętrzna',0,'wewnętrzna','kanałowy',5.20,5.60,'Kanałowy Slim','Kanałowy Slim','AJ052TNMDEG/EU','',4379.00,'',NULL,NULL,NULL,NULL,NULL,0),(266,'2023-11-26 00:00:00.000000','Samsung','wewnętrzna',0,'wewnętrzna','konsola',2.60,2.90,'Konsola','Konsola','AJ026TNJDKG/EU','',3619.00,'',NULL,NULL,NULL,NULL,NULL,0),(267,'2023-11-27 00:00:00.000000','Samsung','wewnętrzna',0,'wewnętrzna','konsola',3.50,3.80,'Konsola','Konsola','AJ035TNJDKG/EU','',4269.00,'',NULL,NULL,NULL,NULL,NULL,0),(268,'2023-11-28 00:00:00.000000','Samsung','wewnętrzna',0,'wewnętrzna','konsola',5.20,5.60,'Konsola','Konsola','AJ052TNJDKG/EU','',4609.00,'',NULL,NULL,NULL,NULL,NULL,0),(269,'2023-11-30 00:00:00.000000','Fuji','agregat',2,'zewnętrzna','',4.00,4.40,'Agregat Multi','ROG14KBTA2 ','','ROG14KBTA2 ',5700.00,'',NULL,NULL,NULL,NULL,NULL,0),(270,'2023-12-01 00:00:00.000000','Fuji','agregat',2,'zewnętrzna','',5.00,5.60,'Agregat Multi','ROG18KBTA2 ','','ROG18KBTA2 ',6600.00,'',NULL,NULL,NULL,NULL,NULL,0),(271,'2023-12-02 00:00:00.000000','Fuji','agregat',3,'zewnętrzna','',5.40,6.80,'Agregat Multi','ROG18KBTA3 ','','ROG18KBTA3 ',8500.00,'',NULL,NULL,NULL,NULL,NULL,0),(272,'2023-12-03 00:00:00.000000','Fuji','agregat',3,'zewnętrzna','',6.80,8.00,'Agregat Multi','ROG24KBTA3 ','','ROG24KBTA3 ',9100.00,'',NULL,NULL,NULL,NULL,NULL,0),(273,'2023-12-04 00:00:00.000000','Fuji','agregat',4,'zewnętrzna','',8.00,9.60,'Agregat Multi','ROG30KBTA4 ','','ROG30KBTA4 ',11100.00,'',NULL,NULL,NULL,NULL,NULL,0),(274,'2023-12-05 00:00:00.000000','Fuji','agregat',5,'zewnętrzna','',9.50,10.60,'Agregat Multi','ROG36KBTA5','','ROG36KBTA5',13700.00,'',NULL,NULL,NULL,NULL,NULL,0),(275,'2023-12-06 00:00:00.000000','Fuji','agregat',6,'zewnętrzna','',12.50,13.50,'Agregat Multi','R410 ROG45LBLA6','','ROG45LBLA6',16500.00,'',NULL,NULL,NULL,NULL,NULL,0),(276,'2023-12-07 00:00:00.000000','Fuji','agregat',8,'zewnętrzna','',14.00,16.00,'Agregat Multi','R410 ROG45LBT8','','ROG45LBT8',16900.00,'',NULL,NULL,NULL,NULL,NULL,0),(277,'2023-12-08 00:00:00.000000','Fuji','wewnętrzna',0,'wewnętrzna','naścienny',2.00,2.50,'KETA White','KETA White','RSG07KETA','',1800.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(278,'2023-12-09 00:00:00.000000','Fuji','wewnętrzna',0,'wewnętrzna','naścienny',2.50,2.80,'KETA White','KETA White','RSG09KETA','',1900.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(279,'2023-12-10 00:00:00.000000','Fuji','wewnętrzna',0,'wewnętrzna','naścienny',3.40,4.00,'KETA White','KETA White','RSG12KETA','',2200.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(280,'2023-12-11 00:00:00.000000','Fuji','wewnętrzna',0,'wewnętrzna','naścienny',4.20,5.40,'KETA White','KETA White','RSG14KETA','',3150.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(281,'2023-12-12 00:00:00.000000','Fuji','wewnętrzna',0,'wewnętrzna','naścienny',2.00,2.50,'KETA Graphite','KETA Graphite','RSG07KETAB','',1800.00,'grafitowy',NULL,NULL,NULL,NULL,NULL,0),(282,'2023-12-13 00:00:00.000000','Fuji','wewnętrzna',0,'wewnętrzna','naścienny',2.50,2.80,'KETA Graphite','KETA Graphite','RSG09KETAB','',1900.00,'grafitowy',NULL,NULL,NULL,NULL,NULL,0),(283,'2023-12-14 00:00:00.000000','Fuji','wewnętrzna',0,'wewnętrzna','naścienny',3.40,4.00,'KETA Graphite','KETA Graphite','RSG12KETAB','',2200.00,'grafitowy',NULL,NULL,NULL,NULL,NULL,0),(284,'2023-12-15 00:00:00.000000','Fuji','wewnętrzna',0,'wewnętrzna','naścienny',4.20,5.40,'KETA Graphite','KETA Graphite','RSG14KETAB','',3150.00,'grafitowy',NULL,NULL,NULL,NULL,NULL,0),(285,'2023-12-16 00:00:00.000000','Fuji','wewnętrzna',0,'wewnętrzna','naścienny',2.00,2.50,'KMCC','KMCC','RSG07KMCC','',1450.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(286,'2023-12-17 00:00:00.000000','Fuji','wewnętrzna',0,'wewnętrzna','naścienny',2.50,2.80,'KMCC','KMCC','RSG09KMCC','',1650.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(287,'2023-12-18 00:00:00.000000','Fuji','wewnętrzna',0,'wewnętrzna','naścienny',3.40,4.00,'KMCC','KMCC','RSG12KMCC','',1850.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(288,'2023-12-19 00:00:00.000000','Fuji','wewnętrzna',0,'wewnętrzna','naścienny',4.20,5.40,'KMCC','KMCC','RSG14KMCC','',2750.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(289,'2023-12-20 00:00:00.000000','Fuji','wewnętrzna',0,'wewnętrzna','naścienny',5.00,6.00,'KMCC','KMCC','RSG18KMTB','',3500.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(290,'2023-12-21 00:00:00.000000','Fuji','wewnętrzna',0,'wewnętrzna','naścienny',7.00,8.20,'KMCC','KMCC','RSG24KMTB','',4200.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(291,'2023-12-22 00:00:00.000000','Fuji','wewnętrzna',0,'wewnętrzna','naścienny',2.00,2.50,'KGTB','KGTB','RSG07KGTB','',1950.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(292,'2023-12-23 00:00:00.000000','Fuji','wewnętrzna',0,'wewnętrzna','naścienny',2.50,2.80,'KGTB','KGTB','RSG09KGTB','',2050.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(293,'2023-12-24 00:00:00.000000','Fuji','wewnętrzna',0,'wewnętrzna','naścienny',3.40,4.00,'KGTB','KGTB','RSG12KGTB','',2200.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(294,'2023-12-25 00:00:00.000000','Fuji','wewnętrzna',0,'wewnętrzna','naścienny',4.20,5.40,'KGTB','KGTB','RSG14KGTB','',3200.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(295,'2023-12-26 00:00:00.000000','Fuji','wewnętrzna',0,'wewnętrzna','przypodłogowy',2.50,3.50,'KVCA','KVCA','RGG09KVCA','',3700.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(296,'2023-12-27 00:00:00.000000','Fuji','wewnętrzna',0,'wewnętrzna','przypodłogowy',3.40,4.50,'KVCA','KVCA','RGG12KVCA','',4400.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(297,'2023-12-28 00:00:00.000000','Fuji','wewnętrzna',0,'wewnętrzna','przypodłogowy',4.20,5.20,'KVCA','KVCA','RGG14KVCA','',5100.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(298,'2023-12-29 00:00:00.000000','Fuji','wewnętrzna',0,'wewnętrzna','przysufitowy',5.20,6.00,'KRTA','KRTA','RYG18KRTA','',4000.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(299,'2023-12-30 00:00:00.000000','Fuji','wewnętrzna',0,'wewnętrzna','przysufitowy',6.00,7.00,'KRTA','KRTA','RYG22KRTA','',4400.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(300,'2023-12-31 00:00:00.000000','Fuji','wewnętrzna',0,'wewnętrzna','kaseton',2.00,2.50,'KVLA','KVLA','RCG07KVLA','',4300.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(301,'2024-01-01 00:00:00.000000','Fuji','wewnętrzna',0,'wewnętrzna','kaseton',2.50,3.20,'KVLA','KVLA','RCG09KVLA','',4400.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(302,'2024-01-02 00:00:00.000000','Fuji','wewnętrzna',0,'wewnętrzna','kaseton',3.50,4.10,'KVLA','KVLA','RCG12KVLA','',4800.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(303,'2024-01-03 00:00:00.000000','Fuji','wewnętrzna',0,'wewnętrzna','kaseton',4.30,5.00,'KVLA','KVLA','RCG14KVLA','',5200.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(304,'2024-01-04 00:00:00.000000','Fuji','wewnętrzna',0,'wewnętrzna','kanałowy',2.00,2.70,'KSLAP','KSLAP','RDG07KSLAP','',3600.00,'',NULL,NULL,NULL,NULL,NULL,0),(305,'2024-01-05 00:00:00.000000','Fuji','wewnętrzna',0,'wewnętrzna','kanałowy',2.50,3.30,'KSLAP','KSLAP','RDG09KSLAP','',3700.00,'',NULL,NULL,NULL,NULL,NULL,0),(306,'2024-01-06 00:00:00.000000','Fuji','wewnętrzna',0,'wewnętrzna','kanałowy',3.50,3.80,'KSLAP','KSLAP','RDG12KSLAP','',3900.00,'',NULL,NULL,NULL,NULL,NULL,0),(307,'2024-01-07 00:00:00.000000','Fuji','wewnętrzna',0,'wewnętrzna','kanałowy',4.00,5.00,'KSLAP','KSLAP','RDG14KSLAP','',4100.00,'',NULL,NULL,NULL,NULL,NULL,0),(308,'2024-01-08 00:00:00.000000','Fuji','wewnętrzna',0,'wewnętrzna','kanałowy',5.00,6.00,'KSLAP','KSLAP','RDG18KSLAP','',4700.00,'',NULL,NULL,NULL,NULL,NULL,0),(309,'2024-01-09 00:00:00.000000','Fuji','wewnętrzna',0,'wewnętrzna','kanałowy',2.00,2.70,'KLLAP','KLLAP','RDG07KLLAP','',3400.00,'',NULL,NULL,NULL,NULL,NULL,0),(310,'2024-01-10 00:00:00.000000','Fuji','wewnętrzna',0,'wewnętrzna','kanałowy',2.50,3.30,'KLLAP','KLLAP','RDG09KLLAP','',3800.00,'',NULL,NULL,NULL,NULL,NULL,0),(311,'2024-01-11 00:00:00.000000','Fuji','wewnętrzna',0,'wewnętrzna','kanałowy',3.50,3.80,'KLLAP','KLLAP','RDG12KLLAP','',3900.00,'',NULL,NULL,NULL,NULL,NULL,0),(312,'2024-01-12 00:00:00.000000','Fuji','wewnętrzna',0,'wewnętrzna','kanałowy',4.00,5.00,'KLLAP','KLLAP','RDG14KLLAP','',3950.00,'',NULL,NULL,NULL,NULL,NULL,0),(313,'2024-01-13 00:00:00.000000','Fuji','wewnętrzna',0,'wewnętrzna','kanałowy',5.00,6.00,'KLLAP','KLLAP','RDG18KLLAP','',4400.00,'',NULL,NULL,NULL,NULL,NULL,0),(314,'2024-01-14 00:00:00.000000','Fuji','wewnętrzna',0,'wewnętrzna','naścienny',2.00,3.00,'LMCA','LMCA','RSG07LMCA','',1300.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(315,'2024-01-15 00:00:00.000000','Fuji','wewnętrzna',0,'wewnętrzna','naścienny',2.50,3.20,'LMCA','LMCA','RSG09LMCA','',1400.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(316,'2024-01-16 00:00:00.000000','Fuji','wewnętrzna',0,'wewnętrzna','naścienny',3.40,4.00,'LMCA','LMCA','RSG12LMCA','',1600.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(317,'2024-01-17 00:00:00.000000','Fuji','wewnętrzna',0,'wewnętrzna','naścienny',4.00,5.00,'LMCA','LMCA','RSG14LMCA','',2450.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(318,'2024-01-18 00:00:00.000000','Fuji','wewnętrzna',0,'wewnętrzna','naścienny',2.00,3.00,'LVLA/B','LVLA/B','RCG07LVLA','',4000.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(319,'2024-01-19 00:00:00.000000','Fuji','wewnętrzna',0,'wewnętrzna','naścienny',2.50,3.20,'LVLA/B','LVLA/B','RCG09LVLA','',4200.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(320,'2024-01-20 00:00:00.000000','Fuji','wewnętrzna',0,'wewnętrzna','naścienny',3.40,4.00,'LVLA/B','LVLA/B','RCG12LVLB','',4350.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(321,'2024-01-21 00:00:00.000000','Fuji','wewnętrzna',0,'wewnętrzna','naścienny',4.00,5.00,'LVLA/B','LVLA/B','RCG14LVLB','',4600.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(322,'2024-01-22 00:00:00.000000','Fuji','wewnętrzna',0,'wewnętrzna','naścienny',5.00,5.90,'LVLA/B','LVLA/B','RCG18LVLB','',4800.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(323,'2024-01-24 00:00:00.000000','Daikin','agregat',2,'zewnętrzna','',4.00,4.00,'Agregat Multi','2MXM40A ','','2MXM40A ',5550.00,'',NULL,NULL,NULL,NULL,NULL,0),(324,'2024-01-25 00:00:00.000000','Daikin','agregat',2,'zewnętrzna','',5.00,5.00,'Agregat Multi','2MXM50A ','','2MXM50A ',6430.00,'',NULL,NULL,NULL,NULL,NULL,0),(325,'2024-01-26 00:00:00.000000','Daikin','agregat',2,'zewnętrzna','',6.80,6.80,'Agregat Multi','2MXM68A ','','2MXM68A ',8370.00,'',NULL,NULL,NULL,NULL,NULL,0),(326,'2024-01-27 00:00:00.000000','Daikin','agregat',3,'zewnętrzna','',4.00,4.00,'Agregat Multi','3MXM40A ','','3MXM40A ',6600.00,'',NULL,NULL,NULL,NULL,NULL,0),(327,'2024-01-28 00:00:00.000000','Daikin','agregat',3,'zewnętrzna','',5.20,5.20,'Agregat Multi','3MXM52A ','','3MXM52A ',7380.00,'',NULL,NULL,NULL,NULL,NULL,0),(328,'2024-01-29 00:00:00.000000','Daikin','agregat',3,'zewnętrzna','',7.00,7.00,'Agregat Multi','3MXM68A ','','3MXM68A ',8680.00,'',NULL,NULL,NULL,NULL,NULL,0),(329,'2024-01-30 00:00:00.000000','Daikin','agregat',4,'zewnętrzna','',7.00,7.00,'Agregat Multi','4MXM68A ','','4MXM68A ',9330.00,'',NULL,NULL,NULL,NULL,NULL,0),(330,'2024-01-31 00:00:00.000000','Daikin','agregat',4,'zewnętrzna','',8.00,8.00,'Agregat Multi','4MXM80A ','','4MXM80A ',10540.00,'',NULL,NULL,NULL,NULL,NULL,0),(331,'2024-02-01 00:00:00.000000','Daikin','agregat',5,'zewnętrzna','',9.50,9.50,'Agregat Multi','5MXM90A','','5MXM90A',11340.00,'',NULL,NULL,NULL,NULL,NULL,0),(332,'2024-02-02 00:00:00.000000','Daikin','wewnętrzna',0,'wewnętrzna','naścienny',1.50,2.00,'Stylish Biały','CTXA-15AW','CTXA-15AW','',2860.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(333,'2024-02-03 00:00:00.000000','Daikin','wewnętrzna',0,'wewnętrzna','naścienny',2.00,2.50,'Stylish Biały','FTXA-20AW','FTXA-20AW','',3070.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(334,'2024-02-04 00:00:00.000000','Daikin','wewnętrzna',0,'wewnętrzna','naścienny',2.50,2.80,'Stylish Biały','FTXA-25AW','FTXA-25AW','',3370.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(335,'2024-02-05 00:00:00.000000','Daikin','wewnętrzna',0,'wewnętrzna','naścienny',3.40,4.00,'Stylish Biały','FTXA-35AW','FTXA-35AW','',3660.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(336,'2024-02-06 00:00:00.000000','Daikin','wewnętrzna',0,'wewnętrzna','naścienny',4.20,5.40,'Stylish Biały','FTXA-42AW','FTXA-42AW','',4450.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(337,'2024-02-07 00:00:00.000000','Daikin','wewnętrzna',0,'wewnętrzna','naścienny',5.00,5.80,'Stylish Biały','FTXA-50AW','FTXA-50AW','',4770.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(338,'2024-02-08 00:00:00.000000','Daikin','wewnętrzna',0,'wewnętrzna','naścienny',1.50,2.00,'Stylish Srebrny','CTXA-15BS','CTXA-15BS','',3050.00,'srebrny',NULL,NULL,NULL,NULL,NULL,0),(339,'2024-02-09 00:00:00.000000','Daikin','wewnętrzna',0,'wewnętrzna','naścienny',2.00,2.50,'Stylish Srebrny','FTXA-20BS','FTXA-20BS','',3370.00,'srebrny',NULL,NULL,NULL,NULL,NULL,0),(340,'2024-02-10 00:00:00.000000','Daikin','wewnętrzna',0,'wewnętrzna','naścienny',2.50,2.80,'Stylish Srebrny','FTXA-25BS','FTXA-25BS','',3660.00,'srebrny',NULL,NULL,NULL,NULL,NULL,0),(341,'2024-02-11 00:00:00.000000','Daikin','wewnętrzna',0,'wewnętrzna','naścienny',3.40,4.00,'Stylish Srebrny','FTXA-35BS','FTXA-35BS','',4000.00,'srebrny',NULL,NULL,NULL,NULL,NULL,0),(342,'2024-02-12 00:00:00.000000','Daikin','wewnętrzna',0,'wewnętrzna','naścienny',4.20,5.40,'Stylish Srebrny','FTXA-42BS','FTXA-42BS','',4650.00,'srebrny',NULL,NULL,NULL,NULL,NULL,0),(343,'2024-02-13 00:00:00.000000','Daikin','wewnętrzna',0,'wewnętrzna','naścienny',5.00,5.80,'Stylish Srebrny','FTXA-50BS','FTXA-50BS','',5040.00,'srebrny',NULL,NULL,NULL,NULL,NULL,0),(344,'2024-02-14 00:00:00.000000','Daikin','wewnętrzna',0,'wewnętrzna','naścienny',1.50,2.00,'Stylish Drewno','CTXA-15BT','CTXA-15BT','',3320.00,'drewno',NULL,NULL,NULL,NULL,NULL,0),(345,'2024-02-15 00:00:00.000000','Daikin','wewnętrzna',0,'wewnętrzna','naścienny',2.00,2.50,'Stylish Drewno','FTXA-20BT','FTXA-20BT','',3370.00,'drewno',NULL,NULL,NULL,NULL,NULL,0),(346,'2024-02-16 00:00:00.000000','Daikin','wewnętrzna',0,'wewnętrzna','naścienny',2.50,2.80,'Stylish Drewno','FTXA-25BT','FTXA-25BT','',3480.00,'drewno',NULL,NULL,NULL,NULL,NULL,0),(347,'2024-02-17 00:00:00.000000','Daikin','wewnętrzna',0,'wewnętrzna','naścienny',3.40,4.00,'Stylish Drewno','FTXA-35BT','FTXA-35BT','',4070.00,'drewno',NULL,NULL,NULL,NULL,NULL,0),(348,'2024-02-18 00:00:00.000000','Daikin','wewnętrzna',0,'wewnętrzna','naścienny',4.20,5.40,'Stylish Drewno','FTXA-42BT','FTXA-42BT','',5070.00,'drewno',NULL,NULL,NULL,NULL,NULL,0),(349,'2024-02-19 00:00:00.000000','Daikin','wewnętrzna',0,'wewnętrzna','naścienny',5.00,5.80,'Stylish Drewno','FTXA-50BT','FTXA-50BT','',5460.00,'drewno',NULL,NULL,NULL,NULL,NULL,0),(350,'2024-02-20 00:00:00.000000','Daikin','wewnętrzna',0,'wewnętrzna','naścienny',1.50,2.00,'Stylish Czarny','CTXA-15BB','CTXA-15BB','',2820.00,'czarny',NULL,NULL,NULL,NULL,NULL,0),(351,'2024-02-21 00:00:00.000000','Daikin','wewnętrzna',0,'wewnętrzna','naścienny',2.00,2.50,'Stylish Czarny','FTXA-20BB','FTXA-20BB','',3220.00,'czarny',NULL,NULL,NULL,NULL,NULL,0),(352,'2024-02-22 00:00:00.000000','Daikin','wewnętrzna',0,'wewnętrzna','naścienny',2.50,2.80,'Stylish Czarny','FTXA-25BB','FTXA-25BB','',3520.00,'czarny',NULL,NULL,NULL,NULL,NULL,0),(353,'2024-02-23 00:00:00.000000','Daikin','wewnętrzna',0,'wewnętrzna','naścienny',3.40,4.00,'Stylish Czarny','FTXA-35BB','FTXA-35BB','',3640.00,'czarny',NULL,NULL,NULL,NULL,NULL,0),(354,'2024-02-24 00:00:00.000000','Daikin','wewnętrzna',0,'wewnętrzna','naścienny',4.20,5.40,'Stylish Czarny','FTXA-42BB','FTXA-42BB','',4430.00,'czarny',NULL,NULL,NULL,NULL,NULL,0),(355,'2024-02-25 00:00:00.000000','Daikin','wewnętrzna',0,'wewnętrzna','naścienny',5.00,5.80,'Stylish Czarny','FTXA-50BB','FTXA-50BB','',4770.00,'czarny',NULL,NULL,NULL,NULL,NULL,0),(356,'2024-02-26 00:00:00.000000','Daikin','wewnętrzna',0,'wewnętrzna','naścienny',1.50,2.00,'Perfera','CTXM-15R','CTXM-15R','',2240.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(357,'2024-02-27 00:00:00.000000','Daikin','wewnętrzna',0,'wewnętrzna','naścienny',2.00,2.50,'Perfera','FTXM-20R','FTXM-20R','',2360.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(358,'2024-02-28 00:00:00.000000','Daikin','wewnętrzna',0,'wewnętrzna','naścienny',2.50,2.80,'Perfera','FTXM-25R','FTXM-25R','',2480.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(359,'2024-02-29 00:00:00.000000','Daikin','wewnętrzna',0,'wewnętrzna','naścienny',3.40,4.00,'Perfera','FTXM-35R','FTXM-35R','',3180.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(360,'2024-03-01 00:00:00.000000','Daikin','wewnętrzna',0,'wewnętrzna','naścienny',4.20,5.40,'Perfera','FTXM-42R','FTXM-42R','',3950.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(361,'2024-03-02 00:00:00.000000','Daikin','wewnętrzna',0,'wewnętrzna','naścienny',5.00,5.80,'Perfera','FTXM-50R','FTXM-50R','',4320.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(362,'2024-03-03 00:00:00.000000','Daikin','wewnętrzna',0,'wewnętrzna','naścienny',6.00,7.00,'Perfera','FTXM-60R','FTXM-60R','',5100.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(363,'2024-03-04 00:00:00.000000','Daikin','wewnętrzna',0,'wewnętrzna','naścienny',7.10,8.20,'Perfera','FTXM-71R','FTXM-71R','',5500.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(364,'2024-03-05 00:00:00.000000','Daikin','wewnętrzna',0,'wewnętrzna','naścienny',2.00,2.50,'Emura AW Biały','Emura AW Biały','FTXJ-20AW','',3580.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(365,'2024-03-06 00:00:00.000000','Daikin','wewnętrzna',0,'wewnętrzna','naścienny',2.50,2.80,'Emura AW Biały','Emura AW Biały','FTXJ-25AW','',3780.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(366,'2024-03-07 00:00:00.000000','Daikin','wewnętrzna',0,'wewnętrzna','naścienny',3.40,4.00,'Emura AW Biały','Emura AW Biały','FTXJ-35AW','',4370.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(367,'2024-03-08 00:00:00.000000','Daikin','wewnętrzna',0,'wewnętrzna','naścienny',5.00,5.80,'Emura AW Biały','Emura AW Biały','FTXJ-50AW','',5710.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(368,'2024-03-09 00:00:00.000000','Daikin','wewnętrzna',0,'wewnętrzna','naścienny',2.00,2.50,'Emura As Srebrny','Emura As Srebrny','FTXJ-20AS','',3910.00,'srebrny',NULL,NULL,NULL,NULL,NULL,0),(369,'2024-03-10 00:00:00.000000','Daikin','wewnętrzna',0,'wewnętrzna','naścienny',2.50,2.80,'Emura As Srebrny','Emura As Srebrny','FTXJ-25AS','',4130.00,'srebrny',NULL,NULL,NULL,NULL,NULL,0),(370,'2024-03-11 00:00:00.000000','Daikin','wewnętrzna',0,'wewnętrzna','naścienny',3.40,4.00,'Emura As Srebrny','Emura As Srebrny','FTXJ-35AS','',4770.00,'srebrny',NULL,NULL,NULL,NULL,NULL,0),(371,'2024-03-12 00:00:00.000000','Daikin','wewnętrzna',0,'wewnętrzna','naścienny',5.00,5.80,'Emura As Srebrny','Emura As Srebrny','FTXJ-50AS','',6030.00,'srebrny',NULL,NULL,NULL,NULL,NULL,0),(372,'2024-03-13 00:00:00.000000','Daikin','wewnętrzna',0,'wewnętrzna','naścienny',2.00,2.50,'Emura AB Czarny','Emura AB Czarny','FTXJ-20AB','',3540.00,'czarny',NULL,NULL,NULL,NULL,NULL,0),(373,'2024-03-14 00:00:00.000000','Daikin','wewnętrzna',0,'wewnętrzna','naścienny',2.50,2.80,'Emura AB Czarny','Emura AB Czarny','FTXJ-25AB','',3610.00,'czarny',NULL,NULL,NULL,NULL,NULL,0),(374,'2024-03-15 00:00:00.000000','Daikin','wewnętrzna',0,'wewnętrzna','naścienny',3.40,4.00,'Emura AB Czarny','Emura AB Czarny','FTXJ-35AB','',4350.00,'czarny',NULL,NULL,NULL,NULL,NULL,0),(375,'2024-03-16 00:00:00.000000','Daikin','wewnętrzna',0,'wewnętrzna','naścienny',5.00,5.80,'Emura AB Czarny','Emura AB Czarny','FTXJ-50AB','',5700.00,'czarny',NULL,NULL,NULL,NULL,NULL,0),(376,'2024-03-17 00:00:00.000000','Daikin','wewnętrzna',0,'wewnętrzna','naścienny',2.00,2.50,'Comfora','Comfora','FTXP-20M9','',1690.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(377,'2024-03-18 00:00:00.000000','Daikin','wewnętrzna',0,'wewnętrzna','naścienny',2.50,3.00,'Comfora','Comfora','FTXP-25M9','',1770.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(378,'2024-03-19 00:00:00.000000','Daikin','wewnętrzna',0,'wewnętrzna','naścienny',3.50,4.00,'Comfora','Comfora','FTXP-35M9','',1950.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(379,'2024-03-20 00:00:00.000000','Daikin','wewnętrzna',0,'wewnętrzna','kanałowy',2.40,3.20,'FDXM','FDXM','FDXM-25F9','',2260.00,'',NULL,NULL,NULL,NULL,NULL,0),(380,'2024-03-21 00:00:00.000000','Daikin','wewnętrzna',0,'wewnętrzna','kanałowy',3.40,4.00,'FDXM','FDXM','FDXM-35F9','',2500.00,'',NULL,NULL,NULL,NULL,NULL,0),(381,'2024-03-22 00:00:00.000000','Daikin','wewnętrzna',0,'wewnętrzna','kanałowy',5.00,5.80,'FDXM','FDXM','FDXM-50F9','',3910.00,'',NULL,NULL,NULL,NULL,NULL,0),(382,'2024-03-23 00:00:00.000000','Daikin','wewnętrzna',0,'wewnętrzna','kanałowy',6.00,7.00,'FDXM','FDXM','FDXM-60F9','',5050.00,'',NULL,NULL,NULL,NULL,NULL,0),(383,'2024-03-24 00:00:00.000000','Daikin','wewnętrzna',0,'wewnętrzna','kanałowy',3.40,4.00,'FBA średni spręż','FBA średni spręż','FBA-35A9','',5170.00,'',NULL,NULL,NULL,NULL,NULL,0),(384,'2024-03-25 00:00:00.000000','Daikin','wewnętrzna',0,'wewnętrzna','kanałowy',5.00,5.50,'FBA średni spręż','FBA średni spręż','FBA-50A9','',5650.00,'',NULL,NULL,NULL,NULL,NULL,0),(385,'2024-03-26 00:00:00.000000','Daikin','wewnętrzna',0,'wewnętrzna','kanałowy',5.70,7.00,'FBA średni spręż','FBA średni spręż','FBA-60A9','',6030.00,'',NULL,NULL,NULL,NULL,NULL,0),(386,'2024-03-27 00:00:00.000000','Daikin','wewnętrzna',0,'wewnętrzna','kanałowy',7.10,8.20,'FBA średni spręż','FBA średni spręż','FBA-71A9','',6880.00,'',NULL,NULL,NULL,NULL,NULL,0),(387,'2024-03-28 00:00:00.000000','Daikin','wewnętrzna',0,'wewnętrzna','przypodłogowy',2.00,2.50,'Perfera','Perfera','CVXM-20A','',3530.00,'',NULL,NULL,NULL,NULL,NULL,0),(388,'2024-03-29 00:00:00.000000','Daikin','wewnętrzna',0,'wewnętrzna','przypodłogowy',2.50,2.80,'Perfera','Perfera','FVXM-25A','',2830.00,'',NULL,NULL,NULL,NULL,NULL,0),(389,'2024-03-30 00:00:00.000000','Daikin','wewnętrzna',0,'wewnętrzna','przypodłogowy',3.40,4.00,'Perfera','Perfera','FVXM-35A','',3130.00,'',NULL,NULL,NULL,NULL,NULL,0),(390,'2024-03-31 00:00:00.000000','Daikin','wewnętrzna',0,'wewnętrzna','przypodłogowy',5.00,5.80,'Perfera','Perfera','FVXM-50A','',4250.00,'',NULL,NULL,NULL,NULL,NULL,0),(391,'2024-04-01 00:00:00.000000','Daikin','wewnętrzna',0,'wewnętrzna','przypodłogowy',2.50,3.40,'Szafkowy FVXM','FVXM','FVXM-25F','',3770.00,'',NULL,NULL,NULL,NULL,NULL,0),(392,'2024-04-02 00:00:00.000000','Daikin','wewnętrzna',0,'wewnętrzna','przypodłogowy',3.50,4.50,'Szafkowy FVXM','FVXM','FVXM-35F','',3990.00,'',NULL,NULL,NULL,NULL,NULL,0),(393,'2024-04-03 00:00:00.000000','Daikin','wewnętrzna',0,'wewnętrzna','przypodłogowy',5.00,5.80,'Szafkowy FVXM','FVXM','FVXM-50F','',4380.00,'',NULL,NULL,NULL,NULL,NULL,0),(394,'2024-04-04 00:00:00.000000','Daikin','wewnętrzna',0,'wewnętrzna','przypodłogowy',2.60,3.20,'Szafkowy FNA','FNA','FNA-25A9','',3290.00,'',NULL,NULL,NULL,NULL,NULL,0),(395,'2024-04-05 00:00:00.000000','Daikin','wewnętrzna',0,'wewnętrzna','przypodłogowy',3.40,4.00,'Szafkowy FNA','FNA','FNA-35A9','',3910.00,'',NULL,NULL,NULL,NULL,NULL,0),(396,'2024-04-06 00:00:00.000000','Daikin','wewnętrzna',0,'wewnętrzna','przypodłogowy',5.00,5.80,'Szafkowy FNA','FNA','FNA-50A9','',4550.00,'',NULL,NULL,NULL,NULL,NULL,0),(397,'2024-04-07 00:00:00.000000','Daikin','wewnętrzna',0,'wewnętrzna','przypodłogowy',6.00,7.00,'Szafkowy FNA','FNA','FNA-60A9','',4990.00,'',NULL,NULL,NULL,NULL,NULL,0),(398,'2024-04-08 00:00:00.000000','Daikin','wewnętrzna',0,'wewnętrzna','kaseton',3.50,4.20,'Kaseton FCAG 360','FCAG 360','FCAG-35B','',4930.00,'',NULL,NULL,NULL,NULL,NULL,0),(399,'2024-04-09 00:00:00.000000','Daikin','wewnętrzna',0,'wewnętrzna','kaseton',5.00,6.00,'Kaseton FCAG 360','FCAG 360','FCAG-50B','',5040.00,'',NULL,NULL,NULL,NULL,NULL,0),(400,'2024-04-10 00:00:00.000000','Daikin','wewnętrzna',0,'wewnętrzna','kaseton',6.00,7.00,'Kaseton FCAG 360','FCAG 360','FCAG-60B','',5220.00,'',NULL,NULL,NULL,NULL,NULL,0),(401,'2024-04-11 00:00:00.000000','Daikin','wewnętrzna',0,'wewnętrzna','kaseton',2.50,3.20,'FFA - płaska','FFA - płaska','FFA-25A9','',4680.00,'',NULL,NULL,NULL,NULL,NULL,0),(402,'2024-04-12 00:00:00.000000','Daikin','wewnętrzna',0,'wewnętrzna','kaseton',3.40,4.20,'FFA - płaska','FFA - płaska','FFA-35A9','',4940.00,'',NULL,NULL,NULL,NULL,NULL,0),(403,'2024-04-13 00:00:00.000000','Daikin','wewnętrzna',0,'wewnętrzna','kaseton',5.00,5.80,'FFA - płaska','FFA - płaska','FFA-50A9','',5000.00,'',NULL,NULL,NULL,NULL,NULL,0),(404,'2024-04-14 00:00:00.000000','Daikin','wewnętrzna',0,'wewnętrzna','kaseton',5.70,7.00,'FFA - płaska','FFA - płaska','FFA-60A9','',5170.00,'',NULL,NULL,NULL,NULL,NULL,0),(405,'2024-04-15 00:00:00.000000','Daikin','wewnętrzna',0,'wewnętrzna','podstropowy',3.40,4.00,'FHA','FHA','FHA-35A9','',4010.00,'',NULL,NULL,NULL,NULL,NULL,0),(406,'2024-04-16 00:00:00.000000','Daikin','wewnętrzna',0,'wewnętrzna','podstropowy',5.00,6.00,'FHA','FHA','FHA-50A9','',4130.00,'',NULL,NULL,NULL,NULL,NULL,0),(407,'2024-04-17 00:00:00.000000','Daikin','wewnętrzna',0,'wewnętrzna','podstropowy',5.70,7.20,'FHA','FHA','FHA-60A9','',4760.00,'',NULL,NULL,NULL,NULL,NULL,0),(408,'2024-04-19 00:00:00.000000','Haier','agregat',2,'zewnętrzna','',4.00,4.40,'Agregat Multi','2U40S2SM1FA','','2U40S2SM1FA',4780.00,'',NULL,NULL,NULL,NULL,NULL,0),(409,'2024-04-20 00:00:00.000000','Haier','agregat',2,'zewnętrzna','',5.10,5.10,'Agregat Multi','2U50S2SM1FA-3','','2U50S2SM1FA-3',5480.00,'',NULL,NULL,NULL,NULL,NULL,0),(410,'2024-04-21 00:00:00.000000','Haier','agregat',3,'zewnętrzna','',5.50,5.50,'Agregat Multi','3U55S2SR5FA','','3U55S2SR5FA',6930.00,'',NULL,NULL,NULL,NULL,NULL,0),(411,'2024-04-22 00:00:00.000000','Haier','agregat',3,'zewnętrzna','',7.00,7.00,'Agregat Multi','3U70S2SR5FA','','3U70S2SR5FA',7350.00,'',NULL,NULL,NULL,NULL,NULL,0),(412,'2024-04-23 00:00:00.000000','Haier','agregat',4,'zewnętrzna','',7.50,8.60,'Agregat Multi','4U75S2SR5FA','','4U75S2SR5FA',8840.00,'',NULL,NULL,NULL,NULL,NULL,0),(413,'2024-04-24 00:00:00.000000','Haier','agregat',4,'zewnętrzna','',8.50,9.60,'Agregat Multi','4U85S2SR5FA','','4U85S2SR5FA',8900.00,'',NULL,NULL,NULL,NULL,NULL,0),(414,'2024-04-25 00:00:00.000000','Haier','agregat',5,'zewnętrzna','',10.00,11.50,'Agregat Multi','5U105S2SS5FA','','5U105S2SS5FA',9870.00,'',NULL,NULL,NULL,NULL,NULL,0),(415,'2024-04-26 00:00:00.000000','Haier','agregat',5,'zewnętrzna','',12.50,12.70,'Agregat Multi','5U125S2SN1FA','','5U125S2SN1FA',12030.00,'',NULL,NULL,NULL,NULL,NULL,0),(416,'2024-04-27 00:00:00.000000','Haier','wewnętrzna',0,'wewnętrzna','naścienny',2.60,3.20,'Jade ','AS25S2SJ1FA-3','AS25S2SJ1FA-4','',3640.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(417,'2024-04-28 00:00:00.000000','Haier','wewnętrzna',0,'wewnętrzna','naścienny',3.50,4.20,'Jade ','AS35S2SJ1FA-3','AS35S2SJ1FA-4','',4080.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(418,'2024-04-29 00:00:00.000000','Haier','wewnętrzna',0,'wewnętrzna','naścienny',5.20,6.00,'Jade ','AS50S2SJ1FA-3','AS50S2SJ1FA-4','',5070.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(419,'2024-04-30 00:00:00.000000','Haier','wewnętrzna',0,'wewnętrzna','naścienny',2.80,3.20,'Expert ','AS25XCAHRA','AS25XCAHRA','',2050.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(420,'2024-05-01 00:00:00.000000','Haier','wewnętrzna',0,'wewnętrzna','naścienny',3.50,4.20,'Expert ','AS35XCAHRA','AS35XCAHRA','',2100.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(421,'2024-05-02 00:00:00.000000','Haier','wewnętrzna',0,'wewnętrzna','naścienny',5.00,5.60,'Expert ','AS50XCAHRA','AS50XCAHRA','',2610.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(422,'2024-05-03 00:00:00.000000','Haier','wewnętrzna',0,'wewnętrzna','naścienny',2.60,3.20,'Flexis  Biały Połysk','AS25S2SF1FA-LW','AS25S2SF1FA-LW','',1740.00,'biały połysk',NULL,NULL,NULL,NULL,NULL,0),(423,'2024-05-04 00:00:00.000000','Haier','wewnętrzna',0,'wewnętrzna','naścienny',3.50,4.20,'Flexis  Biały Połysk','AS35S2SF1FA-LW','AS35S2SF1FA-LW','',1770.00,'biały połysk',NULL,NULL,NULL,NULL,NULL,0),(424,'2024-05-05 00:00:00.000000','Haier','wewnętrzna',0,'wewnętrzna','naścienny',5.20,6.00,'Flexis  Biały Połysk','AS50S2SF1FA-LW','AS50S2SF1FA-LW','',2240.00,'biały połysk',NULL,NULL,NULL,NULL,NULL,0),(425,'2024-05-06 00:00:00.000000','Haier','wewnętrzna',0,'wewnętrzna','naścienny',2.60,3.20,'Flexis  Biały Mat','AS25S2SF1FA-WH','AS25S2SF1FA-WH','',1740.00,'biały mat',NULL,NULL,NULL,NULL,NULL,0),(426,'2024-05-07 00:00:00.000000','Haier','wewnętrzna',0,'wewnętrzna','naścienny',3.50,4.20,'Flexis  Biały Mat','AS35S2SF1FA-WH','AS35S2SF1FA-WH','',1770.00,'biały mat',NULL,NULL,NULL,NULL,NULL,0),(427,'2024-05-08 00:00:00.000000','Haier','wewnętrzna',0,'wewnętrzna','naścienny',5.20,6.00,'Flexis  Biały Mat','AS50S2SF1FA-WH','AS50S2SF1FA-WH','',2240.00,'biały mat',NULL,NULL,NULL,NULL,NULL,0),(428,'2024-05-09 00:00:00.000000','Haier','wewnętrzna',0,'wewnętrzna','naścienny',7.00,8.00,'Flexis  Biały Mat','AS71S2SF1FA-WH','AS71S2SF1FA-WH','',2770.00,'biały mat',NULL,NULL,NULL,NULL,NULL,0),(429,'2024-05-10 00:00:00.000000','Haier','wewnętrzna',0,'wewnętrzna','naścienny',2.60,3.20,'Flexis  Czarny','AS25S2SF1FA-BH','AS25S2SF1FA-BH','',1830.00,'czarny',NULL,NULL,NULL,NULL,NULL,0),(430,'2024-05-11 00:00:00.000000','Haier','wewnętrzna',0,'wewnętrzna','naścienny',3.50,4.20,'Flexis  Czarny','AS35S2SF1FA-BH','AS35S2SF1FA-BH','',1870.00,'czarny',NULL,NULL,NULL,NULL,NULL,0),(431,'2024-05-12 00:00:00.000000','Haier','wewnętrzna',0,'wewnętrzna','naścienny',5.20,6.00,'Flexis  Czarny','AS50S2SF1FA-BH','AS50S2SF1FA-BH','',2330.00,'czarny',NULL,NULL,NULL,NULL,NULL,0),(432,'2024-05-13 00:00:00.000000','Haier','wewnętrzna',0,'wewnętrzna','naścienny',7.00,8.00,'Flexis  Czarny','AS71S2SF1FA-BH','AS71S2SF1FA-BH','',2890.00,'czarny',NULL,NULL,NULL,NULL,NULL,0),(433,'2024-05-14 00:00:00.000000','Haier','wewnętrzna',0,'wewnętrzna','naścienny',2.60,3.20,'Flexis  Siver','AS25S2SF1FA-S','AS25S2SF1FA-S','',1830.00,'silver',NULL,NULL,NULL,NULL,NULL,0),(434,'2024-05-15 00:00:00.000000','Haier','wewnętrzna',0,'wewnętrzna','naścienny',3.50,4.20,'Flexis  Siver','AS35S2SF1FA-S','AS35S2SF1FA-S','',1870.00,'silver',NULL,NULL,NULL,NULL,NULL,0),(435,'2024-05-16 00:00:00.000000','Haier','wewnętrzna',0,'wewnętrzna','naścienny',2.60,2.80,'PEARL ','AS25PBAHRA','AS25PBAHRA','',1230.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(436,'2024-05-17 00:00:00.000000','Haier','wewnętrzna',0,'wewnętrzna','naścienny',3.50,3.50,'PEARL ','AS35PBAHRA','AS35PBAHRA','',1280.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(437,'2024-05-18 00:00:00.000000','Haier','wewnętrzna',0,'wewnętrzna','naścienny',5.00,5.20,'PEARL ','AS50PDAHRA','AS50PDAHRA','',2130.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(438,'2024-05-19 00:00:00.000000','Haier','wewnętrzna',0,'wewnętrzna','naścienny',6.80,6.00,'PEARL ','AS68PDAHRA','AS68PDAHRA','',2230.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(439,'2024-05-20 00:00:00.000000','Haier','wewnętrzna',0,'wewnętrzna','konsola',2.50,2.80,'Console','AF25S2SD1FA','AF25S2SD1FA','',2840.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(440,'2024-05-21 00:00:00.000000','Haier','wewnętrzna',0,'wewnętrzna','konsola',3.40,3.50,'Console','AF35S2SD1FA','AF35S2SD1FA','',2910.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(441,'2024-05-22 00:00:00.000000','Haier','wewnętrzna',0,'wewnętrzna','konsola',4.20,4.70,'Console','AF42S2SD1FA','AF42S2SD1FA','',2980.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(442,'2024-05-23 00:00:00.000000','Haier','wewnętrzna',0,'wewnętrzna','przypodłogowo-podsufitowy',3.50,4.00,'Convertible','AC35S2SG1FA','AC35S2SG1FA','',3760.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(443,'2024-05-24 00:00:00.000000','Haier','wewnętrzna',0,'wewnętrzna','przypodłogowo-podsufitowy',5.00,5.80,'Convertible','AC50S2SG1FA','AC50S2SG1FA','',4020.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(444,'2024-05-25 00:00:00.000000','Haier','wewnętrzna',0,'wewnętrzna','przypodłogowo-podsufitowy',7.10,7.50,'Convertible','AC71S2SG1FA','AC71S2SG1FA','',4470.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(445,'2024-05-26 00:00:00.000000','Haier','wewnętrzna',0,'wewnętrzna','kaseton',2.50,3.20,'Cassette Mini','AB25S2SC2FA','AB25S2SC2FA','',3130.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(446,'2024-05-27 00:00:00.000000','Haier','wewnętrzna',0,'wewnętrzna','kaseton',3.50,4.00,'Cassette Mini','AB35S2SC2FA','AB35S2SC2FA','',3240.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(447,'2024-05-28 00:00:00.000000','Haier','wewnętrzna',0,'wewnętrzna','kaseton',5.00,5.50,'Cassette Mini','AB50S2SC2FA','AB50S2SC2FA','',3360.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(448,'2024-05-29 00:00:00.000000','Haier','wewnętrzna',0,'wewnętrzna','kaseton',7.10,8.00,'Cassete Obwodowy','AB71S2SG1FA','AB71S2SG1FA','',3870.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(449,'2024-05-30 00:00:00.000000','Haier','wewnętrzna',0,'wewnętrzna','kanałowy',2.50,3.00,'Slim Duct','AD25S2SS1FA','AD25S2SS1FA','',3260.00,'',NULL,NULL,NULL,NULL,NULL,0),(450,'2024-05-31 00:00:00.000000','Haier','wewnętrzna',0,'wewnętrzna','kanałowy',3.50,4.00,'Slim Duct','AD35S2SS1FA','AD35S2SS1FA','',3330.00,'',NULL,NULL,NULL,NULL,NULL,0),(451,'2024-06-01 00:00:00.000000','Haier','wewnętrzna',0,'wewnętrzna','kanałowy',5.00,5.50,'Slim Duct','AD50S2SS1FA','AD50S2SS1FA','',4010.00,'',NULL,NULL,NULL,NULL,NULL,0),(452,'2024-06-02 00:00:00.000000','Haier','wewnętrzna',0,'wewnętrzna','kanałowy',7.10,7.50,'Slim Duct','AD71S2SS1FA','AD71S2SS1FA','',4070.00,'',NULL,NULL,NULL,NULL,NULL,0),(453,'2024-06-03 00:00:00.000000','Haier','wewnętrzna',0,'wewnętrzna','kanałowy',3.50,4.00,'Duct','AD35S2SM3FA','AD35S2SM3FA','',3460.00,'',NULL,NULL,NULL,NULL,NULL,0),(454,'2024-06-04 00:00:00.000000','Haier','wewnętrzna',0,'wewnętrzna','kanałowy',5.00,6.00,'Duct','AD50S2SM3FA','AD50S2SM3FA','',3760.00,'',NULL,NULL,NULL,NULL,NULL,0),(455,'2024-06-05 00:00:00.000000','Haier','wewnętrzna',0,'wewnętrzna','kanałowy',7.10,7.50,'Duct','AD71S2SM3FA','AD71S2SM3FA','',4550.00,'',NULL,NULL,NULL,NULL,NULL,0),(456,'2024-06-07 00:00:00.000000','Fujitsu','agregat',2,'zewnętrzna','',4.00,4.40,'Agregat Multi','AOYG14KBTA2','','AOYG14KBTA2',6200.00,'',NULL,NULL,NULL,NULL,NULL,0),(457,'2024-06-08 00:00:00.000000','Fujitsu','agregat',2,'zewnętrzna','',5.00,5.60,'Agregat Multi','AOYG18KBTA2','','AOYG18KBTA2',7200.00,'',NULL,NULL,NULL,NULL,NULL,0),(458,'2024-06-09 00:00:00.000000','Fujitsu','agregat',3,'zewnętrzna','',5.40,6.80,'Agregat Multi','AOYG18KBTA3','','AOYG18KBTA3',9200.00,'',NULL,NULL,NULL,NULL,NULL,0),(459,'2024-06-10 00:00:00.000000','Fujitsu','agregat',3,'zewnętrzna','',6.80,8.00,'Agregat Multi','AOYG24KBTA3','','AOYG24KBTA3',9950.00,'',NULL,NULL,NULL,NULL,NULL,0),(460,'2024-06-11 00:00:00.000000','Fujitsu','agregat',4,'zewnętrzna','',8.00,9.60,'Agregat Multi','AOYG30KBTA4','','AOYG30KBTA4',11950.00,'',NULL,NULL,NULL,NULL,NULL,0),(461,'2024-06-12 00:00:00.000000','Fujitsu','agregat',5,'zewnętrzna','',9.50,10.60,'Agregat Multi','AOYG36KBTA5','','AOYG36KBTA5',14900.00,'',NULL,NULL,NULL,NULL,NULL,0),(462,'2024-06-13 00:00:00.000000','Fujitsu','wewnętrzna',0,'wewnętrzna','naścienny',2.00,2.70,'KETA / KETE Biały','KETA / KETE Biały','ASYG07KETA / ASYG07KETE','',2000.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(463,'2024-06-14 00:00:00.000000','Fujitsu','wewnętrzna',0,'wewnętrzna','naścienny',2.50,3.30,'KETA / KETE Biały','KETA / KETE Biały','ASYG09KETA / ASYG09KETE','',2150.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(464,'2024-06-15 00:00:00.000000','Fujitsu','wewnętrzna',0,'wewnętrzna','naścienny',3.50,3.80,'KETA / KETE Biały','KETA / KETE Biały','ASYG12KETA / ASYG12KETE','',2450.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(465,'2024-06-16 00:00:00.000000','Fujitsu','wewnętrzna',0,'wewnętrzna','naścienny',4.00,5.00,'KETA / KETE Biały','KETA / KETE Biały','ASYG14KETA / ASYG14KETE','',3450.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(466,'2024-06-17 00:00:00.000000','Fujitsu','wewnętrzna',0,'wewnętrzna','naścienny',2.00,2.70,'KETA-B / KETE-B Grafitowy','KETA-B / KETE-B Grafitowy','ASYG07KETA-B / ASYG07KETE-B','',2000.00,'grafitowy',NULL,NULL,NULL,NULL,NULL,0),(467,'2024-06-18 00:00:00.000000','Fujitsu','wewnętrzna',0,'wewnętrzna','naścienny',2.50,3.30,'KETA-B / KETE-B Grafitowy','KETA-B / KETE-B Grafitowy','ASYG09KETA-B / ASYG09KETE-B','',2150.00,'grafitowy',NULL,NULL,NULL,NULL,NULL,0),(468,'2024-06-19 00:00:00.000000','Fujitsu','wewnętrzna',0,'wewnętrzna','naścienny',3.50,3.80,'KETA-B / KETE-B Grafitowy','KETA-B / KETE-B Grafitowy','ASYG12KETA-B / ASYG12KETE-B','',2450.00,'grafitowy',NULL,NULL,NULL,NULL,NULL,0),(469,'2024-06-20 00:00:00.000000','Fujitsu','wewnętrzna',0,'wewnętrzna','naścienny',4.00,5.00,'KETA-B / KETE-B Grafitowy','KETA-B / KETE-B Grafitowy','ASYG14KETA-B / ASYG14KETE-B','',3450.00,'grafitowy',NULL,NULL,NULL,NULL,NULL,0),(470,'2024-06-21 00:00:00.000000','Fujitsu','wewnętrzna',0,'wewnętrzna','naścienny',2.00,2.70,'KG','KG','ASYG07KGTB / ASYG07KGTE','',2150.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(471,'2024-06-22 00:00:00.000000','Fujitsu','wewnętrzna',0,'wewnętrzna','naścienny',2.50,3.30,'KG','KG','ASYG09KGTB / ASYG14KGTE','',2250.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(472,'2024-06-23 00:00:00.000000','Fujitsu','wewnętrzna',0,'wewnętrzna','naścienny',3.50,3.80,'KG','KG','ASYG12KGTB / ASYG12KGTE','',2350.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(473,'2024-06-24 00:00:00.000000','Fujitsu','wewnętrzna',0,'wewnętrzna','naścienny',4.00,5.00,'KG','KG','ASYG14KGTB / ASYG14KGTE','',3500.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(474,'2024-06-25 00:00:00.000000','Fujitsu','wewnętrzna',0,'wewnętrzna','naścienny',2.00,2.70,'KMCC / KMCE','KMCC / KMCE','ASYG07KMCC / ASYG07KMCE','',1550.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(475,'2024-06-26 00:00:00.000000','Fujitsu','wewnętrzna',0,'wewnętrzna','naścienny',2.50,3.30,'KMCC / KMCE','KMCC / KMCE','ASYG09KMCC / ASYG09KMCE','',1750.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(476,'2024-06-27 00:00:00.000000','Fujitsu','wewnętrzna',0,'wewnętrzna','naścienny',3.50,3.80,'KMCC / KMCE','KMCC / KMCE','ASYG12KMCC / ASYG12KMCE','',1950.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(477,'2024-06-28 00:00:00.000000','Fujitsu','wewnętrzna',0,'wewnętrzna','naścienny',4.00,5.00,'KMCC / KMCE','KMCC / KMCE','ASYG14KMCC / ASYG14KMCE','',2950.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(478,'2024-06-29 00:00:00.000000','Fujitsu','wewnętrzna',0,'wewnętrzna','naścienny',5.00,6.00,'KMTB / KMTE','KMTB / KMTE','ASYG18KMTB / ASYG18KMTE','',4300.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(479,'2024-06-30 00:00:00.000000','Fujitsu','wewnętrzna',0,'wewnętrzna','naścienny',6.00,7.00,'KMTB / KMTE','KMTB / KMTE','ASYG22KMTB / ASYG22KMTE','',4500.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(480,'2024-07-01 00:00:00.000000','Fujitsu','wewnętrzna',0,'wewnętrzna','naścienny',7.00,8.20,'KMTB / KMTE','KMTB / KMTE','ASYG24KMTB / ASYG24KMTE','',4600.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(481,'2024-07-02 00:00:00.000000','Fujitsu','wewnętrzna',0,'wewnętrzna','przysufitowy',5.00,6.00,'Przysufitowy','Przysufitowy','ABYG18KRTA','',4400.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(482,'2024-07-03 00:00:00.000000','Fujitsu','wewnętrzna',0,'wewnętrzna','przysufitowy',6.00,7.00,'Przysufitowy','Przysufitowy','ABYG22KRTA','',4800.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(483,'2024-07-04 00:00:00.000000','Fujitsu','wewnętrzna',0,'wewnętrzna','kaseton',2.00,2.70,'Kaseton','Kaseton','AUXG07KVLA','',4700.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(484,'2024-07-05 00:00:00.000000','Fujitsu','wewnętrzna',0,'wewnętrzna','kaseton',2.50,3.30,'Kaseton','Kaseton','AUXG09KVLA','',4900.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(485,'2024-07-06 00:00:00.000000','Fujitsu','wewnętrzna',0,'wewnętrzna','kaseton',3.50,3.80,'Kaseton','Kaseton','AUXG12KVLA','',5100.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(486,'2024-07-07 00:00:00.000000','Fujitsu','wewnętrzna',0,'wewnętrzna','kaseton',4.00,5.00,'Kaseton','Kaseton','AUXG14KVLA','',5550.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(487,'2024-07-08 00:00:00.000000','Fujitsu','wewnętrzna',0,'wewnętrzna','kaseton',5.00,6.00,'Kaseton','Kaseton','AUXG18KVLA','',5750.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(488,'2024-07-09 00:00:00.000000','Fujitsu','wewnętrzna',0,'wewnętrzna','kaseton',6.00,7.00,'Kaseton','Kaseton','AUXG22KVLA','',5850.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(489,'2024-07-10 00:00:00.000000','Fujitsu','wewnętrzna',0,'wewnętrzna','kanałowy',2.00,2.70,'Kanałowy Slim','Kanałowy Slim','ARXG07KLLAP','',3600.00,'',NULL,NULL,NULL,NULL,NULL,0),(490,'2024-07-11 00:00:00.000000','Fujitsu','wewnętrzna',0,'wewnętrzna','kanałowy',2.50,3.30,'Kanałowy Slim','Kanałowy Slim','ARXG09KLLAP','',3700.00,'',NULL,NULL,NULL,NULL,NULL,0),(491,'2024-07-12 00:00:00.000000','Fujitsu','wewnętrzna',0,'wewnętrzna','kanałowy',3.50,3.80,'Kanałowy Slim','Kanałowy Slim','ARXG12KLLAP','',3950.00,'',NULL,NULL,NULL,NULL,NULL,0),(492,'2024-07-13 00:00:00.000000','Fujitsu','wewnętrzna',0,'wewnętrzna','kanałowy',4.00,5.00,'Kanałowy Slim','Kanałowy Slim','ARXG14KLLAP','',4050.00,'',NULL,NULL,NULL,NULL,NULL,0),(493,'2024-07-14 00:00:00.000000','Fujitsu','wewnętrzna',0,'wewnętrzna','kanałowy',5.00,6.00,'Kanałowy Slim','Kanałowy Slim','ARXG18KLLAP','',4700.00,'',NULL,NULL,NULL,NULL,NULL,0),(494,'2024-07-15 00:00:00.000000','Fujitsu','wewnętrzna',0,'wewnętrzna','kanałowy',6.00,7.00,'Kanałowy','Kanałowy','ARXG22KMLB','',6200.00,'',NULL,NULL,NULL,NULL,NULL,0),(495,'2024-07-16 00:00:00.000000','Fujitsu','wewnętrzna',0,'wewnętrzna','kanałowy',2.00,2.70,'Kanałowy Zwarty','Kanałowy Zwarty','ARXG07KSLAP','',3950.00,'',NULL,NULL,NULL,NULL,NULL,0),(496,'2024-07-17 00:00:00.000000','Fujitsu','wewnętrzna',0,'wewnętrzna','kanałowy',2.50,3.30,'Kanałowy Zwarty','Kanałowy Zwarty','ARXG09KSLAP','',4050.00,'',NULL,NULL,NULL,NULL,NULL,0),(497,'2024-07-18 00:00:00.000000','Fujitsu','wewnętrzna',0,'wewnętrzna','kanałowy',3.50,3.80,'Kanałowy Zwarty','Kanałowy Zwarty','ARXG12KSLAP','',4250.00,'',NULL,NULL,NULL,NULL,NULL,0),(498,'2024-07-19 00:00:00.000000','Fujitsu','wewnętrzna',0,'wewnętrzna','kanałowy',4.00,5.00,'Kanałowy Zwarty','Kanałowy Zwarty','ARXG14KSLAP','',4500.00,'',NULL,NULL,NULL,NULL,NULL,0),(499,'2024-07-20 00:00:00.000000','Fujitsu','wewnętrzna',0,'wewnętrzna','kanałowy',5.00,6.00,'Kanałowy Zwarty','Kanałowy Zwarty','ARXG18KSLAP','',5100.00,'',NULL,NULL,NULL,NULL,NULL,0);
/*!40000 ALTER TABLE `klima_devicemultisplit` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `klima_devicesplit`
--

DROP TABLE IF EXISTS `klima_devicesplit`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `klima_devicesplit` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `data` datetime(6) DEFAULT NULL,
  `producent` varchar(255) DEFAULT NULL,
  `typ` varchar(255) DEFAULT NULL,
  `moc_chlodnicza` decimal(8,2) DEFAULT NULL,
  `moc_grzewcza` decimal(8,2) DEFAULT NULL,
  `nazwa_modelu` varchar(255) DEFAULT NULL,
  `nazwa_modelu_producenta` varchar(255) DEFAULT NULL,
  `nazwa_jedn_wew` varchar(255) DEFAULT NULL,
  `nazwa_jedn_zew` varchar(255) DEFAULT NULL,
  `cena_katalogowa_netto` decimal(8,2) DEFAULT NULL,
  `kolor` varchar(255) DEFAULT NULL,
  `glosnosc` decimal(8,2) DEFAULT NULL,
  `wielkosc_wew` decimal(8,2) DEFAULT NULL,
  `wielkosc_zew` decimal(8,2) DEFAULT NULL,
  `klasa_energetyczna_chlodzenie` varchar(255) DEFAULT NULL,
  `klasa_energetyczna_grzanie` varchar(255) DEFAULT NULL,
  `sterowanie_wifi` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=413 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `klima_devicesplit`
--

LOCK TABLES `klima_devicesplit` WRITE;
/*!40000 ALTER TABLE `klima_devicesplit` DISABLE KEYS */;
INSERT INTO `klima_devicesplit` VALUES (1,'2023-03-01 00:00:00.000000','AUX','naścienny',2.70,2.90,'Freedom Plus','AUX-09F2H','','',2490.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(2,'2023-03-01 00:00:00.000000','AUX','naścienny',3.50,3.80,'Freedom Plus','AUX-12F2H','','',2690.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(3,'2023-03-01 00:00:00.000000','AUX','naścienny',5.10,5.10,'Freedom Plus','AUX-18F2H','','',3790.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(4,'2023-03-01 00:00:00.000000','AUX','naścienny',6.70,7.20,'Freedom Plus','AUX-24F2H','','',4790.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(5,'2023-03-01 00:00:00.000000','AUX','naścienny',2.70,3.00,'Q-Smart','AUX-09QC','','',2690.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(6,'2023-03-01 00:00:00.000000','AUX','naścienny',3.50,3.80,'Q-Smart','AUX-12QC','','',2890.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(7,'2023-03-01 00:00:00.000000','AUX','naścienny',5.40,5.60,'Q-Smart','AUX-18QC','','',3990.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(8,'2023-03-01 00:00:00.000000','AUX','naścienny',6.70,6.70,'Q-Smart','AUX-24QC','','',4990.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(9,'2023-03-01 00:00:00.000000','AUX','naścienny',2.70,3.00,'Q-Smart Premium','AUX-09QP','','',3090.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(10,'2023-03-01 00:00:00.000000','AUX','naścienny',3.50,3.80,'Q-Smart Premium','AUX-09QP','','',3390.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(11,'2023-03-01 00:00:00.000000','AUX','naścienny',5.40,5.60,'Q-Smart Premium','AUX-09QP','','',4890.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(12,'2023-03-01 00:00:00.000000','AUX','naścienny',6.70,6.70,'Q-Smart Premium','AUX-09QP','','',5990.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(13,'2023-03-01 00:00:00.000000','AUX','naścienny',2.70,3.00,'Q-Smart Premium Grey','AUX-09QCB','','',3190.00,'szary',NULL,NULL,NULL,NULL,NULL,0),(14,'2023-03-01 00:00:00.000000','AUX','naścienny',3.50,3.80,'Q-Smart Premium Grey','AUX-09QCB','','',3690.00,'szary',NULL,NULL,NULL,NULL,NULL,0),(15,'2023-03-01 00:00:00.000000','AUX','naścienny',5.40,5.60,'Q-Smart Premium Grey','AUX-09QCB','','',4990.00,'szary',NULL,NULL,NULL,NULL,NULL,0),(16,'2023-03-01 00:00:00.000000','AUX','naścienny',6.70,7.20,'Q-Smart Premium Grey','AUX-09QCB','','',6390.00,'szary',NULL,NULL,NULL,NULL,NULL,0),(17,'2023-03-01 00:00:00.000000','AUX','naścienny',2.75,3.10,'Halo','AUX-09QHA','','',2990.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(18,'2023-03-01 00:00:00.000000','AUX','naścienny',3.60,3.80,'Halo','AUX-12HA','','',3390.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(19,'2023-03-01 00:00:00.000000','AUX','naścienny',5.50,5.90,'Halo','AUX-18HA','','',4590.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(20,'2023-03-01 00:00:00.000000','AUX','naścienny',7.30,7.30,'Halo','AUX-24HA','','',5690.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(21,'2023-03-01 00:00:00.000000','AUX','naścienny',2.75,3.10,'Halo Deluxe','AUX-09HE','','',2990.00,'czarny',NULL,NULL,NULL,NULL,NULL,0),(22,'2023-03-01 00:00:00.000000','AUX','naścienny',3.60,3.80,'Halo Deluxe','AUX-12HE','','',3390.00,'czarny',NULL,NULL,NULL,NULL,NULL,0),(23,'2023-03-01 00:00:00.000000','AUX','naścienny',5.50,5.90,'Halo Deluxe','AUX-18HE','','',5290.00,'czarny',NULL,NULL,NULL,NULL,NULL,0),(24,'2023-03-01 00:00:00.000000','AUX','naścienny',7.30,7.30,'Halo Deluxe','AUX-24HE','','',5690.00,'czarny',NULL,NULL,NULL,NULL,NULL,0),(25,'2023-03-01 00:00:00.000000','AUX','naścienny',2.70,3.00,'J-Smart','AUX-09QJ2O','','',3390.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(26,'2023-03-01 00:00:00.000000','AUX','naścienny',3.50,3.80,'J-Smart','AUX-12J2O','','',3690.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(27,'2023-03-01 00:00:00.000000','AUX','naścienny',5.30,5.60,'J-Smart','AUX-18J2O','','',5590.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(28,'2023-03-01 00:00:00.000000','AUX','naścienny',7.20,7.20,'J-Smart','AUX-24J2O','','',6290.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(29,'2023-03-01 00:00:00.000000','AUX','naścienny',2.70,3.00,'J-Smart Art','AUX-09JP','','',3690.00,'czarny',NULL,NULL,NULL,NULL,NULL,0),(30,'2023-03-01 00:00:00.000000','AUX','naścienny',3.50,3.80,'J-Smart Art','AUX-12JP','','',3890.00,'czarny',NULL,NULL,NULL,NULL,NULL,0),(31,'2023-03-01 00:00:00.000000','AUX','naścienny',5.30,5.60,'J-Smart Art','AUX-18JP','','',5590.00,'czarny',NULL,NULL,NULL,NULL,NULL,0),(32,'2023-03-01 00:00:00.000000','AUX','naścienny',7.20,7.20,'J-Smart Art','AUX-24JP','','',6390.00,'czarny',NULL,NULL,NULL,NULL,NULL,0),(33,'2023-03-01 00:00:00.000000','LG','naścienny',2.50,3.30,'ArtCool Gallery','A09FT','A09FT.NSF','A09FT.UL2',7170.00,'',NULL,NULL,NULL,NULL,NULL,0),(34,'2023-03-01 00:00:00.000000','LG','naścienny',3.50,4.00,'ArtCool Gallery','A12FT','A12FT.NSF','A12FT.UL2',8480.00,'',NULL,NULL,NULL,NULL,NULL,0),(35,'2023-03-01 00:00:00.000000','LG','naścienny',2.50,3.30,'ArtCool Beige','AB09BK','AB09BK.NSJ','AB09BK.UA3',5990.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(36,'2023-03-01 00:00:00.000000','LG','naścienny',3.50,4.00,'ArtCool Beige','AB12BK','AB12BK.NSJ','AB12BK.UA3',6400.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(37,'2023-03-01 00:00:00.000000','LG','naścienny',5.00,5.80,'ArtCool Beige','AB18BK','AB18BK.NSJ','AB18BK.UA3',7650.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(38,'2023-03-01 00:00:00.000000','LG','naścienny',6.60,7.50,'ArtCool Beige','AB24BK','AB24BK.NSJ','AB24BK.UA3',9080.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(39,'2023-03-01 00:00:00.000000','LG','naścienny',2.50,3.30,'ArtCool Mirror','AC09BK','AC09BK.NSJ','AC09BK.UA3',5710.00,'czarny',NULL,NULL,NULL,NULL,NULL,0),(40,'2023-03-01 00:00:00.000000','LG','naścienny',3.50,4.00,'ArtCool Mirror','AC12BK','AC12BK.NSJ','AC12BK.UA3',6100.00,'czarny',NULL,NULL,NULL,NULL,NULL,0),(41,'2023-03-01 00:00:00.000000','LG','naścienny',5.00,5.80,'ArtCool Mirror','AC18BK','AC18BK.NSJ','AC18BK.UA3',7280.00,'czarny',NULL,NULL,NULL,NULL,NULL,0),(42,'2023-03-01 00:00:00.000000','LG','naścienny',6.60,7.50,'ArtCool Mirror','AC24BK','AC24BK.NSJ','AC24BK.UA3',8640.00,'czarny',NULL,NULL,NULL,NULL,NULL,0),(43,'2023-03-01 00:00:00.000000','LG','naścienny',2.50,3.30,'DualCool','AP09RK','AP09RK.NSJ','AP09RK.UA3',4980.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(44,'2023-03-01 00:00:00.000000','LG','naścienny',3.50,4.00,'DualCool','AP12RK','AP12RK.NSJ','AP12RK.UA3',5390.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(45,'2023-03-01 00:00:00.000000','LG','naścienny',2.50,3.20,'Deluxe','DC09RK','DC09RK.NSJ','DC09RK.UL2',4720.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(46,'2023-03-01 00:00:00.000000','LG','naścienny',3.50,4.00,'Deluxe','DC12RK','DC12RK.NSJ','DC12RK.UL2',4910.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(47,'2023-03-01 00:00:00.000000','LG','naścienny',5.00,5.80,'Deluxe','DC18RK','DC18RK.NSJ','DC18RK.UL2',6380.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(48,'2023-03-01 00:00:00.000000','LG','naścienny',6.60,7.50,'Deluxe','DC24RK','DC24RK.NSJ','DC24RK.UL2',7760.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(49,'2023-03-01 00:00:00.000000','LG','naścienny',2.50,3.30,'Standard Plus','PC09SK','PC09SK.NSJ','PC09SK.UA3',3900.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(50,'2023-03-01 00:00:00.000000','LG','naścienny',3.50,4.00,'Standard Plus','PC12SK','PC12SK.NSJ','PC12SK.UA3',4080.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(51,'2023-03-01 00:00:00.000000','LG','naścienny',5.00,5.80,'Standard Plus','PC18SK','PC18SK.NSJ','PC18SK.UA3',5890.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(52,'2023-03-01 00:00:00.000000','LG','naścienny',6.60,7.50,'Standard Plus','PC24SK','PC24SK.NSJ','PC24SK.UA3',7210.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(53,'2023-03-01 00:00:00.000000','LG','naścienny',2.50,3.30,'Standard 2','S09ET','S09ET.NSJ','S09ET.UA3',3390.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(54,'2023-03-01 00:00:00.000000','LG','naścienny',3.50,4.00,'Standard 2','S12ET','S12ET.NSJ','S12ET.UA3',3580.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(55,'2023-03-01 00:00:00.000000','LG','naścienny',5.00,5.80,'Standard 2','S18ET','S18ET.NSJ','S18ET.UA3',5170.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(56,'2023-03-01 00:00:00.000000','LG','naścienny',6.60,7.50,'Standard 2','S24ET','S24ET.NSJ','S24ET.UA3',6220.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(57,'2023-03-01 00:00:00.000000','Gree','naścienny',2.70,3.50,'Amber Prestige','AP09','','',6190.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(58,'2023-03-01 00:00:00.000000','Gree','naścienny',3.53,4.20,'Amber Prestige','AP12','','',6690.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(59,'2023-03-01 00:00:00.000000','Gree','naścienny',5.30,5.57,'Amber Prestige','AP18','','',7590.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(60,'2023-03-01 00:00:00.000000','Gree','naścienny',7.03,7.03,'Amber Prestige','AP24','','',8290.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(61,'2023-03-01 00:00:00.000000','Gree','naścienny',2.70,3.20,'U-Crown Silver','UC09S','','',5990.00,'silver',NULL,NULL,NULL,NULL,NULL,0),(62,'2023-03-01 00:00:00.000000','Gree','naścienny',3.53,4.00,'U-Crown Silver','UC12S','','',6490.00,'silver',NULL,NULL,NULL,NULL,NULL,0),(63,'2023-03-01 00:00:00.000000','Gree','naścienny',5.30,5.30,'U-Crown Silver','UC18S','','',7390.00,'silver',NULL,NULL,NULL,NULL,NULL,0),(64,'2023-03-01 00:00:00.000000','Gree','naścienny',2.70,3.20,'U-Crown Champagne','UC09C','','',5990.00,'champagne',NULL,NULL,NULL,NULL,NULL,0),(65,'2023-03-01 00:00:00.000000','Gree','naścienny',3.53,4.00,'U-Crown Champagne','UC12C','','',6490.00,'champagne',NULL,NULL,NULL,NULL,NULL,0),(66,'2023-03-01 00:00:00.000000','Gree','naścienny',5.30,5.30,'U-Crown Champagne','UC18C','','',7390.00,'champagne',NULL,NULL,NULL,NULL,NULL,0),(67,'2023-03-01 00:00:00.000000','Gree','naścienny',2.70,3.00,'Lomo Luxury Plus','LLP09','','',3490.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(68,'2023-03-01 00:00:00.000000','Gree','naścienny',3.51,3.81,'Lomo Luxury Plus','LLP12','','',3790.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(69,'2023-03-01 00:00:00.000000','Gree','naścienny',5.20,5.60,'Lomo Luxury Plus','LLP18','','',5850.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(70,'2023-03-01 00:00:00.000000','Gree','naścienny',7.10,7.80,'Lomo Luxury Plus','LLP24','','',6650.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(71,'2023-03-01 00:00:00.000000','Gree','naścienny',2.70,3.00,'Fairy White','FA09W','','',3690.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(72,'2023-03-01 00:00:00.000000','Gree','naścienny',3.51,3.81,'Fairy White','FA12W','','',3990.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(73,'2023-03-01 00:00:00.000000','Gree','naścienny',5.30,5.60,'Fairy White','FA18W','','',5990.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(74,'2023-03-01 00:00:00.000000','Gree','naścienny',7.10,7.80,'Fairy White','FA24W','','',6790.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(75,'2023-03-01 00:00:00.000000','Gree','naścienny',2.70,3.00,'Fairy Silver','FA09S','','',3690.00,'silver',NULL,NULL,NULL,NULL,NULL,0),(76,'2023-03-01 00:00:00.000000','Gree','naścienny',3.51,3.81,'Fairy Silver','FA12S','','',3990.00,'silver',NULL,NULL,NULL,NULL,NULL,0),(77,'2023-03-01 00:00:00.000000','Gree','naścienny',5.30,5.60,'Fairy Silver','FA18S','','',5990.00,'silver',NULL,NULL,NULL,NULL,NULL,0),(78,'2023-03-01 00:00:00.000000','Gree','naścienny',7.10,7.80,'Fairy Silver','FA24W','','',6790.00,'silver',NULL,NULL,NULL,NULL,NULL,0),(79,'2023-03-01 00:00:00.000000','Gree','naścienny',2.70,3.00,'Fairy Dark','FA09D','','',3690.00,'czarny',NULL,NULL,NULL,NULL,NULL,0),(80,'2023-03-01 00:00:00.000000','Gree','naścienny',3.51,3.81,'Fairy Dark','FA12D','','',3990.00,'czarny',NULL,NULL,NULL,NULL,NULL,0),(81,'2023-03-01 00:00:00.000000','Gree','naścienny',5.30,5.60,'Fairy Dark','FA18D','','',5990.00,'czarny',NULL,NULL,NULL,NULL,NULL,0),(82,'2023-03-01 00:00:00.000000','Gree','naścienny',7.10,7.80,'Fairy Dark','FA24D','','',6790.00,'czarny',NULL,NULL,NULL,NULL,NULL,0),(83,'2023-03-01 00:00:00.000000','Gree','naścienny',2.70,2.93,'Amber Standard White','AS09W','','',4290.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(84,'2023-03-01 00:00:00.000000','Gree','naścienny',3.50,3.81,'Amber Standard White','AS12W','','',4490.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(85,'2023-03-01 00:00:00.000000','Gree','naścienny',5.30,5.57,'Amber Standard White','AS18W','','',6190.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(86,'2023-03-01 00:00:00.000000','Gree','naścienny',7.00,7.20,'Amber Standard White','AS24W','','',6890.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(87,'2023-03-01 00:00:00.000000','Gree','naścienny',2.70,2.93,'Amber Standard Silver','AS09S','','',4290.00,'silver',NULL,NULL,NULL,NULL,NULL,0),(88,'2023-03-01 00:00:00.000000','Gree','naścienny',3.50,3.81,'Amber Standard Silver','AS12S','','',4490.00,'silver',NULL,NULL,NULL,NULL,NULL,0),(89,'2023-03-01 00:00:00.000000','Gree','naścienny',5.30,5.57,'Amber Standard Silver','AS18S','','',6190.00,'silver',NULL,NULL,NULL,NULL,NULL,0),(90,'2023-03-01 00:00:00.000000','Gree','naścienny',7.00,7.20,'Amber Standard Silver','AS24S','','',6890.00,'silver',NULL,NULL,NULL,NULL,NULL,0),(91,'2023-03-01 00:00:00.000000','Gree','naścienny',2.70,2.93,'Amber Standard Full Black','AS09FB','','',4290.00,'czarny full',NULL,NULL,NULL,NULL,NULL,0),(92,'2023-03-01 00:00:00.000000','Gree','naścienny',3.50,3.81,'Amber Standard Full Black','AS12FB','','',4490.00,'czarny full',NULL,NULL,NULL,NULL,NULL,0),(93,'2023-03-01 00:00:00.000000','Gree','naścienny',5.30,5.57,'Amber Standard Full Black','AS18FB','','',6190.00,'czarny full',NULL,NULL,NULL,NULL,NULL,0),(94,'2023-03-01 00:00:00.000000','Gree','naścienny',7.00,7.20,'Amber Standard Full Black','AS24FB','','',6890.00,'czarny full',NULL,NULL,NULL,NULL,NULL,0),(95,'2023-03-01 00:00:00.000000','Gree','naścienny',2.70,2.93,'Amber Standard Black','AS09B','','',3190.00,'czarny',NULL,NULL,NULL,NULL,NULL,0),(96,'2023-03-01 00:00:00.000000','Gree','naścienny',3.50,3.81,'Amber Standard Black','AS12B','','',3490.00,'czarny',NULL,NULL,NULL,NULL,NULL,0),(97,'2023-03-01 00:00:00.000000','Gree','naścienny',5.30,5.57,'Amber Standard Black','AS18B','','',4690.00,'czarny',NULL,NULL,NULL,NULL,NULL,0),(98,'2023-03-01 00:00:00.000000','Gree','naścienny',7.00,7.20,'Amber Standard Black','AS24B','','',5390.00,'czarny',NULL,NULL,NULL,NULL,NULL,0),(99,'2023-03-01 00:00:00.000000','Gree','naścienny',2.70,3.60,'Soyal','SO09','','',5990.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(100,'2023-03-01 00:00:00.000000','Gree','naścienny',3.53,4.20,'Soyal','SO12','','',6490.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(101,'2023-03-01 00:00:00.000000','Gree','naścienny',5.30,5.60,'Soyal','SO18','','',7390.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(102,'2023-03-01 00:00:00.000000','Gree','naścienny',2.70,3.20,'G-Tech Silver','GT09S','','',4350.00,'silver',NULL,NULL,NULL,NULL,NULL,0),(103,'2023-03-01 00:00:00.000000','Gree','naścienny',3.50,3.81,'G-Tech Silver','GT12S','','',4750.00,'silver',NULL,NULL,NULL,NULL,NULL,0),(104,'2023-03-01 00:00:00.000000','Gree','naścienny',2.70,3.20,'G-Tech Rose Gold','GT09R','','',4350.00,'złoty',NULL,NULL,NULL,NULL,NULL,0),(105,'2023-03-01 00:00:00.000000','Gree','naścienny',3.50,3.81,'G-Tech Rose Gold','GT12R','','',4750.00,'złoty',NULL,NULL,NULL,NULL,NULL,0),(106,'2023-03-01 00:00:00.000000','Gree','konsola',2.70,2.90,'Konsola','CO09','','',4990.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(107,'2023-03-01 00:00:00.000000','Gree','konsola',3.52,3.80,'Konsola','CO12','','',5390.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(108,'2023-03-01 00:00:00.000000','Gree','konsola',5.20,5.33,'Konsola','CO18','','',6990.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(109,'2023-03-01 00:00:00.000000','Gree','naścienny',2.50,2.80,'Pular','PU09','','',2600.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(110,'2023-03-01 00:00:00.000000','Gree','naścienny',3.20,3.40,'Pular','PU12','','',2750.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(111,'2023-03-01 00:00:00.000000','Gree','naścienny',4.60,5.20,'Pular','PU18','','',4200.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(112,'2023-03-01 00:00:00.000000','Gree','naścienny',6.20,6.50,'Pular','PU24','','',5350.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(113,'2023-03-01 00:00:00.000000','Ande','naścienny',2.60,2.60,'Basic+','AND-09/FA+','AND-09/FA+','',2400.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(114,'2023-03-01 00:00:00.000000','Ande','naścienny',3.50,3.50,'Basic+','AND-12/FA+','AND-12/FA+','',2600.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(115,'2023-03-01 00:00:00.000000','Ande','naścienny',5.10,5.10,'Basic+','AND-18/FA+','AND-18/FA+','',3790.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(116,'2023-03-01 00:00:00.000000','Ande','naścienny',6.70,6.70,'Basic+','AND-24/FA+','AND-24/FA+','',4790.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(117,'2023-03-01 00:00:00.000000','Ande','naścienny',2.60,2.60,'Jupiter+ UV','AND-09/JA+','AND-09/JA+','',3150.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(118,'2023-03-01 00:00:00.000000','Ande','naścienny',3.50,3.50,'Jupiter+ UV','AND-12/JA+','AND-12/JA+','',3350.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(119,'2023-03-01 00:00:00.000000','Ande','naścienny',5.30,5.30,'Jupiter+ UV','AND-18/JA+','AND-18/JA+','',5090.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(120,'2023-03-01 00:00:00.000000','Ande','naścienny',6.70,6.70,'Jupiter+ UV','AND-24/JA+','AND-24/JA+','',6090.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(121,'2023-03-01 00:00:00.000000','Ande','naścienny',3.50,3.50,'Hero+','AND-12/HG+','AND-12/HG+','',3190.00,'szary',NULL,NULL,NULL,NULL,NULL,0),(122,'2023-03-01 00:00:00.000000','Ande','naścienny',5.30,5.30,'Hero+','AND-18/HG+','AND-18/HG+','',4490.00,'szary',NULL,NULL,NULL,NULL,NULL,0),(123,'2023-03-01 00:00:00.000000','Rotenso','naścienny',2.60,2.60,'Roni','Roni 2,6','R26Xi','R26Xo',2399.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(124,'2023-03-01 00:00:00.000000','Rotenso','naścienny',3.40,3.40,'Roni','Roni 3,3','R35Xi','R35Xo',2499.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(125,'2023-03-01 00:00:00.000000','Rotenso','naścienny',5.10,5.10,'Roni','Roni 5,1','R50Xi','R50Xo',3999.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(126,'2023-03-01 00:00:00.000000','Rotenso','naścienny',6.80,6.90,'Roni','Roni 6,8','R70Xi','R70Xo',5199.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(127,'2023-03-01 00:00:00.000000','Rotenso','naścienny',2.60,2.90,'Ukura','Ukura 2,6','U26Xi','U26Xo',2649.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(128,'2023-03-01 00:00:00.000000','Rotenso','naścienny',3.50,3.80,'Ukura','Ukura 3,5','U35Xi','U35Xo',2769.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(129,'2023-03-01 00:00:00.000000','Rotenso','naścienny',5.30,5.60,'Ukura','Ukura 5,3','U50Xi','U50Xo',4349.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(130,'2023-03-01 00:00:00.000000','Rotenso','naścienny',7.00,7.30,'Ukura','Ukura 7,0','U70Xi','U70Xo',5699.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(131,'2023-03-01 00:00:00.000000','Rotenso','naścienny',2.60,2.90,'Imoto','Imoto 2,6','I26Xi','I26Xo',3699.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(132,'2023-03-01 00:00:00.000000','Rotenso','naścienny',3.50,3.80,'Imoto','Imoto 3,5','I35Xi','I35Xo',3899.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(133,'2023-03-01 00:00:00.000000','Rotenso','naścienny',5.30,5.60,'Imoto','Imoto 5,3','I50Xi','I50Xo',5799.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(134,'2023-03-01 00:00:00.000000','Rotenso','naścienny',7.30,7.50,'Imoto','Imoto 7,3','I70Xi','I70Xo',6999.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(135,'2023-03-01 00:00:00.000000','Rotenso','naścienny',2.60,2.80,'Elis','Elis 2,6','E26Xi','E26Xo',2849.00,'czarny',NULL,NULL,NULL,NULL,NULL,0),(136,'2023-03-01 00:00:00.000000','Rotenso','naścienny',3.30,3.40,'Elis','Elis 3,3','E35Xi','E35Xo',2949.00,'czarny',NULL,NULL,NULL,NULL,NULL,0),(137,'2023-03-01 00:00:00.000000','Rotenso','naścienny',5.10,5.20,'Elis','Elis 5,1','E50Xi','E50Xo',4599.00,'czarny',NULL,NULL,NULL,NULL,NULL,0),(138,'2023-03-01 00:00:00.000000','Rotenso','naścienny',3.40,3.40,'Elis Silver','Elis Silver 3,4','ES35Xi','ES35Xo',2949.00,'silver',NULL,NULL,NULL,NULL,NULL,0),(139,'2023-03-01 00:00:00.000000','Rotenso','naścienny',3.50,3.80,'Teta','Teta 3,5','TA35Xi','TA35Xo',3849.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(140,'2023-03-01 00:00:00.000000','Rotenso','naścienny',5.30,5.60,'Teta','Teta 5,3','TA50Xi','TA50Xo',5599.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(141,'2023-03-01 00:00:00.000000','Rotenso','naścienny',2.70,3.10,'Revio','Revio 2,7','RO26Xi','RO26Xo',4399.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(142,'2023-03-01 00:00:00.000000','Rotenso','naścienny',3.50,4.30,'Revio','Revio 3,5','RO35Xi','RO35Xo',4499.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(143,'2023-03-01 00:00:00.000000','Rotenso','naścienny',5.30,5.60,'Revio','Revio 5,3','RO50Xi','RO50Xo',6949.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(144,'2023-03-01 00:00:00.000000','Rotenso','naścienny',7.30,7.60,'Revio','Revio 7,3','RO70Xi','RO70Xo',8499.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(145,'2023-03-01 00:00:00.000000','Rotenso','naścienny',3.50,3.90,'Luve','Luve 3,5','LE35Xi','LE35Xo',4499.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(146,'2023-03-01 00:00:00.000000','Rotenso','naścienny',2.60,2.90,'Versu Gold','Versu Gold 2,6','VG26Xi','VO26Xo',4799.00,'gold',NULL,NULL,NULL,NULL,NULL,0),(147,'2023-03-01 00:00:00.000000','Rotenso','naścienny',3.50,3.80,'Versu Gold','Versu Gold 3,5','VG35Xi','VO35Xo',4949.00,'gold',NULL,NULL,NULL,NULL,NULL,0),(148,'2023-03-01 00:00:00.000000','Rotenso','naścienny',2.60,2.90,'Versu Silver','Versu Silver 2,6','VS26Xi','VO26Xo',4799.00,'silver',NULL,NULL,NULL,NULL,NULL,0),(149,'2023-03-01 00:00:00.000000','Rotenso','naścienny',3.50,3.80,'Versu Silver','Versu Silver 3,5','VS35Xi','VO35Xo',4949.00,'silver',NULL,NULL,NULL,NULL,NULL,0),(150,'2023-03-01 00:00:00.000000','Rotenso','naścienny',2.60,2.90,'Versu Mirror','Versu Mirror 2,6','VM26Xi','VO26Xo',4799.00,'czarny',NULL,NULL,NULL,NULL,NULL,0),(151,'2023-03-01 00:00:00.000000','Rotenso','naścienny',3.50,3.80,'Versu Mirror','Versu Mirror 3,5','VM35Xi','VO35Xo',4949.00,'czarny',NULL,NULL,NULL,NULL,NULL,0),(152,'2023-03-01 00:00:00.000000','Rotenso','naścienny',2.60,2.70,'Versu Pure','Versu Pure 2,6','VP26Xi','VO26Xo',4799.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(153,'2023-03-01 00:00:00.000000','Rotenso','naścienny',3.50,4.10,'Versu Pure','Versu Pure 3,5','VP35Xi','VO35Xo',4949.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(154,'2023-03-01 00:00:00.000000','Rotenso','naścienny',2.60,2.70,'Versu Cloth Stone','Versu Cloth Stone 2,6','VCS26Xi','VO26Xo R15',4799.00,'stone',NULL,NULL,NULL,NULL,NULL,0),(155,'2023-03-01 00:00:00.000000','Rotenso','naścienny',3.50,4.10,'Versu Cloth Stone','Versu Cloth Stone 3,5','VCS35Xi','VO35Xo R15',4949.00,'stone',NULL,NULL,NULL,NULL,NULL,0),(156,'2023-03-01 00:00:00.000000','Rotenso','naścienny',2.60,2.70,'Versu Cloth Caramel','Versu Cloth Caramel 2,6','VCC26Xi','VO26Xo R15',4799.00,'caramel',NULL,NULL,NULL,NULL,NULL,0),(157,'2023-03-01 00:00:00.000000','Rotenso','naścienny',3.50,4.10,'Versu Cloth Caramel','Versu Cloth Caramel 3,5','VCC35Xi','VO35Xo R15',4949.00,'caramel',NULL,NULL,NULL,NULL,NULL,0),(158,'2023-03-01 00:00:00.000000','Rotenso','naścienny',3.50,3.90,'Fresh','Fresh 3,5','FH35Xi','FH35Xo',5999.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(159,'2023-03-01 00:00:00.000000','Rotenso','naścienny',3.50,3.90,'Mirai','Mirai 3,5','M35Xi','M35Xo',7399.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(160,'2023-03-01 00:00:00.000000','Samsung','naścienny',2.60,2.90,'AR35','AR35','AR09TXHQASINEU','AR09TXHQASIXEU',2948.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(161,'2023-03-01 00:00:00.000000','Samsung','naścienny',3.50,3.80,'AR35','AR35','AR12TXHQASINEU','AR12TXHQASIXEU',3268.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(162,'2023-03-01 00:00:00.000000','Samsung','naścienny',5.30,5.30,'AR35','AR35','AR18TXHQASINEU','AR18TXHQASIXEU',5688.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(163,'2023-03-01 00:00:00.000000','Samsung','naścienny',7.00,7.30,'AR35','AR35','AR24TXHQASINEU','AR24TXHQASIXEU',6838.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(164,'2023-03-01 00:00:00.000000','Samsung','naścienny',2.50,3.20,'Cebu','Cebu','AR09TXFYAWKNEU','AR09TXFYAWKXEU',3998.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(165,'2023-03-01 00:00:00.000000','Samsung','naścienny',3.50,3.50,'Cebu','Cebu','AR12TXFYAWKNEU','AR12TXFYAWKXEU',4468.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(166,'2023-03-01 00:00:00.000000','Samsung','naścienny',5.00,6.00,'Cebu','Cebu','AR18TXFYAWKNEU','AR18TXFYAWKXEU',6858.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(167,'2023-03-01 00:00:00.000000','Samsung','naścienny',6.50,7.40,'Cebu','Cebu','AR24TXFYAWKNEU','AR24TXFYAWKXEU',9048.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(168,'2023-03-01 00:00:00.000000','Samsung','naścienny',2.50,3.20,'WindFree Comfort','WindFree Comfort','AR09TXFCAWKNEU','AR09TXFCAWKXEU',4968.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(169,'2023-03-01 00:00:00.000000','Samsung','naścienny',3.50,3.50,'WindFree Comfort','WindFree Comfort','AR12TXFCAWKNEU','AR12TXFCAWKXEU',5508.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(170,'2023-03-01 00:00:00.000000','Samsung','naścienny',5.00,6.00,'WindFree Comfort','WindFree Comfort','AR18TXFCAWKNEU','AR18TXFCAWKXEU',8468.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(171,'2023-03-01 00:00:00.000000','Samsung','naścienny',6.50,7.40,'WindFree Comfort','WindFree Comfort','AR24TXFCAWKNEU','AR24TXFCAWKXEU',11198.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(172,'2023-03-01 00:00:00.000000','Samsung','naścienny',2.50,3.20,'WindFree AVANT','WindFree AVANT','AR09TXEAAWKNEU','AR09TXEAAWKXEU',5978.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(173,'2023-03-01 00:00:00.000000','Samsung','naścienny',3.50,4.00,'WindFree AVANT','WindFree AVANT','AR12TXEAAWKNEU','AR12TXEAAWKXEU',6618.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(174,'2023-03-01 00:00:00.000000','Samsung','naścienny',5.00,6.00,'WindFree AVANT','WindFree AVANT','AR18TXEAAWKNEU','AR18TXEAAWKXEU',10218.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(175,'2023-03-01 00:00:00.000000','Samsung','naścienny',6.50,7.40,'WindFree AVANT','WindFree AVANT','AR24TXEAAWKNEU','AR24TXEAAWKXEU',13478.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(176,'2023-03-01 00:00:00.000000','Samsung','naścienny',2.50,3.20,'WindFree Elite','WindFree Elite','AR09TXCAAWKNEU','AR09TXCAAWKXEU',6568.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(177,'2023-03-01 00:00:00.000000','Samsung','naścienny',3.50,4.00,'WindFree Elite','WindFree Elite','AR12TXCAAWKNEU','AR12TXCAAWKXEU',7288.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(178,'2023-03-01 00:00:00.000000','Fuji','naścienny',2.00,2.50,'Keta White','KETA White','RSG07KETA','ROG07KETA ',4100.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(179,'2023-03-01 00:00:00.000000','Fuji','naścienny',2.50,2.80,'Keta White','KETA White','RSG09KETA','ROG09KETA ',4750.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(180,'2023-03-01 00:00:00.000000','Fuji','naścienny',3.40,4.00,'Keta White','KETA White','RSG12KETA','ROG12KETA ',5100.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(181,'2023-03-01 00:00:00.000000','Fuji','naścienny',4.20,5.40,'Keta White','KETA White','RSG14KETA','ROG14KETA',7000.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(182,'2023-03-01 00:00:00.000000','Fuji','naścienny',2.00,2.50,'Keta Graphite','KETA Graphite','RSG07KETAB','ROG07KETA ',4100.00,'grafitowy',NULL,NULL,NULL,NULL,NULL,0),(183,'2023-03-01 00:00:00.000000','Fuji','naścienny',2.50,2.80,'Keta Graphite','KETA Graphite','RSG09KETAB','ROG09KETA ',4750.00,'grafitowy',NULL,NULL,NULL,NULL,NULL,0),(184,'2023-03-01 00:00:00.000000','Fuji','naścienny',3.40,4.00,'Keta Graphite','KETA Graphite','RSG12KETAB','ROG12KETA ',5100.00,'grafitowy',NULL,NULL,NULL,NULL,NULL,0),(185,'2023-03-01 00:00:00.000000','Fuji','naścienny',4.20,5.40,'Keta Graphite','KETA Graphite','RSG14KETAB','ROG14KETA',7000.00,'grafitowy',NULL,NULL,NULL,NULL,NULL,0),(186,'2023-03-01 00:00:00.000000','Fuji','naścienny',2.00,2.50,'KGTB','KGTB','RSG07KGTB','ROG07KGCA ',4500.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(187,'2023-03-01 00:00:00.000000','Fuji','naścienny',2.50,2.80,'KGTB','KGTB','RSG09KGTB','ROG09KGCA ',5150.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(188,'2023-03-01 00:00:00.000000','Fuji','naścienny',3.40,4.00,'KGTB','KGTB','RSG12KGTB','ROG12KGCA ',5550.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(189,'2023-03-01 00:00:00.000000','Fuji','naścienny',4.20,5.40,'KGTB','KGTB','RSG14KGTB','ROG14KGCA',7400.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(190,'2023-03-01 00:00:00.000000','Fuji','naścienny',2.00,2.50,'KMCC','KMCC','RSG07KMCC','ROG07KMCC ',3600.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(191,'2023-03-01 00:00:00.000000','Fuji','naścienny',2.50,2.80,'KMCC','KMCC','RSG09KMCC','RSG09KMCC ',3900.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(192,'2023-03-01 00:00:00.000000','Fuji','naścienny',3.40,4.00,'KMCC','KMCC','RSG12KMCC','ROG12KMCC ',4500.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(193,'2023-03-01 00:00:00.000000','Fuji','naścienny',4.20,5.40,'KMCC','KMCC','RSG14KMCC','ROG14KMCC',6500.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(194,'2023-03-01 00:00:00.000000','Fuji','naścienny',2.50,3.20,'KMCDN Nordic','KMCDN Nordic','RSG09KMCDN','ROG09KMCDN ',5200.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(195,'2023-03-01 00:00:00.000000','Fuji','naścienny',3.40,4.00,'KMCDN Nordic','KMCDN Nordic','RSG12KMCDN','ROG12KMCDN ',6000.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(196,'2023-03-01 00:00:00.000000','Fuji','naścienny',4.20,5.40,'KMCDN Nordic','KMCDN Nordic','RSG14KMCDN','ROG14KMCDN',8400.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(197,'2023-03-01 00:00:00.000000','Fuji','naścienny',5.20,6.30,'KMTB','KMTB','RSG18KMTB','ROG18KMTA ',7500.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(198,'2023-03-01 00:00:00.000000','Fuji','naścienny',7.10,8.00,'KMTB','KMTB','RSG24KMTB','ROG24KMTA',10100.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(199,'2023-03-01 00:00:00.000000','Fuji','naścienny',8.00,8.80,'KMTA','KMTA','RSG30KMTA','ROG30KMTA ',14200.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(200,'2023-03-01 00:00:00.000000','Fuji','naścienny',9.40,10.10,'KMTA','KMTA','RSG36KMTA','ROG36KMTA',15400.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(201,'2023-03-01 00:00:00.000000','Fuji','naścienny',2.00,2.50,'KPCA','KPCA','RSG07KPCA','ROG07KPCA ',3400.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(202,'2023-03-01 00:00:00.000000','Fuji','naścienny',2.50,2.80,'KPCA','KPCA','RSG09KPCA','ROG09KPCA ',3550.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(203,'2023-03-01 00:00:00.000000','Fuji','naścienny',3.40,3.80,'KPCA','KPCA','RSG12KPCA','ROG12KPCA',4000.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(204,'2023-03-01 00:00:00.000000','Fuji','naścienny',5.20,6.30,'KLCA','KLCA','RSG18KLCA','ROG18KLCA ',6600.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(205,'2023-03-01 00:00:00.000000','Fuji','naścienny',7.10,8.00,'KLCA','KLCA','RSG24KLCA','ROG24KLCA',9000.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(206,'2023-03-01 00:00:00.000000','Daikin','naścienny',2.00,2.50,'Stylish AW Biały','Stylish AW Biały','FTXA-20AW','RXA-20A9',7600.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(207,'2023-03-01 00:00:00.000000','Daikin','naścienny',2.50,2.80,'Stylish AW Biały','Stylish AW Biały','FTXA-25AW','RXA-25A9',8120.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(208,'2023-03-01 00:00:00.000000','Daikin','naścienny',3.40,4.00,'Stylish AW Biały','Stylish AW Biały','FTXA-35AW','RXA-35A9',8510.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(209,'2023-03-01 00:00:00.000000','Daikin','naścienny',4.20,5.40,'Stylish AW Biały','Stylish AW Biały','FTXA-42AW','RXA-42A9',12990.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(210,'2023-03-01 00:00:00.000000','Daikin','naścienny',5.00,5.80,'Stylish AW Biały','Stylish AW Biały','FTXA-50AW','RXA-50A9',14260.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(211,'2023-03-01 00:00:00.000000','Daikin','naścienny',2.00,2.50,'Stylish BS Srebrny','Stylish BS Srebrny','FTXA-20BS','RXA-20A9',7900.00,'srebrny',NULL,NULL,NULL,NULL,NULL,0),(212,'2023-03-01 00:00:00.000000','Daikin','naścienny',2.50,2.80,'Stylish BS Srebrny','Stylish BS Srebrny','FTXA-25BS','RXA-25A9',8410.00,'srebrny',NULL,NULL,NULL,NULL,NULL,0),(213,'2023-03-01 00:00:00.000000','Daikin','naścienny',3.40,4.00,'Stylish BS Srebrny','Stylish BS Srebrny','FTXA-35BS','RXA-35A9',8850.00,'srebrny',NULL,NULL,NULL,NULL,NULL,0),(214,'2023-03-01 00:00:00.000000','Daikin','naścienny',4.20,5.40,'Stylish BS Srebrny','Stylish BS Srebrny','FTXA-42BS','RXA-42A9',13190.00,'srebrny',NULL,NULL,NULL,NULL,NULL,0),(215,'2023-03-01 00:00:00.000000','Daikin','naścienny',5.00,5.80,'Stylish BS Srebrny','Stylish BS Srebrny','FTXA-50BS','RXA-50A9',14530.00,'srebrny',NULL,NULL,NULL,NULL,NULL,0),(216,'2023-03-01 00:00:00.000000','Daikin','naścienny',2.00,2.50,'Stylish BT Czarne Drewno','Stylish BT Czarne Drewno','FTXA-20BT','RXA-20A9',7900.00,'czarne drewno',NULL,NULL,NULL,NULL,NULL,0),(217,'2023-03-01 00:00:00.000000','Daikin','naścienny',2.50,2.80,'Stylish BT Czarne Drewno','Stylish BT Czarne Drewno','FTXA-25BT','RXA-25A9',8230.00,'czarne drewno',NULL,NULL,NULL,NULL,NULL,0),(218,'2023-03-01 00:00:00.000000','Daikin','naścienny',3.40,4.00,'Stylish BT Czarne Drewno','Stylish BT Czarne Drewno','FTXA-35BT','RXA-35A9',8920.00,'czarne drewno',NULL,NULL,NULL,NULL,NULL,0),(219,'2023-03-01 00:00:00.000000','Daikin','naścienny',4.20,5.40,'Stylish BT Czarne Drewno','Stylish BT Czarne Drewno','FTXA-42BT','RXA-42A9',13610.00,'czarne drewno',NULL,NULL,NULL,NULL,NULL,0),(220,'2023-03-01 00:00:00.000000','Daikin','naścienny',5.00,5.80,'Stylish BT Czarne Drewno','Stylish BT Czarne Drewno','FTXA-50BT','RXA-50A9',14950.00,'czarne drewno',NULL,NULL,NULL,NULL,NULL,0),(221,'2023-03-01 00:00:00.000000','Daikin','naścienny',2.00,2.50,'Stylish BB Czarny','Stylish BB Czarny','FTXA-20BB','RXA-20A9',7750.00,'czarny',NULL,NULL,NULL,NULL,NULL,0),(222,'2023-03-01 00:00:00.000000','Daikin','naścienny',2.50,2.80,'Stylish BB Czarny','Stylish BB Czarny','FTXA-25BB','RXA-25A9',8270.00,'czarny',NULL,NULL,NULL,NULL,NULL,0),(223,'2023-03-01 00:00:00.000000','Daikin','naścienny',3.40,4.00,'Stylish BB Czarny','Stylish BB Czarny','FTXA-35BB','RXA-35A9',8490.00,'czarny',NULL,NULL,NULL,NULL,NULL,0),(224,'2023-03-01 00:00:00.000000','Daikin','naścienny',4.20,5.40,'Stylish BB Czarny','Stylish BB Czarny','FTXA-42BB','RXA-42A9',12970.00,'czarny',NULL,NULL,NULL,NULL,NULL,0),(225,'2023-03-01 00:00:00.000000','Daikin','naścienny',5.00,5.80,'Stylish BB Czarny','Stylish BB Czarny','FTXA-50BB','RXA-50A9',14260.00,'czarny',NULL,NULL,NULL,NULL,NULL,0),(226,'2023-03-01 00:00:00.000000','Daikin','naścienny',2.50,3.60,'Ururu Sarara','Ururu Sarara','FTXZ-25N','RXZ-25N',9820.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(227,'2023-03-01 00:00:00.000000','Daikin','naścienny',3.50,5.00,'Ururu Sarara','Ururu Sarara','FTXZ-35N','RXZ-35N',12650.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(228,'2023-03-01 00:00:00.000000','Daikin','naścienny',5.00,6.30,'Ururu Sarara','Ururu Sarara','FTXZ-50N','RXZ-50N',13650.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(229,'2023-03-01 00:00:00.000000','Daikin','naścienny',2.00,2.50,'Emura AW Biały','Emura AW Biały','FTXJ-20AW','RXJ-20A',8150.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(230,'2023-03-01 00:00:00.000000','Daikin','naścienny',2.50,2.80,'Emura AW Biały','Emura AW Biały','FTXJ-25AW','RXJ-25A',8580.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(231,'2023-03-01 00:00:00.000000','Daikin','naścienny',3.40,4.00,'Emura AW Biały','Emura AW Biały','FTXJ-35AW','RXJ-35A',10140.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(232,'2023-03-01 00:00:00.000000','Daikin','naścienny',5.00,5.80,'Emura AW Biały','Emura AW Biały','FTXJ-50AW','RXJ-50A',15660.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(233,'2023-03-01 00:00:00.000000','Daikin','naścienny',2.00,2.50,'Emura As Srebrny','Emura As Srebrny','FTXJ-20AS','RXJ-20A',8480.00,'srebrny',NULL,NULL,NULL,NULL,NULL,0),(234,'2023-03-01 00:00:00.000000','Daikin','naścienny',2.50,2.80,'Emura As Srebrny','Emura As Srebrny','FTXJ-25AS','RXJ-25A',8930.00,'srebrny',NULL,NULL,NULL,NULL,NULL,0),(235,'2023-03-01 00:00:00.000000','Daikin','naścienny',3.40,4.00,'Emura As Srebrny','Emura As Srebrny','FTXJ-35AS','RXJ-35A',10540.00,'srebrny',NULL,NULL,NULL,NULL,NULL,0),(236,'2023-03-01 00:00:00.000000','Daikin','naścienny',5.00,5.80,'Emura As Srebrny','Emura As Srebrny','FTXJ-50AS','RXJ-50A',15980.00,'srebrny',NULL,NULL,NULL,NULL,NULL,0),(237,'2023-03-01 00:00:00.000000','Daikin','naścienny',2.00,2.50,'Emura AB Czarny','Emura AB Czarny','FTXJ-20AB','RXJ-20A',8110.00,'czarny',NULL,NULL,NULL,NULL,NULL,0),(238,'2023-03-01 00:00:00.000000','Daikin','naścienny',2.50,2.80,'Emura AB Czarny','Emura AB Czarny','FTXJ-25AB','RXJ-25A',8410.00,'czarny',NULL,NULL,NULL,NULL,NULL,0),(239,'2023-03-01 00:00:00.000000','Daikin','naścienny',3.40,4.00,'Emura AB Czarny','Emura AB Czarny','FTXJ-35AB','RXJ-35A',10120.00,'czarny',NULL,NULL,NULL,NULL,NULL,0),(240,'2023-03-01 00:00:00.000000','Daikin','naścienny',5.00,5.80,'Emura AB Czarny','Emura AB Czarny','FTXJ-50AB','RXJ-50A',15650.00,'czarny',NULL,NULL,NULL,NULL,NULL,0),(241,'2023-03-01 00:00:00.000000','Daikin','naścienny',2.00,2.50,'Perfera','Perfera','FTXM-20R','RXM-20R9',6150.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(242,'2023-03-01 00:00:00.000000','Daikin','naścienny',2.50,2.80,'Perfera','Perfera','FTXM-25R','RXM-25R9',6380.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(243,'2023-03-01 00:00:00.000000','Daikin','naścienny',3.40,4.00,'Perfera','Perfera','FTXM-35R','RXM-35R9',8160.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(244,'2023-03-01 00:00:00.000000','Daikin','naścienny',4.20,5.40,'Perfera','Perfera','FTXM-42R','RXM-42R9',8880.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(245,'2023-03-01 00:00:00.000000','Daikin','naścienny',5.00,5.80,'Perfera','Perfera','FTXM-50R','RXM-50R9',9750.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(246,'2023-03-01 00:00:00.000000','Daikin','naścienny',6.00,7.00,'Perfera','Perfera','FTXM-60R','RXM-60R9',12100.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(247,'2023-03-01 00:00:00.000000','Daikin','naścienny',7.10,8.20,'Perfera','Perfera','FTXM-71R','RXM-71R9',14930.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(248,'2023-03-01 00:00:00.000000','Daikin','przypodłogowy',2.50,2.80,'Perfera','Perfera','FVXM-25A','RXM-25R9',6720.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(249,'2023-03-01 00:00:00.000000','Daikin','przypodłogowy',3.40,4.00,'Perfera','Perfera','FVXM-35A','RXM-35R9',8090.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(250,'2023-03-01 00:00:00.000000','Daikin','przypodłogowy',5.00,5.80,'Perfera','Perfera','FVXM-50A','RXM-50R9',9680.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(251,'2023-03-01 00:00:00.000000','Daikin','przypodłogowy',2.50,3.40,'FVXM','FVXM','FVXM-25F','RXM-25R9',7660.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(252,'2023-03-01 00:00:00.000000','Daikin','przypodłogowy',3.50,4.50,'FVXM','FVXM','FVXM-35F','RXM-35R9',8950.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(253,'2023-03-01 00:00:00.000000','Daikin','przypodłogowy',5.00,5.80,'FVXM','FVXM','FVXM-50F','RXM-50R9',9810.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(254,'2023-03-01 00:00:00.000000','Daikin','naścienny',2.00,2.50,'Comfora','Comfora','FTXP-20M9','RXP-20R9',3940.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(255,'2023-03-01 00:00:00.000000','Daikin','naścienny',2.50,3.00,'Comfora','Comfora','FTXP-25M9','RXP-25R9',4220.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(256,'2023-03-01 00:00:00.000000','Daikin','naścienny',3.50,4.00,'Comfora','Comfora','FTXP-35M9','RXP-35R9',4960.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(257,'2023-03-01 00:00:00.000000','Daikin','naścienny',5.00,6.00,'Comfora','Comfora','FTXP-50M9','RXP-50R9',7340.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(258,'2023-03-01 00:00:00.000000','Daikin','naścienny',6.00,7.00,'Comfora','Comfora','FTXP-60M9','RXP-60R9',8470.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(259,'2023-03-01 00:00:00.000000','Daikin','naścienny',7.10,8.20,'Comfora','Comfora','FTXP-71M9','RXP-71R9',11600.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(260,'2023-03-01 00:00:00.000000','Daikin','naścienny',2.00,2.50,'FTXF','FTXF','FTXF-20D','RXF-20D',3720.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(261,'2023-03-01 00:00:00.000000','Daikin','naścienny',2.50,2.80,'FTXF','FTXF','FTXF-25D','RXF-25D',3910.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(262,'2023-03-01 00:00:00.000000','Daikin','naścienny',3.40,4.00,'FTXF','FTXF','FTXF-35D','RXF-35D',4110.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(263,'2023-03-01 00:00:00.000000','Daikin','naścienny',4.20,5.40,'FTXF','FTXF','FTXF-42D','RXF-42D',4950.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(264,'2023-03-01 00:00:00.000000','Daikin','naścienny',5.00,5.80,'FTXF','FTXF','FTXF-50D','RXF-50D',7400.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(265,'2023-03-01 00:00:00.000000','Daikin','naścienny',6.00,7.00,'FTXF','FTXF','FTXF-60D','RXF-60D',7900.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(266,'2023-03-01 00:00:00.000000','Daikin','naścienny',7.10,8.20,'FTXF','FTXF','FTXF-71D','RXF-71D',9000.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(267,'2023-03-01 00:00:00.000000','Daikin','naścienny',2.00,2.50,'ATXF','ATXF','ATXF-20D','ARXF-20D',3610.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(268,'2023-03-01 00:00:00.000000','Daikin','naścienny',2.50,2.80,'ATXF','ATXF','ATXF-25D','ARXF-25D',3780.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(269,'2023-03-01 00:00:00.000000','Daikin','naścienny',3.40,4.00,'ATXF','ATXF','ATXF-35D','ARXF-35D',3950.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(270,'2023-03-01 00:00:00.000000','Daikin','naścienny',4.20,5.40,'ATXF','ATXF','ATXF-42D','ARXF-42D',4760.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(271,'2023-03-01 00:00:00.000000','Daikin','naścienny',5.00,5.80,'ATXF','ATXF','ATXF-50D','ARXF-50D',7140.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(272,'2023-03-01 00:00:00.000000','Daikin','naścienny',6.00,7.00,'ATXF','ATXF','ATXF-60D','ARXF-60D',7630.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(273,'2023-03-01 00:00:00.000000','Daikin','naścienny',7.10,8.20,'ATXF','ATXF','ATXF-71D','ARXF-71D',8700.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(274,'2023-03-01 00:00:00.000000','Daikin','kaseton',3.50,4.20,'FCAG 360','FCAG 360','FCAG-35B','RXM-35R9',8700.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(275,'2023-03-01 00:00:00.000000','Daikin','kaseton',5.00,6.00,'FCAG 360','FCAG 360','FCAG-50B','RXM-50R',9260.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(276,'2023-03-01 00:00:00.000000','Daikin','kaseton',6.00,7.00,'FCAG 360','FCAG 360','FCAG-60B','RXM-60R',11010.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(277,'2023-03-01 00:00:00.000000','Daikin','kaseton',2.50,3.20,'FFA - płaska','FFA - płaska','FFA-25A9','RXM-25R9',7240.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(278,'2023-03-01 00:00:00.000000','Daikin','kaseton',3.40,4.20,'FFA - płaska','FFA - płaska','FFA-35A9','RXM-35R9',8580.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(279,'2023-03-01 00:00:00.000000','Daikin','kaseton',5.00,5.80,'FFA - płaska','FFA - płaska','FFA-50A9','RXM-50R',9090.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(280,'2023-03-01 00:00:00.000000','Daikin','kaseton',5.70,7.00,'FFA - płaska','FFA - płaska','FFA-60A9','RXM-60R',10830.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(281,'2023-03-01 00:00:00.000000','Daikin','podstropowy',3.40,4.00,'FHA','FHA','FHA-35A9','RXM-35R9',8990.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(282,'2023-03-01 00:00:00.000000','Daikin','podstropowy',5.00,6.00,'FHA','FHA','FHA-50A9','RXM-50R',9560.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(283,'2023-03-01 00:00:00.000000','Daikin','podstropowy',5.70,7.20,'FHA','FHA','FHA-60A9','RXM-60R',11760.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(284,'2023-03-01 00:00:00.000000','Daikin','kanałowy',2.40,3.20,'FDXM','FDXM','FDXM-25F9','RXM-25R9',6160.00,'',NULL,NULL,NULL,NULL,NULL,0),(285,'2023-03-01 00:00:00.000000','Daikin','kanałowy',3.40,4.00,'FDXM','FDXM','FDXM-35F9','RXM-35R9',7480.00,'',NULL,NULL,NULL,NULL,NULL,0),(286,'2023-03-01 00:00:00.000000','Daikin','kanałowy',5.00,5.80,'FDXM','FDXM','FDXM-50F9','RXM-50R',9340.00,'',NULL,NULL,NULL,NULL,NULL,0),(287,'2023-03-01 00:00:00.000000','Daikin','kanałowy',6.00,7.00,'FDXM','FDXM','FDXM-60F9','RXM-60R',12050.00,'',NULL,NULL,NULL,NULL,NULL,0),(288,'2023-03-01 00:00:00.000000','Daikin','kanałowy',3.40,4.00,'FBA średni spręż','FBA średni spręż','FBA-35A9','RXM-35R9',10150.00,'',NULL,NULL,NULL,NULL,NULL,0),(289,'2023-03-01 00:00:00.000000','Daikin','kanałowy',5.00,5.50,'FBA średni spręż','FBA średni spręż','FBA-50A9','RXM-50R',11080.00,'',NULL,NULL,NULL,NULL,NULL,0),(290,'2023-03-01 00:00:00.000000','Daikin','kanałowy',5.70,7.00,'FBA średni spręż','FBA średni spręż','FBA-60A9','RXM-60R',13030.00,'',NULL,NULL,NULL,NULL,NULL,0),(291,'2023-03-01 00:00:00.000000','Daikin','przypodłogowy',2.60,3.20,'Przypodłogowy bez obudowy','Przypodłogowy bez obudowy','FNA-25A9','RXM-25R9',7190.00,'',NULL,NULL,NULL,NULL,NULL,0),(292,'2023-03-01 00:00:00.000000','Daikin','przypodłogowy',3.40,4.00,'Przypodłogowy bez obudowy','Przypodłogowy bez obudowy','FNA-35A9','RXM-35R9',8890.00,'',NULL,NULL,NULL,NULL,NULL,0),(293,'2023-03-01 00:00:00.000000','Daikin','przypodłogowy',5.00,5.80,'Przypodłogowy bez obudowy','Przypodłogowy bez obudowy','FNA-50A9','RXM-50R',9980.00,'',NULL,NULL,NULL,NULL,NULL,0),(294,'2023-03-01 00:00:00.000000','Daikin','przypodłogowy',6.00,7.00,'Przypodłogowy bez obudowy','Przypodłogowy bez obudowy','FNA-60A9','RXM-60R',11990.00,'',NULL,NULL,NULL,NULL,NULL,0),(295,'2023-03-01 00:00:00.000000','Daikin','naścienny',3.00,3.20,'Stylish Grzanie Czarny','Stylish Grzanie Czarny','FTXTA-30BB','RXTA-30B',10160.00,'czarny',NULL,NULL,NULL,NULL,NULL,0),(296,'2023-03-01 00:00:00.000000','Daikin','naścienny',3.00,3.20,'Stylish Grzanie Biały','Stylish Grzanie Biały','FTXTA-30BW','RXTA-30B',9670.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(297,'2023-03-01 00:00:00.000000','Daikin','naścienny',3.00,3.20,'Perfera Grzanie','Perfera Grzanie','FTXTM-30R','RXTM-30R',8100.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(298,'2023-03-01 00:00:00.000000','Daikin','naścienny',4.00,4.00,'Perfera Grzanie','Perfera Grzanie','FTXTM-40R','RXTM-40R',9230.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(299,'2023-03-01 00:00:00.000000','Daikin','naścienny',2.50,3.20,'Comfora Grzanie','Comfora Grzanie','FTXTP-25M','RXTP-25R',7920.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(300,'2023-03-01 00:00:00.000000','Daikin','naścienny',3.50,4.00,'Comfora Grzanie','Comfora Grzanie','FTXTP-35M','RXTP-35R',8680.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(301,'2023-03-01 00:00:00.000000','Daikin','przypodłogowy',2.50,3.20,'Perfera Grzanie','Perfera Grzanie','FVXM-25A','RXTP-25R',7790.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(302,'2023-03-01 00:00:00.000000','Daikin','przypodłogowy',3.50,4.00,'Perfera Grzanie','Perfera Grzanie','FVXM-35A','RXTP-35R',8710.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(303,'2023-03-01 00:00:00.000000','Haier','naścienny',2.60,3.20,'Jade Plus','Jade Plus','AS25S2SJ1FA-3','1U25MECFRA-3',8050.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(304,'2023-03-01 00:00:00.000000','Haier','naścienny',3.50,4.20,'Jade Plus','Jade Plus','AS35S2SJ1FA-3','1U35MECFRA-3',8540.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(305,'2023-03-01 00:00:00.000000','Haier','naścienny',5.20,6.00,'Jade Plus','Jade Plus','AS50S2SJ1FA-3','1U50JECFRA-3',12840.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(306,'2023-03-01 00:00:00.000000','Haier','naścienny',5.20,6.00,'Jade Plus','Jade Plus','AS50JDJHRA-W','1U50REJFRA',9380.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(307,'2023-03-01 00:00:00.000000','Haier','naścienny',2.80,3.20,'Expert Plus','Expert Plus','AS25XCAHRA','1U25S2SM1FA-2',5390.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(308,'2023-03-01 00:00:00.000000','Haier','naścienny',3.50,4.20,'Expert Plus','Expert Plus','AS35XCAHRA','1U35S2SM1FA-2',5650.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(309,'2023-03-01 00:00:00.000000','Haier','naścienny',5.00,5.60,'Expert Plus','Expert Plus','AS50XCAHRA','1U50S2SJ2FA',7380.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(310,'2023-03-01 00:00:00.000000','Haier','naścienny',2.60,3.20,'Flexis Plus Biały Połysk','Flexis Plus Biały Połysk','AS25S2SF1FA-LW','1U25S2SM1FA-2',5080.00,'biały połysk',NULL,NULL,NULL,NULL,NULL,0),(311,'2023-03-01 00:00:00.000000','Haier','naścienny',3.50,4.20,'Flexis Plus Biały Połysk','Flexis Plus Biały Połysk','AS35S2SF1FA-LW','1U35S2SM1FA-2',5320.00,'biały połysk',NULL,NULL,NULL,NULL,NULL,0),(312,'2023-03-01 00:00:00.000000','Haier','naścienny',5.20,6.00,'Flexis Plus Biały Połysk','Flexis Plus Biały Połysk','AS50S2SF1FA-LW','1U50S2SJ2FA',7010.00,'biały połysk',NULL,NULL,NULL,NULL,NULL,0),(313,'2023-03-01 00:00:00.000000','Haier','naścienny',2.60,3.20,'Flexis Plus Biały Mat','Flexis Plus Biały Mat','AS25S2SF1FA-WH','1U25S2SM1FA-2 ',5080.00,'biały mat',NULL,NULL,NULL,NULL,NULL,0),(314,'2023-03-01 00:00:00.000000','Haier','naścienny',3.50,4.20,'Flexis Plus Biały Mat','Flexis Plus Biały Mat','AS35S2SF1FA-WH','1U35S2SM1FA-2',5320.00,'biały mat',NULL,NULL,NULL,NULL,NULL,0),(315,'2023-03-01 00:00:00.000000','Haier','naścienny',5.20,6.00,'Flexis Plus Biały Mat','Flexis Plus Biały Mat','AS50S2SF1FA-WH','1U50S2SJ2FA',7010.00,'biały mat',NULL,NULL,NULL,NULL,NULL,0),(316,'2023-03-01 00:00:00.000000','Haier','naścienny',7.00,8.00,'Flexis Plus Biały Mat','Flexis Plus Biały Mat','AS71S2SF1FA-WH','1U71S2SR2FA',8670.00,'biały mat',NULL,NULL,NULL,NULL,NULL,0),(317,'2023-03-01 00:00:00.000000','Haier','naścienny',2.60,3.20,'Flexis Plus Czarny','Flexis Plus Czarny','AS25S2SF1FA-BH','1U25S2SM1FA-2 ',5170.00,'czarny',NULL,NULL,NULL,NULL,NULL,0),(318,'2023-03-01 00:00:00.000000','Haier','naścienny',3.50,4.20,'Flexis Plus Czarny','Flexis Plus Czarny','AS35S2SF1FA-BH','1U35S2SM1FA-2',5420.00,'czarny',NULL,NULL,NULL,NULL,NULL,0),(319,'2023-03-01 00:00:00.000000','Haier','naścienny',5.20,6.00,'Flexis Plus Czarny','Flexis Plus Czarny','AS50S2SF1FA-BH','1U50S2SJ2FA',7100.00,'czarny',NULL,NULL,NULL,NULL,NULL,0),(320,'2023-03-01 00:00:00.000000','Haier','naścienny',7.00,8.00,'Flexis Plus Czarny','Flexis Plus Czarny','AS71S2SF1FA-BH','1U71S2SR2FA',8790.00,'czarny',NULL,NULL,NULL,NULL,NULL,0),(321,'2023-03-01 00:00:00.000000','Haier','naścienny',2.60,3.20,'Flexis Plus Siver','Flexis Plus Siver','AS25S2SF1FA-S','1U25S2SM1FA-2 ',5170.00,'srebrny',NULL,NULL,NULL,NULL,NULL,0),(322,'2023-03-01 00:00:00.000000','Haier','naścienny',3.50,4.20,'Flexis Plus Siver','Flexis Plus Siver','AS35S2SF1FA-S','1U35S2SM1FA-2',5420.00,'srebrny',NULL,NULL,NULL,NULL,NULL,0),(323,'2023-03-01 00:00:00.000000','Haier','naścienny',3.50,4.20,'NORDIC FLEXIS Plus Biały Połysk','NORDIC FLEXIS Plus Biały Połysk','AS35S2SF1FA-LW','1U35MEHFRA-1',5610.00,'biały połysk',NULL,NULL,NULL,NULL,NULL,0),(324,'2023-03-01 00:00:00.000000','Haier','naścienny',5.20,6.00,'NORDIC FLEXIS Plus Biały Połysk','NORDIC FLEXIS Plus Biały Połysk','AS50S2SF1FA-LW','1U50S2SJ2FA-1',7290.00,'biały połysk',NULL,NULL,NULL,NULL,NULL,0),(325,'2023-03-01 00:00:00.000000','Haier','naścienny',3.50,4.20,'NORDIC FLEXIS Plus Biały Mat','NORDIC FLEXIS Plus Biały Mat','AS35S2SF1FA-WH','1U35MEHFRA-1',5610.00,'biały mat',NULL,NULL,NULL,NULL,NULL,0),(326,'2023-03-01 00:00:00.000000','Haier','naścienny',5.20,6.00,'NORDIC FLEXIS Plus Biały Mat','NORDIC FLEXIS Plus Biały Mat','AS50S2SF1FA-WH','1U50S2SJ2FA-1',7290.00,'biały mat',NULL,NULL,NULL,NULL,NULL,0),(327,'2023-03-01 00:00:00.000000','Haier','naścienny',3.50,4.20,'NORDIC FLEXIS Plus Czarny','NORDIC FLEXIS Plus Czarny','AS35S2SF1FA-BH','1U35MEHFRA-1',5710.00,'czarny',NULL,NULL,NULL,NULL,NULL,0),(328,'2023-03-01 00:00:00.000000','Haier','naścienny',5.20,6.00,'NORDIC FLEXIS Plus Czarny','NORDIC FLEXIS Plus Czarny','AS50S2SF1FA-BH','1U50S2SJ2FA-1',7380.00,'czarny',NULL,NULL,NULL,NULL,NULL,0),(329,'2023-03-01 00:00:00.000000','Haier','naścienny',3.50,4.20,'NORDIC FLEXIS Plus Silver','NORDIC FLEXIS Plus Silver','AS35S2SF1FA-S','1U35MEHFRA-1',5710.00,'srebrny',NULL,NULL,NULL,NULL,NULL,0),(330,'2023-03-01 00:00:00.000000','Haier','naścienny',2.60,2.80,'PEARL Plus','PEARL Plus','AS25PBAHRA','1U25YEGFRA',3770.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(331,'2023-03-01 00:00:00.000000','Haier','naścienny',3.50,3.50,'PEARL Plus','PEARL Plus','AS35PBAHRA','1U35YEGFRA',3960.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(332,'2023-03-01 00:00:00.000000','Haier','naścienny',5.00,5.20,'PEARL Plus','PEARL Plus','AS50PDAHRA','1U50MEGFRA',5730.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(333,'2023-03-01 00:00:00.000000','Haier','naścienny',6.80,6.00,'PEARL Plus','PEARL Plus','AS68PDAHRA','1U68WEGFRA',7450.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(334,'2023-03-01 00:00:00.000000','Haier','naścienny',7.00,8.00,'Flare','Flare','AS71S2SF2FA-2','1U71S2SR2FA',7310.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(335,'2023-03-01 00:00:00.000000','Haier','naścienny',2.60,2.80,'TAYGA Plus','TAYGA Plus','AS25THMHRA-C','1U25YEFFRA-C',2770.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(336,'2023-03-01 00:00:00.000000','Haier','naścienny',3.20,3.40,'TAYGA Plus','TAYGA Plus','AS35TAMHRA-C','1U35YEFFRA-C',2940.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(337,'2023-03-01 00:00:00.000000','Haier','naścienny',5.00,5.20,'TAYGA Plus','TAYGA Plus','AS50TDMHRA-C','1U50MEMFRA-C',4490.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(338,'2023-03-01 00:00:00.000000','Haier','naścienny',7.00,8.10,'TAYGA Plus','TAYGA Plus','AS68TEMHRA-C','1U68RENFRA-C',5980.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(339,'2023-03-01 00:00:00.000000','Haier','konsola',2.50,2.80,'Console','Console','AF25S2SD1FA','1U25S2SM1FA-2',6180.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(340,'2023-03-01 00:00:00.000000','Haier','konsola',3.40,3.50,'Console','Console','AF35S2SD1FA','1U35S2SM1FA-2',6460.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(341,'2023-03-01 00:00:00.000000','Fujitsu','naścienny',2.00,2.50,'KETA / KETE Biały','KETA / KETE Biały','ASYG07KETA / ASYG07KETE','AOYG07KETA ',4900.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(342,'2023-03-01 00:00:00.000000','Fujitsu','naścienny',2.50,2.80,'KETA / KETE Biały','KETA / KETE Biały','ASYG09KETA / ASYG09KETE','AOYG09KETA ',5600.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(343,'2023-03-01 00:00:00.000000','Fujitsu','naścienny',3.40,4.00,'KETA / KETE Biały','KETA / KETE Biały','ASYG12KETA / ASYG12KETE','AOYG12KETA ',6000.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(344,'2023-03-01 00:00:00.000000','Fujitsu','naścienny',4.20,5.40,'KETA / KETE Biały','KETA / KETE Biały','ASYG14KETA / ASYG14KETE','AOYG14KETA ',8000.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(345,'2023-03-01 00:00:00.000000','Fujitsu','naścienny',2.00,2.50,'KETA-B / KETE-B Grafitowy','KETA-B / KETE-B Grafitowy','ASYG07KETA-B / ASYG07KETE-B','AOYG07KETA ',4900.00,'grafitowy',NULL,NULL,NULL,NULL,NULL,0),(346,'2023-03-01 00:00:00.000000','Fujitsu','naścienny',2.50,2.80,'KETA-B / KETE-B Grafitowy','KETA-B / KETE-B Grafitowy','ASYG09KETA-B / ASYG09KETE-B','AOYG09KETA ',5600.00,'grafitowy',NULL,NULL,NULL,NULL,NULL,0),(347,'2023-03-01 00:00:00.000000','Fujitsu','naścienny',3.40,4.00,'KETA-B / KETE-B Grafitowy','KETA-B / KETE-B Grafitowy','ASYG12KETA-B / ASYG12KETE-B','AOYG12KETA ',6000.00,'grafitowy',NULL,NULL,NULL,NULL,NULL,0),(348,'2023-03-01 00:00:00.000000','Fujitsu','naścienny',4.20,5.40,'KETA-B / KETE-B Grafitowy','KETA-B / KETE-B Grafitowy','ASYG14KETA-B / ASYG14KETE-B','AOYG14KETA ',8000.00,'grafitowy',NULL,NULL,NULL,NULL,NULL,0),(349,'2023-03-01 00:00:00.000000','Fujitsu','naścienny',2.00,2.50,'KMCC/KMCE','KMCC/KMCE','ASYG07KMCC / ASYG07KMCE','AOYG07KMCC',3900.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(350,'2023-03-01 00:00:00.000000','Fujitsu','naścienny',2.50,2.80,'KMCC/KMCE','KMCC/KMCE','ASYG09KMCC / ASYG09KMCE','AOYG09KMCC',4200.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(351,'2023-03-01 00:00:00.000000','Fujitsu','naścienny',3.40,4.00,'KMCC/KMCE','KMCC/KMCE','ASYG12KMCC / ASYG12KMCE','AOYG12KMCC',4900.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(352,'2023-03-01 00:00:00.000000','Fujitsu','naścienny',4.20,5.40,'KMCC/KMCE','KMCC/KMCE','ASYG14KMCC / ASYG14KMCE','AOYG14KMCC',7100.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(353,'2023-03-01 00:00:00.000000','Fujitsu','naścienny',5.20,6.30,'KMTB/KMTE/KMTA','KMTB/KMTE/KMTA','ASYG18KMTB / ASYG18KMTE','AOYG18KMTA',8200.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(354,'2023-03-01 00:00:00.000000','Fujitsu','naścienny',7.10,8.00,'KMTB/KMTE/KMTA','KMTB/KMTE/KMTA','ASYG24KMTB / ASYG24KMTE','AOYG24KMTA',11000.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(355,'2023-03-01 00:00:00.000000','Fujitsu','naścienny',8.00,8.80,'KMTB/KMTE/KMTA','KMTB/KMTE/KMTA','ASYG30KMTA','AOYG30KMTA',15300.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(356,'2023-03-01 00:00:00.000000','Fujitsu','naścienny',9.40,10.10,'KMTB/KMTE/KMTA','KMTB/KMTE/KMTA','ASYG36KMTA','AOYG36KMTA',16500.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(357,'2023-03-01 00:00:00.000000','Fujitsu','naścienny',2.00,2.50,'KG','KG','ASYG07KGTB / ASYG07KGTE','AOYG07KGCA',4900.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(358,'2023-03-01 00:00:00.000000','Fujitsu','naścienny',2.50,2.80,'KG','KG','ASYG09KGTB / ASYG14KGTE','AOYG09KGCA',5600.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(359,'2023-03-01 00:00:00.000000','Fujitsu','naścienny',3.40,4.00,'KG','KG','ASYG12KGTB / ASYG12KGTE','AOYG12KGCA',6000.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(360,'2023-03-01 00:00:00.000000','Fujitsu','naścienny',4.20,5.40,'KG','KG','ASYG14KGTB / ASYG14KGTE','AOYG14KGCA',8000.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(361,'2023-03-01 00:00:00.000000','Fujitsu','naścienny',2.00,2.50,'KPCA','KPCA','ASYG07KPCA / ASYG07KPCE','AOYG07KPCA',3600.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(362,'2023-03-01 00:00:00.000000','Fujitsu','naścienny',2.50,2.80,'KPCA','KPCA','ASYG09KPCA / ASYG09KPCE','AOYG09KPCA',3800.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(363,'2023-03-01 00:00:00.000000','Fujitsu','naścienny',3.40,3.80,'KPCA','KPCA','ASYG12KPCA / ASYG12KPCE','AOYG12KPCA',4300.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(364,'2023-03-01 00:00:00.000000','Fujitsu','naścienny',3.40,5.00,'KX','KX','ASYG12KXCA','AOYG12KXCA',13900.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(365,'2023-03-01 00:00:00.000000','Fujitsu','naścienny',5.20,6.30,'KLCA','KLCA','ASYG18KLCA','AOYG18KLCA',7100.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(366,'2023-03-01 00:00:00.000000','Fujitsu','naścienny',7.10,8.00,'KLCA','KLCA','ASYG24KLCA','AOYG24KLCA',9600.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(367,'2023-03-01 00:00:00.000000','Fujitsu','naścienny',2.00,3.00,'LM','LM','ASYG07LMCE','AOYG07LMCE',3900.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(368,'2023-03-01 00:00:00.000000','Fujitsu','naścienny',2.50,3.20,'LM','LM','ASYG09LMCE','AOYG09LMCE',4200.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(369,'2023-03-01 00:00:00.000000','Fujitsu','naścienny',3.40,4.00,'LM','LM','ASYG12LMCE','AOYG12LMCE',2900.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(370,'2023-03-01 00:00:00.000000','Fujitsu','naścienny',4.00,5.00,'LM','LM','ASYG14LMCE','AOYG14LMCE',7100.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(371,'2023-03-01 00:00:00.000000','Fujitsu','naścienny',2.50,3.20,'KH - Nordic','KH - Nordic','ASYG09KHCA','AOYG09KHCAN',8100.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(372,'2023-03-01 00:00:00.000000','Fujitsu','naścienny',3.40,4.00,'KH - Nordic','KH - Nordic','ASYG12KHCA','AOYG12KHCAN',8900.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(373,'2023-03-01 00:00:00.000000','Fujitsu','naścienny',4.20,5.40,'KH - Nordic','KH - Nordic','ASYG14KHCA','AOYG14KHCAN',11300.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(374,'2023-03-01 00:00:00.000000','Fujitsu','naścienny',2.50,3.20,'KM - Nordic','KM - Nordic','ASYG09KMCDN','AOYG09KMCDN',5600.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(375,'2023-03-01 00:00:00.000000','Fujitsu','naścienny',3.40,4.00,'KM - Nordic','KM - Nordic','ASYG12KMCDN','AOYG12KMCDN',6500.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(376,'2023-03-01 00:00:00.000000','Fujitsu','naścienny',4.20,5.40,'KM - Nordic','KM - Nordic','ASYG14KMCDN','AOYG14KMCDN',9100.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(377,'2023-03-01 00:00:00.000000','Fujitsu','przypodłogowy',2.50,3.50,'Przypodłogowy','Przypodłogowy','AGYG09KVCA','AOYG09KVCA',7800.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(378,'2023-03-01 00:00:00.000000','Fujitsu','przypodłogowy',3.50,4.50,'Przypodłogowy','Przypodłogowy','AGYG12KVCA','AOYG12KVCA',8900.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(379,'2023-03-01 00:00:00.000000','Fujitsu','przypodłogowy',4.20,5.20,'Przypodłogowy','Przypodłogowy','AGYG14KVCA','AOYG14KVCA',10200.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(380,'2023-03-01 00:00:00.000000','Fujitsu','przypodłogowy',2.50,3.50,'Przypodłogowy - Nordic','Przypodłogowy - Nordic','AGYG09KVCB','AOYG09KVCBN',8800.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(381,'2023-03-01 00:00:00.000000','Fujitsu','przypodłogowy',3.50,4.50,'Przypodłogowy - Nordic','Przypodłogowy - Nordic','AGYG12KVCB','AOYG12KVCBN',10100.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(382,'2023-03-01 00:00:00.000000','Fujitsu','przypodłogowy',4.20,5.20,'Przypodłogowy - Nordic','Przypodłogowy - Nordic','AGYG14KVCB','AOYG14KVCBN',11500.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(383,'2023-03-01 00:00:00.000000','Toshiba','naścienny',1.50,2.00,'SEIYA 2','SEIYA 2','RAS-B05E2KVG-E','RAS-05E2AVG-E',3950.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(384,'2023-03-01 00:00:00.000000','Toshiba','naścienny',2.00,2.50,'SEIYA 2','SEIYA 2','RAS-B07E2KVG-E','RAS-07E2AVG-E',4150.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(385,'2023-03-01 00:00:00.000000','Toshiba','naścienny',2.50,3.20,'SEIYA 2','SEIYA 2','RAS-B10E2KVG-E','RAS-10E2AVG-E',4650.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(386,'2023-03-01 00:00:00.000000','Toshiba','naścienny',3.30,3.60,'SEIYA 2','SEIYA 2','RAS-B13E2KVG-E','RAS-13E2AVG-E',4800.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(387,'2023-03-01 00:00:00.000000','Toshiba','naścienny',4.20,5.00,'SEIYA 2','SEIYA 2','RAS-B16E2KVG-E','RAS-16E2AVG-E',6200.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(388,'2023-03-01 00:00:00.000000','Toshiba','naścienny',5.00,5.40,'SEIYA 2','SEIYA 2','RAS-18E2KVG-E','RAS-18E2AVG-E',7400.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(389,'2023-03-01 00:00:00.000000','Toshiba','naścienny',6.50,7.00,'SEIYA 2','SEIYA 2','RAS-24E2KVG-E','RAS-24E2AVG-E',8800.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(390,'2023-03-01 00:00:00.000000','Toshiba','naścienny',2.00,2.30,'SHORAI EDGE White','SHORAI EDGE White','RAS-B07G3KVSG-E','RAS-07J2AVSG-E1',6100.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(391,'2023-03-01 00:00:00.000000','Toshiba','naścienny',2.50,2.50,'SHORAI EDGE White','SHORAI EDGE White','RAS-B10G3KVSG-E','RAS-10J2AVSG-E1',6600.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(392,'2023-03-01 00:00:00.000000','Toshiba','naścienny',3.50,3.20,'SHORAI EDGE White','SHORAI EDGE White','RAS-B13G3KVSG-E','RAS-13J2AVSG-E1 ',7800.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(393,'2023-03-01 00:00:00.000000','Toshiba','naścienny',4.60,4.00,'SHORAI EDGE White','SHORAI EDGE White','RAS-B16G3KVSG-E','RAS-16J2AVSG-E1',9000.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(394,'2023-03-01 00:00:00.000000','Toshiba','naścienny',5.00,4.30,'SHORAI EDGE White','SHORAI EDGE White','RAS-18J2G3KVSG-E','RAS-18J2AVSG-E1',10800.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(395,'2023-03-01 00:00:00.000000','Toshiba','naścienny',6.10,4.70,'SHORAI EDGE White','SHORAI EDGE White','RAS-B22G3KVSG-E','RAS-22J2AVSG-E1',11600.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(396,'2023-03-01 00:00:00.000000','Toshiba','naścienny',7.00,6.30,'SHORAI EDGE White','SHORAI EDGE White','RAS-B24G3KVSG-E ','RAS-24J2AVSG-E1',12700.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(397,'2023-03-01 00:00:00.000000','Toshiba','naścienny',2.00,2.30,'SHORAI EDGE Black','SHORAI EDGE Black','RAS-B07G3KVSGB-E','RAS-07J2AVSG-E1',6400.00,'czarny',NULL,NULL,NULL,NULL,NULL,0),(398,'2023-03-01 00:00:00.000000','Toshiba','naścienny',2.50,2.50,'SHORAI EDGE Black','SHORAI EDGE Black','RAS-B10G3KVSGB-E','RAS-10J2AVSG-E1',7000.00,'czarny',NULL,NULL,NULL,NULL,NULL,0),(399,'2023-03-01 00:00:00.000000','Toshiba','naścienny',3.50,3.20,'SHORAI EDGE Black','SHORAI EDGE Black','RAS-B13G3KVSGB-E','RAS-13J2AVSG-E1 ',8200.00,'czarny',NULL,NULL,NULL,NULL,NULL,0),(400,'2023-03-01 00:00:00.000000','Toshiba','naścienny',4.60,4.00,'SHORAI EDGE Black','SHORAI EDGE Black','RAS-B16G3KVSGB-E','RAS-16J2AVSG-E1',9500.00,'czarny',NULL,NULL,NULL,NULL,NULL,0),(401,'2023-03-01 00:00:00.000000','Toshiba','naścienny',5.00,4.30,'SHORAI EDGE Black','SHORAI EDGE Black','RAS-B18G3KVSGB-E','RAS-18J2AVSG-E1',11500.00,'czarny',NULL,NULL,NULL,NULL,NULL,0),(402,'2023-03-01 00:00:00.000000','Toshiba','naścienny',6.10,4.70,'SHORAI EDGE Black','SHORAI EDGE Black','RAS-B22G3KVSGB-E','RAS-22J2AVSG-E1',12400.00,'czarny',NULL,NULL,NULL,NULL,NULL,0),(403,'2023-03-01 00:00:00.000000','Toshiba','naścienny',7.00,6.30,'SHORAI EDGE Black','SHORAI EDGE Black','RAS-B24G3KVSGB-E','RAS-24J2AVSG-E1',13700.00,'czarny',NULL,NULL,NULL,NULL,NULL,0),(404,'2023-03-01 00:00:00.000000','Toshiba','naścienny',2.50,3.20,'HAORI','HAORI','RAS-B10N4KVRG-E','RAS-10J2AVSG-E1',7700.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(405,'2023-03-01 00:00:00.000000','Toshiba','naścienny',3.50,4.20,'HAORI','HAORI','RAS-B13N4KVRG-E','RAS-13J2AVSG-E1 ',8900.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(406,'2023-03-01 00:00:00.000000','Toshiba','naścienny',4.60,5.50,'HAORI','HAORI','RAS-B16N4KVRG-E','RAS-16J2AVSG-E1 ',10300.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(407,'2023-03-01 00:00:00.000000','Toshiba','naścienny',2.50,3.20,'DAISEIKAI 9','DAISEIKAI 9','RAS-10PKVPG-E','RAS-10PAVPG-E',11100.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(408,'2023-03-01 00:00:00.000000','Toshiba','naścienny',3.50,4.00,'DAISEIKAI 9','DAISEIKAI 9','RAS-13PKVPG-E','RAS-13PAVPG-E',11700.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(409,'2023-03-01 00:00:00.000000','Toshiba','naścienny',4.50,4.50,'DAISEIKAI 9','DAISEIKAI 9','RAS-16PKVPG-E','RAS-16PAVPG-E',13600.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(410,'2023-03-01 00:00:00.000000','Toshiba','konsola',2.50,3.20,'Konsola Bi-Flow','Konsola Bi-Flow','RAS-B10J2FVG-E','RAS-10J2AVSG-E1',8000.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(411,'2023-03-01 00:00:00.000000','Toshiba','konsola',3.50,4.20,'Konsola Bi-Flow','Konsola Bi-Flow','RAS-B13J2FVG-E','RAS-13J2AVSG-E1 ',9300.00,'biały',NULL,NULL,NULL,NULL,NULL,0),(412,'2023-03-01 00:00:00.000000','Toshiba','konsola',5.00,6.00,'Konsola Bi-Flow','Konsola Bi-Flow','RAS-B18J2FVG-E','RAS-18J2AVSG-E1',13000.00,'biały',NULL,NULL,NULL,NULL,NULL,0);
/*!40000 ALTER TABLE `klima_devicesplit` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `klima_faktury`
--

DROP TABLE IF EXISTS `klima_faktury`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `klima_faktury` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `issue_date` date NOT NULL,
  `order` int NOT NULL,
  `ac_user_id` bigint NOT NULL,
  `client_id` bigint NOT NULL,
  `instalacja_id` bigint DEFAULT NULL,
  `id_fakturowni` varchar(100) DEFAULT NULL,
  `numer_faktury` varchar(100) DEFAULT NULL,
  `status` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `klima_faktury_ac_user_id_17c3146b_fk_klima_acuser_id` (`ac_user_id`),
  KEY `klima_faktury_client_id_160ea19d_fk_klima_acuser_id` (`client_id`),
  KEY `klima_faktury_instalacja_id_e59d741f_fk_klima_instalacja_id` (`instalacja_id`),
  CONSTRAINT `klima_faktury_ac_user_id_17c3146b_fk_klima_acuser_id` FOREIGN KEY (`ac_user_id`) REFERENCES `klima_acuser` (`id`),
  CONSTRAINT `klima_faktury_client_id_160ea19d_fk_klima_acuser_id` FOREIGN KEY (`client_id`) REFERENCES `klima_acuser` (`id`),
  CONSTRAINT `klima_faktury_instalacja_id_e59d741f_fk_klima_instalacja_id` FOREIGN KEY (`instalacja_id`) REFERENCES `klima_instalacja` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `klima_faktury`
--

LOCK TABLES `klima_faktury` WRITE;
/*!40000 ALTER TABLE `klima_faktury` DISABLE KEYS */;
INSERT INTO `klima_faktury` VALUES (6,'2023-11-23',6,3,6,NULL,'253197094','FV/07/11/2023/AC','partial'),(7,'2023-11-23',7,3,11,NULL,'253222360','Dftyygvbb','issued'),(8,'2023-11-22',8,3,11,NULL,'253243332','FV/08/11/2023','paid'),(9,'2023-11-22',9,3,6,NULL,'253248902','FV/09/11/2023','paid');
/*!40000 ALTER TABLE `klima_faktury` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `klima_group`
--

DROP TABLE IF EXISTS `klima_group`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `klima_group` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `nazwa` varchar(255) NOT NULL,
  `owner` int unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `klima_group_chk_1` CHECK ((`owner` >= 0))
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `klima_group`
--

LOCK TABLES `klima_group` WRITE;
/*!40000 ALTER TABLE `klima_group` DISABLE KEYS */;
INSERT INTO `klima_group` VALUES (1,'Pierwsza1',3),(2,'Ekipa 1',3),(3,'Tomek',3);
/*!40000 ALTER TABLE `klima_group` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `klima_inspekcja`
--

DROP TABLE IF EXISTS `klima_inspekcja`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `klima_inspekcja` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `rooms` int DEFAULT NULL,
  `created_date` datetime(6) NOT NULL,
  `rooms_m2` double DEFAULT NULL,
  `device_amount` int DEFAULT NULL,
  `power_amount` double DEFAULT NULL,
  `dlugosc_instalacji` double DEFAULT NULL,
  `prowadzenie_instalacji` varchar(100) DEFAULT NULL,
  `prowadzenie_skroplin` varchar(100) DEFAULT NULL,
  `miejsce_agregatu` varchar(100) DEFAULT NULL,
  `podlaczenie_elektryki` varchar(100) DEFAULT NULL,
  `miejsce_urzadzen_wew` varchar(100) DEFAULT NULL,
  `obnizenie` double DEFAULT NULL,
  `uwagi` longtext,
  `instalacja_id` bigint NOT NULL,
  PRIMARY KEY (`id`),
  KEY `klima_inspekcja_instalacja_id_897f3c67_fk_klima_instalacja_id` (`instalacja_id`),
  CONSTRAINT `klima_inspekcja_instalacja_id_897f3c67_fk_klima_instalacja_id` FOREIGN KEY (`instalacja_id`) REFERENCES `klima_instalacja` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=29 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `klima_inspekcja`
--

LOCK TABLES `klima_inspekcja` WRITE;
/*!40000 ALTER TABLE `klima_inspekcja` DISABLE KEYS */;
INSERT INTO `klima_inspekcja` VALUES (1,2,'2023-09-21 19:55:44.616143',NULL,NULL,NULL,NULL,'','','','','',NULL,'',1),(3,NULL,'2023-09-21 19:56:01.644657',NULL,NULL,NULL,NULL,'','','','','',NULL,'',3),(4,75,'2023-09-24 11:08:37.634872',5,6,3.5,45,'6','7','Test','Test','Test',5,'Testtttt',4),(5,NULL,'2023-09-26 08:00:27.016071',NULL,NULL,NULL,NULL,'','','','','',NULL,'',5),(6,NULL,'2023-09-27 09:36:25.297963',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'Hdhhahaja',6),(7,NULL,'2023-10-06 11:19:28.577566',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,7),(8,NULL,'2023-10-06 12:26:35.056400',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,8),(9,NULL,'2023-10-06 12:27:05.954735',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,9),(10,NULL,'2023-10-06 12:28:25.860030',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,10),(11,NULL,'2023-10-07 10:07:00.033221',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,11),(12,NULL,'2023-10-07 10:07:01.835072',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,12),(13,NULL,'2023-10-07 18:16:44.406188',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,13),(14,NULL,'2023-10-27 13:24:47.853725',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,14),(15,NULL,'2023-10-27 13:39:06.935681',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,15),(16,5,'2023-10-29 20:55:40.159262',10,5,10,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,16),(17,NULL,'2023-11-06 11:33:55.951442',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,17),(19,12,'2023-11-16 10:14:49.729479',143,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,19),(23,NULL,'2023-11-17 16:42:38.567256',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,23),(24,1,'2023-11-23 09:28:36.308472',1,1,1,1,'1','2','2','2','2',4,'6\n\n\n\n1\n\nW\n\n\n\n\n\n\n\n\nJaką\nU\nS',24),(25,10,'2023-11-27 21:11:05.555096',24,2,3.5,10,'Fhsbcbns','Fhsjjfnsn','Fnsndnjfjs','Hfsjjdjsb','Bcnsjajjs',100,'Chdhbdbs',25),(26,NULL,'2023-12-05 15:46:09.041791',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,26),(27,NULL,'2023-12-06 12:27:31.755917',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,27),(28,NULL,'2023-12-06 12:27:45.731398',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,28);
/*!40000 ALTER TABLE `klima_inspekcja` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `klima_inspekcja_photos`
--

DROP TABLE IF EXISTS `klima_inspekcja_photos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `klima_inspekcja_photos` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `inspekcja_id` bigint NOT NULL,
  `photo_id` bigint NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `klima_inspekcja_photos_inspekcja_id_photo_id_e7de72ce_uniq` (`inspekcja_id`,`photo_id`),
  KEY `klima_inspekcja_photos_photo_id_55920b5e_fk_klima_photo_id` (`photo_id`),
  CONSTRAINT `klima_inspekcja_phot_inspekcja_id_1c583d7a_fk_klima_ins` FOREIGN KEY (`inspekcja_id`) REFERENCES `klima_inspekcja` (`id`),
  CONSTRAINT `klima_inspekcja_photos_photo_id_55920b5e_fk_klima_photo_id` FOREIGN KEY (`photo_id`) REFERENCES `klima_photo` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `klima_inspekcja_photos`
--

LOCK TABLES `klima_inspekcja_photos` WRITE;
/*!40000 ALTER TABLE `klima_inspekcja_photos` DISABLE KEYS */;
/*!40000 ALTER TABLE `klima_inspekcja_photos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `klima_instalacja`
--

DROP TABLE IF EXISTS `klima_instalacja`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `klima_instalacja` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `created_date` datetime(6) NOT NULL,
  `klient_id` bigint NOT NULL,
  `owner_id` bigint NOT NULL,
  PRIMARY KEY (`id`),
  KEY `klima_instalacja_klient_id_a449e3d1_fk_klima_acuser_id` (`klient_id`),
  KEY `klima_instalacja_owner_id_6c9cc282_fk_klima_acuser_id` (`owner_id`),
  CONSTRAINT `klima_instalacja_klient_id_a449e3d1_fk_klima_acuser_id` FOREIGN KEY (`klient_id`) REFERENCES `klima_acuser` (`id`),
  CONSTRAINT `klima_instalacja_owner_id_6c9cc282_fk_klima_acuser_id` FOREIGN KEY (`owner_id`) REFERENCES `klima_acuser` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=29 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `klima_instalacja`
--

LOCK TABLES `klima_instalacja` WRITE;
/*!40000 ALTER TABLE `klima_instalacja` DISABLE KEYS */;
INSERT INTO `klima_instalacja` VALUES (1,NULL,'2023-09-21 19:55:44.612720',5,3),(3,NULL,'2023-09-21 19:56:01.640727',5,3),(4,NULL,'2023-09-24 11:08:37.631407',6,3),(5,NULL,'2023-09-26 08:00:27.012455',6,3),(6,NULL,'2023-09-27 09:36:25.294392',6,3),(7,NULL,'2023-10-06 11:19:28.573570',10,3),(8,NULL,'2023-10-06 12:26:35.051991',23,3),(9,NULL,'2023-10-06 12:27:05.951810',10,3),(10,NULL,'2023-10-06 12:28:25.856063',24,3),(11,NULL,'2023-10-07 10:07:00.029794',26,3),(12,NULL,'2023-10-07 10:07:01.830669',26,3),(13,NULL,'2023-10-07 18:16:44.400930',27,3),(14,NULL,'2023-10-27 13:24:47.849446',6,3),(15,NULL,'2023-10-27 13:39:06.931878',6,3),(16,NULL,'2023-10-29 20:55:40.154906',11,3),(17,NULL,'2023-11-06 11:33:55.949077',11,3),(19,'Instalacja test','2023-11-16 10:14:49.723302',11,3),(23,'Instalacja','2023-11-17 16:42:38.562492',6,3),(24,'Instalacja','2023-11-23 09:28:36.304636',47,3),(25,'Instalacja marszałkowska ','2023-11-27 21:11:05.552072',50,3),(26,'Testowwwwa','2023-12-05 15:46:09.038066',11,3),(27,'Instalacja','2023-12-06 12:27:31.752956',11,3),(28,'Instalacja','2023-12-06 12:27:45.727009',11,3);
/*!40000 ALTER TABLE `klima_instalacja` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `klima_invoicesettings`
--

DROP TABLE IF EXISTS `klima_invoicesettings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `klima_invoicesettings` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `footer` longtext,
  `place_of_issue` varchar(255) DEFAULT NULL,
  `issuer_name` varchar(255) DEFAULT NULL,
  `standard_payment_term` int DEFAULT NULL,
  `prefix` varchar(10) DEFAULT NULL,
  `suffix` varchar(10) DEFAULT NULL,
  `numbering_type` varchar(10) DEFAULT NULL,
  `year_format` varchar(4) DEFAULT NULL,
  `month_format` varchar(10) DEFAULT NULL,
  `day_format` varchar(10) DEFAULT NULL,
  `ac_user_id` bigint NOT NULL,
  `iban` varchar(28) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ac_user_id` (`ac_user_id`),
  CONSTRAINT `klima_invoicesettings_ac_user_id_b7cc538a_fk_klima_acuser_id` FOREIGN KEY (`ac_user_id`) REFERENCES `klima_acuser` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `klima_invoicesettings`
--

LOCK TABLES `klima_invoicesettings` WRITE;
/*!40000 ALTER TABLE `klima_invoicesettings` DISABLE KEYS */;
INSERT INTO `klima_invoicesettings` VALUES (1,'TestFooter','TestPlace','Test Tes',10,'FV','2023','monthly','YYYY','full_name','numeric',3,'PL12345678901234567890123456');
/*!40000 ALTER TABLE `klima_invoicesettings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `klima_katalog`
--

DROP TABLE IF EXISTS `klima_katalog`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `klima_katalog` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `file` varchar(100) NOT NULL,
  `created_date` datetime(6) NOT NULL,
  `is_active` tinyint(1) NOT NULL,
  `ac_user_id` bigint NOT NULL,
  PRIMARY KEY (`id`),
  KEY `klima_katalog_ac_user_id_6bc56913_fk_klima_acuser_id` (`ac_user_id`),
  CONSTRAINT `klima_katalog_ac_user_id_6bc56913_fk_klima_acuser_id` FOREIGN KEY (`ac_user_id`) REFERENCES `klima_acuser` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `klima_katalog`
--

LOCK TABLES `klima_katalog` WRITE;
/*!40000 ALTER TABLE `klima_katalog` DISABLE KEYS */;
INSERT INTO `klima_katalog` VALUES (3,'Test3','documents/katalogi/3/sample_L3RIrb3.pdf','2023-09-20 11:25:52.450346',1,3),(6,'Testowy katalog','documents/katalogi/3/sample_y5g947w.pdf','2023-11-14 09:29:38.939620',1,3);
/*!40000 ALTER TABLE `klima_katalog` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `klima_montaz`
--

DROP TABLE IF EXISTS `klima_montaz`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `klima_montaz` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `created_date` datetime(6) NOT NULL,
  `data_montazu` datetime(6) DEFAULT NULL,
  `gwarancja` int DEFAULT NULL,
  `liczba_przegladow` int DEFAULT NULL,
  `split_multisplit` tinyint(1) DEFAULT NULL,
  `nr_seryjny_jedn_zew` varchar(100) DEFAULT NULL,
  `nr_seryjny_jedn_zew_photo` varchar(100) DEFAULT NULL,
  `nr_seryjny_jedn_wew` varchar(100) DEFAULT NULL,
  `nr_seryjny_jedn_wew_photo` varchar(100) DEFAULT NULL,
  `miejsce_montazu_jedn_zew` varchar(100) DEFAULT NULL,
  `miejsce_montazu_jedn_zew_photo` int unsigned DEFAULT NULL,
  `miejsce_montazu_jedn_wew` varchar(100) DEFAULT NULL,
  `miejsce_montazu_jedn_wew_photo` int unsigned DEFAULT NULL,
  `sposob_skroplin` varchar(100) DEFAULT NULL,
  `miejsce_skroplin` varchar(100) DEFAULT NULL,
  `miejsce_i_sposob_montazu_jedn_zew` varchar(100) DEFAULT NULL,
  `miejsce_i_sposob_montazu_jedn_zew_photo` int unsigned DEFAULT NULL,
  `miejsce_podlaczenia_elektryki` varchar(100) DEFAULT NULL,
  `gaz` varchar(100) DEFAULT NULL,
  `gaz_ilosc_dodana` double DEFAULT NULL,
  `gaz_ilos` double DEFAULT NULL,
  `temp_zew_montazu` double DEFAULT NULL,
  `temp_wew_montazu` double DEFAULT NULL,
  `cisnienie` double DEFAULT NULL,
  `przegrzanie` double DEFAULT NULL,
  `temp_chlodzenia` double DEFAULT NULL,
  `temp_grzania` double DEFAULT NULL,
  `uwagi` longtext,
  `instalacja_id` bigint NOT NULL,
  PRIMARY KEY (`id`),
  KEY `klima_montaz_instalacja_id_0d28dc45_fk_klima_instalacja_id` (`instalacja_id`),
  CONSTRAINT `klima_montaz_instalacja_id_0d28dc45_fk_klima_instalacja_id` FOREIGN KEY (`instalacja_id`) REFERENCES `klima_instalacja` (`id`),
  CONSTRAINT `klima_montaz_chk_3` CHECK ((`miejsce_montazu_jedn_zew_photo` >= 0)),
  CONSTRAINT `klima_montaz_chk_4` CHECK ((`miejsce_montazu_jedn_wew_photo` >= 0)),
  CONSTRAINT `klima_montaz_chk_5` CHECK ((`miejsce_i_sposob_montazu_jedn_zew_photo` >= 0))
) ENGINE=InnoDB AUTO_INCREMENT=29 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `klima_montaz`
--

LOCK TABLES `klima_montaz` WRITE;
/*!40000 ALTER TABLE `klima_montaz` DISABLE KEYS */;
INSERT INTO `klima_montaz` VALUES (1,'2023-09-21 19:55:44.618582',NULL,NULL,NULL,NULL,'','','','','',NULL,'',NULL,'','','',NULL,'','',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'',1),(3,'2023-09-21 19:56:01.648862',NULL,NULL,NULL,NULL,'','','','','',NULL,'',NULL,'','','',NULL,'','',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'',3),(4,'2023-09-24 11:08:37.637194',NULL,NULL,NULL,NULL,'4567','','43578','','',NULL,'',NULL,'Test','Test',NULL,NULL,'Test','Test',5,10,10,20,234,55,56,76,'Testttt',4),(5,'2023-09-26 08:00:27.019417',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,5),(6,'2023-09-27 09:36:25.300855',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,6),(7,'2023-10-06 11:19:28.588043',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,7),(8,'2023-10-06 12:26:35.058727',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,8),(9,'2023-10-06 12:27:05.958227',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,9),(10,'2023-10-06 12:28:25.863375',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,10),(11,'2023-10-07 10:07:00.036944',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,11),(12,'2023-10-07 10:07:01.839359',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,12),(13,'2023-10-07 18:16:44.408756',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,13),(14,'2023-10-27 13:24:47.857063',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,14),(15,'2023-10-27 13:39:06.938618',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,15),(16,'2023-10-29 20:55:40.162883',NULL,NULL,NULL,0,'245777',NULL,'334678',NULL,'Tutaj',NULL,'Tutaj',NULL,'Normalny','Tam',NULL,NULL,'Hdjdjdjjs',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,16),(17,'2023-11-06 11:33:55.958171',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,17),(19,'2023-11-16 10:14:49.733881',NULL,2,3,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,19),(23,'2023-11-17 16:42:38.570348',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,23),(24,'2023-11-23 09:28:36.312571',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,24),(25,'2023-11-27 21:11:05.557341',NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,25),(26,'2023-12-05 15:46:09.046440',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,26),(27,'2023-12-06 12:27:31.758010',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,27),(28,'2023-12-06 12:27:45.734376',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,28);
/*!40000 ALTER TABLE `klima_montaz` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `klima_montaz_devices_multi_split`
--

DROP TABLE IF EXISTS `klima_montaz_devices_multi_split`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `klima_montaz_devices_multi_split` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `montaz_id` bigint NOT NULL,
  `devicemultisplit_id` bigint NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `klima_montaz_devices_mul_montaz_id_devicemultispl_14c31ef1_uniq` (`montaz_id`,`devicemultisplit_id`),
  KEY `klima_montaz_devices_devicemultisplit_id_14a512cf_fk_klima_dev` (`devicemultisplit_id`),
  CONSTRAINT `klima_montaz_devices_devicemultisplit_id_14a512cf_fk_klima_dev` FOREIGN KEY (`devicemultisplit_id`) REFERENCES `klima_devicemultisplit` (`id`),
  CONSTRAINT `klima_montaz_devices_montaz_id_036690fb_fk_klima_mon` FOREIGN KEY (`montaz_id`) REFERENCES `klima_montaz` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `klima_montaz_devices_multi_split`
--

LOCK TABLES `klima_montaz_devices_multi_split` WRITE;
/*!40000 ALTER TABLE `klima_montaz_devices_multi_split` DISABLE KEYS */;
/*!40000 ALTER TABLE `klima_montaz_devices_multi_split` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `klima_montaz_devices_split`
--

DROP TABLE IF EXISTS `klima_montaz_devices_split`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `klima_montaz_devices_split` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `montaz_id` bigint NOT NULL,
  `devicesplit_id` bigint NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `klima_montaz_devices_spl_montaz_id_devicesplit_id_d145faa7_uniq` (`montaz_id`,`devicesplit_id`),
  KEY `klima_montaz_devices_devicesplit_id_4068ceed_fk_klima_dev` (`devicesplit_id`),
  CONSTRAINT `klima_montaz_devices_devicesplit_id_4068ceed_fk_klima_dev` FOREIGN KEY (`devicesplit_id`) REFERENCES `klima_devicesplit` (`id`),
  CONSTRAINT `klima_montaz_devices_split_montaz_id_f7ddb651_fk_klima_montaz_id` FOREIGN KEY (`montaz_id`) REFERENCES `klima_montaz` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `klima_montaz_devices_split`
--

LOCK TABLES `klima_montaz_devices_split` WRITE;
/*!40000 ALTER TABLE `klima_montaz_devices_split` DISABLE KEYS */;
/*!40000 ALTER TABLE `klima_montaz_devices_split` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `klima_narzut`
--

DROP TABLE IF EXISTS `klima_narzut`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `klima_narzut` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `value` double NOT NULL,
  `created_date` datetime(6) NOT NULL,
  `owner_id` bigint NOT NULL,
  `order` int unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `klima_narzut_owner_id_bbcae5e7_fk_klima_acuser_id` (`owner_id`),
  CONSTRAINT `klima_narzut_owner_id_bbcae5e7_fk_klima_acuser_id` FOREIGN KEY (`owner_id`) REFERENCES `klima_acuser` (`id`),
  CONSTRAINT `klima_narzut_chk_1` CHECK ((`order` >= 0))
) ENGINE=InnoDB AUTO_INCREMENT=34 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `klima_narzut`
--

LOCK TABLES `klima_narzut` WRITE;
/*!40000 ALTER TABLE `klima_narzut` DISABLE KEYS */;
INSERT INTO `klima_narzut` VALUES (24,'Test',466,'2023-11-21 09:28:44.333057',3,5),(29,'Testttt',1097,'2023-11-21 13:07:32.295482',3,1),(30,'Nowy',12345,'2023-11-21 13:08:47.501253',3,2),(32,'Testowy kk',222,'2023-11-21 13:19:02.201326',3,3),(33,'Że',69,'2023-11-23 09:23:14.258154',3,4);
/*!40000 ALTER TABLE `klima_narzut` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `klima_oferta`
--

DROP TABLE IF EXISTS `klima_oferta`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `klima_oferta` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `is_accepted` tinyint(1) NOT NULL,
  `offer_type` varchar(255) NOT NULL,
  `creator_id` bigint NOT NULL,
  `instalacja_id` bigint NOT NULL,
  PRIMARY KEY (`id`),
  KEY `klima_oferta_creator_id_4f737db6_fk_klima_acuser_id` (`creator_id`),
  KEY `klima_oferta_instalacja_id_ad0a16a6_fk_klima_instalacja_id` (`instalacja_id`),
  CONSTRAINT `klima_oferta_creator_id_4f737db6_fk_klima_acuser_id` FOREIGN KEY (`creator_id`) REFERENCES `klima_acuser` (`id`),
  CONSTRAINT `klima_oferta_instalacja_id_ad0a16a6_fk_klima_instalacja_id` FOREIGN KEY (`instalacja_id`) REFERENCES `klima_instalacja` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `klima_oferta`
--

LOCK TABLES `klima_oferta` WRITE;
/*!40000 ALTER TABLE `klima_oferta` DISABLE KEYS */;
INSERT INTO `klima_oferta` VALUES (18,0,'split',3,14),(19,0,'split',3,5);
/*!40000 ALTER TABLE `klima_oferta` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `klima_oferta_devices_multi_split`
--

DROP TABLE IF EXISTS `klima_oferta_devices_multi_split`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `klima_oferta_devices_multi_split` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `oferta_id` bigint NOT NULL,
  `devicemultisplit_id` bigint NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `klima_oferta_devices_mul_oferta_id_devicemultispl_e0420d73_uniq` (`oferta_id`,`devicemultisplit_id`),
  KEY `klima_oferta_devices_devicemultisplit_id_3a7787e0_fk_klima_dev` (`devicemultisplit_id`),
  CONSTRAINT `klima_oferta_devices_devicemultisplit_id_3a7787e0_fk_klima_dev` FOREIGN KEY (`devicemultisplit_id`) REFERENCES `klima_devicemultisplit` (`id`),
  CONSTRAINT `klima_oferta_devices_oferta_id_3a64dab0_fk_klima_ofe` FOREIGN KEY (`oferta_id`) REFERENCES `klima_oferta` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `klima_oferta_devices_multi_split`
--

LOCK TABLES `klima_oferta_devices_multi_split` WRITE;
/*!40000 ALTER TABLE `klima_oferta_devices_multi_split` DISABLE KEYS */;
/*!40000 ALTER TABLE `klima_oferta_devices_multi_split` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `klima_oferta_devices_split`
--

DROP TABLE IF EXISTS `klima_oferta_devices_split`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `klima_oferta_devices_split` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `oferta_id` bigint NOT NULL,
  `devicesplit_id` bigint NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `klima_oferta_devices_spl_oferta_id_devicesplit_id_b36fe3b2_uniq` (`oferta_id`,`devicesplit_id`),
  KEY `klima_oferta_devices_devicesplit_id_bf033344_fk_klima_dev` (`devicesplit_id`),
  CONSTRAINT `klima_oferta_devices_devicesplit_id_bf033344_fk_klima_dev` FOREIGN KEY (`devicesplit_id`) REFERENCES `klima_devicesplit` (`id`),
  CONSTRAINT `klima_oferta_devices_split_oferta_id_932853db_fk_klima_oferta_id` FOREIGN KEY (`oferta_id`) REFERENCES `klima_oferta` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=41 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `klima_oferta_devices_split`
--

LOCK TABLES `klima_oferta_devices_split` WRITE;
/*!40000 ALTER TABLE `klima_oferta_devices_split` DISABLE KEYS */;
INSERT INTO `klima_oferta_devices_split` VALUES (37,18,1),(38,18,2),(39,19,178),(40,19,179);
/*!40000 ALTER TABLE `klima_oferta_devices_split` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `klima_oferta_narzut`
--

DROP TABLE IF EXISTS `klima_oferta_narzut`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `klima_oferta_narzut` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `oferta_id` bigint NOT NULL,
  `narzut_id` bigint NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `klima_oferta_narzut_oferta_id_narzut_id_12178fe4_uniq` (`oferta_id`,`narzut_id`),
  KEY `klima_oferta_narzut_narzut_id_1d09652a_fk_klima_narzut_id` (`narzut_id`),
  CONSTRAINT `klima_oferta_narzut_narzut_id_1d09652a_fk_klima_narzut_id` FOREIGN KEY (`narzut_id`) REFERENCES `klima_narzut` (`id`),
  CONSTRAINT `klima_oferta_narzut_oferta_id_3c8b4f3a_fk_klima_oferta_id` FOREIGN KEY (`oferta_id`) REFERENCES `klima_oferta` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `klima_oferta_narzut`
--

LOCK TABLES `klima_oferta_narzut` WRITE;
/*!40000 ALTER TABLE `klima_oferta_narzut` DISABLE KEYS */;
INSERT INTO `klima_oferta_narzut` VALUES (7,18,32),(8,19,30);
/*!40000 ALTER TABLE `klima_oferta_narzut` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `klima_oferta_rabat`
--

DROP TABLE IF EXISTS `klima_oferta_rabat`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `klima_oferta_rabat` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `oferta_id` bigint NOT NULL,
  `rabat_id` bigint NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `klima_oferta_rabat_oferta_id_rabat_id_175e5c90_uniq` (`oferta_id`,`rabat_id`),
  KEY `klima_oferta_rabat_rabat_id_990cc78d_fk_klima_rabat_id` (`rabat_id`),
  CONSTRAINT `klima_oferta_rabat_oferta_id_c561256a_fk_klima_oferta_id` FOREIGN KEY (`oferta_id`) REFERENCES `klima_oferta` (`id`),
  CONSTRAINT `klima_oferta_rabat_rabat_id_990cc78d_fk_klima_rabat_id` FOREIGN KEY (`rabat_id`) REFERENCES `klima_rabat` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `klima_oferta_rabat`
--

LOCK TABLES `klima_oferta_rabat` WRITE;
/*!40000 ALTER TABLE `klima_oferta_rabat` DISABLE KEYS */;
/*!40000 ALTER TABLE `klima_oferta_rabat` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `klima_photo`
--

DROP TABLE IF EXISTS `klima_photo`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `klima_photo` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `instalacja` int unsigned DEFAULT NULL,
  `serwis` int unsigned DEFAULT NULL,
  `montaz` int unsigned DEFAULT NULL,
  `image` varchar(100) NOT NULL,
  `klient_id` bigint NOT NULL,
  `owner_id` bigint NOT NULL,
  PRIMARY KEY (`id`),
  KEY `klima_photo_klient_id_f2e6fd26_fk_klima_acuser_id` (`klient_id`),
  KEY `klima_photo_owner_id_29840f81_fk_klima_acuser_id` (`owner_id`),
  CONSTRAINT `klima_photo_klient_id_f2e6fd26_fk_klima_acuser_id` FOREIGN KEY (`klient_id`) REFERENCES `klima_acuser` (`id`),
  CONSTRAINT `klima_photo_owner_id_29840f81_fk_klima_acuser_id` FOREIGN KEY (`owner_id`) REFERENCES `klima_acuser` (`id`),
  CONSTRAINT `klima_photo_chk_1` CHECK ((`instalacja` >= 0)),
  CONSTRAINT `klima_photo_chk_2` CHECK ((`serwis` >= 0)),
  CONSTRAINT `klima_photo_chk_3` CHECK ((`montaz` >= 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `klima_photo`
--

LOCK TABLES `klima_photo` WRITE;
/*!40000 ALTER TABLE `klima_photo` DISABLE KEYS */;
/*!40000 ALTER TABLE `klima_photo` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `klima_photo_tags`
--

DROP TABLE IF EXISTS `klima_photo_tags`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `klima_photo_tags` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `photo_id` bigint NOT NULL,
  `tag_id` bigint NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `klima_photo_tags_photo_id_tag_id_04462fb4_uniq` (`photo_id`,`tag_id`),
  KEY `klima_photo_tags_tag_id_85e93676_fk_klima_tag_id` (`tag_id`),
  CONSTRAINT `klima_photo_tags_photo_id_8505c930_fk_klima_photo_id` FOREIGN KEY (`photo_id`) REFERENCES `klima_photo` (`id`),
  CONSTRAINT `klima_photo_tags_tag_id_85e93676_fk_klima_tag_id` FOREIGN KEY (`tag_id`) REFERENCES `klima_tag` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `klima_photo_tags`
--

LOCK TABLES `klima_photo_tags` WRITE;
/*!40000 ALTER TABLE `klima_photo_tags` DISABLE KEYS */;
/*!40000 ALTER TABLE `klima_photo_tags` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `klima_rabat`
--

DROP TABLE IF EXISTS `klima_rabat`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `klima_rabat` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `producent` varchar(255) NOT NULL,
  `value` double NOT NULL,
  `created_date` datetime(6) NOT NULL,
  `owner_id` bigint NOT NULL,
  PRIMARY KEY (`id`),
  KEY `klima_rabat_owner_id_e7d20fad_fk_klima_acuser_id` (`owner_id`),
  CONSTRAINT `klima_rabat_owner_id_e7d20fad_fk_klima_acuser_id` FOREIGN KEY (`owner_id`) REFERENCES `klima_acuser` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `klima_rabat`
--

LOCK TABLES `klima_rabat` WRITE;
/*!40000 ALTER TABLE `klima_rabat` DISABLE KEYS */;
INSERT INTO `klima_rabat` VALUES (4,'Rotenso',25,'2023-10-02 10:19:54.854337',3),(5,'LG',13,'2023-11-20 16:04:24.357689',3),(6,'AUX',13,'2023-11-20 16:16:07.588975',3),(7,'Rotenso',10,'2023-11-20 17:49:37.529219',3),(8,'Toshiba',5,'2023-11-23 09:24:02.809929',3);
/*!40000 ALTER TABLE `klima_rabat` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `klima_serwis`
--

DROP TABLE IF EXISTS `klima_serwis`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `klima_serwis` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `created_date` datetime(6) NOT NULL,
  `instalacja_id` bigint NOT NULL,
  `czyszczenie_filtrow_jedn_wew` tinyint(1) DEFAULT NULL,
  `czyszczenie_obudowy_jedn_wew` tinyint(1) DEFAULT NULL,
  `czyszczenie_obudowy_jedn_zew` tinyint(1) DEFAULT NULL,
  `czyszczenie_tacy_skroplin` tinyint(1) DEFAULT NULL,
  `czyszczenie_wymiennika_ciepla_wew` tinyint(1) DEFAULT NULL,
  `czyszczenie_wymiennika_ciepla_zew` tinyint(1) DEFAULT NULL,
  `data_montazu` datetime(6) DEFAULT NULL,
  `data_przegladu` datetime(6) DEFAULT NULL,
  `diagnostyka_awari` tinyint(1) DEFAULT NULL,
  `dlugosc_gwarancji` int DEFAULT NULL,
  `kontrola_droznosci_skroplin` tinyint(1) DEFAULT NULL,
  `kontrola_poprawnosci_dzialania` tinyint(1) DEFAULT NULL,
  `kontrola_stanu_jedn_wew` tinyint(1) DEFAULT NULL,
  `kontrola_stanu_jedn_zew` tinyint(1) DEFAULT NULL,
  `kontrola_stanu_mocowania_agregatu` tinyint(1) DEFAULT NULL,
  `kontrola_szczelnosci` tinyint(1) DEFAULT NULL,
  `kontrola_temperatury_nawiewu_wew` tinyint(1) DEFAULT NULL,
  `liczba_przegladow_rok` int DEFAULT NULL,
  `uwagi` longtext,
  PRIMARY KEY (`id`),
  KEY `klima_serwis_instalacja_id_818a22a8_fk_klima_instalacja_id` (`instalacja_id`),
  CONSTRAINT `klima_serwis_instalacja_id_818a22a8_fk_klima_instalacja_id` FOREIGN KEY (`instalacja_id`) REFERENCES `klima_instalacja` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=29 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `klima_serwis`
--

LOCK TABLES `klima_serwis` WRITE;
/*!40000 ALTER TABLE `klima_serwis` DISABLE KEYS */;
INSERT INTO `klima_serwis` VALUES (1,'2023-09-21 19:55:44.622353',1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(3,'2023-09-21 19:56:01.655120',3,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(4,'2023-09-24 11:08:37.639383',4,0,0,0,0,0,0,'2023-09-27 13:00:13.384000',NULL,0,NULL,0,0,0,0,0,0,0,NULL,'Testtt'),(5,'2023-09-26 08:00:27.022819',5,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(6,'2023-09-27 09:36:25.303489',6,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(7,'2023-10-06 11:19:28.596349',7,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(8,'2023-10-06 12:26:35.060815',8,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(9,'2023-10-06 12:27:05.961192',9,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(10,'2023-10-06 12:28:25.866652',10,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(11,'2023-10-07 10:07:00.039767',11,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(12,'2023-10-07 10:07:01.844524',12,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(13,'2023-10-07 18:16:44.411049',13,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(14,'2023-10-27 13:24:47.859844',14,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(15,'2023-10-27 13:39:06.945902',15,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(16,'2023-10-29 20:55:40.166256',16,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(17,'2023-11-06 11:33:55.960501',17,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(19,'2023-11-16 10:14:49.737655',19,NULL,NULL,NULL,NULL,NULL,NULL,'2023-11-20 10:47:51.959000',NULL,NULL,NULL,NULL,NULL,1,1,NULL,NULL,NULL,NULL,NULL),(23,'2023-11-17 16:42:38.573813',23,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(24,'2023-11-23 09:28:36.316124',24,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(25,'2023-11-27 21:11:05.559989',25,1,1,1,1,1,1,'2023-11-16 22:50:00.075000',NULL,1,NULL,1,1,1,1,1,1,1,NULL,'Jakieś uwagi'),(26,'2023-12-05 15:46:09.050120',26,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(27,'2023-12-06 12:27:31.759979',27,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(28,'2023-12-06 12:27:45.736777',28,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
/*!40000 ALTER TABLE `klima_serwis` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `klima_szablon`
--

DROP TABLE IF EXISTS `klima_szablon`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `klima_szablon` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `nazwa` varchar(255) NOT NULL,
  `typ` varchar(10) NOT NULL,
  `owner_id` bigint NOT NULL,
  PRIMARY KEY (`id`),
  KEY `klima_szablon_owner_id_08b48d59_fk_klima_acuser_id` (`owner_id`),
  CONSTRAINT `klima_szablon_owner_id_08b48d59_fk_klima_acuser_id` FOREIGN KEY (`owner_id`) REFERENCES `klima_acuser` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `klima_szablon`
--

LOCK TABLES `klima_szablon` WRITE;
/*!40000 ALTER TABLE `klima_szablon` DISABLE KEYS */;
INSERT INTO `klima_szablon` VALUES (5,'Testowy','split',3),(6,'Szablon 2 test','split',3);
/*!40000 ALTER TABLE `klima_szablon` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `klima_szablon_devices_multisplit`
--

DROP TABLE IF EXISTS `klima_szablon_devices_multisplit`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `klima_szablon_devices_multisplit` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `szablon_id` bigint NOT NULL,
  `devicemultisplit_id` bigint NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `klima_szablon_devices_mu_szablon_id_devicemultisp_0e3146d1_uniq` (`szablon_id`,`devicemultisplit_id`),
  KEY `klima_szablon_device_devicemultisplit_id_a31dd410_fk_klima_dev` (`devicemultisplit_id`),
  CONSTRAINT `klima_szablon_device_devicemultisplit_id_a31dd410_fk_klima_dev` FOREIGN KEY (`devicemultisplit_id`) REFERENCES `klima_devicemultisplit` (`id`),
  CONSTRAINT `klima_szablon_device_szablon_id_e3cc8268_fk_klima_sza` FOREIGN KEY (`szablon_id`) REFERENCES `klima_szablon` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `klima_szablon_devices_multisplit`
--

LOCK TABLES `klima_szablon_devices_multisplit` WRITE;
/*!40000 ALTER TABLE `klima_szablon_devices_multisplit` DISABLE KEYS */;
/*!40000 ALTER TABLE `klima_szablon_devices_multisplit` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `klima_szablon_devices_split`
--

DROP TABLE IF EXISTS `klima_szablon_devices_split`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `klima_szablon_devices_split` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `szablon_id` bigint NOT NULL,
  `devicesplit_id` bigint NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `klima_szablon_devices_sp_szablon_id_devicesplit_i_cabd11e3_uniq` (`szablon_id`,`devicesplit_id`),
  KEY `klima_szablon_device_devicesplit_id_2967b0dd_fk_klima_dev` (`devicesplit_id`),
  CONSTRAINT `klima_szablon_device_devicesplit_id_2967b0dd_fk_klima_dev` FOREIGN KEY (`devicesplit_id`) REFERENCES `klima_devicesplit` (`id`),
  CONSTRAINT `klima_szablon_device_szablon_id_6899c697_fk_klima_sza` FOREIGN KEY (`szablon_id`) REFERENCES `klima_szablon` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `klima_szablon_devices_split`
--

LOCK TABLES `klima_szablon_devices_split` WRITE;
/*!40000 ALTER TABLE `klima_szablon_devices_split` DISABLE KEYS */;
INSERT INTO `klima_szablon_devices_split` VALUES (8,5,1),(9,5,2),(10,6,178),(11,6,179);
/*!40000 ALTER TABLE `klima_szablon_devices_split` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `klima_szablon_narzuty`
--

DROP TABLE IF EXISTS `klima_szablon_narzuty`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `klima_szablon_narzuty` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `szablon_id` bigint NOT NULL,
  `narzut_id` bigint NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `klima_szablon_narzuty_szablon_id_narzut_id_a34b9816_uniq` (`szablon_id`,`narzut_id`),
  KEY `klima_szablon_narzuty_narzut_id_2035dc4b_fk_klima_narzut_id` (`narzut_id`),
  CONSTRAINT `klima_szablon_narzuty_narzut_id_2035dc4b_fk_klima_narzut_id` FOREIGN KEY (`narzut_id`) REFERENCES `klima_narzut` (`id`),
  CONSTRAINT `klima_szablon_narzuty_szablon_id_98a11379_fk_klima_szablon_id` FOREIGN KEY (`szablon_id`) REFERENCES `klima_szablon` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `klima_szablon_narzuty`
--

LOCK TABLES `klima_szablon_narzuty` WRITE;
/*!40000 ALTER TABLE `klima_szablon_narzuty` DISABLE KEYS */;
INSERT INTO `klima_szablon_narzuty` VALUES (6,5,32),(7,6,30);
/*!40000 ALTER TABLE `klima_szablon_narzuty` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `klima_szkolenie`
--

DROP TABLE IF EXISTS `klima_szkolenie`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `klima_szkolenie` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `file` varchar(100) NOT NULL,
  `created_date` datetime(6) NOT NULL,
  `set_date` datetime(6) NOT NULL,
  `ac_user_id` bigint NOT NULL,
  PRIMARY KEY (`id`),
  KEY `klima_szkolenie_ac_user_id_0ca33fb6_fk_klima_acuser_id` (`ac_user_id`),
  CONSTRAINT `klima_szkolenie_ac_user_id_0ca33fb6_fk_klima_acuser_id` FOREIGN KEY (`ac_user_id`) REFERENCES `klima_acuser` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `klima_szkolenie`
--

LOCK TABLES `klima_szkolenie` WRITE;
/*!40000 ALTER TABLE `klima_szkolenie` DISABLE KEYS */;
INSERT INTO `klima_szkolenie` VALUES (2,'Szkolenie2','documents/szkolenia/3/sample_WptiNGl.pdf','2023-09-21 11:35:55.013874','2023-09-21 11:35:48.020000',3),(3,'Szkolenie123','documents/szkolenia/3/sample_L3RIrb3.pdf','2023-09-21 11:41:47.313734','2023-09-21 11:41:00.531000',3);
/*!40000 ALTER TABLE `klima_szkolenie` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `klima_tag`
--

DROP TABLE IF EXISTS `klima_tag`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `klima_tag` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `created_date` datetime(6) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `klima_tag`
--

LOCK TABLES `klima_tag` WRITE;
/*!40000 ALTER TABLE `klima_tag` DISABLE KEYS */;
/*!40000 ALTER TABLE `klima_tag` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `klima_task`
--

DROP TABLE IF EXISTS `klima_task`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `klima_task` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `start_date` datetime(6) NOT NULL,
  `end_date` datetime(6) NOT NULL,
  `name` varchar(100) NOT NULL,
  `task_type` varchar(20) NOT NULL,
  `status` varchar(20) NOT NULL,
  `assigned_monter_id` bigint NOT NULL,
  PRIMARY KEY (`id`),
  KEY `klima_task_assigned_monter_id_22051ce6_fk_klima_acuser_id` (`assigned_monter_id`),
  CONSTRAINT `klima_task_assigned_monter_id_22051ce6_fk_klima_acuser_id` FOREIGN KEY (`assigned_monter_id`) REFERENCES `klima_acuser` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `klima_task`
--

LOCK TABLES `klima_task` WRITE;
/*!40000 ALTER TABLE `klima_task` DISABLE KEYS */;
/*!40000 ALTER TABLE `klima_task` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `klima_ulotka`
--

DROP TABLE IF EXISTS `klima_ulotka`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `klima_ulotka` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `file` varchar(100) NOT NULL,
  `created_date` datetime(6) NOT NULL,
  `is_active` tinyint(1) NOT NULL,
  `ac_user_id` bigint NOT NULL,
  PRIMARY KEY (`id`),
  KEY `klima_ulotka_ac_user_id_9893c004_fk_klima_acuser_id` (`ac_user_id`),
  CONSTRAINT `klima_ulotka_ac_user_id_9893c004_fk_klima_acuser_id` FOREIGN KEY (`ac_user_id`) REFERENCES `klima_acuser` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `klima_ulotka`
--

LOCK TABLES `klima_ulotka` WRITE;
/*!40000 ALTER TABLE `klima_ulotka` DISABLE KEYS */;
INSERT INTO `klima_ulotka` VALUES (3,'Ulotka test','documents/ulotka/3/sample_LOAC6Au.pdf','2023-10-05 11:20:54.598149',1,3),(5,'Testttt','documents/ulotka/3/sample_y5g947w_2oNfh8Z.pdf','2023-12-04 11:06:20.276299',1,3);
/*!40000 ALTER TABLE `klima_ulotka` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `klima_userdata`
--

DROP TABLE IF EXISTS `klima_userdata`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `klima_userdata` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `rodzaj_klienta` varchar(20) NOT NULL,
  `nazwa_firmy` varchar(100) DEFAULT NULL,
  `nip` varchar(15) DEFAULT NULL,
  `typ_klienta` varchar(20) NOT NULL,
  `ulica` varchar(100) DEFAULT NULL,
  `kod_pocztowy` varchar(10) DEFAULT NULL,
  `miasto` varchar(100) DEFAULT NULL,
  `numer_telefonu` varchar(20) DEFAULT NULL,
  `longitude` double DEFAULT NULL,
  `latitude` double DEFAULT NULL,
  `ac_user_id` bigint NOT NULL,
  `mieszkanie` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ac_user_id` (`ac_user_id`),
  CONSTRAINT `klima_userdata_ac_user_id_6b2c7a9d_fk_klima_acuser_id` FOREIGN KEY (`ac_user_id`) REFERENCES `klima_acuser` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=37 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `klima_userdata`
--

LOCK TABLES `klima_userdata` WRITE;
/*!40000 ALTER TABLE `klima_userdata` DISABLE KEYS */;
INSERT INTO `klima_userdata` VALUES (1,'firma','Grzybki industries ','6793185522','aktualny','krakowska','54-654','Vfghjbbh','435435456',NULL,NULL,3,NULL),(2,'firma','','','aktualny','krakowska','','','',NULL,NULL,4,NULL),(3,'firma','','','aktualny','Vcfjj','65-787','Wwa','678655786',-77.0364,38.8951,5,NULL),(4,'firma','Dhshbababa','9721290748','aktualny','Fraszki 25','02-406','Warszawa','666555444',19.921473,50.058157,6,'35'),(5,'firma','','','aktualny','Ulica','01-100','Warszawa','666555444',NULL,NULL,7,NULL),(6,'firma','','','aktualny','Fraszki','02-406','Warszawa','666555666',19.921473,50.058157,8,NULL),(8,'firma','Ftyhjhcdr','1234567890','aktualny','Vfgujbg','54-678','Vcfghjbbv','345765775',21.077973,0.5,10,NULL),(9,'firma','Dhshajhs','5261727123','aktualny','Fhshchjaha','65-700','Co shjsjaj','465746847',21.077973,52.211119,11,NULL),(13,'firma','Xhsbjaba','1234567890','aktualny','Fhajbzbsba','65-756','Dhsbjan','354625345',0.5,0.7,16,NULL),(14,'firma','','','aktualny','','','','',0.5,0.6,17,NULL),(15,'firma','','','aktualny','','','','',0.5,0.6,18,NULL),(16,'firma','','','aktualny','','','','',0.5,0.6,19,NULL),(17,'firma','Dhshbaba','1234567890','aktualny','Xbshhajan','54-659','Dbbabab','',0.6,0.7,20,NULL),(18,'firma',NULL,NULL,'aktualny',NULL,NULL,NULL,NULL,NULL,NULL,22,NULL),(19,'firma',NULL,NULL,'aktualny',NULL,NULL,NULL,NULL,NULL,NULL,23,NULL),(20,'firma',NULL,NULL,'aktualny',NULL,NULL,NULL,NULL,NULL,NULL,24,NULL),(21,'firma',NULL,NULL,'aktualny',NULL,NULL,NULL,NULL,NULL,NULL,25,NULL),(22,'firma',NULL,NULL,'aktualny','Łódzka','37-638','Olsztyn','997998112',NULL,NULL,26,NULL),(23,'firma',NULL,NULL,'aktualny','Herbu Janina 5','02-455','Warszawa','345666777',0,0,27,NULL),(25,'firma',NULL,NULL,'aktualny',NULL,'','','',NULL,NULL,29,NULL),(28,'firma','Hfahjsjs','2645363721','aktualny','Jakaś / 7','45-376','Smth','354635276',NULL,NULL,43,'10'),(29,'firma',NULL,NULL,'aktualny','Żeglarska 5','87-100','Toruń','001001001',18.6051881,53.0101729,44,'10'),(30,'firma',NULL,NULL,'aktualny','Żeglarska 5','87-100','Toruń','000000090',18.605688130459185,53.00863835,45,'10'),(31,'firma',NULL,NULL,'aktualny',NULL,'60-362','Dżihad ','675849302',NULL,NULL,46,NULL),(32,'firma',NULL,NULL,'aktualny','29','25-268','Kaiek','234875829',NULL,NULL,47,'10'),(33,'firma',NULL,NULL,'aktualny',NULL,'46-382','Fhsjjqks','274628648',NULL,NULL,48,NULL),(34,'firma',NULL,NULL,'aktualny','Hajfusuajjw 5','64-736','Fjjajsjd','123456789',NULL,NULL,49,NULL),(35,'osoba',NULL,NULL,'aktualny','Reymonta 11','05-070','Sulejówek','555666777',21.28959533235372,52.24487925,50,NULL),(36,'firma','Winnik','6557654323','aktualny','Kordeckiego 60','04-355','Warszawa','654654654',21.09501598770018,52.24506505,51,'20');
/*!40000 ALTER TABLE `klima_userdata` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `klima_zadanie`
--

DROP TABLE IF EXISTS `klima_zadanie`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `klima_zadanie` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `status` varchar(20) NOT NULL,
  `nazwa` varchar(255) NOT NULL,
  `start_date` datetime(6) NOT NULL,
  `end_date` datetime(6) NOT NULL,
  `czy_oferta` tinyint(1) NOT NULL,
  `czy_faktura` tinyint(1) NOT NULL,
  `typ` varchar(20) NOT NULL,
  `grupa_id` bigint DEFAULT NULL,
  `rodzic_id` bigint NOT NULL,
  `instalacja_id` bigint DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `klima_zadanie_rodzic_id_37543160_fk_klima_acuser_id` (`rodzic_id`),
  KEY `klima_zadanie_instalacja_id_4cc558c0_fk_klima_instalacja_id` (`instalacja_id`),
  KEY `klima_zadanie_grupa_id_b9e8b9bb_fk_klima_group_id` (`grupa_id`),
  CONSTRAINT `klima_zadanie_grupa_id_b9e8b9bb_fk_klima_group_id` FOREIGN KEY (`grupa_id`) REFERENCES `klima_group` (`id`),
  CONSTRAINT `klima_zadanie_instalacja_id_4cc558c0_fk_klima_instalacja_id` FOREIGN KEY (`instalacja_id`) REFERENCES `klima_instalacja` (`id`),
  CONSTRAINT `klima_zadanie_rodzic_id_37543160_fk_klima_acuser_id` FOREIGN KEY (`rodzic_id`) REFERENCES `klima_acuser` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `klima_zadanie`
--

LOCK TABLES `klima_zadanie` WRITE;
/*!40000 ALTER TABLE `klima_zadanie` DISABLE KEYS */;
INSERT INTO `klima_zadanie` VALUES (8,'wykonane','Montaż fraszki','2023-10-31 07:00:05.332000','2023-10-31 07:00:05.332000',0,0,'montaż',1,3,NULL),(9,'niewykonane','Montaz','2023-11-16 07:00:01.645000','2023-11-16 07:00:01.645000',0,0,'montaż',1,3,NULL),(10,'wykonane','Hfhshsjaj','2023-11-03 12:46:12.851000','2023-11-03 12:46:12.851000',0,0,'szkolenie',2,3,NULL),(11,'niewykonane','Montaż Fraszki','2023-11-13 07:00:02.044000','2023-11-13 07:00:02.044000',0,0,'montaż',NULL,3,NULL),(12,'niewykonane','Gaga’sjja','2023-11-13 14:55:08.436000','2023-11-13 14:55:08.436000',0,0,'szkolenie',2,3,NULL),(13,'niewykonane','Gaga’sjja','2023-11-13 14:55:08.436000','2023-11-13 14:55:08.436000',0,0,'szkolenie',2,3,NULL),(14,'niewykonane','Test oględziny','2023-11-14 09:54:29.380000','2023-11-14 09:54:29.380000',0,0,'oględziny',2,3,NULL),(16,'wykonane','Test','2023-11-17 16:41:38.987000','2023-11-17 16:41:38.987000',0,0,'szkolenie',2,3,NULL),(17,'niewykonane','TestIOS','2023-11-20 10:19:07.868000','2023-11-20 10:19:07.868000',0,0,'szkolenie',1,3,NULL),(18,'niewykonane','Montaż Fraszki','2023-11-22 07:00:15.844000','2023-11-22 07:00:15.844000',0,0,'montaż',NULL,3,NULL),(20,'niewykonane','Testtttt','2023-11-21 13:47:56.791000','2023-11-21 13:47:56.791000',0,0,'szkolenie',1,3,NULL),(22,'niewykonane','Shjwwb','2023-12-05 14:13:59.282000','2023-12-05 14:13:59.282000',0,0,'szkolenie',2,3,NULL);
/*!40000 ALTER TABLE `klima_zadanie` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2024-02-13  8:56:40
