// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

import { useState, useEffect, useCallback } from "react";
import { DramaChannelData } from "@/types/drama";
import DramaService from "../services/dramaService";

interface UseDramaChannelReturn {
  data: DramaChannelData;
  loading: boolean;
  error: string | null;
  refresh: () => Promise<void>;
  hasData: boolean;
}

export const useDramaChannel = (): UseDramaChannelReturn => {
  const [data, setData] = useState<DramaChannelData>({
    loop: [],
    trending: [],
    new: [],
    recommend: [],
  });
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const loadData = useCallback(async () => {
    try {
      setLoading(true);
      setError(null);

      // 尝试从真实API获取数据
      const realData = await DramaService.getDramaChannel();
      setData(realData);
    } catch (apiError) {
      console.warn("API request failed, using mock data:", apiError);
      setError("数据加载失败");
    } finally {
      setLoading(false);
    }
  }, []);

  const refresh = useCallback(async () => {
    await loadData();
  }, [loadData]);

  useEffect(() => {
    loadData();
  }, [loadData]);

  // 检查是否有数据
  const hasData =
    data.loop.length > 0 ||
    data.trending.length > 0 ||
    data.new.length > 0 ||
    data.recommend.length > 0;

  return {
    data,
    loading,
    error,
    refresh,
    hasData,
  };
};
