CREATE
DATABASE IF NOT EXISTS `videoone`;

USE
`videoone`;

DROP TABLE IF EXISTS `app_info`;
CREATE TABLE `app_info`
(
    `id`                bigint(20) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Primary key',
    `app_id`            varchar(32)  NOT NULL DEFAULT '' COMMENT 'app id',
    `app_key`           varchar(128) NOT NULL DEFAULT '' COMMENT 'app key',
    `access_key`        varchar(128) NOT NULL COMMENT 'access_key',
    `secret_access_key` varchar(128) NOT NULL COMMENT 'secret_access_key',
    `vod_space`         varchar(100) NOT NULL DEFAULT '' COMMENT 'vod space',
    `live_stream_key`   varchar(128) NOT NULL DEFAULT '' COMMENT 'live_stream_key',
    `live_push_domain`  varchar(256) NOT NULL DEFAULT '' COMMENT 'live_push_domain',
    `live_pull_domain`  varchar(256) NOT NULL DEFAULT '' COMMENT 'live_pull_domain',
    `live_app_name`     varchar(256) NOT NULL DEFAULT '' COMMENT 'live_app_name',
    `create_time`       timestamp    NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'create time',
    `update_time`       timestamp    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'update time',
    PRIMARY KEY (`id`),
    UNIQUE KEY `unique_app_id` (`app_id`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4 COMMENT ='app information';

DROP TABLE IF EXISTS `live_linker`;
CREATE TABLE `live_linker`
(
    `id`            bigint(20) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Primary key',
    `app_id`        varchar(64)  DEFAULT NULL COMMENT 'app_id',
    `linker_id`     varchar(100) DEFAULT NULL COMMENT 'linker_id',
    `from_room_id`  varchar(100) DEFAULT NULL COMMENT 'from_room_id',
    `from_user_id`  varchar(100) DEFAULT NULL COMMENT 'from_user_id',
    `to_room_id`    varchar(100) DEFAULT NULL COMMENT 'to_room_id',
    `to_user_id`    varchar(100) DEFAULT NULL COMMENT 'to_user_id',
    `biz_id`        varchar(100) DEFAULT NULL COMMENT 'biz_id',
    `scene`         int(2) DEFAULT NULL COMMENT '0: audience link 1: host pk',
    `linker_status` int(10) DEFAULT NULL COMMENT 'linker_status',
    `create_time`   timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'create time',
    `linking_time`  timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'temporary status when link mic',
    `linked_time`   timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'linked time',
    `update_time`   timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'update time',
    `status`        int(2) DEFAULT NULL COMMENT 'status',
    `extra`         varchar(256) DEFAULT NULL COMMENT 'extra information',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uniq_linker_id` (`linker_id`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  ROW_FORMAT = DYNAMIC COMMENT ='link information';

DROP TABLE IF EXISTS `live_room`;
CREATE TABLE `live_room`
(
    `id`             bigint(20) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Primary key',
    `live_app_id`    varchar(100)       DEFAULT NULL COMMENT 'live_app_id',
    `rtc_app_id`     varchar(100)       DEFAULT NULL COMMENT 'rtc_app_id',
    `room_id`        varchar(100)       DEFAULT NULL COMMENT 'room_id',
    `room_name`      varchar(100)       DEFAULT NULL COMMENT 'room_name',
    `host_user_id`   varchar(100)       DEFAULT NULL COMMENT 'host_user_id',
    `host_user_name` varchar(100)       DEFAULT NULL COMMENT 'host_user_name',
    `stream_id`      varchar(100)       DEFAULT NULL COMMENT 'stream_id',
    `status`         int(11) DEFAULT NULL COMMENT 'status',
    `create_time`    timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'create time',
    `update_time`    timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'update time',
    `start_time`     timestamp NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT 'room start time',
    `finish_time`    timestamp NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT 'room finish time',
    `extra`          varchar(512)       DEFAULT '' COMMENT 'extra info',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uniq_app_room_id` (`rtc_app_id`, `room_id`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4 COMMENT ='room information';



DROP TABLE IF EXISTS `live_room_user`;
CREATE TABLE `live_room_user`
(
    `id`          bigint(20) unsigned NOT NULL AUTO_INCREMENT COMMENT 'primary key',
    `room_id`     varchar(100) DEFAULT NULL COMMENT 'room_id',
    `user_id`     varchar(100) DEFAULT NULL COMMENT 'user_id',
    `user_name`   varchar(100) DEFAULT NULL COMMENT 'user_name',
    `user_role`   varchar(100) DEFAULT NULL COMMENT 'user_role',
    `status`      int(11) DEFAULT NULL COMMENT 'user status',
    `mic`         int(11) DEFAULT NULL COMMENT 'status for mic',
    `camera`      int(11) DEFAULT NULL COMMENT 'status for camera',
    `extra`       varchar(256) DEFAULT NULL COMMENT 'extra',
    `create_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'create time',
    `update_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'update time',
    `app_id`      varchar(64)  DEFAULT NULL COMMENT 'app_id',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uniq_room_id_user_id` (`room_id`, `user_id`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4 COMMENT ='user information when in room';



DROP TABLE IF EXISTS `user_profile`;
CREATE TABLE `user_profile`
(
    `id`         bigint(20) unsigned NOT NULL AUTO_INCREMENT COMMENT 'primary key',
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

CREATE TABLE `video_info`
(
    `id`                         bigint(20) unsigned NOT NULL AUTO_INCREMENT COMMENT 'id',
    `vid`                        varchar(100) NOT NULL DEFAULT '' COMMENT 'vid',
    `video_type`                 tinyint(4) NOT NULL DEFAULT '0' COMMENT 'video type 0: short video 1:medium video 2: long video',
    `anti_screenshot_and_record` tinyint(4) NOT NULL DEFAULT '0' COMMENT 'support screen recording and screenshot prevention? 0: Not supported, 1: Supported',
    `support_smart_subtitle`     tinyint(4) NOT NULL DEFAULT '0' COMMENT 'support intelligent subtitles? 0: not supported, 1: supported',
    `update_time`                datetime     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'update_time',
    `create_time`                datetime     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'create time',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uniq_vid` (`vid`),
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='video info';

CREATE TABLE `video_comments`
(
    `id`          bigint(20) unsigned NOT NULL AUTO_INCREMENT COMMENT 'id',
    `vid`         varchar(100) NOT NULL DEFAULT '' COMMENT 'vid',
    `name`        varchar(100) NOT NULL DEFAULT '' COMMENT 'name',
    `content`     text COMMENT 'content',
    `create_time` datetime     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'create time',
    `update_time` datetime     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'update_time',
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='comments of video';

INSERT INTO video_comments(`name`, `content`)
VALUES ('Tom', 'This is a fantastic video.'),
       ('Oliver', 'The way I would try.'),
       ('Jake', 'wow!!!'),
       ('Harry', 'This feeling is indescribable. '),
       ('Jacob', 'broooo imagine.'),
       ('Charlie', 'I love this view, I need to be there.😍'),
       ('Oscar', 'It is what I like.'),
       ('William', 'Visited this year was beautiful.'),
       ('Robert', 'very empty magic.'),
       ('Isabella', 'This is too pretty! 😍'),
       ('Emma Emma', 'My perfect getaway ❤️❤️❤️');

CREATE TABLE `song`
(
    `id`            bigint(20) unsigned NOT NULL AUTO_INCREMENT COMMENT 'id',
    `name`          varchar(512) NOT NULL DEFAULT '' COMMENT 'song name',
    `artist`        varchar(100) NOT NULL DEFAULT '' COMMENT 'artist',
    `duration`      int(11) NOT NULL DEFAULT '0' COMMENT 'duration, unit: ms',
    `cover_url`     varchar(512) NOT NULL DEFAULT '' COMMENT 'song cover download url ',
    `song_lrc_url`  varchar(512) NOT NULL DEFAULT '' COMMENT 'song lrc file download url ',
    `song_file_url` varchar(512) NOT NULL DEFAULT '' COMMENT 'song file download url ',
    `create_time`   timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'create time',
    `update_time`   timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'update time',
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC COMMENT='song info';

CREATE TABLE `ktv_room`
(
    `id`                             bigint(20) unsigned NOT NULL AUTO_INCREMENT COMMENT 'id',
    `app_id`                         varchar(100) DEFAULT '' COMMENT 'live app id',
    `room_id`                        varchar(100) DEFAULT '' COMMENT 'room id',
    `room_name`                      varchar(200) DEFAULT '' COMMENT 'name of live room',
    `host_user_id`                   varchar(100) DEFAULT '' COMMENT 'host id',
    `host_user_name`                 varchar(200) DEFAULT '' COMMENT 'host name',
    `status`                         int(11) DEFAULT 0 COMMENT 'live room status',
    `enable_audience_interact_apply` int(11) DEFAULT 0 COMMENT 'enable audience interact apply',
    `create_time`                    timestamp    DEFAULT CURRENT_TIMESTAMP COMMENT 'create_ ime',
    `update_time`                    timestamp    DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'update time',
    `start_time`                     bigint(20) DEFAULT NULL COMMENT 'start unix time',
    `finish_time`                    bigint(20) DEFAULT NULL COMMENT 'finish unix time',
    `ext`                            varchar(200) DEFAULT NULL COMMENT 'extra info',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uniq_room_id` (`room_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC COMMENT='info of KTV live room';

CREATE TABLE `ktv_user`
(
    `id`              bigint(20) unsigned NOT NULL AUTO_INCREMENT COMMENT 'id',
    `app_id`          varchar(100) DEFAULT '' COMMENT 'live app id',
    `room_id`         varchar(100) DEFAULT '' COMMENT 'room id',
    `user_id`         varchar(255) DEFAULT '' COMMENT 'user id',
    `user_name`       varchar(255) DEFAULT '' COMMENT 'user name',
    `user_role`       int(11) DEFAULT 0 COMMENT 'user role 1: host 2:audience',
    `net_status`      int(11) DEFAULT 0 COMMENT 'user net status',
    `interact_status` int(11) DEFAULT 0 COMMENT 'user interact status',
    `seat_id`         int(11) DEFAULT '0' COMMENT 'seat id',
    `mic`             tinyint(4) DEFAULT '0' COMMENT 'mic status',
    `create_time`     timestamp    DEFAULT CURRENT_TIMESTAMP COMMENT 'create time',
    `update_time`     timestamp    DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'update time',
    `join_time`       bigint(20) DEFAULT NULL COMMENT 'join time',
    `leave_time`      bigint(20) DEFAULT NULL COMMENT 'leave time',
    `device_id`       varchar(128) DEFAULT '' COMMENT 'device id',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uniq_room_id_user_id` (`room_id`,`user_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC COMMENT='info of KTV live user';
