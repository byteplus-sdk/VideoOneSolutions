// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.vertcdemo.solution.chorus.view;

import android.animation.ValueAnimator;
import android.os.Build;
import android.text.TextUtils;
import android.text.format.DateUtils;

import java.io.BufferedReader;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.lang.reflect.Field;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.Charset;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Locale;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * 工具类
 */
class LrcUtils {
    private static final Pattern PATTERN_LINE = Pattern.compile("((\\[\\d\\d:\\d\\d\\.\\d{2,3}\\])+)(.+)");
    private static final Pattern PATTERN_TIME = Pattern.compile("\\[(\\d\\d):(\\d\\d)\\.(\\d{2,3})\\]");

    /**
     * 从文件解析双语歌词
     */
    static List<LrcEntry> parseLrc(File[] lrcFiles) {
        if (lrcFiles == null || lrcFiles.length != 2 || lrcFiles[0] == null) {
            return null;
        }

        File mainLrcFile = lrcFiles[0];
        File secondLrcFile = lrcFiles[1];
        List<LrcEntry> mainEntryList = parseLrc(mainLrcFile);
        List<LrcEntry> secondEntryList = parseLrc(secondLrcFile);

        if (mainEntryList != null && secondEntryList != null) {
            for (LrcEntry mainEntry : mainEntryList) {
                for (LrcEntry secondEntry : secondEntryList) {
                    if (mainEntry.getTime() == secondEntry.getTime()) {
                        mainEntry.setSecondText(secondEntry.getText());
                    }
                }
            }
        }
        return mainEntryList;
    }

    /**
     * 从文件解析歌词
     */
    private static List<LrcEntry> parseLrc(File lrcFile) {
        if (lrcFile == null || !lrcFile.exists()) {
            return null;
        }

        List<LrcEntry> entryList = new ArrayList<>();
        try {
            BufferedReader br = new BufferedReader(new InputStreamReader(new FileInputStream(lrcFile), Charset.defaultCharset()));
            String line;
            while ((line = br.readLine()) != null) {
                List<LrcEntry> list = parseLine(line);
                if (list != null && !list.isEmpty()) {
                    entryList.addAll(list);
                }
            }
            br.close();
        } catch (IOException e) {
            e.printStackTrace();
        }

        Collections.sort(entryList);
        return entryList;
    }

    /**
     * 从文本解析双语歌词
     */
    static List<LrcEntry> parseLrc(String[] lrcTexts) {
        if (lrcTexts == null || lrcTexts.length != 2 || TextUtils.isEmpty(lrcTexts[0])) {
            return null;
        }

        String mainLrcText = lrcTexts[0];
        String secondLrcText = lrcTexts[1];
        List<LrcEntry> mainEntryList = parseLrc(mainLrcText);
        List<LrcEntry> secondEntryList = parseLrc(secondLrcText);

        if (mainEntryList != null && secondEntryList != null) {
            for (LrcEntry mainEntry : mainEntryList) {
                for (LrcEntry secondEntry : secondEntryList) {
                    if (mainEntry.getTime() == secondEntry.getTime()) {
                        mainEntry.setSecondText(secondEntry.getText());
                    }
                }
            }
        }
        return mainEntryList;
    }

    /**
     * 从文本解析歌词
     */
    private static List<LrcEntry> parseLrc(String lrcText) {
        if (TextUtils.isEmpty(lrcText)) {
            return null;
        }

        if (lrcText.startsWith("\uFEFF")) {
            lrcText = lrcText.replace("\uFEFF", "");
        }

        List<LrcEntry> entryList = new ArrayList<>();
        String[] array = lrcText.split("\\n");
        for (String line : array) {
            List<LrcEntry> list = parseLine(line);
            if (list != null && !list.isEmpty()) {
                entryList.addAll(list);
            }
        }

        Collections.sort(entryList);
        return entryList;
    }

    /**
     * 获取网络文本，需要在工作线程中执行
     */
    static String getContentFromNetwork(String url, String charset) {
        String lrcText = null;
        try {
            URL _url = new URL(url);
            HttpURLConnection conn = (HttpURLConnection) _url.openConnection();
            conn.setRequestMethod("GET");
            conn.setConnectTimeout(10000);
            conn.setReadTimeout(10000);
            if (conn.getResponseCode() == 200) {
                InputStream is = conn.getInputStream();
                ByteArrayOutputStream bos = new ByteArrayOutputStream();
                byte[] buffer = new byte[1024];
                int len;
                while ((len = is.read(buffer)) != -1) {
                    bos.write(buffer, 0, len);
                }
                is.close();
                bos.close();
                lrcText = bos.toString(charset);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return lrcText;
    }

    /**
     * 解析一行歌词
     */
    private static List<LrcEntry> parseLine(String line) {
        if (TextUtils.isEmpty(line)) {
            return null;
        }

//        line = "[00:17.65]让我掉下眼泪的";

        line = line.trim();
        // [00:17.65]让我掉下眼泪的
        // [474,3500]<0,353,0>千<353,256,0>里<609,305,0>之<914,303,0>外 <1217,407,0>-
        // <1624,254,0>费<1878,306,0>玉<2184,353,0>清；<2537,306,0>周<2843,353,0>杰<3196,304,0>伦
        Matcher lineMatcher = PATTERN_LINE.matcher(line);
        if (!lineMatcher.matches()) {
            return null;
        }

        String times = lineMatcher.group(1);
        String text = lineMatcher.group(3);
        List<LrcEntry> entryList = new ArrayList<>();
//        entryList.add(new LrcEntry(parseTime(line), parseText(line)));

        // [00:17.65]
        Matcher timeMatcher = PATTERN_TIME.matcher(times);
        while (timeMatcher.find()) {
            long min = Long.parseLong(timeMatcher.group(1));
            long sec = Long.parseLong(timeMatcher.group(2));
            String milString = timeMatcher.group(3);
            long mil = Long.parseLong(milString);
            // 如果毫秒是两位数，需要乘以10
            if (milString.length() == 2) {
                mil = mil * 10;
            }
            long time = min * DateUtils.MINUTE_IN_MILLIS + sec * DateUtils.SECOND_IN_MILLIS + mil;
            entryList.add(new LrcEntry(time, text));
        }
        return entryList;
    }

    static Long parseTime(String line) {
        int lastIndexOfRightBracket = line.lastIndexOf("]");
        if (lastIndexOfRightBracket != -1) {
            String[] times = line.substring(1, lastIndexOfRightBracket).split(",");
            return Long.parseLong(times[0]);
        }
        return 0l;
    }

    static String parseText(String line) {
        String[] text = line.split(">");
        if (text.length == 0) {
            return "";
        }
        StringBuffer sb = new StringBuffer();
        for (int i = 1; i < text.length; i++) {
            sb.append(text[i].charAt(0));
        }
        return sb.toString();
    }

    /**
     * 转为[分:秒]
     */
    static String formatTime(long milli) {
        int m = (int) (milli / DateUtils.MINUTE_IN_MILLIS);
        int s = (int) ((milli / DateUtils.SECOND_IN_MILLIS) % 60);
        String mm = String.format(Locale.getDefault(), "%02d", m);
        String ss = String.format(Locale.getDefault(), "%02d", s);
        return mm + ":" + ss;
    }

    /**
     * 强制开启动画
     * Android 10 以后无法使用
     */
    static void resetDurationScale() {
        try {
            if (Build.VERSION.SDK_INT <= Build.VERSION_CODES.P) {
                Field mField = ValueAnimator.class.getDeclaredField("sDurationScale");
                mField.setAccessible(true);
                mField.setFloat(null, 1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
