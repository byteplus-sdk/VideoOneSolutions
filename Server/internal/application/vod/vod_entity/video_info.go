package vod_entity

import "time"

type VideoInfo struct {
	ID         int64     `gorm:"column:id"`
	Vid        string    `gorm:"column:vid"`
	AuthorID   string    `gorm:"column:author_id"`
	VideoType  int       `gorm:"column:video_type"`
	CreateTime time.Time `gorm:"column:create_time"`
	UpdateTime time.Time `gorm:"column:update_time"`
}
