CREATE TABLE `twitter_accounts` (
	`id` INT(11) NOT NULL AUTO_INCREMENT,
	`avatar_url` VARCHAR(255) NULL DEFAULT NULL COLLATE 'utf8mb4_bin',
	PRIMARY KEY (`id`)
)
COLLATE='utf8mb4_bin'
ENGINE=InnoDB
AUTO_INCREMENT=1
;

CREATE TABLE `twitter_likes` (
	`id` INT(11) NOT NULL AUTO_INCREMENT,
	`authorId` INT(11) NULL DEFAULT NULL,
	`tweetId` INT(11) NULL DEFAULT NULL,
	PRIMARY KEY (`id`),
	INDEX `FK_twitter_likes_twitter_accounts` (`authorId`),
	INDEX `FK_twitter_likes_twitter_tweets` (`tweetId`),
	CONSTRAINT `FK_twitter_likes_twitter_accounts` FOREIGN KEY (`authorId`) REFERENCES `twitter_accounts` (`id`),
	CONSTRAINT `FK_twitter_likes_twitter_tweets` FOREIGN KEY (`tweetId`) REFERENCES `twitter_tweets` (`id`) ON DELETE CASCADE
)
COLLATE='utf8mb4_bin'
ENGINE=InnoDB
AUTO_INCREMENT=1
;

CREATE TABLE `twitter_tweets` (
	`id` INT(11) NOT NULL AUTO_INCREMENT,
	`authorId` INT(11) NOT NULL,
	`message` VARCHAR(256) NOT NULL COLLATE 'utf8mb4_unicode_ci',
	`time` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
	`likes` INT(11) NOT NULL DEFAULT '0',
	PRIMARY KEY (`id`),
	INDEX `FK_twitter_tweets_twitter_accounts` (`authorId`)
)
COLLATE='utf8mb4_unicode_ci'
ENGINE=InnoDB
AUTO_INCREMENT=1
;