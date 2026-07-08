-- YourMAPS FlagScript — persistent world flags
-- Run once on the server database (requires oxmysql).

CREATE TABLE IF NOT EXISTS `ym_flags_placed` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `char_id` VARCHAR(64) NOT NULL,
  `identifier` VARCHAR(64) DEFAULT NULL,
  `flag_type` VARCHAR(48) NOT NULL,
  `item_name` VARCHAR(64) NOT NULL,
  `x` DOUBLE NOT NULL,
  `y` DOUBLE NOT NULL,
  `z` DOUBLE NOT NULL,
  `heading` DOUBLE NOT NULL DEFAULT 0,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_char_id` (`char_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
