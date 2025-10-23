// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

import React, { useEffect } from "react";
import {
  View,
  StyleSheet,
  FlatList,
  SafeAreaView,
  Text,
  Platform,
} from "react-native";
import { Image } from "expo-image";
import { HomeCard, UserAvatar } from "@/components";
import { HOME_POSTER_CONFIG } from "@/constants/HomeConstants";
import {
  initEnv,
  enableEngineStrategy,
  StrategyType,
  StrategyScene,
  setActiveAudioSession,
  setupLogger,
  LogLevel,
} from "../utils/playerConfig";
import { UserService } from "@/services/userService";

export default function HomeScreen() {
  // Initialize user ID
  useEffect(() => {
    const initializeUser = async () => {
      try {
        await UserService.getUserId();
      } catch (error) {
        console.error("Failed to initialize user ID:", error);
      }
    };

    const initSDK = async () => {
      await initEnv({
        AppID: "573848",
        AppName: "VideoOneRN",
        AppVersion: "1.0.0",
        AppChannel: Platform.select({
          android: "GoogleStore",
          ios: "AppStore",
          default: "AppStore",
        }),
        PackageName: "com.byteplus.videoone.rn",
        BundleID: "com.byteplus.videoone.rn",
        LicenseUri: Platform.select({
          android: "assets:///ttsdk.lic",
          ios: "ttsdk.lic",
          default: "",
        }),
        MaxCacheSize: 300 * 1024 * 1024,
        UserUniqueID: "video_one_user",
        OpenLog: true,
      });

      enableEngineStrategy(StrategyType.Preload, StrategyScene.SmallVideo);
      enableEngineStrategy(StrategyType.PreRender, StrategyScene.SmallVideo);
      setActiveAudioSession(true);
      // setupLogger({level: LogLevel.INFO});
    };
    initSDK();
    initializeUser();
  }, []);

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.backgroundContainer}>
        {/* Background image */}
        <Image
          source={require("@/assets/images/home/bg.png")}
          style={styles.backgroundImage}
        />
      </View>

      <View style={styles.content}>
        <View style={styles.header}>
          <View style={styles.logoContainer}>
            <Image
              source={require("@/assets/images/home/logo.png")}
              style={styles.logo}
            />
            <Text style={styles.title}>VideoOne Center</Text>
          </View>
          <UserAvatar size={30} />
        </View>

        <Text style={styles.welcomeText}>
          Welcome to the VideoOne Demo Center! Please select the scene of
          interest.
        </Text>

        <FlatList
          data={HOME_POSTER_CONFIG}
          renderItem={({ item }) => (
            <HomeCard
              imgPath={item.imgPath}
              title={item.title}
              subTitle={item.subTitle}
              linkRoute={item.linkRoute}
            />
          )}
          keyExtractor={(item, index) => index.toString()}
          contentContainerStyle={styles.listContainer}
        />
      </View>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  backgroundContainer: {
    position: "absolute",
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    width: "100%",
    height: "100%",
  },
  backgroundImage: {
    width: "100%",
    height: "100%",
  },
  content: {
    flex: 1,
    paddingHorizontal: 16,
  },
  header: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "flex-start",
    paddingTop: 60,
    marginBottom: 16,
  },
  logoContainer: {
    flexDirection: "column",
    justifyContent: "space-between",
    height: 57,
  },
  logo: {
    width: 72,
    height: 13,
  },
  title: {
    color: "#FFFFFF",
    fontSize: 28,
    fontWeight: "bold",
    lineHeight: 36,
    marginTop: 8,
  },
  welcomeText: {
    color: "#FFFFFF",
    fontSize: 14,
    lineHeight: 20,
    marginBottom: 20,
  },
  listContainer: {
    flex: 1,
  },
});
