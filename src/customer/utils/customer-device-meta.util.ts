import { DevicePlatform } from '@prisma/client';

export enum DevicePlatformApi {
  IOS = 'IOS',
  ANDROID = 'ANDROID',
  WEB = 'WEB',
}

export interface CustomerDeviceMeta {
  deviceName: string | null;
  appVersion: string | null;
  osVersion: string | null;
}

export function mapApiPlatformToPrisma(
  platform: DevicePlatformApi,
): DevicePlatform {
  switch (platform) {
    case DevicePlatformApi.IOS:
      return DevicePlatform.ios;
    case DevicePlatformApi.ANDROID:
    case DevicePlatformApi.WEB:
      return DevicePlatform.android;
    default:
      return DevicePlatform.android;
  }
}

export function mapPrismaPlatformToApi(
  platform: DevicePlatform,
  requestedPlatform?: DevicePlatformApi,
): DevicePlatformApi {
  if (requestedPlatform) {
    return requestedPlatform;
  }

  return platform === DevicePlatform.ios
    ? DevicePlatformApi.IOS
    : DevicePlatformApi.ANDROID;
}

export function maskDeviceToken(token: string): string {
  if (token.length <= 8) {
    return '****';
  }

  return `${token.slice(0, 4)}...${token.slice(-4)}`;
}
