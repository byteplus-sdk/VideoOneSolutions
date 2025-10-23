// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

const { withInfoPlist } = require('@expo/config-plugins');

const withATSConfig = (config) => {
  return withInfoPlist(config, (config) => {
    // 获取当前的 NSAppTransportSecurity 配置
    const atsConfig = config.modResults.NSAppTransportSecurity || {};
    
    // 设置允许任意加载（开发环境）
    atsConfig.NSAllowsArbitraryLoads = true;
    atsConfig.NSAllowsLocalNetworking = true;
    
    // 添加异常域名配置
    atsConfig.NSExceptionDomains = {
      // 开发服务器 IP
      '100.80.236.211': {
        NSExceptionAllowsInsecureHTTPLoads: true,
        NSExceptionMinimumTLSVersion: 'TLSv1.0',
        NSIncludesSubdomains: true,
      },
      // 本地开发
      'localhost': {
        NSExceptionAllowsInsecureHTTPLoads: true,
        NSExceptionMinimumTLSVersion: 'TLSv1.0',
        NSIncludesSubdomains: true,
      },
      '127.0.0.1': {
        NSExceptionAllowsInsecureHTTPLoads: true,
        NSExceptionMinimumTLSVersion: 'TLSv1.0',
        NSIncludesSubdomains: true,
      },
      // 常见的开发域名
      '192.168.0.0': {
        NSExceptionAllowsInsecureHTTPLoads: true,
        NSExceptionMinimumTLSVersion: 'TLSv1.0',
        NSIncludesSubdomains: true,
      },
      '10.0.0.0': {
        NSExceptionAllowsInsecureHTTPLoads: true,
        NSExceptionMinimumTLSVersion: 'TLSv1.0',
        NSIncludesSubdomains: true,
      },
    };
    
    config.modResults.NSAppTransportSecurity = atsConfig;
    
    return config;
  });
};

module.exports = withATSConfig;
