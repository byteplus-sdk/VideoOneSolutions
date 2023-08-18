CREATE DATABASE IF NOT EXISTS `videoone`;

USE `videoone`;

DROP TABLE IF EXISTS `app_info`;
CREATE TABLE `app_info`
(
    `id`                bigint(20) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Primary key',
    `app_id`            varchar(32)         NOT NULL DEFAULT '' COMMENT 'app id',
    `app_key`           varchar(128)        NOT NULL DEFAULT '' COMMENT 'app key',
    `access_key`        varchar(128)        NOT NULL COMMENT 'access_key',
    `secret_access_key` varchar(128)        NOT NULL COMMENT 'secret_access_key',
    `account_id`        varchar(100)        NOT NULL DEFAULT '' COMMENT 'byteplus id',
    `vod_space`         varchar(100)        NOT NULL DEFAULT '' COMMENT 'vod space',
    `live_stream_key`   varchar(128)        NOT NULL DEFAULT '' COMMENT 'live_stream_key',
    `live_push_domain`  varchar(256)        NOT NULL DEFAULT '' COMMENT 'live_push_domain',
    `live_pull_domain`  varchar(256)        NOT NULL DEFAULT '' COMMENT 'live_pull_domain',
    `live_app_name`     varchar(256)        NOT NULL DEFAULT '' COMMENT 'live_app_name',
    `create_time`       timestamp           NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'create time',
    `update_time`       timestamp           NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'update time',
    PRIMARY KEY (`id`),
    UNIQUE KEY `unique_app_id` (`app_id`, `account_id`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4 COMMENT ='app information';

DROP TABLE IF EXISTS `live_linker`;
CREATE TABLE `live_linker`
(
    `id`            bigint(20) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Primary key',
    `app_id`        varchar(64)              DEFAULT NULL COMMENT 'app_id',
    `linker_id`     varchar(100)             DEFAULT NULL COMMENT 'linker_id',
    `from_room_id`  varchar(100)             DEFAULT NULL COMMENT 'from_room_id',
    `from_user_id`  varchar(100)             DEFAULT NULL COMMENT 'from_user_id',
    `to_room_id`    varchar(100)             DEFAULT NULL COMMENT 'to_room_id',
    `to_user_id`    varchar(100)             DEFAULT NULL COMMENT 'to_user_id',
    `biz_id`        varchar(100)             DEFAULT NULL COMMENT 'biz_id',
    `scene`         int(2)                   DEFAULT NULL COMMENT '0: audience link 1: host pk',
    `linker_status` int(10)                  DEFAULT NULL COMMENT 'linker_status',
    `create_time`   timestamp           NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'create time',
    `linking_time`  timestamp           NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'temporary status when link mic',
    `linked_time`   timestamp           NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'linked time',
    `update_time`   timestamp           NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'update time',
    `status`        int(2)                   DEFAULT NULL COMMENT 'status',
    `extra`         varchar(256)             DEFAULT NULL COMMENT 'extra information',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uniq_linker_id` (`linker_id`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  ROW_FORMAT = DYNAMIC COMMENT ='link information';

DROP TABLE IF EXISTS `live_room`;
CREATE TABLE `live_room`
(
    `id`             bigint(20) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Primary key',
    `live_app_id`    varchar(100)                 DEFAULT NULL COMMENT 'live_app_id',
    `rtc_app_id`     varchar(100)                 DEFAULT NULL COMMENT 'rtc_app_id',
    `room_id`        varchar(100)                 DEFAULT NULL COMMENT 'room_id',
    `room_name`      varchar(100)                 DEFAULT NULL COMMENT 'room_name',
    `host_user_id`   varchar(100)                 DEFAULT NULL COMMENT 'host_user_id',
    `host_user_name` varchar(100)                 DEFAULT NULL COMMENT 'host_user_name',
    `stream_id`      varchar(100)                 DEFAULT NULL COMMENT 'stream_id',
    `status`         int(11)                      DEFAULT NULL COMMENT 'status',
    `create_time`    timestamp           NULL     DEFAULT CURRENT_TIMESTAMP COMMENT 'create time',
    `update_time`    timestamp           NULL     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'update time',
    `start_time`     timestamp           NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT 'room start time',
    `finish_time`    timestamp           NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT 'room finish time',
    `extra`          varchar(512)                 DEFAULT '' COMMENT 'extra info',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uniq_app_room_id` (`rtc_app_id`, `room_id`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4 COMMENT ='room information';



DROP TABLE IF EXISTS `live_room_user`;
CREATE TABLE `live_room_user`
(
    `id`          bigint(20) unsigned NOT NULL AUTO_INCREMENT COMMENT 'primary key',
    `room_id`     varchar(100)             DEFAULT NULL COMMENT 'room_id',
    `user_id`     varchar(100)             DEFAULT NULL COMMENT 'user_id',
    `user_name`   varchar(100)             DEFAULT NULL COMMENT 'user_name',
    `user_role`   varchar(100)             DEFAULT NULL COMMENT 'user_role',
    `status`      int(11)                  DEFAULT NULL COMMENT 'user status',
    `mic`         int(11)                  DEFAULT NULL COMMENT 'status for mic',
    `camera`      int(11)                  DEFAULT NULL COMMENT 'status for camera',
    `extra`       varchar(256)             DEFAULT NULL COMMENT 'extra',
    `create_time` timestamp           NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'create time',
    `update_time` timestamp           NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'update time',
    `app_id`      varchar(64)              DEFAULT NULL COMMENT 'app_id',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uniq_room_id_user_id` (`room_id`, `user_id`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4 COMMENT ='user information when in room';



DROP TABLE IF EXISTS `user_profile`;
CREATE TABLE `user_profile`
(
    `id`         bigint(20) unsigned                             NOT NULL AUTO_INCREMENT COMMENT 'primary key',
    `user_id`    varchar(32) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL DEFAULT '' COMMENT 'user id',
    `user_name`  varchar(64) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL DEFAULT '' COMMENT 'user name',
    `app_id`     varchar(64)                                     NOT NULL COMMENT 'app_id',
    `poster_url` varchar(512)                                    not null DEFAULT '' COMMENT 'url',
    `created_at` timestamp                                       NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'create time',
    `updated_at` timestamp                                       NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'update time',
    PRIMARY KEY (`id`),
    UNIQUE KEY `idx_user_id` (`user_id`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4 COMMENT ='user profile information';