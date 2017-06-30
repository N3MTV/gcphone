ALTER TABLE `user_message`
	ADD COLUMN `phone_number` VARCHAR(10) NULL;

CREATE TABLE IF NOT EXISTS `phone_messages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `transmitter` varchar(10) NOT NULL,
  `receiver` varchar(10) NOT NULL,
  `message` varchar(255) NOT NULL DEFAULT '0',
  `time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `isRead` int(11) NOT NULL DEFAULT '0',
  `owner` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
);

CREATE TABLE IF NOT EXISTS `phone_users_contacts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `identifier` varchar(255) NOT NULL,
  `number` varchar(10) NOT NULL,
  `display` varchar(64) NOT NULL,
  PRIMARY KEY (`id`)
);



-- CONVERT
-- INSERT into phone_users_contacts ( identifier, number, display) 
-- (Select user_phonelist.owner_id , users.phone_number , CONCAT(users.prenom, ' ', users.nom)
-- from user_phonelist left join users on users.identifier = user_phonelist.contact_id)