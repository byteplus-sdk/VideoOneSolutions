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

package main

import (
	"flag"
	"math/rand"
	"time"

	"github.com/byteplus/VideoOneServer/cmd/api"
	"github.com/byteplus/VideoOneServer/cmd/handler"
	"github.com/byteplus/VideoOneServer/internal/pkg/config"
	"github.com/byteplus/VideoOneServer/internal/pkg/db"
	"github.com/byteplus/VideoOneServer/internal/pkg/logs"
	"github.com/byteplus/VideoOneServer/internal/pkg/redis_cli"
)

var conf = flag.String("config", "conf/config.yaml", "server config file path")

func main() {
	rand.Seed(time.Now().UnixNano())

	config.InitConfig(*conf)
	logs.InitLog()
	db.Open(config.Configs().MysqlDSN)
	redis_cli.NewRedis(config.Configs().RedisAddr, config.Configs().RedisPassword)
	handler.StartCronJob()

	r := api.NewHttpApi()
	err := r.Run()
	if err != nil {
		panic("http server start failed, error:" + err.Error())
	}
}
