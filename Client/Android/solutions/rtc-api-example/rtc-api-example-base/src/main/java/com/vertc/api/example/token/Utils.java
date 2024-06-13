package com.vertc.api.example.token;


import java.security.InvalidKeyException;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;

public class Utils {
    private static final SecureRandom secureRandom = new SecureRandom();
    public static final long HMAC_SHA256_LENGTH = 32;
    public static final int VERSION_LENGTH = 3;
    public static final int APP_ID_LENGTH = 24;

    public static byte[] hmacSign(String keyString, byte[] msg) throws InvalidKeyException, NoSuchAlgorithmException {
        SecretKeySpec keySpec = new SecretKeySpec(keyString.getBytes(), "HmacSHA256");
        Mac mac = Mac.getInstance("HmacSHA256");
        mac.init(keySpec);
        return mac.doFinal(msg);
    }

    public static String base64Encode(byte[] data) {
//        return java.util.Base64.getEncoder().encodeToString(data);
        return android.util.Base64.encodeToString(data, android.util.Base64.NO_WRAP);
    }

    public static byte[] base64Decode(String data) {
//        return java.util.Base64.getDecoder().decode(data.getBytes());
        return android.util.Base64.decode(data.getBytes(), android.util.Base64.NO_WRAP);
    }

    public static int getTimestamp() {
        return (int) (System.currentTimeMillis() / 1000);
    }

    public static int randomInt() {
        return secureRandom.nextInt();
    }
}