// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.scenekit.data.page;

import java.util.ArrayList;
import java.util.List;


public class Book<T> {
    private final List<Page<T>> pages = new ArrayList<>();
    private final int pageSize;
    private boolean end;

    public Book(int pageSize) {
        this.pageSize = pageSize;
    }

    public List<T> firstPage(Page<T> page) {
        this.end = false;
        pages.clear();
        pages.add(page);
        return page.list;
    }

    public List<T> addPage(Page<T> page) {
        pages.add(page);
        return page.list;
    }

    public boolean hasMore() {
        if (end) return false;
        if (!pages.isEmpty()) {
            Page<T> last = pages.get(pages.size() - 1);
            if (last.total == Page.TOTAL_INFINITY) {
                return last.list != null && !last.list.isEmpty() && last.list.size() >= pageSize;
            } else {
                return last.total != last.index;
            }
        }
        return false;
    }

    public int nextPageIndex() {
        if (!hasMore()) throw new IllegalStateException("has no more data!");
        Page<T> last = pages.get(pages.size() - 1);
        return last.index + 1;
    }

    public int pageSize() {
        return pageSize;
    }

    public void end() {
        this.end = true;
    }
}
