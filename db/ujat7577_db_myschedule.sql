-- phpMyAdmin SQL Dump
-- version 5.2.2
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Jan 22, 2026 at 10:07 PM
-- Server version: 11.4.9-MariaDB-cll-lve
-- PHP Version: 8.4.16

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `ujat7577_db_myschedule`
--

-- --------------------------------------------------------

--
-- Table structure for table `articles`
--

CREATE TABLE `articles` (
  `id_article` int(11) NOT NULL,
  `title` varchar(255) NOT NULL,
  `content` text NOT NULL,
  `image_url` varchar(900) NOT NULL,
  `id_user` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `articles`
--

INSERT INTO `articles` (`id_article`, `title`, `content`, `image_url`, `id_user`) VALUES
(1, 'Ngoding Vibe', 'Asik nih ngopi di tempat ini sembari ngoding', 'article_1_1768972617.jpg', 1),
(4, 'Jalan-Jalan', 'Ayoo coba jalan kesini. Aku lagi di Bandungggg asiiiikkkkk', 'article_3_1768975944.jpg', 3),
(5, 'Olahraga Dullsss', 'Lari Pagi di GBK, lumayan rame yah. LOL', 'article_4_1768979489.jpg', 4),
(6, 'Perkenalan', 'HALOOO maaf ya saya baru upload, tapi saya disini adalah admin disini. Salam kenal yahhh :>', 'article_5_1768979758.jpg', 5),
(7, 'asas', 'asa', 'article_6_1769092374.jpg', 6);

-- --------------------------------------------------------

--
-- Table structure for table `schedules`
--

CREATE TABLE `schedules` (
  `id_schedule` int(11) NOT NULL,
  `id_user` int(11) NOT NULL,
  `title` varchar(255) NOT NULL,
  `description` text NOT NULL,
  `datetime` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `schedules`
--

INSERT INTO `schedules` (`id_schedule`, `id_user`, `title`, `description`, `datetime`) VALUES
(16, 4, 'Workout Pagi', 'Leg Day', '2026-01-21 06:30:00'),
(17, 2, 'Lari', 'Marathon 40KM', '2026-01-28 09:00:00'),
(18, 3, 'Belajar', 'Belajar untuk UAS', '2026-01-21 19:30:00'),
(19, 3, 'Jalan-Jalan', 'Pergi Ke Bandung', '2026-01-31 10:00:00'),
(20, 1, 'Ngoding Date ', 'Ngoding Date di Starbucks Jakarta Utara', '2026-01-24 10:00:00');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id_user` int(11) NOT NULL,
  `username` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `full_name` varchar(255) NOT NULL,
  `profile_picture` varchar(255) DEFAULT NULL,
  `role` enum('admin','user') DEFAULT 'user'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id_user`, `username`, `password`, `full_name`, `profile_picture`, `role`) VALUES
(1, 'tommysatrio', '$2y$10$zrWbQj.gYXeAJS6fuPncI.jKWg2hrs0RMues5HVF0S8b50D/F2Dp2', 'Tommy Satrio Wicaksono', 'profile_1_1768971327.jpg', 'user'),
(2, 'riszki', '$2y$10$g4jlITTtev5nUEvivQvxre/tMzFL5BQ5hKsFGCeP51TrwvLy7YKZK', 'Riszki Fadillah', 'profile_2_1768911450.jpg', 'user'),
(3, 'iqbal', '$2y$10$vYSfkGeWUg74aJ95xilij.Zljq5K8h22KfIf8tzQf2R5gLKVDdzOq', 'Teuku Maulana Iqbal Khairy', 'profile_3_1768917629.jpg', 'user'),
(4, 'ihsan', '$2y$10$5iW3ODIsVTTAxrB0m8HCA.UC9HLVfrNu6RBApt1NCargw543s0q9O', 'Muhammad Ihsan Anafi ', 'profile_4_1768970799.jpg', 'user'),
(5, 'admin', '$2y$10$Jb1wvH5oZOsQwDIJaWtBB.54m4FzZS8.ufKNeCfHxCbZ7/j5HVluu', 'adminSGM', 'profile_5_1768979352.jpg', 'admin'),
(6, 'test', '$2y$10$H0chCLLuFcEt2Nry6EZbOu6L3aBLZfKNGsIJTFoS5kRC2QlM9z87.', 'test', NULL, 'user');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `articles`
--
ALTER TABLE `articles`
  ADD PRIMARY KEY (`id_article`),
  ADD UNIQUE KEY `user_id` (`id_user`);

--
-- Indexes for table `schedules`
--
ALTER TABLE `schedules`
  ADD PRIMARY KEY (`id_schedule`),
  ADD KEY `schedules_users` (`id_user`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id_user`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `articles`
--
ALTER TABLE `articles`
  MODIFY `id_article` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `schedules`
--
ALTER TABLE `schedules`
  MODIFY `id_schedule` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=22;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id_user` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `articles`
--
ALTER TABLE `articles`
  ADD CONSTRAINT `article_user` FOREIGN KEY (`id_user`) REFERENCES `users` (`id_user`) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Constraints for table `schedules`
--
ALTER TABLE `schedules`
  ADD CONSTRAINT `schedules_users` FOREIGN KEY (`id_user`) REFERENCES `users` (`id_user`) ON DELETE NO ACTION ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
