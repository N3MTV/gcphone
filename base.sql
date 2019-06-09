CREATE TABLE `phone_app_chat` (
	`id` INT(11) NOT NULL AUTO_INCREMENT,
	`channel` VARCHAR(20) NOT NULL,
	`message` VARCHAR(255) NOT NULL,
	`time` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
	PRIMARY KEY (`id`)
)
COLLATE='utf8_general_ci'
ENGINE=InnoDB
AUTO_INCREMENT=1
;

CREATE TABLE `phone_calls` (
	`id` INT(11) NOT NULL AUTO_INCREMENT,
	`owner` VARCHAR(12) NOT NULL COMMENT 'Num tel proprio',
	`num` VARCHAR(12) NOT NULL COMMENT 'Num reférence du contact',
	`incoming` INT(11) NOT NULL COMMENT 'Défini si on est à l\'origine de l\'appels',
	`time` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
	`accepts` INT(11) NOT NULL COMMENT 'Appels accepter ou pas',
	PRIMARY KEY (`id`)
)
COLLATE='utf8_general_ci'
ENGINE=InnoDB
AUTO_INCREMENT=1
;

CREATE TABLE `phone_messages` (
	`id` INT(11) NOT NULL AUTO_INCREMENT,
	`transmitter` VARCHAR(12) NOT NULL,
	`receiver` VARCHAR(12) NOT NULL,
	`message` VARCHAR(255) NOT NULL DEFAULT '0',
	`time` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
	`isRead` INT(11) NOT NULL DEFAULT '0',
	`owner` INT(11) NOT NULL DEFAULT '0',
	PRIMARY KEY (`id`)
)
COLLATE='utf8_general_ci'
ENGINE=MyISAM
AUTO_INCREMENT=1
;

CREATE TABLE `phone_users_contacts` (
	`id` INT(11) NOT NULL AUTO_INCREMENT,
	`charid` INT(11) NULL DEFAULT NULL,
	`number` VARCHAR(12) NULL DEFAULT NULL COLLATE 'utf8mb4_0900_ai_ci',
	`display` VARCHAR(64) NOT NULL DEFAULT '-1' COLLATE 'utf8mb4_0900_ai_ci',
	PRIMARY KEY (`id`)
)
COLLATE='utf8_general_ci'
ENGINE=MyISAM
AUTO_INCREMENT=1
;
