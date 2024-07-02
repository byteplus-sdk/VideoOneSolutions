/*
 * Copyright (c) 2023 BytePlus Pte. Ltd.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package config

import (
	"fmt"
	"os"

	"github.com/jinzhu/configor"
)

type Configuration struct {
	MysqlDSN      string `yaml:"mysql_dsn"`
	RedisInit     bool   `yaml:"redis_init"`
	RedisAddr     string `yaml:"redis_addr"`
	RedisPassword string `yaml:"redis_password"`

	Port            string `yaml:"port"`
	AccessKey       string `yaml:"access_key"`
	SecretAccessKey string `yaml:"secret_access_key"`

	RTCAppID  string `yaml:"rtc_app_id"`
	RTCAppKey string `yaml:"rtc_app_key"`

	LiveAppName    string `yaml:"live_app_name"`
	LivePullDomain string `yaml:"live_pull_domain"`
	LivePushDomain string `yaml:"live_push_domain"`
	LiveStreamKey  string `yaml:"live_stream_key"`

	VodSpace      string `yaml:"vod_space"`
	VodPlayListID string `yaml:"vod_play_list_id"`

	LiveTimerEnable    bool `yaml:"live_timer_enable"`
	LiveExperienceTime int  `yaml:"live_experience_time"`

	KtvTimerEnable    bool `yaml:"ktv_timer_enable"`
	KtvExperienceTime int  `yaml:"ktv_experience_time"`

	OwcTimerEnable    bool `yaml:"owc_timer_enable"`
	OwcExperienceTime int  `yaml:"owc_experience_time"`
}

var configs *Configuration

func InitConfig(file string) {
	configs = &Configuration{}
	if err := configor.Load(configs, file); err != nil {
		fmt.Fprintf(os.Stderr, "ParseConfig failed: err=%v\n", err)
		os.Exit(1)
	}
}

func Configs() *Configuration {
	if configs == nil {
		panic("config not init")
	}
	return configs
}
