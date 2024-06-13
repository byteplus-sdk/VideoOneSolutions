package com.vertc.api.example.utils;

import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

public class ExampleExecutor {
    public static final ExecutorService cached = Executors.newCachedThreadPool();
}
