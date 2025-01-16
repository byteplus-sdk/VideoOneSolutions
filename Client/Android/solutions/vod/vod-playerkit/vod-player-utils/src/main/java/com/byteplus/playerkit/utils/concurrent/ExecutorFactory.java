// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.playerkit.utils.concurrent;


import androidx.annotation.NonNull;

import java.util.concurrent.LinkedBlockingQueue;
import java.util.concurrent.ThreadFactory;
import java.util.concurrent.ThreadPoolExecutor;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicInteger;


public interface ExecutorFactory {

    ExecutorFactory DEFAULT = new ExecutorFactory() {

        final ThreadFactory threadFactory = new ThreadFactory() {
            private final AtomicInteger counter = new AtomicInteger(0);

            @Override
            public Thread newThread(@NonNull Runnable r) {
                Thread t = new Thread(r, "player-kit#" + this.counter.getAndIncrement());
                if (t.isDaemon()) t.setDaemon(false);
                if (t.getPriority() != Thread.NORM_PRIORITY) t.setPriority(Thread.NORM_PRIORITY);
                return t;
            }
        };

        @Override
        public ThreadPoolExecutor create(int nThreads) {
            return new ThreadPoolExecutor(nThreads,
                    nThreads,
                    0L,
                    TimeUnit.MILLISECONDS,
                    new LinkedBlockingQueue<>(),
                    threadFactory);
        }
    };

    ThreadPoolExecutor create(int nThreads);
}
